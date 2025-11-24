#!/bin/bash

# Download HD map & its components
cd /host_data
wget -O ub_hdmap.tar.xz https://buffalo.box.com/shared/static/ieqo2qw17kucgkqdg3lejhrkhpx7fimx.xz
tar --no-same-owner -xvf ub_hdmap.tar.xz
rm ub_hdmap.tar.xz