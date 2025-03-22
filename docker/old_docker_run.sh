#!/bin/bash

CONTAINER_NAME=cavas_lincoln
HOST_DATA_PATH=/home/user/cavas_data

if ! docker inspect $CONTAINER_NAME > /dev/null 2>&1; then
  # Container does not exist, create one
  docker run -itd \
  -e DISPLAY=$DISPLAY \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  --runtime=nvidia \
  --gpus all \
  --privileged \
  --network host \
  -v /dev:/dev \
  -v /run/udev:/run/udev:ro \
  -v $HOST_DATA_PATH:/cavas/host_data \
  --name $CONTAINER_NAME \
  ub-cavas/ros2-humble-lincoln > /dev/null 2>&1;
else
  # Container exists
  if [ $(docker inspect -f '{{.State.Running}}' $CONTAINER_NAME) = "false" ]; then 
    # Container not running, start it
    docker start $CONTAINER_NAME > /dev/null 2>&1;
  fi
fi

docker exec -it $CONTAINER_NAME /bin/bash -c '/ros_entrypoint.sh bash'; 
