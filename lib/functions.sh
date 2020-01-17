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

check_os()
{
    if [ `uname` == "Linux" ]; then
        echo -e "${GREEN}Linux${NC}\r\n"
        ostype=1
        osname="Linux"
    elif [ `uname` == "Darwin" ]; then
        echo -e  "${GREEN}Darwin (macOS)${NC}\r\n"
        ostype=2
        osname="Darwin"
    else
        echo -e  "${RED}Unknown OS. Abort.${NC}\r\n"
        exit 1
    fi
}

check_version()
{
    stack_name=$1
    stack_name_lc=$(lc "$stack_name")

    read -p "$1 version to install [$(get_version 'elasticsearch' 'latest')]: " version

    if [[ -z $version ]]; then
        version=$(get_version 'elasticsearch' 'latest')
    fi

    set_filename $stack_name_lc $version
    set_urls $stack_name_lc

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
    read -p "Choose your installation directory [${PWD}]: " installdir

    if [ -z $installdir ]; then installdir="${PWD}"; fi

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

    if [[ "${POS[@]}" =~ "$(lc "$installkb")" ]]; then
        installkb=true
        echo -e "${GREEN}Kibana will get installed alongside Elasticsearch.${NC}\r\n"
    elif [[ "${NEG[@]}" =~ "$(lc "$installkb")" || (-z $installkb) ]]; then
        installkb=false
        echo -e "${GREEN}Skip Kibana installation...${NC}\r\n"
    else
        echo -e "${RED}Incorrect input, try again.${NC}\r\n"
        check_kb_standalone
    fi
}

download()
{
    stack_name=$1
    stack_name_lc=$(lc "$stack_name")

    set_filename $stack_name_lc $version
    set_urls $stack_name_lc

    if [ -f "$installdir/$filename" ]; then
        echo -e "${RED}$stack_name archive file already exists in this location. Skip.${NC}\r\n"
    else
        echo "Downloading $stack_name ($version) for $osname..."
        cd $installdir && curl -O $full_url
        dl_res=$?

        if test "$dl_res" == "0"; then
            echo -e "${GREEN}Download completed successfully!${NC}\r\n"
        else
            echo -e "${RED}Download failed for some reasons.${NC}\r\n"
            exit 1
        fi
    fi
}

extract()
{
    stack_name=$1
    stack_name_lc=$(lc "$stack_name")

    set_filename $stack_name_lc $version

    archive_path=$installdir/$filename

    echo "Extracting $stack_name from the archive..."

    tar xzvf "$archive_path" --directory "$installdir"
    tar_res=$?

    if test "$tar_res" == "0"; then
        echo -e "${GREEN}$stack_name extracted successfully!${NC}\r\n"
    else
        echo -e "${RED}$stack_name extraction failed.${NC}\r\n"
        exit 1
    fi
}

check_delete()
{

    stack_name=$1
    stack_name_lc=$(lc "$stack_name")

    set_filename $stack_name_lc $version

    archive_path=$installdir/$filename

    read -p "Delete $stack_name archive file (tar.gz)? [y/N]" delete

    POS=("y" "yes")
    NEG=("n" "no")

    if [[ "${POS[@]}" =~ "$(lc "$delete")" ]]; then
        delete=true
        delete $stack_name $archive_path
    elif [[ "${NEG[@]}" =~ "$(lc "$delete")" || (-z $delete) ]]; then
        delete=false
        echo -e "${GREEN}Skip deletion...${NC}\r\n"
    else
        echo -e "${RED}Incorrect input, try again.${NC}\r\n"
        check_delete $stack_name
    fi
}

delete()
{
    echo -e "Deleting $stack_name archive file..."
    rm -v "$archive_path"
    rm_res=$?

    if test "$rm_res" == "0"; then
        echo -e "${GREEN}$stack_name archive file removed successfully!${NC}\r\n"
    else
        echo -e "${RED}$stack_name archive file deletion failure.${NC}\r\n"
        exit 1
    fi
}

####################
#                  #
#     Services     #
#                  #
####################

check_start()
{
    read -p "Start Elasticsearch $(if [[ $installkb = true ]]; then echo "/ Kibana"; fi)? [y/N]" servstart

    POS=("y" "yes")
    NEG=("n" "no")

    if [[ "${POS[@]}" =~ "$(lc "$servstart")" ]]; then
        servstart=true
        echo -e "Starting service(s)..."
        start "Elasticsearch"
        if [ $installkb = true ]; then start "Kibana"; fi
    elif [[ "${NEG[@]}" =~ "$(lc "$servstart")" || (-z $servstart) ]]; then
        servstart=false
        echo -e "${GREEN}Skip service(s) startup.${NC}\r\n"
    else
        echo -e "${RED}Incorrect input, try again.${NC}\r\n"
        check_start
    fi
}

start()
{
    stack_name=$1
    stack_name_lc=$(lc "$stack_name")

    if [[ $stack_name = "Kibana" ]]; then
        install_path="$installdir/$stack_name_lc-$version-$(lc $osname)-x86_64"
    else
        install_path="$installdir/$stack_name_lc-$version"
    fi

    nohup $install_path/bin/$stack_name_lc > "$stack_name_lc.out" &
    echo -e "${GREEN}$stack_name started at: http://localhost:9200${NC}\r\n"
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

# Set URLs
set_urls()
{
    base_url="https://artifacts.elastic.co/downloads/$stack_name_lc/"
    full_url="$base_url$filename"
}

# Set Filename
set_filename()
{

    filename="$1-$2-$(lc $osname)-x86_64.tar.gz"
}

# Get version of a stack product
get_version()
{
    url=https://api.github.com/repos/elastic/$1/releases/$2
    tag_name_json=$(curl -X GET "$url" 2>/dev/null | grep -o '"tag_name": "[^"]*' | grep -o '[^v]*$')
    echo "$tag_name_json"
}