#!/bin/sh

# LigeroSmart for linux

get_distribution() {
	lsb_dist=""
	if [ -r /etc/os-release ]; then
		lsb_dist="$(. /etc/os-release && echo "$ID")"
	fi
	echo "$lsb_dist"
}

lsb_dist=$( get_distribution )
lsb_dist="$(echo "$lsb_dist" | tr '[:upper:]' '[:lower:]')"

set -e

case "$lsb_dist" in
		ubuntu|debian|raspbian)
            apt-get update
            apt-get install -y -qq --no-install-recommends \
                git \
                python3-pip
        ;;

		centos|fedora)
            yum install -y -q \
                git \
                python3-pip
        ;;

		*)
			if command_exists lsb_release; then
				dist_version="$(lsb_release --release | cut -f2)"
			fi
			if [ -z "$dist_version" ] && [ -r /etc/os-release ]; then
				dist_version="$(. /etc/os-release && echo "$VERSION_ID")"
			fi

            echo "Installation on $dist_version not implemented yet"
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
