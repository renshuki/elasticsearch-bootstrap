#!/bin/bash

####################
#                  #
#        OS        #
#                  #
####################

check_os_version()
{
    if [ `uname` == "Linux" ]; then
        echo -e "${GREEN}Linux${NC}\r\n"
        ostype=1
        osname="Linux"
    elif [ `uname` == "Darwin" ]; then
        echo -e  "${GREEN}macOS${NC}\r\n"
        ostype=2
        osname="macOS"
    else
        echo -e  "${RED}Unknown OS. Abort.${NC}\r\n"
        exit 1
    fi
}

####################
#                  #
#   Elasticsearch  #
#                  #
####################

check_es_version()
{
    base_es_url="https://artifacts.elastic.co/downloads/elasticsearch/"

    case $1 in
        1)
            es_filename="elasticsearch-$2-linux-x86_64.tar.gz"
            ;;
        2)
            es_filename="elasticsearch-$2-darwin-x86_64.tar.gz"
            ;;
    esac

    full_es_url="$base_es_url$es_filename"
    http_response=`curl -I "$full_es_url" 2>/dev/null | head -n 1 | cut -d$' ' -f2`

    if [[ $http_response == 200 ]]; then
        echo -e "${GREEN}Elasticsearch version $2 found for $osname!${NC}\r\n"
        break
    else
        echo -e "${RED}Elasticsearch version $2 not found for $osname! :/${NC}\r\n"
    fi
}

check_install_dir()
{
    if [ -d "$1" ]; then
        echo -e "${GREEN}$1 is a directory.${NC}\r\n"
        break
    else
        echo -e "${RED}$1 is not a directory.${NC}\r\n"
    fi  
}

download_es()
{
    if [ -f "$installdir/$es_filename" ]; then
        echo -e "${RED}Elasticsearch archive file already exists in this location. Skip.${NC}\r\n"
    else
        echo "Downloading Elasticsearch ($esversion) for $osname..."
        cd $1 && curl -O $full_es_url
        dl_res=$?

        if test "$dl_res" == "0"; then
            echo -e "${GREEN}Download completed successfully!${NC}\r\n"
        else
            echo -e "${RED}Download failed for some reasons.${NC}\r\n"
            exit 1
        fi
    fi
}

extract_es()
{
    echo "Extracting Elasticsearch from the archive..."
    es_archive_path="$1/$2"
    tar xzvf "$es_archive_path" --directory "$1"
    tar_res=$?

    if test "$tar_res" == "0"; then
        echo -e "${GREEN}Elasticsearch extracted successfully!${NC}\r\n"
    else
        echo -e "${RED}Elasticsearch extraction failed.${NC}\r\n"
        exit 1
    fi
}

delete_es_archive()
{
    echo "Deleting Elasticsearch archive file..."
    rm -v "$es_archive_path"
    rm_res=$?

    if test "$rm_res" == "0"; then
        echo -e "${GREEN}Elasticsearch archive file removed successfully!${NC}\r\n"
    else
        echo -e "${RED}Elasticsearch archive file deletion failure.${NC}\r\n"
        exit 1
    fi
}

####################
#                  #
#      Kibana      #
#                  #
####################

check_kb_version()
{
    kbversion=$esversion
    base_kb_url="https://artifacts.elastic.co/downloads/kibana/"

    case $1 in
        1)
            kb_filename="kibana-$kbversion-linux-x86_64.tar.gz"
            ;;
        2)
            kb_filename="kibana-$kbversion-darwin-x86_64.tar.gz"
            ;;
    esac

    full_kb_url="$base_kb_url$kb_filename"
    http_response=`curl -I "$full_kb_url" 2>/dev/null | head -n 1 | cut -d$' ' -f2`

    if [[ $http_response == 200 ]]; then
        echo -e "${GREEN}Kibana version $kbversion found for $osname!${NC}\r\n"
        break
    else
        echo -e "${RED}Kibana version $kbversion not found for $osname! :/${NC}\r\n"
    fi
}

download_kb()
{
    if [ -f "$installdir/$kb_filename" ]; then
        echo -e "${RED}Kibana archive file already exists in this location. Skip.${NC}\r\n"
    else
        echo "Downloading Kibana ($esversion) for $osname..."
        cd $1 && curl -O $full_kb_url
        dl_res=$?

        if test "$dl_res" == "0"; then
            echo -e "${GREEN}Download completed successfully!${NC}\r\n"
        else
            echo -e "${RED}Download failed for some reasons.${NC}\r\n"
            exit 1
        fi
    fi
}

extract_kb()
{
    echo "Extracting Kibana from the archive..."
    kb_archive_path="$1/$2"
    tar xzvf "$kb_archive_path" --directory "$1"
    tar_res=$?

    if test "$tar_res" == "0"; then
        echo -e "${GREEN}Kibana extracted successfully!${NC}\r\n"
    else
        echo -e "${RED}Kibana extraction failed.${NC}\r\n"
        exit 1
    fi
}