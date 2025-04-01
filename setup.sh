#!/bin/bash

set -e

mydomain=$1
 
OK="\n 👌: "$(tput setaf 2) 	# green
ERR="\n 💩: "$(tput setaf 1) 	# red
WARN="\n ⚠️: "$(tput setaf 3) 	# yellow
INFO="\n 👣: "$(tput setaf 4) 	# blue
NC=$(tput sgr0)"\n"  		# unset
BELL=$(tput bel)  				# play a bell

 
if [ -z ${mydomain+x} ] || [ "$mydomain" = "MyLovelyOpencart.site" ] ; then 
 printf "${ERR}Script will terminate, because you need to set YOUR own domain as parameter ${NC}" || exit 1 
else 
  printf "${OK}Domain is set to '$mydomain'${NC}"
fi
 
# accordingly to https://www.digitalocean.com/community/tools/nginx?global.security.securityTxt=true&global.logging.errorLogEnabled=true&global.logging.logNotFound=true

# Navigate to your NGINX configuration directory on your server:
cd /etc/nginx
printf "${INFO}Creating a backup of your current NGINX configuration${NC}"
# tar --exclude='nginx*.tar.gz'  -czf nginx_$(date +'%F_%H-%M-%S').tar.gz nginx.conf sites-available/ sites-enabled/ nginxconfig.io/ conf.d/ modules-available/ modules-enabled/ snippets/
tar --exclude='nginx*.tar.gz'  -czf nginx_all_$(date +'%F_%H-%M-%S').tar.gz /etc/nginx/


curl -o nginx-opencart-setup.zip -fSL "https://github.com/radiocab/nginx-opencart-setup/archive/refs/heads/main.zip"  
# unzip nginx-opencart-setup.zip | xargs -I {} -0 chmod 0644 {}
# sed "s|\$ROOT|${HOME}|g" abc.sh
sudo apt-get install unzip

# unzip -o nginx-opencart-setup.zip | grep 'inflating:' | sed 's/^.*: //'
echo "mydomain is set to $mydomain"
unzip -o nginx-opencart-setup.zip | grep 'inflating:' | sed 's/^.*: //' | sed 's/^[ ]*//;s/[ ]*$//' | xargs -d $'\n' sh -c 'for arg do chmod 0644 "./$arg"; sed -i "s/example.com/'$mydomain'/g" "./$arg"; done' _
rm nginx-opencart-setup.zip


(cd ./nginx-opencart-setup-main && tar c .) | (cd . && tar xf -)

 
rm -r ./nginx-opencart-setup-main
#rmdir ./nginx-opencart-setup-main

mv ./sites-available/example.com.conf ./sites-available/$mydomain.conf
ln -sf ../sites-available/$mydomain.conf ./sites-enabled/$mydomain.conf

# mv ./sites-available/example.com.cert.available.conf ./sites-available/$mydomain.cert.available.conf

#  RENAMED mv ./conf.d/opencart.example.com.conf ./conf.d/opencart.$mydomain.conf

printf "${INFO}Running all steps${NC}" 
chmod a+x ./ssl-init.sh && source ./ssl-init.sh
chmod a+x ./certbot.sh && source ./certbot.sh
chmod a+x ./check-conf.sh && source ./check-conf.sh

printf "${OK} All Setup scripts ended without errors${NC}"