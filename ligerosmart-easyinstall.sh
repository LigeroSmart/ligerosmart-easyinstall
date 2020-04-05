#!/bin/sh
# LigeroSmart for linux
#
# Using this command to run the script:
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
                echo "Sorry! I don't detect how to install packages on your system."
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
sysctl -w vm.max_map_count=262144
echo 'sysctl -w vm.max_map_count=262144' > /etc/sysctl.d/elasticsearch.conf

# Stack repository
git clone https://github.com/LigeroSmart/ligerosmart-stack

cd ligerosmart-stack

# info
cat README.md
docker -v
docker-compose -v
