#!/bin/bash

set -e
  
mydomain=$1

# accordingly to 
#  https://stackoverflow.com/questions/67252779/check-if-nginx-config-test-is-sucessfull-as-condition-for-bash-if 


if out=$(sudo nginx -t 2>&1); then
    printf "${OK}👌: Configuration was successful${NC}" | sudo systemctl reload nginx
else
    printf "${BELL}${ERR}💩: Configuration failure, because: $out ${NC}"
fi
printf "\n\n\n"
# if out=$(sudo nginx -t 2>&1); then echo "Configuration was successful" | sudo systemctl reload nginx; else echo "Configuration failure, because: $out"; fi

mkdir /var/www/$mydomain

rm -rf certbot.sh ssl-init.sh setup.sh check-conf.sh

printf "${INFO} Creating base html directory /var/www/$mydomain ${NC}"
sudo mkdir -p /var/www/$mydomain
printf "${INFO} Coping under-construction.html into base html directory${NC}"
mv ./under-construction.html /var/www/$mydomain/index.html
printf "${OK} Check-conf script ended without errors${NC}"