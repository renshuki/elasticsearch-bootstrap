#!/bin/bash

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

while :
do
echo -e "Select your Operating System:\n 1. Linux\n 2. macOS\n 3. Auto-detect\n 4. Quit\r\n"
read ostype
    case $ostype in
        1)
            echo -e "Linux\r\n"
            break
            ;;
        2)
            echo -e  "macOS\r\n"
            break
            ;;
        3)
            echo -e "Not implemented yet...\r\n"
            ;;
        4)
            exit 0
            ;;
        *)
            echo -e "Incorrect input, try again.\r\n"
    esac
done

read -p "Elasticsearch version to install (e.g. 7.4.0): " esversion

echo "Elasticsearch version found!"
echo "Elasticsearch version not found! :/"
echo "Installing Elasticsearch ($esversion)..."


# https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.4.2-darwin-x86_64.tar.gz
# https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.4.2-linux-x86_64.tar.gz