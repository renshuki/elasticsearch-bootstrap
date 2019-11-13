#!/bin/bash

source "lib/functions.sh"

# COLORS
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

main() {

    # Display Bootstrap Elasticsearch banner
    display_banner

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
                check_os
                break
                ;;
            "")
                check_os
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
    check_version "Elasticsearch"

    # Check installation directory
    check_install_dir

    # Kibana alongside Elasticsearch
    check_kb_standalone

    # Download Elasticsearch in the given directory
    download_es $installdir $es_filename

    # Extract Elasticsearch
    extract_es $installdir $es_filename

    # Delete Elasticsearch tarball
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

    # Download Kibana
    download_kb $installdir $kb_filename

    # Extract Kibana archive
    extract_kb $installdir $kb_filename

    # Delete Kibana tarball
    while :
    do
        read -p "Delete Kibana archive file (tar.gz)? [y/N]" kbdelete
        case $kbdelete in
            "y")
                delete_kb_archive $es_archive_path
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

    # Start Elasticsearch / Kibana
    while :
    do
        read -p "Start Elasticsearch / Kibana? [Y/n]" servstart
        case $servstart in
            "y")
                start_services
                break
                ;;
            "n")
                echo -e "${GREEN}Skip services startup.${NC}\r\n"
                break
                ;;
            "")
                start_services
                break
                ;;
            *)
               echo -e "${RED}Incorrect input, try again.${NC}\r\n" 
        esac
    done

    echo -e "${YELLOW}Congratulations! You're done!${NC}"
}

main "$@"