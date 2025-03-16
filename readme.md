# Overview
This repo contains a dockerfile to build a docker image to simplify the use of CAV tools for UB's Lincoln MKZ. This will include ROS2, the needed ROS2 driver nodes to interface with the onboard hardware, and Autoware Universe. Currently a work in progress as we work to pull everything into this image.

# Prerequisites
1) Install Docker [[Link]](https://docs.docker.com/engine/install/ubuntu/)
2) Set docker user to not require sudo when running docker: [[Link]](https://docs.docker.com/engine/install/)
3) Install NVIDIA container toolkit and register with docker: [[Link]](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html)


# In Container
### Dataspeed DBW Commands:
    ros2 launch ds_dbw_can dbw.launch.xml
    
    ros2 launch ds_dbw_joystick_demo joystick_demo.launch.xml sys:=true