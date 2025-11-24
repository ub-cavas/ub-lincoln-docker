#!/bin/bash

RED="\e[31m"
BLUE="\e[34m"
GREEN="\033[32m"
RESET="\e[0m"

# Setup workspace
current_dir=$(pwd)
echo -e "${GREEN}current dir:${RESET} ${BLUE} $current_dir ${RESET}"

#Create host_data folder
cd ../../
mkdir -p host_data
cd host_data
host_data_dir=$(pwd)
echo -e "${GREEN}host_data folder created at:${RESET} ${BLUE} $host_data_dir ${RESET}"

#Create autoware_data folder and download artifacts
cd ../
mkdir -p autoware_data
cd autoware_data
autoware_data_dir=$(pwd)
echo -e "${GREEN}autoware_data created at:${RESET} ${BLUE} $autoware_data_dir ${RESET}"

# Update the .env file with the actual folder paths
ENV_FILE=$current_dir/.env
echo -e "${GREEN}ENV file path:${RESET} ${BLUE} $ENV_FILE ${RESET}"

# Change directory
cd ../ub-lincoln-docker/docker || exit

#Set the paths for HOST_DATA & AUTOWARE_DATA variables in .env
sed -i "s|^HOST_DATA_PATH=.*|HOST_DATA_PATH=$host_data_dir|" "$ENV_FILE"
sed -i "s|^AUTOWARE_DATA_PATH=.*|AUTOWARE_DATA_PATH=$autoware_data_dir|" "$ENV_FILE"

## Copy host_dl_artifacts file to autoware_data and run
cd $current_dir/../scripts
cp host_dl_artifacts.bash $autoware_data_dir
cd $autoware_data_dir
bash host_dl_artifacts.bash
rm -rf host_dl_artifacts.bash

echo -e "${GREEN} Workspace Setup Completed. Updating the .env file. ${RESET}"
