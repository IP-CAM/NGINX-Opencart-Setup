#!/bin/bash

# example of using arguments to a script
echo "Fist arg is $1"
echo "Second arg is $2"
echo "Total number of arguments is $#" 

# accordingly to https://www.digitalocean.com/community/tools/nginx?global.security.securityTxt=true&global.logging.errorLogEnabled=true&global.logging.logNotFound=true

# Navigate to your NGINX configuration directory on your server:
cd /etc/nginx
# Create a backup of your current NGINX configuration:
tar -czvf nginx_$(date +'%F_%H-%M-%S').tar.gz nginx.conf sites-available/ sites-enabled/ nginxconfig.io/ conf.d/ modules-available/ modules-enabled/ snippets/
tar -czvf nginx_all_$(date +'%F_%H-%M-%S').tar.gz /etc/nginx/


curl -o nginx-opencart-setup.zip -fSL "https://github.com/radiocab/nginx-opencart-setup/archive/refs/heads/main.zip"
unzip nginx-opencart-setup.zip | xargs chmod 0644
rm nginx-opencart-setup.zip

# Make scripts executable
#chmod a+x ./ssl-init.sh
#chmod a+x ./certbot.sh
chmod a+x ./check-conf.sh | source ./check-conf.sh
