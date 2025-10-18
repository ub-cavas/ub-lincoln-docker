#!/bin/bash

#For complete rebuild, use: --pull --no-cache
BUILD_NUMBER=0
DOCKER_TAG=$(date +%Y%m%d).$BUILD_NUMBER-dev
docker build -t ubcavas/ros2-lincoln:$DOCKER_TAG -f ros2.dockerfile --pull --no-cache $@ . 