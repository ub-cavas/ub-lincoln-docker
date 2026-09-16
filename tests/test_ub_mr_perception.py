"""Regression tests for profile safety and compatibility, without requiring ROS."""
import importlib.util
import json
from pathlib import Path
import tempfile
import unittest

HELPER = Path(__file__).resolve().parents[1] / 'docker/resources/configure_ub_mr_perception.py'
spec = importlib.util.spec_from_file_location('profile', HELPER)
profile = importlib.util.module_from_spec(spec)
spec.loader.exec_module(profile)


class ProfileTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        for package in ('autoware_multi_object_tracker', 'tier4_perception_launch'):
            self.write(package, 'package.xml', '<package><version>0.43.0</version></package>')
        self.write('autoware_multi_object_tracker', 'launch/multi_object_tracker.launch.xml',
                   '<launch><arg name="selected_input_channels"/><arg name="input_channels_path"/></launch>')
        self.write('tier4_perception_launch', 'launch/object_recognition/tracking/tracking.launch.xml', '''<launch>
<let name="input/detection_input_channels" value="['detected_objects', 'custom_real']"/>
<let name="detection_enabled_channels" value="['lidar_$(var lidar_dnn_detection_output)']"/>
<arg name="selected_input_channels" value="$(var detection_enabled_channels)"/>
</launch>''')
        channels = '''/**:
  ros__parameters:
    input_channels:
      detected_objects:
        topic: "/real/objects"
        can_spawn_new_tracker: true
      custom_real:
        topic: "/another/objects"
'''
        self.write('autoware_multi_object_tracker', 'config/input_channels.param.yaml', channels)
        self.write('autoware_launch', 'config/perception/object_recognition/tracking/multi_object_tracker/input_channels.param.yaml', channels)
        self.write('autoware_launch', 'launch/autoware.launch.xml',
                   '<launch><arg name="use_empty_dynamic_object_publisher" value="true"/></launch>')

    def write(self, package, name, text):
        path = profile.share(self.root, package) / name
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(text)
        return path

    def snapshot(self):
        return {str(p.relative_to(self.root)): p.read_text() for p in self.root.rglob('*') if p.is_file()}

    def test_roundtrip_idempotence_preserves_real_channels(self):
        original = self.snapshot()
        profile.apply(self.root, '/virtual_obstacles')
        applied = self.snapshot()
        profile.apply(self.root, '/virtual_obstacles')
        self.assertEqual(applied, self.snapshot())
        state = json.loads((self.root / profile.STATE_FILE).read_text())
        self.assertEqual(4, len(state['changes']))
        combined = '\n'.join(item['applied'] for item in state['changes'])
        self.assertIn("'detected_objects', 'custom_real', 'ub_mr_virtual_objects'", combined)
        self.assertIn('/real/objects', combined)
        self.assertIn('/another/objects', combined)
        self.assertIn('value="false"', combined)
        profile.restore(self.root)
        self.assertEqual(original, self.snapshot())
        profile.restore(self.root)

    def test_unsupported_version_does_not_write(self):
        self.write('autoware_multi_object_tracker', 'package.xml', '<package><version>99.0.0</version></package>')
        original = self.snapshot()
        with self.assertRaises(ValueError): profile.apply(self.root, '/virtual_obstacles')
        self.assertEqual(original, self.snapshot())

    def test_bad_layout_does_not_write(self):
        self.write('tier4_perception_launch', 'launch/object_recognition/tracking/tracking.launch.xml', '<launch/>')
        original = self.snapshot()
        with self.assertRaises(ValueError): profile.apply(self.root, '/virtual_obstacles')
        self.assertEqual(original, self.snapshot())

    def test_dry_run_does_not_write(self):
        original = self.snapshot()
        profile.apply(self.root, '/custom/virtual', dry_run=True)
        self.assertEqual(original, self.snapshot())

    def test_external_changes_are_not_overwritten(self):
        profile.apply(self.root, '/virtual_obstacles')
        path = profile.share(self.root, 'autoware_launch') / 'launch/autoware.launch.xml'
        path.write_text(path.read_text() + '\n<!-- external edit -->\n')
        original = self.snapshot()
        with self.assertRaises(ValueError): profile.restore(self.root)
        self.assertEqual(original, self.snapshot())

    def test_topic_change_requires_restore(self):
        profile.apply(self.root, '/virtual_obstacles')
        with self.assertRaises(ValueError): profile.apply(self.root, '/different')

    def test_virtual_topic_cannot_alias_real_input(self):
        original = self.snapshot()
        with self.assertRaises(ValueError): profile.apply(self.root, '/real/objects')
        self.assertEqual(original, self.snapshot())

    def test_carla_ground_truth_replacement_is_removed(self):
        text = '/**:\n  ros__parameters:\n    input_channels:\n      detected_objects:\n        topic: "/carla/ground_truth/perception/object_recognition/detection/objects"\n'
        patched = profile.patch_channels(text, '/virtual_obstacles')
        self.assertNotIn('/carla/ground_truth/', patched)
        self.assertIn('topic: "/perception/object_recognition/detection/objects"', patched)


if __name__ == '__main__':
    unittest.main()
