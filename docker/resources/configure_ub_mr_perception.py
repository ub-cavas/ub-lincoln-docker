#!/usr/bin/env python3
"""Reversible UB-MR profile for Autoware Universe 0.43.0 (20251015.0 image).

Run only while Autoware is stopped. No ROS nodes are started by this utility.
"""
import argparse
import json
from pathlib import Path
import re
import sys
import xml.etree.ElementTree as ET

import yaml

CHANNEL = 'ub_mr_virtual_objects'
SUPPORTED_VERSION = '0.43.0'
STATE_FILE = '.ub_mr_perception_profile.json'


def share(root, package):
    return root / 'install' / package / 'share' / package


def require(condition, message):
    if not condition:
        raise ValueError(message)


def patch_tracking(text):
    ET.fromstring(text)
    require('name="selected_input_channels"' in text,
            'Tracking launch does not use selected_input_channels.')
    pattern = r'(<let\s+name="(?:input/detection_input_channels|detection_enabled_channels)"\s+value=")(\[[^"\n]*\])(")'

    def prepend(match):
        values = match[2]
        require(CHANNEL not in values, 'Virtual channel already present without matching profile state.')
        # Autoware 0.43 starts with input stream 0 as its processing trigger.
        # A silent real detector would otherwise prevent virtual-only traffic
        # from ever being processed (including selection of another trigger).
        remaining = values[1:-1].strip()
        channels = "['" + CHANNEL + "'" + (', ' + remaining if remaining else '') + ']'
        return match[1] + channels + match[3]

    updated, count = re.subn(pattern, prepend, text)
    require(count >= 2, 'Unsupported tracking channel selection layout; expected normal and multi-channel branches.')
    ET.fromstring(updated)
    return updated


def patch_channels(text, topic):
    document = yaml.safe_load(text)
    channels = document['/**']['ros__parameters']['input_channels']
    require('detected_objects' in channels, 'Missing real detected_objects channel.')
    require(CHANNEL not in channels, 'Virtual channel already exists without matching profile state.')
    require(topic not in {channel.get('topic') for channel in channels.values()},
            'Virtual topic must be separate from every existing real-detection input.')
    # A prior CARLA launcher may have replaced the real channel with simulator ground truth.
    real_topic = channels['detected_objects']['topic']
    if real_topic.startswith('/carla/ground_truth/'):
        require(topic != '/perception/object_recognition/detection/objects',
                'Virtual topic must be separate from the restored real-detection input.')
        text = text.replace('"' + real_topic + '"', '"/perception/object_recognition/detection/objects"')
        require(real_topic not in text, 'Unsupported CARLA ground-truth topic formatting.')
    marker = '    input_channels:\n'
    require(text.count(marker) == 1, 'Unsupported input_channels YAML indentation.')
    block = (f'      {CHANNEL}:\n'
             f'        topic: "{topic}"\n'
             '        can_spawn_new_tracker: true\n'
             '        optional:\n'
             '          name: "UB-MR virtual objects"\n'
             '          short_name: "MR"\n')
    return text.replace(marker, marker + block, 1)


def patch_empty_publisher(text):
    ET.fromstring(text)
    # Override an existing argument passed by the CARLA ego-only profile, if present.
    return re.sub(r'(<arg\s+name="use_empty_dynamic_object_publisher"\s+value=")true(")',
                  r'\g<1>false\2', text)


def proposed_changes(root, topic):
    for package in ('autoware_multi_object_tracker', 'tier4_perception_launch'):
        version = ET.parse(share(root, package) / 'package.xml').getroot().findtext('version')
        require(version == SUPPORTED_VERSION,
                f'{package} {version} is unsupported; expected {SUPPORTED_VERSION}. '
                'Port and test the profile for this Autoware version before applying it.')
    tracker = share(root, 'autoware_multi_object_tracker')
    interface = (tracker / 'launch/multi_object_tracker.launch.xml').read_text()
    require('name="selected_input_channels"' in interface and 'name="input_channels_path"' in interface,
            'Unsupported tracker interface; expected selected_input_channels and input_channels_path.')
    launch = share(root, 'autoware_launch')
    paths = {
        share(root, 'tier4_perception_launch') / 'launch/object_recognition/tracking/tracking.launch.xml': patch_tracking,
        launch / 'config/perception/object_recognition/tracking/multi_object_tracker/input_channels.param.yaml':
            lambda text: patch_channels(text, topic),
        tracker / 'config/input_channels.param.yaml': lambda text: patch_channels(text, topic),
        launch / 'launch/autoware.launch.xml': patch_empty_publisher,
    }
    changes = []
    for path, transform in paths.items():
        original = path.read_text()
        updated = transform(original)
        if original != updated:
            changes.append({'path': str(path.relative_to(root)), 'original': original, 'applied': updated})
    return changes


def apply(root, topic, dry_run=False):
    require(re.fullmatch(r'/[A-Za-z_][A-Za-z0-9_]*(/[A-Za-z_][A-Za-z0-9_]*)*', topic) is not None,
            'Topic must be an absolute ROS topic with valid name tokens.')
    state_path = root / STATE_FILE
    if state_path.exists():
        state = json.loads(state_path.read_text())
        require(state['topic'] == topic, 'Profile topic changed; restore the existing profile before applying a new topic.')
        for change in state['changes']:
            require((root / change['path']).read_text() == change['applied'],
                    f"Profile file changed externally: {change['path']}. Restore before applying other launch patches.")
        print('UB-MR perception profile already applied.')
        return
    # Validate every file before creating a backup or modifying the installation.
    changes = proposed_changes(root, topic)
    for change in changes:
        print(('Would update ' if dry_run else 'Updating ') + change['path'])
    if dry_run:
        return
    state = {'version': 1, 'topic': topic, 'changes': changes}
    state_path.write_text(json.dumps(state, indent=2) + '\n')
    try:
        for change in changes:
            (root / change['path']).write_text(change['applied'])
    except Exception:
        for change in changes:
            (root / change['path']).write_text(change['original'])
        state_path.unlink()
        raise
    print(f'UB-MR perception enabled: real detections + {topic}. Restart Autoware to apply.')


def restore(root, dry_run=False):
    state_path = root / STATE_FILE
    if not state_path.exists():
        print('No UB-MR perception profile to restore.')
        return
    state = json.loads(state_path.read_text())
    for change in state['changes']:
        current = (root / change['path']).read_text()
        require(current in (change['applied'], change['original']),
                f"Refusing to overwrite external changes in {change['path']}; "
                f'reconcile this file with the saved original/applied text in {state_path} first.')
    for change in state['changes']:
        print(('Would restore ' if dry_run else 'Restoring ') + change['path'])
        if not dry_run:
            (root / change['path']).write_text(change['original'])
    if not dry_run:
        state_path.unlink()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('action', choices=('apply', 'restore'))
    parser.add_argument('--autoware-root', type=Path, default=Path('/autoware'))
    parser.add_argument('--topic', default='/virtual_obstacles')
    parser.add_argument('--dry-run', action='store_true')
    args = parser.parse_args()
    try:
        if args.action == 'apply':
            apply(args.autoware_root.resolve(), args.topic, args.dry_run)
        else:
            restore(args.autoware_root.resolve(), args.dry_run)
    except (ValueError, OSError, KeyError, ET.ParseError, yaml.YAMLError) as exc:
        parser.exit(1, f'UB-MR profile error: {exc}\n')


if __name__ == '__main__':
    main()
