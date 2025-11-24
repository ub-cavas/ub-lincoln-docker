#!/bin/bash

#!/bin/bash

BLUE="\e[34m"
RESET="\e[0m"
GREEN='\033[1;92m'
echo -e "\e[34mThis text will be blue.\e[0m"
# Setup workspace
current_dir=$(pwd)
echo -e "${BLUE}Current Dir: $current_dir${RESET}"

#Create host_data folder
cd ../../
mkdir -p host_data
cd host_data
host_dir=$(pwd)
echo -e "${BLUE}host_data folder created at: $host_dir${RESET}"

#Create autoware_data folder and download artifacts
cd ../
mkdir -p autoware_data
autoware_data_dir=$(pwd)
echo -e "${BLUE}autoware_data folder created at: $autoware_data_dir${RESET}"

cd ub-lincoln-docker/scripts
cp host_dl_artifacts.bash $autoware_data_dir/autoware_data
cd $autoware_data_dir/autoware_data

echo -e "${BLUE}$(pwd)${RESET}"

bash host_dl_artifacts.bash
rm -rf host_dl_artifacts.bash

# service="autoware"
# if [ -n "$1" ]; then
#     service="$1"
# fi

# ../scripts/host_config_dds.bash
# docker compose up -d $service