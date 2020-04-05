#!/bin/sh

# LigeroSmart for linux
#
# Using this command to run the script:
#
# curl https://get.ligerosmart.com | sh


get_distribution() {
	lsb_dist=""
	if [ -r /etc/os-release ]; then
		lsb_dist="$(. /etc/os-release && echo "$ID")"
	fi
	echo "$lsb_dist"
}

lsb_dist=$( get_distribution )
lsb_dist="$(echo "$lsb_dist" | tr '[:upper:]' '[:lower:]')"

command -v apt-get > /dev/null && pkg_mgmt=apt
command -v yum > /dev/null && pkg_mgmt=yum

set -e

case "$pkg_mgmt" in
        apt)
            apt-get update
            apt-get install -y -qq --no-install-recommends \
                git \
                python3-pip
        ;;

        yum)
            yum install -y -q \
                git \
                python3-pip
        ;;

        *)
            echo "Installation on $lsb_dist not implemented yet."
            exit 1;
        ;;
esac

# Install

## docker 
curl -fsSL https://get.docker.com | sh

## docker-compose
pip3 install docker-compose


# Kernel config

## elasticsearch
sysctl -w vm.max_map_count=262144
echo 'sysctl -w vm.max_map_count=262144' > /etc/sysctl.d/elasticsearch.conf

# Stack repository
git clone https://github.com/LigeroSmart/ligerosmart-stack

cd ligerosmart-stack

# info
cat README.md
docker -v
docker-compose -v
