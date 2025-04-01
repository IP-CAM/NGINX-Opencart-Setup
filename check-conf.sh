#!/bin/bash

# example of using arguments to a script
echo "Fist arg is $1"
echo "Second arg is $2"
echo "Total number of arguments is $#" 

# accordingly to 
#  https://stackoverflow.com/questions/67252779/check-if-nginx-config-test-is-sucessfull-as-condition-for-bash-if
 
if out=$(sudo nginx -t 2>&1); then
    echo "${OK}Configuration was successful${NC}" | sudo systemctl reload nginx
else
    echo "${ERR}Configuration failure, because: $out ${NC}"
fi

# if out=$(sudo nginx -t 2>&1); then echo "Configuration was successful" | sudo systemctl reload nginx; else echo "Configuration failure, because: $out"; fi

