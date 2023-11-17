#!/bin/bash
#
# Docker Swarm Mode install
#
# curl https://get.ligerosmart.com/swarm/manager/ | bash
# 

# commands detection
command -v apt-get > /dev/null && pkg_mgmt=apt
command -v yum > /dev/null && pkg_mgmt=yum
command -v systemctl > /dev/null && systemctl_cmd=1
command -v git > /dev/null || install_packages=1
command -v pip3 > /dev/null || install_packages=1
command -v docker > /dev/null || install_docker=1
command -v docker-compose > /dev/null || install_dockercompose=1

# to read your local .env file if exists and creating project as you wish
[ -f .env ] && . ./.env

# default values
installation_only=${installation_only:-0}

if [ $install_packages ]; then
    case "$pkg_mgmt" in
            apt)
                apt-get update
                apt-get install -y --no-install-recommends \
                    git \
                    python3-pip \
                    ncdu \
                    htop \
                    rsync \
                    vim
            ;;

            yum)
                yum install -y \
                    git \
                    python3-pip \
                    ncdu \
                    htop \
                    rsync \
                    vim
            ;;

            *)
                echo "Sorry! I did not detect the package manager for this system"
                echo "Could you help us? Check https://github.com/LigeroSmart/ligerosmart-easyinstall"
                exit 1;
            ;;
    esac
fi;

if [ "$install_docker" ]; then
    hostnamectl | grep 'Ubuntu' > /dev/null
    if [ $? -eq 0 ]; then
        apt install docker.io -y
    else 
        curl -fsSL https://get.docker.com | sh
    fi
    if [ $systemctl_cmd ]; then
        systemctl enable docker && systemctl start docker
    fi;
fi;

if [ "$install_dockercompose" ]; then
    python3 -m pip install --upgrade pip
    pip3 install setuptools
    pip3 install docker-compose

    # docker-compose link
    if [ -f /usr/local/bin/docker-compose ]; then
        ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose
    fi;
fi;

## Kernel config for elasticsearch
if [ -f /proc/sys/vm/max_map_count ]; then
    max_map_count=$(sysctl -n vm.max_map_count || echo 0)
    if [ $max_map_count -lt 262144 ]; then
        echo "The elasticsearch service will not run with max_map_count=$max_map_count. I will try to increase it"
        sysctl -w vm.max_map_count=262144
        echo 'vm.max_map_count=262144' > /etc/sysctl.d/elasticsearch.conf
    fi
fi

ADVERTISE_INTERFACE=${ADVERTISE_INTERFACE:-`ip -br a | grep -v 127.0 | head -n 1 | cut -f 1 -d " "`}
ADVERTISE_IP=`ip -br a | grep $ADVERTISE_INTERFACE | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'`
ADVERTISE_IP=${ADVERTISE_IP:-"server_ip"}
PORTAINER_USERNAME=${PORTAINER_USERNAME:-"admin"}
PORTAINER_PASSWORD=${PORTAINER_PASSWORD:-"portainer#12"}

echo "Docker Info"
docker info

echo "Docker Networks"
docker network ls

echo "Docker Swarm Init"
docker swarm init --advertise-addr ${ADVERTISE_INTERFACE}:2377 
docker swarm update --task-history-limit 1

echo "Docker Ingress network"
docker network create --driver=overlay web

echo "Docker Volume Manager"
docker volume create manager 

echo "Portainer Configuration"
git clone https://github.com/complemento/portainer/ /var/lib/docker/volumes/manager/_data/portainer
bash /var/lib/docker/volumes/manager/_data/portainer/update.sh


while true; do 
    echo "Waiting portainer service"
    sleep 10
    curl -qsI localhost:9000 > /dev/null
    if [ "$?" == "0" ]; then break; fi
done

echo "Portainer started"

curl -X POST http://localhost:9000/api/users/admin/init \
  -H 'Content-Type: application/json' \
  -d "{ \"Username\": \"$PORTAINER_USERNAME\", \"Password\": \"$PORTAINER_PASSWORD\" }" > /dev/null

if [ "$?" == "0" ]; then 
  echo "Access: http://$ADVERTISE_IP:9000"
  echo "Username: $PORTAINER_USERNAME"
  echo "Password: $PORTAINER_PASSWORD" 
fi
