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
