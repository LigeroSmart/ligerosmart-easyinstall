#!/bin/bash
#
# curl -s https://get.ligerosmart.com/core/fix-ola/ | bash
# 

set -e

#cd /opt/otrs

# Configura user.email apenas se não estiver definido
if [ -z "$(git config --global user.email)" ]; then
    git config --global user.email "otrs@localhost"
fi

# Verifica se o patch já foi aplicado checando se as modificações já estão presentes
if grep -q "Check if current state is in the paused SLA states list" Kernel/System/GenericAgent/SetSolutionTimeField.pm 2>/dev/null && \
   grep -q "Track if any SLA type is paused to set EscalationTimeWorkingTime correctly" Kernel/System/Ticket/TicketExtensionsStopEscalation.pm 2>/dev/null && \
   grep -q "Function to check if a text indicates paused SLA" var/httpd/htdocs/js/Complemento.TicketEscalation.js 2>/dev/null; then
    echo "Patch 'fix: OLA Suspend' já foi aplicado anteriormente."
    exit 0
fi

curl -s https://raw.githubusercontent.com/LigeroSmart/ligerosmart-easyinstall/main/core/fix-ola/0001-fix-OLA-Suspend.patch > /tmp/0001-fix-OLA-Suspend.patch

git apply --whitespace=nowarn /tmp/0001-fix-OLA-Suspend.patch 2>&1 | grep -v "trailing whitespace" | grep -v "whitespace errors" | grep -v "squelched" || true

git add Kernel/System/GenericAgent/SetSolutionTimeField.pm
git add Kernel/System/Ticket/TicketExtensionsStopEscalation.pm
git add var/httpd/htdocs/js/Complemento.TicketEscalation.js

git commit -m "fix: OLA Suspend"
