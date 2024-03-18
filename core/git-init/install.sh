#!/bin/bash
#
# curl https://get.ligerosmart.com/core/git-init/ | bash
#

git config --global user.email "otrs@ligerosmart"

git init

curl https://get.ligerosmart.com/core/fix-gitignore/ | bash