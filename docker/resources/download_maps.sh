#!/bin/bash

# Download Accel_map & Brake_map
wget -O accel_brake_map.tar.xz https://buffalo.box.com/shared/static/zytwnlemxjtsecqb5jypjxvv3j6ghbeg.xz
tar --no-same-owner -xvf accel_brake_map.tar.xz
rm accel_brake_map.tar.xz

# Download HD map & its components
wget -O ub_hdmap.tar.xz https://buffalo.box.com/shared/static/ieqo2qw17kucgkqdg3lejhrkhpx7fimx.xz
tar --no-same-owner -xvf ub_hdmap.tar.xz
rm ub_hdmap.tar.xz
