#!/bin/bash

# example of using arguments to a script
echo "Fist arg is $1"
echo "Second arg is $2"
echo "Total number of arguments is $#" 

# accordingly to https://www.digitalocean.com/community/tools/nginx?global.security.securityTxt=true&global.logging.errorLogEnabled=true&global.logging.logNotFound=true

echo "Generating Diffie-Hellman keys by running this command on your server"
openssl dhparam -out /etc/nginx/dhparam.pem 2048

echo "Creating a common ACME-challenge directory (for Let's Encrypt)"
mkdir -p /var/www/_letsencrypt
chown www-data /var/www/_letsencrypt