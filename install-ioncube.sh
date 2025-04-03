#!/bin/sh

set -e

  
# ionCube loader based on https://wetopi.com/install-ioncube-loader/  :
iontar=ioncube_loaders_lin_x86-64.tar.gz
curl -o $iontar -fSL "https://downloads.ioncube.com/loader_downloads/$iontar"
tar -xzf $iontar
rm $iontar;
extensionsdir="$(php -i | grep 'extension_dir' | grep -o '[^ ]*$')"
phpver="$(php -r 'echo implode(".", array_slice(explode(".", PHP_VERSION),0,2));')"
cp ./ioncube/ioncube_loader_lin_$phpver.so $extensionsdir
confspath="$(php -i | grep 'additional .ini files' | grep -o '[^ ]*$')"
# for php-fpm running creates ini in /etc/php/X.X/fpm/, for php-cli - in /etc/php/X.X/cli/ :
echo "zend_extension=ioncube_loader_lin_$phpver.so" > $confspath/00-ioncube-loader.ini
sudo systemctl restart php$phpver-fpm
php -v
if [ -z "$(php -v | grep 'ionCube PHP Loader')" ] ; then 
 printf "\n\n${ERR}Something goes wrong with ionCube Loader installation. Exiting..\n\n${NC}" && exit 1 
else 
  printf "\n\n${OK}ionCube Loader successfully installed\n\n${NC}"
  rm -rf ioncube
fi
 
#mkdir -p tmp && cd tmp
#curl -o loader-wizard.zip -fSL 'https://www.ioncube.com/loader-wizard/loader-wizard.zip'


# With wizard doesn't work without interventions, so this way was commented out:
#unzip -o -q loader-wizard.zip
#rm loader-wizard.zip;
##mv -f ./$releaseroot/* $webroot/
#(cd ./ioncube && tar c .) | (cd $webroot/install && tar xf -)
#cd ..
#rm -rf tmp

#printf "\n
#######################################################
# 👣 If you plan to use paid Opencart extensions, it is advicable to install also
# the 'ionCube Loader' they mostly use with a Wizard:
#  https://$mydomain/install/loader-wizard.php
# Don't forget to delete loader-wizard.php after installation!:
#######################################################\n\n"  