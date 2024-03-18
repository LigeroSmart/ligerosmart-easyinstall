#!/bin/bash
#
# curl https://get.ligerosmart.com/core/fix-gitignore/ | bash
# 

curl https://raw.githubusercontent.com/LigeroSmart/ligerosmart/rel-6_1/.gitignore > $HOME/.gitignore

git add $HOME/.gitignore
git commit -m "fix: gitignore"