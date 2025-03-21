FROM ub-cavas/ros2-lincoln

# Install Dev Tools
ENV pre_commit_clang_format_version=17.0.5
RUN apt-get update && \
    apt-get install -y \
        python3-pip \
        golang \
        ros-$ROS_DISTRO-plotjuggler-ros \
    git-lfs && \
    git lfs install && \
    pip3 install pre-commit && \
    pip3 install clang-format==${pre_commit_clang_format_version}

# Install gdown
RUN pip3 install gdown

# Install geographiclib
RUN apt-get update && \
    apt-get install -y \
        geographiclib-tools && \
    # Add EGM2008 geoid grid to geographiclib
    geographiclib-get-geoids egm2008-1

# Install pacmod
RUN sh -c 'echo "deb [trusted=yes] https://s3.amazonaws.com/autonomoustuff-repo/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/autonomoustuff-public.list'
RUN apt-get update && \
    apt-get install -y \
        apt-transport-https \
        ros-$ROS_DISTRO-pacmod3

# Install Autoware Universe
RUN git clone https://github.com/autowarefoundation/autoware.git
RUN cd autoware && \
    mkdir src && \
    vcs import src < autoware.repos && \
    vcs import src < extra-packages.repos
RUN /bin/bash -c "cd autoware && \
    source /opt/ros/humble/setup.bash && \
    apt-get update && \
    apt-get upgrade -y && \
    rosdep update && \
    rosdep install -y --from-paths src --ignore-src --rosdistro $ROS_DISTRO"
RUN /bin/bash -c "cd autoware && \
    source /opt/ros/humble/setup.bash && \
    colcon build --symlink-install --cmake-args -DCMAKE_BUILD_TYPE=Release"

