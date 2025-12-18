#!/bin/sh
# LigeroSmart Easy Install for linux | https://ligerosmart.com | https://complemento.net.br | https://github.com/LigeroSmart
#
# HOW TO:
#
#     Use this command to run the script:
#
#          curl https://get.ligerosmart.com | sh
#
# ENVIRONMENT VARIABLES:
#
#      PROJECT_NAME=ligerosmart-stack
#            The project name will be created and used to directory name and containers suffix
#
#      BRANCH=[main|dev|postgresql|mariadb|traefik]
#            You can pass the branch to be used in repository.
#            See the list of branches available at https://github.com/LigeroSmart/ligerosmart-stack/branches
#
# EXAMPLES:
#
#     Development stack (nginx+plack with DEBUG_MODE on)
#
#          curl https://get.ligerosmart.com | BRANCH=dev sh
#
#     Branch mariadb (compose with MariaDB as database service) and project name myproject
#
#          curl https://get.ligerosmart.com | BRANCH=mariadb PROJECT_NAME=myproject sh
#
# ENVIRONMENT FILE
#     You can also create an .env file and in the same directory the stack will be created with the information from this file
#
#          echo "PROJECT_NAME=newproject" > .env
#          curl https://get.ligerosmart.com | sh
#
# Have fun!
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
export BRANCH=${BRANCH:-main}
export PROJECT_NAME=${PROJECT_NAME:-ligerosmart-stack}
export WEBSERVER_FQDN=${WEBSERVER_FQDN:-`hostname -f`}
export ACME_EMAIL
installation_only=${installation_only:-0}

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

## Kernel config
sysctl -w vm.max_map_count=262144
echo 'vm.max_map_count=262144' > /etc/sysctl.d/elasticsearch.conf
sysctl -w vm.overcommit_memory=1
echo 'vm.overcommit_memory=1' > /etc/sysctl.d/redis.conf

if [ "$installation_only" = "1" ]; then 
    exit 0; 
fi;

# Stack repository
git clone --branch=$BRANCH https://github.com/LigeroSmart/ligerosmart-stack $PROJECT_NAME || true
cd $PROJECT_NAME

# show cmd versions
docker -v
docker-compose -v

# force pull images
docker compose pull

# download and run at first time 
docker compose up -d

# stack info
cat README.md
echo ""
echo "-----------------------------------------------------------------------------------------------------------"
echo ""
# environment info
echo "Environment information:"
echo "   Project name: $PROJECT_NAME"
echo "         Branch: $BRANCH"
echo "      Directory: $(pwd)"
echo "Services status:"
docker-compose ps
