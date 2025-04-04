#!/bin/bash

service="autoware"
if [ -n "$1" ]; then
    service="$1"
fi

docker compose exec -it $service /bin/bash