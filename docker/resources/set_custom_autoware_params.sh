#!/bin/bash

# ~~~ Set UB MKZ Custom Parameters ~~~ #

# Change Max Velocity to 40 kph (11.12 m/s)
sed -i 's|max_vel: 4.17 |max_vel: 11.12|' /autoware/src/launcher/autoware_launch/autoware_launch/config/planning/scenario_planning/common/common.param.yaml

# Change Engage Velocity to 1 m/s because 0.25 is not enough to start MKZ moving
sed -i 's|engage_velocity: 0.25|engage_velocity: 1.0 |' /autoware/src/launcher/autoware_launch/autoware_launch/config/planning/scenario_planning/common/autoware_velocity_smoother/velocity_smoother.param.yaml

# Comment out the launch commands for HddMonitor in autoware_system_monitor package
sed -i '/<composable_node[^>]*plugin="HddMonitor"/,/<\/composable_node>/ {
  /<composable_node[^>]*plugin="HddMonitor"/ s/^/<!-- /
  /<\/composable_node>/ s/$/ -->/
}' /autoware/src/universe/autoware_universe/system/autoware_system_monitor/launch/system_monitor.launch.xml

# Move Calibrated Accel & Brake maps into Autoware
mv /resources/autoware_accel_brake_calibrator_files/accel_map.csv /autoware/src/universe/autoware_universe/vehicle/autoware_raw_vehicle_cmd_converter/data/default/accel_map.csv
mv /resources/autoware_accel_brake_calibrator_files/brake_map.csv /autoware/src/universe/autoware_universe/vehicle/autoware_raw_vehicle_cmd_converter/data/default/brake_map.csv
rm -rf /resources/autoware_accel_brake_calibrator_files

# Move Camera files into /root as required by vimbax
mkdir /root/.ros/camera_info
mv /resources/camera_files/DEV_000F315C3534.xml /root/.ros/camera_info/DEV_000F315C3534.xml
mv /resources/camera_files/DEV_000F315C3534.xml /root/.ros/camera_info/DEV_000F315C3534.yaml
rm -rf /resources/camera_files