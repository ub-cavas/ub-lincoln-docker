#!/usr/bin/env python3
"""Run inside the sourced Autoware 0.43.0 container on a separate ROS domain.

ROS_DOMAIN_ID=182 python3 recognition_tracker_smoke.py
No live launch files are modified. Only a tracker test process is started.
"""
import os
from pathlib import Path
import signal
import subprocess
import tempfile
import time

import rclpy
from autoware_perception_msgs.msg import DetectedObject, DetectedObjects, ObjectClassification, TrackedObjects
from geometry_msgs.msg import TransformStamped
from tf2_ros import StaticTransformBroadcaster
import yaml


def main():
    assert int(os.environ.get('ROS_DOMAIN_ID', '0')) not in (0, 1), 'Use an isolated ROS_DOMAIN_ID (e.g. 182).'
    rclpy.init()
    node = rclpy.create_node('ub_mr_tracker_smoke')
    tf = StaticTransformBroadcaster(node)
    transform = TransformStamped()
    transform.header.stamp = node.get_clock().now().to_msg()
    transform.header.frame_id = 'map'
    transform.child_frame_id = 'base_link'
    transform.transform.rotation.w = 1.0
    tf.sendTransform(transform)
    real = node.create_publisher(DetectedObjects, '/test/real_objects', 1)
    virtual = node.create_publisher(DetectedObjects, '/test/virtual_objects', 1)
    latest = []

    def receive(message):
        latest[:] = message.objects

    subscription = node.create_subscription(TrackedObjects, '/test/tracked_objects', receive, 1)
    package = Path('/autoware/install/autoware_multi_object_tracker/share/autoware_multi_object_tracker')
    with tempfile.TemporaryDirectory(prefix='ub-mr-tracker-') as directory:
        directory = Path(directory)
        parameters = {'/**': {'ros__parameters': {
            'use_sim_time': False,
            'selected_input_channels': ['detected_objects', 'ub_mr_virtual_objects'],
            'input_channels.detected_objects.topic': '/test/real_objects',
            'input_channels.detected_objects.can_spawn_new_tracker': True,
            'input_channels.ub_mr_virtual_objects.topic': '/test/virtual_objects',
            'input_channels.ub_mr_virtual_objects.can_spawn_new_tracker': True,
        }}}
        params = directory / 'inputs.yaml'
        params.write_text(yaml.safe_dump(parameters))
        log_path = directory / 'tracker.log'
        with log_path.open('w') as log:
            process = subprocess.Popen([
                '/autoware/install/autoware_multi_object_tracker/lib/autoware_multi_object_tracker/multi_object_tracker_node',
                '--ros-args', '--params-file', str(package / 'config/multi_object_tracker_node.param.yaml'),
                '--params-file', str(package / 'config/data_association_matrix.param.yaml'),
                '--params-file', str(params), '-r', 'output:=/test/tracked_objects',
            ], stdout=log, stderr=subprocess.STDOUT, start_new_session=True)
            try:
                def detection(x):
                    message = DetectedObjects()
                    message.header.frame_id = 'base_link'
                    message.header.stamp = node.get_clock().now().to_msg()
                    obj = DetectedObject()
                    obj.existence_probability = 1.0
                    obj.classification = [ObjectClassification(label=ObjectClassification.CAR, probability=1.0)]
                    obj.kinematics.pose_with_covariance.pose.position.x = x
                    obj.kinematics.pose_with_covariance.pose.orientation.w = 1.0
                    obj.kinematics.orientation_availability = 2
                    obj.kinematics.has_position_covariance = True
                    for index in (0, 7, 14, 21, 28, 35):
                        obj.kinematics.pose_with_covariance.covariance[index] = 0.01
                    obj.shape.type = 0
                    obj.shape.dimensions.x = 4.0
                    obj.shape.dimensions.y = 2.0
                    obj.shape.dimensions.z = 1.5
                    message.objects = [obj]
                    return message

                def phase(seconds, publish_virtual=False, empty_virtual=False):
                    start = time.monotonic()
                    while time.monotonic() - start < seconds:
                        assert process.poll() is None, log_path.read_text()
                        real.publish(detection(10.0))
                        if publish_virtual:
                            virtual.publish(detection(30.0 + (time.monotonic() - start)))
                        elif empty_virtual:
                            message = detection(30.0)
                            message.objects = []
                            virtual.publish(message)
                        rclpy.spin_once(node, timeout_sec=0.03)
                        time.sleep(0.03)

                phase(3)
                assert len(latest) == 1, f'Real detections blocked by idle virtual channel: {len(latest)} tracks.'
                phase(5, publish_virtual=True)
                assert len(latest) == 2, f'Expected real and virtual tracks, got {len(latest)}.'
                moving = max(latest, key=lambda obj: obj.kinematics.pose_with_covariance.pose.position.x)
                assert moving.kinematics.twist_with_covariance.twist.linear.x > 0.1, 'Tracker did not estimate virtual-object motion.'
                phase(3, empty_virtual=True)
                assert len(latest) == 1, f'Despawned virtual object did not expire: {len(latest)} tracks.'
                phase(3)
                assert len(latest) == 1, 'Real tracking stopped when Unity stopped publishing.'
                print('PASS: idle virtual channel, real + moving virtual tracks, motion estimation, empty-array expiry, Unity disconnect.')
            except Exception:
                print(log_path.read_text())
                raise
            finally:
                if process.poll() is None:
                    os.killpg(process.pid, signal.SIGINT)
                    try:
                        process.wait(timeout=10)
                    except subprocess.TimeoutExpired:
                        os.killpg(process.pid, signal.SIGKILL)
                        process.wait()
    node.destroy_subscription(subscription)
    node.destroy_node()
    rclpy.shutdown()


if __name__ == '__main__':
    main()
