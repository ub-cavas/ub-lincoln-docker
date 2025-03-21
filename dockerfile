FROM osrf/ros:humble-desktop-full

# Update and install necessary dependencies
RUN apt-get update \
 && apt-get upgrade -y \
 && apt-get install -y \
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
 # Build Tools
 build-essential \
 python3-colcon-common-extensions
 && rm -rf /var/lib/apt/lists/*

# Create directory for persistent host data
RUN mkdir -p /cavas/host_data

# Install Dataspeed DBW SDK
RUN mkdir -p /tmp/downloads \
 && wget -q -O /tmp/downloads/sdk_install.bash https://bitbucket.org/DataspeedInc/dbw_ros/raw/ros2/ds_dbw/scripts/sdk_install.bash \
 && bash /tmp/downloads/sdk_install.bash

# Copy and install VimbaX SDK
COPY VimbaX_Setup-2024-1-Linux64.tar.gz /opt/
WORKDIR /opt
RUN tar -xvf VimbaX_Setup-2024-1-Linux64.tar.gz \
 && cd VimbaX_2024-1/cti \
 && ./Install_GenTL_Path.sh \
 && ./Set_GenTL_Path.sh

# Set up ROS2 environment
RUN bash -c "source /opt/ros/humble/setup.bash && \
    if [ ! -f /etc/ros/rosdep/sources.list.d/20-default.list ]; then rosdep init; fi && \
    rosdep update && \
    apt-get update"

# Clone and build the vimbax_ros2_driver
RUN mkdir -p /root/ros2_ws/src \
 && cd /root/ros2_ws/src \
 && git clone https://github.com/ub-cavas/vimbax_ros2_driver.git \
 && cd /root/ros2_ws/ \
 && rosdep install --from-path src --ignore-src -y \
 && bash -c "source /opt/ros/humble/setup.bash && colcon build --cmake-args -DVMB_DIR=/opt/VimbaX_2024-1"

RUN mkdir -p /ros_ws/src

# Install Velodyne Lidar 
WORKDIR /ros_ws/src
RUN git clone https://github.com/ros-drivers/velodyne.git

WORKDIR /ros_ws/src
RUN rosdep install --from-paths /ros_ws/src --ignore-src --rosdistro humble -y
RUN /bin/bash -c "source /opt/ros/humble/setup.bash && colcon build --symlink-install"
