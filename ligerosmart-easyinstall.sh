#!/bin/sh
# LigeroSmart Easy Install for linux | https://ligerosmart.com | https://complemento.net.br | https://github.com/LigeroSmart
#
# Use this command to run the script:
#
# curl https://get.ligerosmart.com | sh

command -v apt-get > /dev/null && pkg_mgmt=apt
command -v yum > /dev/null && pkg_mgmt=yum
command -v git > /dev/null || install_packages=1
command -v pip3 > /dev/null || install_packages=1
command -v docker > /dev/null || install_docker=1
command -v docker-compose > /dev/null || install_dockercompose=1

set -e

if [ $install_packages ]; then
    case "$pkg_mgmt" in
            apt)
                apt-get update
                apt-get install -y --no-install-recommends \
                    git \
                    python3-pip
            ;;

            yum)
                yum install -y \
                    git \
                    python3-pip
            ;;

            *)
                echo "Sorry! I did not detect the package manager for this system"
                echo "Could you help us? Check https://github.com/LigeroSmart/ligerosmart-easyinstall"
                exit 1;
            ;;
    esac
fi;

if [ $install_docker ]; then
    curl -fsSL https://get.docker.com | sh
fi;

if [ $install_dockercompose ]; then
    pip3 install setuptools
    pip3 install docker-compose
fi;

## Kernel config for elasticsearch
max_map_count=$(sysctl -n vm.max_map_count)
if [ $max_map_count -lt 262144 ]; then
    echo "The elasticsearch service will not run with max_map_count=$max_map_count. I will try to increase it"
    sysctl -w vm.max_map_count=262144
    echo 'sysctl -w vm.max_map_count=262144' > /etc/sysctl.d/elasticsearch.conf
fi

# Stack repository
git clone https://github.com/LigeroSmart/ligerosmart-stack || true
cd ligerosmart-stack

# show cmd versions
docker -v
docker-compose -v

# download and run at first time 
docker-compose up -d

# stack info
cat README.md

# services running info
docker-compose ps
