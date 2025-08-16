#!/bin/bash

# ~~~ Set UB MKZ Custom Parameters ~~~ #

# Change Max Velocity to 40 kph (11.12 m/s)
sed -i 's|max_vel: 4.17 |max_vel: 11.12|' /autoware/src/launcher/autoware_launch/autoware_launch/config/planning/scenario_planning/common/common.param.yaml

# Change Engage Velocity to 1 m/s because 0.25 is not enough to start MKZ moving
sed -i 's|engage_velocity: 0.25|engage_velocity: 1.0 |' /autoware/src/launcher/autoware_launch/autoware_launch/config/planning/scenario_planning/common/autoware_velocity_smoother/velocity_smoother.param.yaml
