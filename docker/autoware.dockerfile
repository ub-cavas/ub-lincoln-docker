FROM ubcavas/ros2-lincoln:20250625.1

# Clone Autoware Universe
RUN git clone -b 0.43.1 --depth 1 https://github.com/autowarefoundation/autoware.git
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

# Add resources dir
ADD resources/ /resources/

# Clone ub_lincoln.repos
RUN cd /autoware && \
    vcs import src < /resources/ub_lincoln.repos

# Apply autoware_launch patch
# https://github.com/autowarefoundation/autoware_launch/pull/1403
RUN cd /autoware/src/launcher/autoware_launch && \
    git cherry-pick -n d4e825c580f8624169bc3ec5bb0776d13007fec7

# Install dependencies
RUN /bin/bash -c "cd autoware && \
    source /opt/ros/humble/setup.bash && \
    apt-get update && \
    rosdep update && \
    rosdep install -y --from-paths src --ignore-src --rosdistro $ROS_DISTRO"

# Build
RUN /bin/bash -c "cd autoware && \
    source /opt/ros/humble/setup.bash && \
    colcon build --symlink-install --cmake-args -DCMAKE_BUILD_TYPE=Release"

# Setup .bashrc to source /autoware
RUN sed -i 's|# source /autoware/install/setup.bash|source /autoware/install/setup.bash|' ~/.bashrc
