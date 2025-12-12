FROM osrf/ros:humble-desktop-full

RUN apt-get update && \
    apt-get install -y \
        # General tools
        git-lfs \
        wget \
        gpg \
        nano \
        apt-transport-https \
        usbutils \
        # Display tools (xeyes)
        x11-apps \
        # Networking tools
        net-tools \
        iputils-ping \
        # Velodyne lidar driver
        ros-humble-velodyne \
        # Novatel OEM7 GNSS driver 
        ros-humble-novatel-oem7-driver && \
    rm -rf /var/lib/apt/lists/* && \
    git lfs install

# Install VSCode
RUN wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg && \
    install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg && \
    echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" |sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null && \
    rm -f packages.microsoft.gpg && \
    apt-get update && \
    apt-get install -y code

# Install Dataspeed DBW SDK
RUN mkdir -p /tmp/downloads && \
    wget -q -O /tmp/downloads/sdk_install.bash https://bitbucket.org/DataspeedInc/dbw_ros/raw/ros2/ds_dbw/scripts/sdk_install.bash && \
    bash /tmp/downloads/sdk_install.bash && \
    rm /tmp/downloads/sdk_install.bash

# Make /ros_ws/src folder    
RUN mkdir -p /ros_ws/src

# Setup .bashrc
RUN echo "" >> ~/.bashrc && \
    echo "# Added from ros2.dockerfile build" >> ~/.bashrc

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
    echo "# source /autoware/install/setup.bash" >> ~/.bashrc && \
    echo "source /ros_ws/install/local_setup.bash" >> ~/.bashrc && \
    echo "cd /ros_ws" >> ~/.bashrc