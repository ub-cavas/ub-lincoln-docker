FROM ubcavas/ros2-lincoln

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

# Setup .bashrc
RUN echo "" >> ~/.bashrc && \
    echo "# Added from autoware.dockerfile build" >> ~/.bashrc

# Install DDS
ENV rmw_implementation_dashed=rmw-cyclonedds-cpp
RUN apt-get update && \
    apt-get install -y ros-humble-${rmw_implementation_dashed}

# Add Cyclonedds.xml DDS resource
ADD resources/cyclonedds.xml /resources/cyclonedds.xml

# Setup DDS settings
RUN echo "export RMW_IMPLEMENTATION=rmw_cyclonedds_cpp" >> ~/.bashrc && \
    echo "export CYCLONEDDS_URI=file:///resources/cyclonedds.xml" >> ~/.bashrc

# Install Nvidia CUDA Toolkit
ENV cuda_version_dashed=11-6
RUN sh -c 'echo "deb http://archive.ubuntu.com/ubuntu focal main restricted" > /etc/apt/sources.list.d/focal.list'
RUN wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-keyring_1.1-1_all.deb && \
    dpkg -i cuda-keyring_1.1-1_all.deb && \ 
    rm cuda-keyring_1.1-1_all.deb
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y cuda-toolkit-${cuda_version_dashed}
RUN sh -c 'echo "export PATH=/usr/local/cuda/bin:\${PATH:+:\${PATH}}" >> ~/.bashrc'
RUN sh -c 'echo "export LD_LIBRARY_PATH=/usr/local/cuda/lib64\${LD_LIBRARY_PATH:+:\${LD_LIBRARY_PATH}}" >> ~/.bashrc'

# Install Nvidia cuDNN and TensorRT
ENV cudnn_version=8.4.1.50-1+cuda11.6
ENV tensorrt_version=8.4.2-1+cuda11.6
RUN apt-get install -y \
    libcudnn8=${cudnn_version} \
    libcudnn8-dev=${cudnn_version}
RUN apt-mark hold \
    libcudnn8 \
    libcudnn8-dev
RUN apt-get install -y \
    libnvinfer8=${tensorrt_version} \
    libnvonnxparsers8=${tensorrt_version} \
    libnvparsers8=${tensorrt_version} \
    libnvinfer-plugin8=${tensorrt_version} \
    libnvinfer-dev=${tensorrt_version} \
    libnvonnxparsers-dev=${tensorrt_version} \
    libnvparsers-dev=${tensorrt_version} \
    libnvinfer-plugin-dev=${tensorrt_version}
RUN apt-mark hold \
    libnvinfer8 \
    libnvonnxparsers8 \
    libnvparsers8 \
    libnvinfer-plugin8 \
    libnvinfer-dev \
    libnvonnxparsers-dev \
    libnvparsers-dev \
    libnvinfer-plugin-dev

# Clone Autoware Universe Repos
RUN git clone -b awsim-stable --single-branch https://github.com/autowarefoundation/autoware.git
RUN cd autoware && \
    mkdir src && \
    vcs import src < autoware.repos

# Clone universe_dbw2_bridge
RUN cd /autoware/src/vehicle/external && \
    git clone https://github.com/ub-cavas/universe_dbw2_bridge.git

# Clone transform_data
RUN cd /autoware/src/vehicle/external && \
    git clone https://github.com/ub-cavas/transform_data.git

# Clone lincoln_launch
RUN cd /autoware/src/launcher && \
    git clone https://github.com/ub-cavas/lincoln_launch.git

# Install Dependancies
RUN /bin/bash -c "cd autoware && \
    source /opt/ros/humble/setup.bash && \
    apt-get update && \
    rosdep update && \
    rosdep install -y --from-paths src --ignore-src --rosdistro $ROS_DISTRO"

# Build
RUN /bin/bash -c "cd autoware && \
    source /opt/ros/humble/setup.bash && \
    colcon build --symlink-install --cmake-args -DCMAKE_BUILD_TYPE=Release"

# Setup .bashrc
RUN sed -i 's|# source /autoware/install/setup.bash|source /autoware/install/setup.bash|' ~/.bashrc
   
# Add map resources
ADD resources/service_road_corrected/ /resources/service_road_corrected/

# Apply temp. patches (will be removed ASAP)
ADD resources/sensor_kit_calibration.yaml /autoware/src/param/autoware_individual_params/individual_params/config/default/awsim_sensor_kit/sensor_kit_calibration.yaml
