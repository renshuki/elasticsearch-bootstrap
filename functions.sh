#!/bin/bash

display_banner()
{
    banner="
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
                                                                                                                      
    "

    echo -e "$banner"
}

####################
#                  #
#        OS        #
#                  #
####################

check_os()
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

    read -p "Elasticsearch version to install (e.g. 7.4.0): " esversion

    case $ostype in
        1)
            es_filename="elasticsearch-$esversion-linux-x86_64.tar.gz"
            ;;
        2)
            es_filename="elasticsearch-$esversion-darwin-x86_64.tar.gz"
            ;;
    esac

    full_es_url="$base_es_url$es_filename"
    http_response=`curl -I "$full_es_url" 2>/dev/null | head -n 1 | cut -d$' ' -f2`

    if [[ $http_response == 200 ]]; then
        echo -e "${GREEN}Elasticsearch version $esversion found for $osname!${NC}\r\n"
    else
        echo -e "${RED}Elasticsearch version $esversion not found for $osname! :/${NC}\r\n"
        check_es_version
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

delete_kb_archive()
{
    echo "Deleting Kibana archive file..."
    rm -v "$kb_archive_path"
    rm_res=$?

    if test "$rm_res" == "0"; then
        echo -e "${GREEN}Kibana archive file removed successfully!${NC}\r\n"
    else
        echo -e "${RED}Kibana archive file deletion failure.${NC}\r\n"
        exit 1
    fi
}

####################
#                  #
#     Services     #
#                  #
####################

start_services()
{
    echo -e "Starting service(s)..."
    es_path=`echo "$installdir/elasticsearch-$esversion"`
    echo "$es_path"
    if [ $kbdl == "y" ]; then
        kb_path=`echo "$installdir/$kb_filename"|rev|cut -d"." -f3-|rev`
        echo "$kb_path"
        start_es $es_path
        start_kb $kb_path
    else
        start_es $es_path
    fi
}

start_es()
{
    nohup $1/bin/elasticsearch &
    echo -e "${GREEN}Elasticsearch started at: http://localhost:9200${NC}\r\n"
}

start_kb()
{
    nohup $1/bin/kibana &
    echo -e "${GREEN}Kibana started at: http://localhost:5601${NC}\r\n"
}