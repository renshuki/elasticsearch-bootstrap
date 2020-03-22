#!/bin/bash

BASE_DIR=$(dirname "$(realpath "$0")")

source "$BASE_DIR/lib/functions.sh"

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
        echo -e "Select your Operating System:\n 1. Linux\n 2. Darwin (macOS)\n 3. Auto-detect\n 4. Quit\r\n"
        read -p "[Auto-detect]: " ostype
        case $ostype in
            1)
                echo -e "${GREEN}Linux${NC}\r\n"
                osname="Linux"
                break
                ;;
            2)
                echo -e  "${GREEN}macOS${NC}\r\n"
                osname="Darwin"
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
    download "Elasticsearch"

    # Download Kibana if requested
    if [[ $installkb = true ]]; then
        download "Kibana"
    fi

    parallel_download # To speed up things

    # Extract Elasticsearch
    extract "Elasticsearch"

    # Extract Kibana if previously downloaded
    if [[ $installkb = true ]]; then
        extract "Kibana"
    fi

    # Check delete Elasticsearch tarball
    check_delete "Elasticsearch"

    # Check delete Kibana tarball
    if [[ $installkb = true ]]; then
        check_delete "Kibana"
    fi

    # Start Elasticsearch / Kibana
    check_start

    echo -e "${YELLOW}Congratulations! You're done!${NC}"
}

main "$@"
