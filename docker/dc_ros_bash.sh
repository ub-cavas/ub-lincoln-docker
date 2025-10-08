#!/bin/bash

service="ros"
if [ -n "$1" ]; then
    service="$1"
fi

docker compose exec -it $service /bin/bash
