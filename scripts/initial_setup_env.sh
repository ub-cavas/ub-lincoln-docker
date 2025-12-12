#!/bin/bash

# Colors
R="\e[31m"
G="\033[32m"
B="\e[34m"
RESET="\e[0m"

# Setup workspace
current_dir=$(pwd)
echo -e "${G}Current dir:${RESET} ${B}$current_dir${RESET}"

# Create host_data folder
cd "$current_dir/../../"
mkdir -p host_data
cd host_data
host_data_dir=$(pwd)

# Download ub_hdmaps in host_data
cd "$current_dir/../scripts" 
echo -e "$(pwd)"

cp download_maps.sh "$host_data_dir"
cd "$host_data_dir"
bash download_maps.sh
rm -f download_maps.sh

# Create autoware_data folder
cd "$current_dir/../../"
mkdir -p autoware_data
cd autoware_data
autoware_data_dir=$(pwd)

# Copy host_dl_artifacts to autoware_data and run
cp "$current_dir/../scripts/host_download_artifacts.bash" "$autoware_data_dir"
cd "$autoware_data_dir"
bash host_download_artifacts.bash
rm -f host_download_artifacts.bash

# Setup .env File
cd "$current_dir"
ENV_FILE="$current_dir/.env-example"
ENV_FILE_NEW="$current_dir/.env"

if [ -f "$ENV_FILE_NEW" ]; then
    echo -e "${R}.env file already exists! Printing the contents:${RESET}"
    cat "$ENV_FILE_NEW"; echo ""
    echo -e "${G}Not proceeding with .env setup.${RESET}"
else
    echo -e "${G}No .env file found, creating a new one...${RESET}"
    # Copy .env-example to .env
    cp "$ENV_FILE" "$ENV_FILE_NEW"
    # Update .env values
    sed -i "s|^# HOST_DATA_PATH=.*|HOST_DATA_PATH=$host_data_dir|" "$ENV_FILE_NEW"
    sed -i "s|^# AUTOWARE_DATA_PATH=.*|AUTOWARE_DATA_PATH=$autoware_data_dir|" "$ENV_FILE_NEW"
    echo -e "${G}.env file created with the following updated values: ${RESET}"
    cat "$ENV_FILE_NEW"; echo ""
fi

echo -e "${G}host_data folder created at:${RESET} ${B}$host_data_dir${RESET}"
echo -e "${G}Downloaded UB_HDMAPS at:${RESET} ${B}$host_data_dir${RESET}"
echo -e "${G}autoware_data folder created at:${RESET} ${B}$autoware_data_dir${RESET}"
echo -e "${G}Downloaded Artifacts at:${RESET} ${B}$autoware_data_dir${RESET}"
echo -e "${G}Workspace Setup Completed${RESET}"
