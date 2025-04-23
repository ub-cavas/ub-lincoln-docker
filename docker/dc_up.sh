#!/bin/bash

service="autoware"
if [ -n "$1" ]; then
    service="$1"
fi

../scripts/host_config_dds.bash
docker compose up -d $service