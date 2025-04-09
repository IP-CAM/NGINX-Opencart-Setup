#!/bin/sh

set -e

ls -l `which sh`

echo "\nshell? $SHELL\n" 
: ${mydomain:=$1}
: ${dry_run:=$2}

printf '%s\n' "👣👣👣👣👣👣 Starting in setup.sh with params $*"
printf "👣👣👣👣👣👣 Starting in setup.sh with domain '$mydomain' and option='$2' ...\n"

if sh -c ": >/dev/tty" >/dev/null 2>/dev/null; then
    # /dev/tty is available and usable
 OK=$(tput setaf 2)"\n 👌: " 	# green
 ERR=$(tput setaf 1)"\n 💩: " 	# red
 WARN=$(tput setaf 3)"\n 👽: " 	# yellow
 INFO=$(tput setaf 4)"\n 👣: " 	# blue
 NC=$(tput sgr0)"\n"  		    # unset
 BELL=$(tput bel)  				# play a bell
else
    # /dev/tty is not available
 OK="\n 👌: "  
 ERR="\n 💩: " 
 WARN="\n 👽: " 	 
 INFO="\n 👣: "  
 NC="\n"  		    
 BELL=""  			 
fi
 

printf "\nStep1" 
if [ -z ${mydomain+x} ] || [ "$mydomain" = "reallymydomain.site" ] ; then 
 printf "${ERR}You need to set YOUR own domain as first argument. Exiting..${NC}" && exit 1 
else 
  printf "${OK}Domain is set to '$mydomain'${NC}"
fi
 
 if  [ $# -gt 1 ] && [ "$dry_run" !=  "--dry-run" ] ; then 
  printf "${ERR}Only --dry-run is allowed as second argument (not $2). Exiting..${NC}" && exit 1 
 fi
 
# Further accordingly to
#  https://www.digitalocean.com/community/tools/nginx?global.security.securityTxt=true&global.logging.errorLogEnabled=true&global.logging.logNotFound=true

# Navigate to your NGINX configuration directory on your server:
cd /etc/nginx
mkdir -p /etc/nginx/backups/$mydomain
printf "\nStep2" 
printf "${INFO}Creating a backup of your current NGINX configurations${NC}"
# tar --exclude='nginx*.tar.gz'  -czf nginx_$(date +'%F_%H-%M-%S').tar.gz nginx.conf sites-available/ sites-enabled/ nginxconfig.io/ conf.d/ modules-available/ modules-enabled/ snippets/
tar --exclude='/etc/nginx/backups'  -czf /etc/nginx/backups/$mydomain/nginx_all_$(date +'%F_%H-%M-%S').tar.gz /etc/nginx/

printf "\nStep3" 
rm -f ./sites-enabled/default

printf "${INFO}Downloading nginx-opencart-setup.zip${NC}"
curl -s -o nginx-opencart-setup.zip -fSL \
 "https://github.com/radiocab/nginx-opencart-setup/archive/refs/heads/main.zip"  
# unzip nginx-opencart-setup.zip | xargs -I {} -0 chmod 0644 {}
# sed "s|\$ROOT|${HOME}|g" abc.sh
sudo apt-get install unzip

# unzip -o nginx-opencart-setup.zip | grep 'inflating:' | sed 's/^.*: //'
echo "mydomain is set to $mydomain"
unzip -o nginx-opencart-setup.zip | grep 'inflating:' | sed 's/^.*: //' \
| sed 's/^[ ]*//;s/[ ]*$//' \
| xargs -d$'\n' sh -c 'for arg do chmod 0644 "./$arg"; sed -i "s/example.com/'$mydomain'/g" "./$arg"; done' _

(cd ./nginx-opencart-setup-main && tar c .) | (cd . && tar xf -)

mv ./sites-available/example.com.conf ./sites-available/$mydomain.conf
ln -sf ../sites-available/$mydomain.conf ./sites-enabled/$mydomain.conf

# mv ./sites-available/example.com.cert.available.conf ./sites-available/$mydomain.cert.available.conf

#  RENAMED mv ./conf.d/opencart.example.com.conf ./conf.d/opencart.$mydomain.conf

printf "${INFO}Running all steps${NC}" 
#chmod a+x ./ssl-init.sh && source ./ssl-init.sh
#chmod a+x ./certbot.sh && source ./certbot.sh
#chmod a+x ./check-conf.sh && source ./check-conf.sh
chmod a+x ./ssl-init.sh && . ./ssl-init.sh
chmod a+x ./certbot.sh && . ./certbot.sh
chmod a+x ./check-conf.sh && . ./check-conf.sh

printf "${INFO}Cleaning after all${NC}" 
rm -rf certbot.sh ssl-init.sh setup.sh check-conf.sh
rm -r ./nginx-opencart-setup-main
rm nginx-opencart-setup.zip
 

printf "${OK} All Setup scripts ended without errors${NC}"