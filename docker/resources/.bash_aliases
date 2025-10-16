# Aliases

alias code='code --no-sandbox --user-data-dir=~'

#alias autoware_clean='cd /autoware && rm -rf build/ install/ log/'
#alias autoware_build='cd /autoware && source /opt/ros/humble/setup.bash && colcon build --symlink-install --cmake-args -DCMAKE_BUILD_TYPE=Release'
alias ub_build='colcon build --symlink-install --cmake-args -DCMAKE_BUILD_TYPE=Release'

alias ub_autoware='ros2 launch autoware_launch autoware.launch.xml sensor_model:=ub_lincoln_sensor_kit vehicle_model:=ub_lincoln_vehicle map_path:=/resources/ub_hdmap'

alias ub_autoware_carla='ros2 launch autoware_launch e2e_simulator.launch.xml map_path:=/host_data/maps/ub_carla_map vehicle_model:=sample_vehicle sensor_model:=awsim_sensor_kit simulator_type:=carla carla_map:=UBAutonomousProvingGrounds'