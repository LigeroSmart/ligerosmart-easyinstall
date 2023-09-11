#!/bin/bash
#
# Docker Swarm Mode install
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
                    rsync
            ;;

            yum)
                yum install -y \
                    git \
                    python3-pip \
                    ncdu \
                    htop \
                    rsync
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

ADVERTISE_INTERFACE=${ADVERTISE_INTERFACE:-`ip -br a | grep -v 127.0 |  ip -br a | grep -v 127.0 | head -n 1 | cut -f 1 -d " "`}

echo "Docker Info"
docker info

echo "Docker Networks"
docker network ls

echo "Docker Swarm Init"
docker swarm init --advertise-addr ${ADVERTISE_INTERFACE}:2377 

echo "Docker Ingress network"
docker network create --driver=overlay web

echo "Docker Volume Manager"
docker volume create manager 

echo "Portainer Configuration"
git clone https://github.com/complemento/portainer/ /var/lib/docker/volumes/manager/_data/portainer
bash /var/lib/docker/volumes/manager/_data/portainer/update.sh