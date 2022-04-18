#!/bin/bash
sudo apt update
sudo apt install -y nfs-kernel-server

#-----------------------------------------------------
# Start subfolders to create
#-----------------------------------------------------
folders=()

# -----------------------------------------
# Zabbix
# -----------------------------------------
# Zabbix - Postgres volume
folders+=("/nfs/system/zabbix/postgres")

# -----------------------------------------
# Graylog
# -----------------------------------------
# Graylog - Mongodb volume
folders+=("/nfs/system/graylog/mongodb")
# Graylog - Elasticsearch volume
folders+=("/nfs/system/graylog/elasticsearch")

# -----------------------------------------
# kibana
# -----------------------------------------
# Kibana - Elasticsearch volume
folders+=("/nfs/system/kibana/elasticsearch")

#-----------------------------------------------------
# End subfolders to create
#-----------------------------------------------------

# Create the root folder
if [ ! -d "/nfs/" ];then
    sudo mkdir -p /nfs/
fi

# Create each subfolder
for folder in "${folders[@]}"
do 
    if [ ! -d $folder ];then
        sudo mkdir -p $folder
    fi
done

conf_exist=$(cat /etc/exports | grep "/nfs/ 192.168.80.0/24*")
if [[ -z $conf_exist ]];then
    sudo echo "/nfs/ 192.168.80.0/24(rw,sync,no_subtree_check,no_root_squash)" >> /etc/exports
fi

sudo chmod -R go+rw /nfs/
sudo chown nobody:nogroup -R /nfs/
sudo systemctl restart nfs-kernel-server