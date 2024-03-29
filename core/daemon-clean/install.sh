#!/bin/bash
#
# curl https://get.ligerosmart.com/core/daemon-clean/ | bash
# 
# Patch from github
# https://github.com/LigeroSmart/ligerosmart/commit/52035e64feed4dc01a6ab57db2978a17c862ace2.patch

curl https://raw.githubusercontent.com/LigeroSmart/ligerosmart/rel-6_1/var/cron/daemon-clean > $HOME/var/cron/daemon-clean
curl https://raw.githubusercontent.com/LigeroSmart/ligerosmart/rel-6_1/Kernel/System/Console/Command/Maint/Daemon/Clean.pm > $HOME/Kernel/System/Console/Command/Maint/Daemon/Clean.pm

git add $HOME/var/cron/daemon-clean $HOME/Kernel/System/Console/Command/Maint/Daemon/Clean.pm
git commit -m "fix: daemon clean"