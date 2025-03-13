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

# Create ROS workspace for all drivers
RUN mkdir -p /ros_ws/src

WORKDIR /ros_ws/src
RUN sudo apt install -y ros-humble-novatel-oem7-driver 
# # Install & Run Novatel OEM7 Driver
# WORKDIR /ros_ws/src
# RUN git clone https://github.com/novatel/novatel_oem7_driver.git \
#     && cd novatel_oem7_driver \
#     && git switch humble \
#     && rosdep install --from-paths src --ignore-src -r -y \
#     && export ROS_DISTRO=humble \
#     && source /opt/ros/humble/setup.bash \
#     && ./build.sh -f

# # Install dependencies and build workspace
# WORKDIR /ros_ws
# RUN . /opt/ros/humble/setup.sh && \
#     rosdep install --from-paths src --ignore-src -r -y 

# RUN colcon build

# # Add source commands to .bashrc for convenience
# RUN echo "source /opt/ros/humble/setup.bash" >> /root/.bashrc \