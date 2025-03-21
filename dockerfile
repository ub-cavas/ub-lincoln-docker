FROM osrf/ros:humble-desktop-full

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
 && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /cavas/host_data

# Run Dataspeed DBW SDK Install
RUN mkdir -p /tmp/downloads \
 && wget -q -O /tmp/downloads/sdk_install.bash https://bitbucket.org/DataspeedInc/dbw_ros/raw/ros2/ds_dbw/scripts/sdk_install.bash \
 && bash /tmp/downloads/sdk_install.bash

# Clone Velodyne Lidar & Vimbax ROS2 Driver. 
RUN mkdir -p /ros_ws/src \
    &&  cd /ros_ws/src \
    && git clone https://github.com/ros-drivers/velodyne.git \
    && git clone https://github.com/ub-cavas/vimbax_ros2_driver.git

# Install VimbaX SDK
COPY VimbaX_Setup-2024-1-Linux64.tar.gz /tmp/downloads
WORKDIR /tmp/downloads
RUN tar -xvf VimbaX_Setup-2024-1-Linux64.tar.gz && \
    cd VimbaX_2024-1/cti && \
    ./Install_GenTL_Path.sh && \
    # Directly set environment variable for Docker
    echo "export GENICAM_GENTL64_PATH=$(pwd)" >> /etc/bash.bashrc && \
    echo "export GENICAM_GENTL64_PATH=$(pwd)" >> /root/.bashrc
ENV GENICAM_GENTL64_PATH=/tmp/downloads/VimbaX_2024-1/cti

# Install Velodyne Lidar & Vimbax ROS2 Driver.
# RUN cd /ros_ws \
#     && rosdep install --from-paths src --ignore-src --rosdistro humble -y \
#     && /bin/bash -c "source /opt/ros/humble/setup.bash && colcon build --symlink-install"

# Add to existing colcon build RUN command
RUN cd /ros_ws \
    && rosdep install --from-paths src --ignore-src --rosdistro humble -y \
    && /bin/bash -c "source /opt/ros/humble/setup.bash && colcon build --symlink-install" \
    && echo "source /opt/ros/humble/setup.bash" >> /root/.bashrc \
    && echo "source /ros_ws/install/local_setup.bash" >> /root/.bashrc \
    && echo "cd /ros_ws" >> /root/.bashrc
