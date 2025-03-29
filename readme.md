# Overview
This repo contains a dockerfile to build a docker image to simplify the use of CAV tools for UB's Lincoln MKZ. This will include ROS2, the needed ROS2 driver nodes to interface with the onboard hardware, and Autoware Universe. Currently a work in progress as we work to pull everything into this image.

# Prerequisites
1) Install Docker [[Link]](https://docs.docker.com/engine/install/ubuntu/)
2) Set docker user to not require sudo when running docker: [[Link]](https://docs.docker.com/engine/install/)
3) Install NVIDIA container toolkit and register with docker: [[Link]](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html)

# Usage
1) Pull or Build Images:
```
cd docker
docker compose pull

- or -

cd docker 
./build_ros2.sh
./build_autoware.sh
```
2) Configure `.env` with the path to the shared folder on the host which will be shared with the container

3) Docker Compose Up:
```
./dc_up.sh
```
4) Start Bash Shell In Container:
```
./dc_bash.sh
```

# In Container
## Dataspeed DBW Commands:
    ros2 launch ds_dbw_can dbw.launch.xml
    
#### Only The Joystick Testing Demo:
```
ros2 launch ds_dbw_joystick_demo joystick_demo.launch.xml sys:=true
```

## Velodyne Lidar Command:
    ros2 launch velodyne velodyne-all-nodes-VLP32C-composed-launch.py

## Novatel GPS Command:
    ros2 launch novatel_oem7_driver oem7_net.launch.py oem7_ip_addr:=192.168.100.201 oem7_port:=3005

## Mako Camera Command
    ros2 run vimbax_camera vimbax_camera_node
