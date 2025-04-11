#!/bin/bash

service="autoware"
if [ -n "$1" ]; then
    service="$1"
fi

# export XAUTHORITY=$(xauth info | grep "Authority file" | awk '{ print $3 }')
docker compose up -d $service