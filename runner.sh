#!/bin/sh

set -e 

randomtmp=tmp-"$(pwgen -1 -s 5)"
mkdir -p $randomtmp && cd $randomtmp
curl -o oc-setup.zip -fSL https://github.com/radiocab/nginx-opencart-setup/archive/refs/heads/main.zip
unzip -o -q oc-setup.zip
rm oc-setup.zip;
(cd ./nginx-opencart-setup-main && tar c .) | (cd ./ && tar xf -)

source ./includes.sh

setcolors
read_args_by_name
source ./$ACTION.sh
footermsg 

cd ..
rm -r $randomtmp
