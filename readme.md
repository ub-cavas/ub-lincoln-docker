# Overview
This repo contains a dockerfile to build a docker image to simplify the use of CAV tools for UB's Lincoln MKZ. This will include ROS2, the needed ROS2 driver nodes to interface with the onboard hardware, and Autoware Universe. Currently a work in progress as we work to pull everything into this image.

# Prerequisites
1) Install Docker [[Link]](https://docs.docker.com/engine/install/ubuntu/)
2) Set docker user to not require sudo when running docker: [[Link]](https://docs.docker.com/engine/install/)
3) Install NVIDIA container toolkit and register with docker: [[Link]](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html)
4) Please **ENSURE** that **VimbaX Viewer Setup file** is present in the folder from where this repo is cloned to. The software can be downloaded from [[Here]](https://www.alliedvision.com/en/products/software/vimba-x-sdk/#c13326)

# In Container
### Setup environment:
    source /opt/ros/humble/setup.bash

    source ~/ros_ws/install/setup.bash

> This is automatically done while building the dockerfile and automatically done when launching the container!

### Dataspeed DBW Commands:
    ros2 launch ds_dbw_can dbw.launch.xml
    
    ros2 launch ds_dbw_joystick_demo joystick_demo.launch.xml sys:=true

### Velodyne Lidar Command:
    ros2 launch velodyne_driver velodyne_driver_node-VLP32C-launch.py

### Novatel GPS Command:
    ros2 launch novatel_oem7_driver oem7_net.launch.py oem7_ip_addr:=192.168.100.201 oem7_port:=3005

### Mako Camera Command
    ros2 run vimbax_camera vimbax_camera_node
