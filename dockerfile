FROM osrf/ros:humble-desktop-full

RUN apt-get update \
 && apt-get upgrade -y \
 && apt-get install -y \
 wget \
 # tools for display testing (xeyes)
 x11-apps \
 # Velodyne Lidar specific packages
 ros-humble-velodyne \
 ros-humble-ament-cmake \
 ros-humble-ament-cmake-ros \
 && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /cavas/host_data

# Run Dataspeed DBW SDK Install
RUN mkdir -p /tmp/downloads \
 && wget -q -O /tmp/downloads/sdk_install.bash https://bitbucket.org/DataspeedInc/dbw_ros/raw/ros2/ds_dbw/scripts/sdk_install.bash \
 && bash /tmp/downloads/sdk_install.bash

# ROS2 Workspace setup
WORKDIR /root/catkin_ws/src

#Install Velodyne Lidar
RUN git clone https://github.com/ros-drivers/velodyne.git
# (Future ROS2 packages clones here)

WORKDIR /root/catkin_ws

# ROS2 dependencies and workspace build
RUN rosdep install --from-paths src --ignore-src --rosdistro humble -y 
RUN /bin/bash -c "source /opt/ros/humble/setup.bash && colcon build --symlink-install"
