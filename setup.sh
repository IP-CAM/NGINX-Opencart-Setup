#!/bin/bash

# example of using arguments to a script
echo "Fist arg is $1" && mydomain=$1
# echo "Second arg is $2"
echo "Total number of arguments is $#" 
if [ -z ${mydomain+x} ]; then echo "mydomain is unset and will be set to test123.com" &&  mydomain="test123.com"; else echo "mydomain is set to '$mydomain'"; fi

# accordingly to https://www.digitalocean.com/community/tools/nginx?global.security.securityTxt=true&global.logging.errorLogEnabled=true&global.logging.logNotFound=true

# Navigate to your NGINX configuration directory on your server:
cd /etc/nginx
# Create a backup of your current NGINX configuration:
tar -czvf nginx_$(date +'%F_%H-%M-%S').tar.gz nginx.conf sites-available/ sites-enabled/ nginxconfig.io/ conf.d/ modules-available/ modules-enabled/ snippets/
tar -czvf nginx_all_$(date +'%F_%H-%M-%S').tar.gz /etc/nginx/


curl -o nginx-opencart-setup.zip -fSL "https://github.com/radiocab/nginx-opencart-setup/archive/refs/heads/main.zip"  
# unzip nginx-opencart-setup.zip | xargs -I {} -0 chmod 0644 {}
# sed "s|\$ROOT|${HOME}|g" abc.sh
sudo apt-get install unzip
unzip -o nginx-opencart-setup.zip | grep -o "inflating.*" | xargs -d $'\n' sh -c 'for arg do chmod 0644 "$arg"; sed -i "s/example.com/${mydomain}/g" "$arg"; done' _
rm nginx-opencart-setup.zip


ln -s /sites-available/example.com.conf /sites-enabled/$mydomain.conf

# Make scripts executable
#chmod a+x ./ssl-init.sh
#chmod a+x ./certbot.sh
chmod a+x ./check-conf.sh && source ./check-conf.sh
