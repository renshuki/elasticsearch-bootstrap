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

check_version()
{
    stack_name=$1
    stack_name_lc=$(lc "$stack_name")
    base_url="https://artifacts.elastic.co/downloads/$stack_name_lc/"

    read -p "$1 version to install (e.g. 7.4.0): " version

    case $ostype in
        1)
            filename="$stack_name_lc-$version-linux-x86_64.tar.gz"
            ;;
        2)
            filename="$stack_name_lc-$version-darwin-x86_64.tar.gz"
            ;;
    esac

    full_url="$base_url$filename"
    http_response=`curl -I "$full_url" 2>/dev/null | head -n 1 | cut -d$' ' -f2`

    if [[ $http_response == 200 ]]; then
        echo -e "${GREEN}$stack_name version $version found for $osname!${NC}\r\n"
    else
        echo -e "${RED}$stack_name version $version not found for $osname! :/${NC}\r\n"
        check_version "$stack_name"
    fi
}

check_install_dir()
{
    read -p "Choose your installation directory [${HOME}]: " installdir

    if [ -d "$installdir" ]; then
        echo -e "${GREEN}$installdir is a directory.${NC}\r\n"
    else
        echo -e "${RED}$installdir is not a directory.${NC}\r\n"
        check_install_dir
    fi  
}

check_kb_standalone()
{
    read -p "Download Kibana alongside Elasticsearch? [y/N]" installkb

    POS=("y" "yes")
    NEG=("n" "no")

    if [[ "${POS[@]}" =~ "${installkb,,}" ]]; then
        check_version "Kibana"
    elif [[ "${NEG[@]}" =~ "${installkb,,}" ]]; then
        echo -e "${GREEN}Skip Kibana installation...${NC}\r\n"
    else
        echo -e "${RED}Incorrect input, try again.${NC}\r\n"
        check_kb_standalone
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

####################
#                  #
#      General     #
#                  #
####################

# Lowercase function 
# (for compatibility with macOS as ${1,,} doesn't seem to be working)
lc()
{
    echo "$1" | tr '[:upper:]' '[:lower:]'
}