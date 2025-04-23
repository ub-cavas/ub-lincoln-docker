#!/bin/bash

# DDS Host Setup From
# https://autowarefoundation.github.io/autoware-documentation/main/installation/additional-settings-for-developers/network-configuration/dds-settings/

echo "Set multicast on lo"
sudo ip link set lo multicast on

echo -e "\nSet Sysctl Settings:"
# Increase the maximum receive buffer size for network packets
sudo sysctl -w net.core.rmem_max=2147483647  # 2 GiB, default is 208 KiB

# IP fragmentation settings
sudo sysctl -w net.ipv4.ipfrag_time=3  # in seconds, default is 30 s
sudo sysctl -w net.ipv4.ipfrag_high_thresh=134217728  # 128 MiB, default is 256 KiB

RED='\033[1;91m'
GREEN='\033[1;92m'
RESET='\033[0m'

echo -e "\nValidate Settings:"
if [ "$(sudo sysctl net.core.rmem_max)" = "net.core.rmem_max = 2147483647" ]; then
  echo -e "${GREEN}Valid${RESET}: net.core.rmem_max = 2147483647"
else
  echo -e "${RED}Invalid${RESET}: net.core.rmem_max = 2147483647"
fi

if [ "$(sudo sysctl net.ipv4.ipfrag_time)" = "net.ipv4.ipfrag_time = 3" ]; then
  echo -e "${GREEN}Valid${RESET}: net.ipv4.ipfrag_time = 3"
else
  echo -e "${RED}Invalid${RESET}: net.ipv4.ipfrag_time = 3"
fi

if [ "$(sudo sysctl net.ipv4.ipfrag_high_thresh)" = "net.ipv4.ipfrag_high_thresh = 134217728" ]; then
  echo -e "${GREEN}Valid${RESET}: net.ipv4.ipfrag_high_thresh = 134217728"
else
  echo -e "${RED}Invalid${RESET}: net.ipv4.ipfrag_high_thresh = 134217728"
fi