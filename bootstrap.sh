#!/bin/bash

source "functions.sh"

# COLORS
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

banner=$(cat << EOF
  ____              _       _                                 
 |  _ \            | |     | |                                
 | |_) | ___   ___ | |_ ___| |_ _ __ __ _ _ __                
 |  _ < / _ \ / _ \| __/ __| __| '__/ _\` | '_ \               
 | |_) | (_) | (_) | |_\__ \ |_| | | (_| | |_) |              
 |____/_\___/ \___/ \__|___/\__|_|  \__,_| .__/         _     
 |  ____| |         | | (_)              | |           | |    
 | |__  | | __ _ ___| |_ _  ___ ___  ___ |_| _ _ __ ___| |__  
 |  __| | |/ _\` / __| __| |/ __/ __|/ _ \/ _\` | '__/ __| '_ \ 
 | |____| | (_| \__ \ |_| | (__\__ \  __/ (_| | | | (__| | | |
 |______|_|\__,_|___/\__|_|\___|___/\___|\__,_|_|  \___|_| |_|
                                                                                                                  
EOF
)

echo -e "$banner"

# Check OS
while :
do
    echo -e "Select your Operating System:\n 1. Linux\n 2. macOS\n 3. Auto-detect\n 4. Quit\r\n"
    read -p "[Auto-detect]: " ostype
    case $ostype in
        1)
            echo -e "${GREEN}Linux${NC}\r\n"
            osname="Linux"
            break
            ;;
        2)
            echo -e  "${GREEN}macOS${NC}\r\n"
            osname="macOS"
            break
            ;;
        3)
            check_os_version
            break
            ;;
        "")
            check_os_version
            break
            ;;
        4)
            exit 0
            ;;
        *)
            echo -e "${RED}Incorrect input, try again.${NC}\r\n"
    esac
done

# Check Elasticsearch version
while :
do
    read -p "Elasticsearch version to install (e.g. 7.4.0): " esversion
    check_es_version $ostype $esversion
done

# Check installation directory
while :
do
    read -p "Choose your installation directory [${HOME}]: " installdir
    check_install_dir $installdir
done

# Download Elasticsearch in the given directory
download_es $installdir $es_filename

# Extract Elasticsearch
extract_es $installdir $es_filename

# Delete Elasticsearch archive
while :
do
    read -p "Delete Elasticsearch archive file (tar.gz)? [y/N]" esdelete
    case $esdelete in
        "y")
            delete_es_archive $es_archive_path
            break
            ;;
        "n")
            echo -e "${GREEN}Skip deletion...${NC}\r\n"
            break
            ;;
        "")
            echo -e "${GREEN}Skip deletion...${NC}\r\n"
            break
            ;;
        *)
           echo -e "${RED}Incorrect input, try again.${NC}\r\n" 
    esac
done

# Kibana alongside Elasticsearch
while :
do
    read -p "Download Kibana alongside Elasticsearch? [y/N]" kbdl
    case $kbdl in
        "y")
            check_kb_version $ostype $kbdl
            ;;
        "n")
            echo -e "${GREEN}Skip Kibana installation...${NC}\r\n"
            break
            ;;
        "")
            echo -e "${GREEN}Skip Kibana installation...${NC}\r\n"
            break
            ;;
        *)
            echo -e "${RED}Incorrect input, try again.${NC}\r\n" 
    esac
done

# Download Kibana
download_kb $installdir $kb_filename

echo -e "${YELLOW}Congratulations! You're done!${NC}"
