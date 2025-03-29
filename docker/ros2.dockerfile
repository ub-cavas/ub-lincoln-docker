FROM osrf/ros:humble-desktop-full

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y \
        # General tools
        wget \
        nano \
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

# Install Dataspeed DBW SDK
RUN mkdir -p /tmp/downloads && \
    wget -q -O /tmp/downloads/sdk_install.bash https://bitbucket.org/DataspeedInc/dbw_ros/raw/ros2/ds_dbw/scripts/sdk_install.bash && \
    bash /tmp/downloads/sdk_install.bash && \
    rm /tmp/downloads/sdk_install.bash

# Make /ros_ws/src folder    
RUN mkdir -p /ros_ws/src

# Clone Velodyne Src
RUN cd /ros_ws/src && \
    git clone https://github.com/ros-drivers/velodyne.git 

# Clone VimbaX ROS2 Driver
RUN cd /ros_ws/src && \
    git clone https://github.com/ub-cavas/vimbax_ros2_driver.git

# Install VimbaX SDK
RUN mkdir -p /opt/vimbax && \
    cp /ros_ws/src/vimbax_ros2_driver/vimbax_sdk/VimbaX_Setup-2024-1-Linux64.tar.gz /opt/vimbax && \
    cd /opt/vimbax && \
    tar -xvf VimbaX_Setup-2024-1-Linux64.tar.gz && \
    cd VimbaX_2024-1/cti && \
    ./Install_GenTL_Path.sh && \
    echo "export GENICAM_GENTL64_PATH=$(pwd)" >> ~/.bashrc && \
    rm /opt/vimbax/VimbaX_Setup-2024-1-Linux64.tar.gz
ENV GENICAM_GENTL64_PATH=/opt/vimbax/VimbaX_2024-1/cti

# Building the packages and sourcing required files on startup
RUN cd /ros_ws && \
    rosdep install --from-paths src --ignore-src --rosdistro humble -y && \
    /bin/bash -c "source /opt/ros/humble/setup.bash && colcon build --symlink-install"

# Setup .bashrc
RUN echo "source /opt/ros/humble/setup.bash" >> ~/.bashrc && \
    echo "source /ros_ws/install/local_setup.bash" >> ~/.bashrc && \
    echo "cd /ros_ws" >> ~/.bashrc
