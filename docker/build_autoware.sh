#!/bin/bash

#For complete rebuild, use: --pull --no-cache
BUILD_NUMBER=0
DOCKER_TAG=$(date +%Y%m%d).$BUILD_NUMBER
docker build -t ubcavas/autoware-lincoln:$DOCKER_TAG -f autoware.dockerfile $@ . 