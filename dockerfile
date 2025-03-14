FROM osrf/ros:humble-desktop-full

RUN apt-get update \
 && apt-get upgrade -y \
 && apt-get install -y \
 wget \
 # tools for display testing (xeyes)
 x11-apps \
 && rm -rf /var/lib/apt/lists/*
 #Tools for ethernet debugging
RUN sudo apt update \
&& apt install net-tools \
&& apt install iputils-ping
RUN mkdir -p /cavas/host_data

# Run Dataspeed DBW SDK Install
RUN mkdir -p /tmp/downloads \
 && wget -q -O /tmp/downloads/sdk_install.bash https://bitbucket.org/DataspeedInc/dbw_ros/raw/ros2/ds_dbw/scripts/sdk_install.bash \
 && bash /tmp/downloads/sdk_install.bash

# Create ROS workspace for all drivers
RUN mkdir -p /ros_ws/src

WORKDIR /ros_ws/src
RUN sudo apt install -y ros-humble-novatel-oem7-driver 

#Install Velodyn Lidar 
WORKDIR /ros_ws/src
RUN git clone https://github.com/ros-drivers/velodyne.git

WORKDIR /ros_ws/src

RUN rosdep install --from-paths /ros_ws/src --ignore-src --rosdistro humble -y \
&& /bin/bash -c "source /opt/ros/humble/setup.bash && colcon build --symlink-install"