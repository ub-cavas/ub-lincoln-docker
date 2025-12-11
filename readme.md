# Overview
This repo contains a dockerfile to build a docker image to simplify the use of CAV tools for UB's Lincoln MKZ. This will include ROS2, the needed ROS2 driver nodes to interface with the onboard hardware, and Autoware Universe. Currently a work in progress as we work to pull everything into this image.

# Prerequisites
1) Install Docker [[Link]](https://docs.docker.com/engine/install/ubuntu/)
2) Setup docker user to not require sudo when running docker [[Link]](https://docs.docker.com/engine/install/linux-postinstall/)
3) Install NVIDIA container toolkit [[Link]](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html#with-apt-ubuntu-debian) and register with docker [[Link]](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html#configuration)
> [!NOTE]
> Currently, with this setup, an NVIDIA GeForce RTX 20 Series video card or better is required for Autoware perception tasks
4) Test the install out by running a sample workload [[Link]](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/sample-workload.html)

# Usage
1) Pull or Build Images:
```
cd docker
docker compose pull

- or -

cd docker 
./build_ros2.sh
./build_autoware.sh
```
2) Configure `.env` to set the container mounted directories to your host system.
    - $HOST_DATA_PATH
    - $AUTOWARE_DATA_PATH

3) Verify that `AUTOWARE_DATA_PATH` directory has the artifact models downloaded within. If not, use `scripts/host_download_artifacts.sh` in the directory to download them.

4) Verify that `UB_HDMAP` exist in the `host_data` folder. If not, use `scripts/host_download_maps.sh` in the directory to download them.

> [!NOTE]
> Alternatively For Steps 2-4 [STILL IN DEVELOPMENT]:
> Run `scrips/initial_setup_env.sh` to setup the workspace. The `initial_setup_env.sh` creates `host_data` & `autoware_data` folders, updates their paths in the .env file, downloads all the deep learning artifacts used in autoware in `autoware_data` and the `UB_HDMAP` in the `host_data` folder.

5) Docker Compose Up:
```
./dc_up.sh
```
6) Start Bash Shell In Container:
```
./dc_bash.sh
```

# In Container Commands
## Use Lincoln Launch Package:
```
ros2 launch lincoln_launch dbw.launch.py
ros2 launch lincoln_launch lidar.launch.py
ros2 launch lincoln_launch gps.launch.py
ros2 launch lincoln_launch bridge.launch.py
ros2 launch lincoln_launch transform.launch.py
ros2 launch lincoln_launch autoware.launch.xml
```

## Individual Packages:
```
# DBW:
ros2 launch ds_dbw_can dbw.launch.xml

# Velodyne Lidar:
ros2 launch velodyne velodyne-all-nodes-VLP32C-composed-launch.py

# Novatel GPS:
ros2 launch novatel_oem7_driver oem7_net.launch.py oem7_ip_addr:=192.168.100.201 oem7_port:=3005

# Mako Camera:
ros2 run vimbax_camera vimbax_camera_node
```


```
# Other Misc Packages:

# DBW Joystick Testing Demo:
ros2 launch ds_dbw_joystick_demo joystick_demo.launch.xml sys:=true
```