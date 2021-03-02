#!/bin/sh
# LigeroSmart Easy Install for linux | https://ligerosmart.com | https://complemento.net.br | https://github.com/LigeroSmart
#
# Use this command to run the script:
#
#     curl https://get.ligerosmart.com | sh
#
# You can pass the branch to be used for the respective stack with the BRANCH variable.
#
#     # Development stack (nginx+plack with DEBUG_MODE on)
#     curl https://get.ligerosmart.com | BRANCH=dev sh
#
#     # PostgreSQL support
#     curl https://get.ligerosmart.com | BRANCH=postgresql sh
#
#     # MariaDB support
#     curl https://get.ligerosmart.com | BRANCH=mariadb sh
#
# See the list of branches available at https://github.com/LigeroSmart/ligerosmart-stack/branches
# 

BRANCH=${BRANCH:-main}

command -v apt-get > /dev/null && pkg_mgmt=apt
command -v yum > /dev/null && pkg_mgmt=yum
command -v systemctl > /dev/null && systemctl_cmd=1
command -v git > /dev/null || install_packages=1
command -v pip3 > /dev/null || install_packages=1
command -v docker > /dev/null || install_docker=1
command -v docker-compose > /dev/null || install_dockercompose=1

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
    hostnamectl | grep 'Ubuntu 20.04' > /dev/null
    if [ $? == 0 ]; then
        apt install docker.io
    else 
        curl -fsSL https://get.docker.com | sh
    fi
    if [ $systemctl_cmd ]; then
        systemctl enable docker && systemctl start docker
    fi;
fi;

if [ $install_dockercompose ]; then
    python3 -m pip install --upgrade pip
    pip3 install setuptools
    pip3 install docker-compose
fi;

## Kernel config for elasticsearch
max_map_count=$(sysctl -n vm.max_map_count || echo "")
if [ ! -z $max_map_count ] && [ $max_map_count -lt 262144 ]; then
    echo "The elasticsearch service will not run with max_map_count=$max_map_count. I will try to increase it"
    sysctl -w vm.max_map_count=262144
    echo 'sysctl -w vm.max_map_count=262144' > /etc/sysctl.d/elasticsearch.conf
fi

# Stack repository
git clone --branch=$BRANCH https://github.com/LigeroSmart/ligerosmart-stack || true
cd ligerosmart-stack

# show cmd versions
docker -v
docker-compose -v

# force pull images
docker-compose pull

# download and run at first time 
docker-compose up -d

# stack info
cat README.md
echo -e "\n-----------------\n"

# services running info
echo "Services status:"
docker-compose ps
