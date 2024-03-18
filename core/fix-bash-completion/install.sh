#!/bin/bash
#
# curl https://get.ligerosmart.com/core/fix-bash-completion/ | bash
# 

curl https://raw.githubusercontent.com/LigeroSmart/ligerosmart/rel-6_1/.bash_completion > $HOME/.bash_completion

git add $HOME/.bash_completion
git commit -m "fix: bash_completion"