#!/bin/bash

export XAUTHORITY=$(xauth info | grep "Authority file" | awk '{ print $3 }')
docker compose up -d