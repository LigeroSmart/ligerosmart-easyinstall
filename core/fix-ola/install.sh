#!/bin/bash
#
# curl https://get.ligerosmart.com/core/fix-ola/ | bash
# 

set -e

cd /opt/otrs

git config --global user.email "otrs@localhost"

curl https://raw.githubusercontent.com/LigeroSmart/ligerosmart-easyinstall/main/core/fix-ola/0001-fix-OLA-Suspend.patch > /tmp/0001-fix-OLA-Suspend.patch

git apply /tmp/0001-fix-OLA-Suspend.patch

git add Kernel/System/GenericAgent/SetSolutionTimeField.pm
git add Kernel/System/Ticket/TicketExtensionsStopEscalation.pm
git add var/httpd/htdocs/js/Complemento.TicketEscalation.js

git commit -m "fix: OLA Suspend"
