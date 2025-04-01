#!/bin/bash
 
   
mydomain=$1

# accordingly to https://www.digitalocean.com/community/tools/nginx?global.security.securityTxt=true&global.logging.errorLogEnabled=true&global.logging.logNotFound=true

printf "${INFO}Generating Diffie-Hellman keys. Please wait about 10 seconds..${NC}"
openssl dhparam -out /etc/nginx/dhparam.pem 2048 &>/dev/null

printf "${INFO}Creating a common ACME-challenge directory (for Let's Encrypt)${NC}"
mkdir -p /var/www/_letsencrypt
chown www-data /var/www/_letsencrypt