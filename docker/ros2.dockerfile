FROM osrf/ros:humble-desktop-full

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y \
        # General tools
        wget \
        # Display tools (xeyes)
        x11-apps \
        # Networking tools
        net-tools \
        iputils-ping \
        # Velodyne Lidar specific packages
        ros-humble-velodyne \
        ros-humble-ament-cmake \
        ros-humble-ament-cmake-ros \
        # Novatel OEM7 GNSS Driver 
        ros-humble-novatel-oem7-driver \
        && rm -rf /var/lib/apt/lists/*

# Run Dataspeed DBW SDK Install
RUN mkdir -p /tmp/downloads && \
    wget -q -O /tmp/downloads/sdk_install.bash https://bitbucket.org/DataspeedInc/dbw_ros/raw/ros2/ds_dbw/scripts/sdk_install.bash && \
    bash /tmp/downloads/sdk_install.bash

# RUN mkdir -p /ros_ws/src

# # Install Velodyne Lidar 
# WORKDIR /ros_ws/src
# RUN git clone https://github.com/ros-drivers/velodyne.git

# WORKDIR /ros_ws/src
# RUN rosdep install --from-paths /ros_ws/src --ignore-src --rosdistro humble -y
# RUN /bin/bash -c "source /opt/ros/humble/setup.bash && colcon build --symlink-install"
