#!/bin/bash

set -e
  
mydomain=$1  # e.g.reallymydomain.site

# accordingly to 
#  https://stackoverflow.com/questions/67252779/check-if-nginx-config-test-is-sucessfull-as-condition-for-bash-if 


if out=$(sudo nginx -t 2>&1); then
    printf "${OK} Configuration was successful${NC}" | sudo systemctl reload nginx
else
    printf "${BELL}${ERR} Configuration failure, because: $out ${NC}" && exit 1
fi
printf "\n\n\n"
# if out=$(sudo nginx -t 2>&1); then echo "Configuration was successful" | sudo systemctl reload nginx; else echo "Configuration failure, because: $out"; fi

printf "${INFO} Creating base html directory /var/www/$mydomain/public ${NC}"
mkdir -p /var/www/$mydomain/public
printf "${INFO} Coping under-construction.html into base html directory${NC}"
mv ./under-construction.html /var/www/$mydomain/public/under-construction.html
printf "${OK} Check-conf script ended without errors${NC}"