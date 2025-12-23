FROM ubcavas/autoware-lincoln:latest

# Install DLIO & GLIM SLAM dependencies
RUN sudo apt install -y libomp-dev libboost-all-dev libmetis-dev libpcl-dev libeigen3-dev \
    libfmt-dev libspdlog-dev libglm-dev libglfw3-dev libpng-dev libjpeg-dev

# Install GTSAM
RUN /bin/bash -c "cd / && git clone https://github.com/borglab/gtsam && \
    cd gtsam && git checkout 4.3a0 && \
    mkdir -p build && cd build && \
    cmake .. -DGTSAM_BUILD_EXAMPLES_ALWAYS=OFF \
            -DGTSAM_BUILD_TESTS=OFF \
            -DGTSAM_WITH_TBB=OFF \
            -DGTSAM_USE_SYSTEM_EIGEN=ON \
            -DGTSAM_BUILD_WITH_MARCH_NATIVE=OFF && \
    make -j$(nproc) && \
    sudo make install"

# Install Iridescence for visualization
RUN /bin/bash -c "cd / && git clone https://github.com/koide3/iridescence --recursive && \
    mkdir iridescence/build && cd iridescence/build && \
    cmake .. -DCMAKE_BUILD_TYPE=Release && \
    make -j$(nproc) && \
    sudo make install"

# Install gtsam_points
RUN /bin/bash -c "cd / && git clone https://github.com/koide3/gtsam_points && \
    mkdir gtsam_points/build && cd gtsam_points/build && \
    cmake .. -DCMAKE_BUILD_TYPE=Release && \
    make -j$(nproc) && \
    sudo make install && \
    sudo ldconfig"

# Clone DLIO & GLIM SLAM packages
RUN /bin/bash -c "cd /ros_ws/src && \
    git clone https://github.com/koide3/glim && \
    git clone https://github.com/koide3/glim_ros2 && \
    git clone -b feature/ros2 https://github.com/vectr-ucla/direct_lidar_inertial_odometry.git"

#Build packages
RUN /bin/bash -c "cd /ros_ws && \
    source /opt/ros/humble/setup.bash && \
    colcon build --symlink-install --cmake-args -DCMAKE_BUILD_TYPE=Release"