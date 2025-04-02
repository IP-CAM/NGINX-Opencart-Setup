#!/bin/sh

set -e
echo \n4

mydomain=$1    # e.g.reallymydomain.site
if [ -z ${mydomain+x} ] || [ "$mydomain" = "reallymydomain.site" ] ; then 
 printf "${ERR}You need to set YOUR own domain as first argument. Exiting..${NC}" && exit 1 
fi
printf "${OK}Domain is set to '$mydomain'\n${NC}\n"
 
releaseurl=$2  # e.g. 'https://github.com/opencart/opencart/releases/download/3.0.3.2/opencart-3.0.3.2.zip'
if  [ -z ${releaseurl+x} ] ; then releaseurl='https://github.com/opencart/opencart/releases/download/3.0.4.0/opencart-3.0.4.0.zip'; fi
printf "${OK}Release url is set to '$releaseurl'\n${NC}\n"

releaseroot=$3 # e.g. 'upload-3040' 
if  [ -z ${releaseroot+x} ] ; then releaseroot='upload'; fi
printf "${OK}Release root is set to '$releaseroot'\n${NC}\n"

webroot=/var/www/$mydomain/public
printf "${OK}Web root is  '$webroot'\n${NC}\n"


################################
#      Install Opencart        #
################################

mkdir -p tmp && cd tmp
curl -o oc.zip -fSL $releaseurl
unzip -o -q oc.zip
rm oc.zip;
#mv -f ./$releaseroot/* $webroot/
(cd ./$releaseroot && tar c .) | (cd $webroot && tar xf -)

cd ..
mv  $webroot/config-dist.php $webroot/config.php
mv  $webroot/admin/config-dist.php $webroot/admin/config.php
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


printf "\n
#######################################################
 👣 Now visit https://$mydomain and you should be taken to the installer page. 
 Follow the on screen instructions.\n
 👣 Don't forget to delete your installation directory after installation!:
    sudo rm -r $webroot/install\n
 👣 Also  It is very important that you move the storage directory 
 outside of the web directory to /var/www/$mydomain/storage by default
#######################################################\n\n"
mkdir -p /var/www/$mydomain/storage && chmod 0777 /var/www/$mydomain/storage
mkdir -p /var/www/$mydomain/storage/logs && chmod 0777 /var/www/$mydomain/storage/logs
mkdir -p /var/www/$mydomain/storage/cache && chmod 0777 /var/www/$mydomain/storage/cache

  #sudo chmod g+w /var/www -R
  #sudo chown -R www-data:www-data /var/www/
