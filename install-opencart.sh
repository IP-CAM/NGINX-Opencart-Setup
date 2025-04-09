#!/bin/sh

set -e
 
ls -l `which sh`
# mydomain=$1    # e.g.reallymydomain.site
: ${mydomain:=$1}
: ${sourceurl:=$2}
: ${sourceroot:=$2}



if [ -z ${mydomain+x} ] || [ "$mydomain" = "reallymydomain.site" ] ; then 
 printf "${ERR}You need to set YOUR own domain as first argument. Exiting..${NC}" && exit 1 
fi
printf "${OK}Domain is set to '$mydomain'\n${NC}\n"
 
sourceurl=$2  # e.g. 'https://github.com/opencart/opencart/sources/download/3.0.3.2/opencart-3.0.3.2.zip'
if  [ -z ${sourceurl+x} ] ; then sourceurl='https://github.com/opencart/opencart/releases/download/3.0.4.0/opencart-3.0.4.0.zip'; fi
printf "${OK}source url is set to '$sourceurl'\n${NC}\n"

sourceroot=$3 # e.g. 'upload-3040' 
if  [ -z ${sourceroot+x} ] ; then sourceroot='upload'; fi
printf "${OK}source root is set to '$sourceroot'\n${NC}\n"

webroot=/var/www/$mydomain/public
printf "${OK}Web root is  '$webroot'\n${NC}\n"


################################
#      Install Opencart        #
################################

mkdir -p tmp && cd tmp
curl -o oc.zip -fSL $sourceurl
unzip -o -q oc.zip
rm oc.zip;
#mv -f ./$sourceroot/* $webroot/
(cd ./$sourceroot && tar c .) | (cd $webroot && tar xf -)

cd ..
mv  $webroot/config-dist.php $webroot/config.php
mv  $webroot/admin/config-dist.php $webroot/admin/config.php
# see https://docs.vultr.com/how-to-install-opencart-on-ubuntu-20-04-with-nginx   :
chmod  644 $webroot/config.php
chmod  644 $webroot/index.php
chmod  644 $webroot/admin/config.php
chmod  644 $webroot/admin/index.php
chmod  644 $webroot/system/startup.php
# mv $webroot/admin $webroot/privatemin
rm -rf tmp
#chmod -R 777 $webroot
# see for 0777 cache https://forum.opencart.com/viewtopic.php?t=235006
chmod 0777 $webroot/system/storage/cache/

chmod 0777 $webroot/system/storage/download/
chmod 0777 $webroot/system/storage/logs/
chmod 0777 $webroot/system/storage/modification/
chmod 0777 $webroot/system/storage/session/
chmod 0777 $webroot/system/storage/upload/
chmod 0777 $webroot/system/storage/vendor/
chmod 0777 $webroot/image/
chmod 0777 $webroot/image/cache/
chmod 0777 $webroot/image/catalog/
chmod 0777 $webroot/config.php
chmod 0777 $webroot/admin/config.php



chmod 0777 /var/www/$mydomain
#chmod -R g+w /var/www/$mydomain
chown -R www-data:www-data  /var/www/$mydomain

# mkdir -p /var/www/$mydomain/storage && chmod 0777 /var/www/$mydomain/storage
#mkdir -p /var/www/$mydomain/storage/logs && chmod 0777 /var/www/$mydomain/storage/logs
#mkdir -p /var/www/$mydomain/storage/cache && chmod 0777 /var/www/$mydomain/storage/cache
  
set -e
printf "\n
 👣 You will sure use some paid Opencart extensions, so we will install right now  
    the 'ionCube Loader' they mostly use:\n"	
scripturl='https://raw.githubusercontent.com/radiocab/nginx-opencart-setup/refs/heads/main/install-ioncube.sh'	
scriptname="${scripturl##*/}"
random=$scriptname."$(pwgen -1 -s 5)"

curl -s $scripturl  -o $random
chmod a+x ./$random
echo "running $random ..."
source ./$random 
echo "exited $random !"
rm -f $random
printf "\n'ionCube Loader' installed\n"
 

printf "\n
#######################################################
 👣 Now visit https://$mydomain and you should be taken to the installer page. 
 Follow the on screen instructions.\n
 👣 Do not forget to delete your installation directory after installation!:
    sudo rm -r $webroot/install\n
 👣 Also  It is very important that you move the storage directory 
 outside of the web directory to /var/www/$mydomain/storage by default
#######################################################\n\n"  