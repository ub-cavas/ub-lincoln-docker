FROM osrf/ros:humble-desktop-full

RUN apt-get update \
 && apt-get upgrade -y \
 && apt-get install -y \
 wget \
 # tools for display testing (xeyes)
 x11-apps \
 && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /cavas/host_data

# Run Dataspeed DBW SDK Install
RUN mkdir -p /tmp/downloads \
 && wget -q -O /tmp/downloads/sdk_install.bash https://bitbucket.org/DataspeedInc/dbw_ros/raw/ros2/ds_dbw/scripts/sdk_install.bash \
 && bash /tmp/downloads/sdk_install.bash

RUN apt-get update && apt-get install -y ros-humble-velodyne 

RUN mkdir -p ~/catkin_ws/src

WORKDIR ~/catkin_ws/src
RUN git clone https://github.com/ros-drivers/velodyne.git

WORKDIR /root/catkin_ws

RUN rosdep update && rosdep install --from-paths src --ignore-src --rosdistro humble -y

RUN colcon build --symlink-install
