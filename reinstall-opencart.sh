#!bin/sh
 
set -e 

 if [ -z ${INCLUDESARELOADED+x} ]; then  
. ./includes.sh # also sets colors and print header message here by include
fi

scriptname='reinstall-opencart.sh'

check_mydomain_set

set_dbreqs
# check_dbreqs() {
 if [ -z ${dbrootpassword+x} ] ; then printf "${ERR}You need to set DB-root password. Exiting..${NC}" && exit 1 ; fi
 if [ -z ${dbrootusername+x} ] ; then printf "${WARN}will try with DB-root user name 'root'.${NC}";dbrootusername='root'; fi
# }

set_opencart_source
# check_opencart_source() {
 if [ -z ${sourceurl+x} ] ; then  printf "${ERR}You need to set source URL sourceurl. Exiting..${NC}" && exit 1 ; fi
 if [ -z ${sourceroot+x} ] ; then  printf "${ERR}You need to set YOUR own domain. Exiting..${NC}" && exit 1 ; fi
# }

if [ -z ${db2drop+x} ] ; then printf "${WARN}No previous DB and DB-USER will be dropped'.${NC}"; fi

# webroot=/var/www/$mydomain/public

if [ ! -z ${db2drop+x} ] ; then 
 # printf "dbrootusername=$dbrootusername , dbrootpassword=$dbrootpassword--"
 printf "$(date '+%F - %T') - Dropping old Opencart database '${db2drop}' and user '${user2drop}'@'localhost' first.\n" | tee -a $HOME/log.txt
 sudo mysql -u $dbrootusername -p$dbrootpassword -e "
  DROP USER IF EXISTS '$user2drop'@'localhost';
  DROP DATABASE IF EXISTS $db2drop;
  FLUSH PRIVILEGES;"
fi
echo -e "$(date "+%F - %T") - Creating Opencart database." | tee -a $HOME/log.txt
echo "$(date "+%F - %T") - Generating Opencart user,password and DB name." | tee -a $HOME/log.txt
OPENCART_USER_NAME="admin$(pwgen -1 -s 2)"
OPENCART_USER_PASS="$(pwgen -1 -s 16)" 
OPENCART_DATABASE="db$(pwgen -1 -s 2)"
sudo mysql -u $dbrootusername -p$dbrootpassword -e \
  "
  CREATE DATABASE $OPENCART_DATABASE;
  CREATE USER '$OPENCART_USER_NAME'@'localhost' IDENTIFIED BY '$OPENCART_USER_PASS';
  GRANT ALL PRIVILEGES on $OPENCART_DATABASE.* TO '$OPENCART_USER_NAME'@'localhost' IDENTIFIED BY '$OPENCART_USER_PASS' WITH GRANT OPTION;
  FLUSH PRIVILEGES;
 "
echo -e '\n' >> $HOME/log.txt
echo '# ============ OPENCART USER PASSWORD AND NAME============' >> $HOME/log.txt
echo '# =====' >> $HOME/log.txt
echo "# ===== OPENCART USER PASSWORD: $OPENCART_USER_PASS" >> $HOME/log.txt
echo "# ===== OPENCART USER NAME: $OPENCART_USER_NAME" >> $HOME/log.txt
echo "# ===== OPENCART DATABASE NAME: $OPENCART_DATABASE" >> $HOME/log.txt
echo '# =====' >> $HOME/log.txt
  
#curl -s https://raw.githubusercontent.com/radiocab/nginx-opencart-setup/refs/heads/main/install-opencart.sh | bash -s -- $mydomain $sourceurl $sourceroot
 
datetime=$(date "+%F@%T")
cp -a $webroot/. $webroot-saved-$datetime/ || true
rm -r $webroot/* || true
 
cp -a /var/www/$mydomain/storage/. /var/www/$mydomain/storage-saved-$datetime/ || true 
rm -r /var/www/$mydomain/storage/ || true 
 
scripturl='https://raw.githubusercontent.com/radiocab/nginx-opencart-setup/refs/heads/main/install-opencart.sh'
scriptname="${scripturl##*/}"
random=$scriptname."$(pwgen -1 -s 5)"
 
curl -s $scripturl  -o $random
chmod a+x ./$random
echo "Running $random ...."
source ./$random $mydomain $sourceurl $sourceroot 
echo "Exited $random !"
rm -f $random

if [ ! -z ${cliinstall+x} ] ; then 
 cd $webroot/install/
 php $webroot/install/cli_install.php install    \
  --db_hostname 'localhost' \
  --db_username $dbrootusername \
  --db_password $dbrootpassword \
  --db_database $OPENCART_DATABASE \
  --db_driver 'mysqli' \
  --db_port '3306' \
  --username $OPENCART_USER_NAME \
  --password $OPENCART_USER_PASS \
  --email 'youremail@change.me.later' \
  --http_server "http://$mydomain/"
 # returns back to prev dir:
 cd -
fi

# /var/www/gsm-radio.ru/public/system/storage
#cp -a $webroot/system/storage/. /var/www/$mydomain/storage/
#rm -r $webroot/system/storage/ || true
 
footermsg 
printf "${OK}${BELL} 
  *      OPENCART SERVER IS READY!!! 
  * We have reached end of installation with 'set -e' restriction, so all seems to be OK
  * You can access through your domain name '$mydomain' or public ip address.${NC}"
