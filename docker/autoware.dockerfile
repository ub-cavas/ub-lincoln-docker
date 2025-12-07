FROM ubcavas/ros2-lincoln:20251018.0

# Clone Autoware Universe
RUN git clone -b 0.45.1 --depth 1 https://github.com/autowarefoundation/autoware.git
RUN cd /autoware && \
    mkdir src && \
    vcs import src < autoware.repos

# Install Dev Tools
RUN bash -c 'source /autoware/amd64.env && \
    apt-get update && \
    apt-get install -y \
        python3-pip \
        golang \
        ros-${rosdistro}-plotjuggler-ros && \
    pip3 install pre-commit && \
    pip3 install clang-format==${pre_commit_clang_format_version}'

# Install gdown
RUN pip3 install gdown

# Install geographiclib
RUN apt-get install -y \
    geographiclib-tools && \
    # Add EGM2008 geoid grid to geographiclib
    geographiclib-get-geoids egm2008-1

# Install pacmod
RUN bash -c 'source /autoware/amd64.env && \
    echo "deb [trusted=yes] https://s3.amazonaws.com/autonomoustuff-repo/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/autonomoustuff-public.list && \
    apt-get update && \
    apt-get install -y ros-${rosdistro}-pacmod3'

# Configure .bashrc
RUN echo "" >> ~/.bashrc && \
    echo "# Added from autoware.dockerfile build" >> ~/.bashrc

# Install RMW & Configure
RUN apt-get update
RUN bash -c 'source /autoware/amd64.env && \
    apt-get install -y ros-humble-${rmw_implementation//_/-}'
## Setup DDS settings
RUN echo "export RMW_IMPLEMENTATION=rmw_cyclonedds_cpp" >> ~/.bashrc && \
    echo "export CYCLONEDDS_URI=file:///resources/cyclonedds.xml" >> ~/.bashrc

# Install Nvidia CUDA Toolkit
RUN wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.1-1_all.deb && \
    dpkg -i cuda-keyring_1.1-1_all.deb && \ 
    rm cuda-keyring_1.1-1_all.deb
RUN bash -c 'source /autoware/amd64.env && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y cuda-toolkit-${cuda_version//_/-}'
RUN sh -c 'echo "export PATH=/usr/local/cuda/bin:\${PATH:+:\${PATH}}" >> ~/.bashrc'
RUN sh -c 'echo "export LD_LIBRARY_PATH=/usr/local/cuda/lib64\${LD_LIBRARY_PATH:+:\${LD_LIBRARY_PATH}}" >> ~/.bashrc'

# Install Nvidia cuDNN and TensorRT
RUN bash -c 'source /autoware/amd64.env && \
    apt-get install -y \
        libcudnn8=${cudnn_version} \
        libnvinfer10=${tensorrt_version} \
        libnvinfer-plugin10=${tensorrt_version} \
        libnvonnxparsers10=${tensorrt_version} \
        libcudnn8-dev=${cudnn_version} \
        libnvinfer-dev=${tensorrt_version} \
        libnvinfer-plugin-dev=${tensorrt_version} \
        libnvinfer-headers-dev=${tensorrt_version} \
        libnvinfer-headers-plugin-dev=${tensorrt_version} \
        libnvonnxparsers-dev=${tensorrt_version}'
RUN apt-mark hold \
        libcudnn8 \
        libnvinfer10 \
        libnvinfer-plugin10 \
        libnvonnxparsers10 \
        libcudnn8-dev \
        libnvinfer-dev \
        libnvinfer-plugin-dev \
        libnvonnxparsers-dev \
        libnvinfer-headers-dev \
        libnvinfer-headers-plugin-dev

# Install cumm & spconv
RUN bash -c 'source /autoware/amd64.env && \
    wget -O cumm.deb https://github.com/autowarefoundation/spconv_cpp/releases/download/spconv_v${spconv_version}%2Bcumm_v${cumm_version}/cumm_${cumm_version}_amd64.deb && \
    dpkg -i cumm.deb && \ 
    rm cumm.deb && \
    wget -O spconv.deb https://github.com/autowarefoundation/spconv_cpp/releases/download/spconv_v${spconv_version}%2Bcumm_v${cumm_version}/spconv_${spconv_version}_amd64.deb && \
    dpkg -i spconv.deb && \ 
    rm spconv.deb'

# Add resources dir
ADD resources/ /resources/

# Download Accel & Brake Maps and Camera files
RUN /bin/bash -c "cd /resources && /resources/download_assets.sh"

# Clone ub_lincoln.repos
RUN cd /autoware && \
    vcs import src < /resources/ub_lincoln.repos

# Install DLIO & GLIM SLAM dependencies
RUN apt install -y libomp-dev libboost-all-dev libmetis-dev libpcl-dev libeigen3-dev \
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
    cmake .. -DBUILD_WITH_CUDA=ON && \
    make -j$(nproc) && \
    sudo make install && \
    sudo ldconfig"

# Clone DLIO & GLIM SLAM packages
RUN /bin/bash -c "cd /ros_ws/src && \
    git clone https://github.com/koide3/glim && \
    git clone https://github.com/koide3/glim_ros2 && \
    git clone -b feature/ros2 https://github.com/vectr-ucla/direct_lidar_inertial_odometry.git"

RUN /bin/bash -c "cd /ros_ws && \
    source /opt/ros/humble/setup.bash && \
    colcon build --symlink-install --cmake-args -DCMAKE_BUILD_TYPE=Release"

# Install dependencies
RUN /bin/bash -c "cd autoware && \
    source /opt/ros/humble/setup.bash && \
    apt-get update && \
    rosdep update && \
    rosdep install -y --from-paths src --ignore-src --rosdistro $ROS_DISTRO"

# Set Custom Autoware Params
RUN /bin/bash -c "/resources/set_custom_autoware_params.sh"

# Build Autoware Packages
RUN /bin/bash -c "cd autoware && \
    source /opt/ros/humble/setup.bash && \
    colcon build --symlink-install --cmake-args -DCMAKE_BUILD_TYPE=Release"

# Configure .bashrc
RUN sed -i 's|# source /autoware/install/setup.bash|source /autoware/install/setup.bash|' ~/.bashrc
RUN sed -i 's|cd /ros_ws|cd /autoware|' ~/.bashrc
RUN echo ". /resources/.bash_aliases" >> ~/.bashrc
RUN echo ". /resources/.bash_ros2_debug" >> ~/.bashrc