#!/bin/bash

# Download Accel_map & Brake_map
wget -O accel_map.csv https://buffalo.box.com/shared/static/ktktf1pdvh2r5x4ic9andkyk2as7het3.csv
wget -O brake_map.csv https://buffalo.box.com/shared/static/tb3oxytl3s6vj4ou36ev6pti9txl90u6.csv

# Download Map & its components
mkdir -p ub_hdmap
cd ub_hdmap
wget -O pointcloud_map.tar.xz https://buffalo.box.com/shared/static/g6yv8b86xzutu0kyo3ho3c6qleznc25t.xz
tar -xvf pointcloud_map.tar.xz
rm pointcloud_map.tar.xz
wget -O lanelet2_map.osm https://buffalo.box.com/shared/static/5uaqp6q33qrejsub5hqifh1lle9r3j83.osm
wget -O map_projector_info.yaml https://buffalo.box.com/shared/static/rfqc8oemy1o7058g5tk2fqwrh48epy0b.yaml
wget -O map_config.yaml https://buffalo.box.com/shared/static/s7kwjvil3ok0zzij5oqi3i3h9r4ah32n.yaml
