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

# Clone repositories and copy specific files
RUN mkdir -p /ros_ws/src \
    && cd /ros_ws/src \
    && git clone https://github.com/ros-drivers/velodyne.git \
    && git clone -b Branch-with-files-for-docker-container --single-branch https://github.com/ub-cavas/vimbax_ros2_driver.git \
# Move the Setup file from vimbax repository to /tmp/downlods
    && mv /ros_ws/src/vimbax_ros2_driver/VimbaX_Setup-2024-1-Linux64.tar.gz /tmp/downloads

# Install VimbaX SDK
WORKDIR /tmp/downloads
RUN tar -xvf VimbaX_Setup-2024-1-Linux64.tar.gz && \
    cd VimbaX_2024-1/cti && \
    ./Install_GenTL_Path.sh && \
    # Directly set environment variable for Docker
    echo "export GENICAM_GENTL64_PATH=$(pwd)" >> /etc/bash.bashrc && \
    echo "export GENICAM_GENTL64_PATH=$(pwd)" >> /root/.bashrc
ENV GENICAM_GENTL64_PATH=/tmp/downloads/VimbaX_2024-1/cti

# Delete the setup file to save space
RUN rm /tmp/downloads/VimbaX_Setup-2024-1-Linux64.tar.gz

# Building the packages and sourcing required files on startup
RUN cd /ros_ws \
    && rosdep install --from-paths src --ignore-src --rosdistro humble -y \
    && /bin/bash -c "source /opt/ros/humble/setup.bash && colcon build --symlink-install" \
    && echo "source /opt/ros/humble/setup.bash" >> /root/.bashrc \
    && echo "source /ros_ws/install/local_setup.bash" >> /root/.bashrc \
    && echo "cd /ros_ws" >> /root/.bashrc
