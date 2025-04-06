#!/bin/sh

set -e 

#echo "# arguments start-runner called with ---->  ${@}"

randomtmp=tmp-"$(pwgen -1 -s 5)"
mkdir -p $randomtmp && cd $randomtmp
curl -o oc-setup.zip -fSL https://github.com/radiocab/nginx-opencart-setup/archive/refs/heads/main.zip
unzip -o -q oc-setup.zip
rm oc-setup.zip;
(cd ./nginx-opencart-setup-main && tar c .) | (cd ./ && tar xf -)

set +e
# Propagate all my arguments to runner script:
source ./runner.sh "$@"
set -e

cd ..
rm -r $randomtmp