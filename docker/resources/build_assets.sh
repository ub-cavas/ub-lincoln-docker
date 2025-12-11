#!/bin/bash

# Download Accel_map & Brake_map
wget -O accel_brake_map.tar.xz https://buffalo.box.com/shared/static/zytwnlemxjtsecqb5jypjxvv3j6ghbeg.xz
tar --no-same-owner -xvf accel_brake_map.tar.xz
rm accel_brake_map.tar.xz

# Move Calibrated Accel & Brake maps into Autoware
mv /resources/autoware_accel_brake_calibrator_files/accel_map.csv /autoware/src/universe/autoware_universe/vehicle/autoware_raw_vehicle_cmd_converter/data/default/accel_map.csv
mv /resources/autoware_accel_brake_calibrator_files/brake_map.csv /autoware/src/universe/autoware_universe/vehicle/autoware_raw_vehicle_cmd_converter/data/default/brake_map.csv
rm -rf /resources/autoware_accel_brake_calibrator_files

# Download Camera Files
wget -O camera_files.tar.xz https://buffalo.box.com/shared/static/iwnncf6fw59qo9o3sufho4kelby1l4ze.xz
tar --no-same-owner -xvf camera_files.tar.xz
rm camera_files.tar.xz

# Move Camera files into /root as required by vimbax
mkdir /root/.ros/camera_info
mv /resources/camera_files/DEV_000F315C3534.xml /root/.ros/camera_info/DEV_000F315C3534.xml
mv /resources/camera_files/DEV_000F315C3534.yaml /root/.ros/camera_info/DEV_000F315C3534.yaml
rm -rf /resources/camera_files