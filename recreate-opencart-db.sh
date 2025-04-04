#!bin/sh
 
set -e 

OK=$(tput setaf 2)"\n 👌: " 	# green
ERR=$(tput setaf 1)"\n 💩: " 	# red
WARN=$(tput setaf 3)"\n 👽: " 	# yellow
INFO=$(tput setaf 4)"\n 👣: " 	# blue
NC=$(tput sgr0)"\n"  		# unset
BELL=$(tput bel)  		# play a bell
 
mydomain=$1
if [ -z ${mydomain+x} ] ; then  printf "${ERR}You need to set YOUR own domain mydomain. Exiting..${NC}" && exit 1 ; fi
releaseurl=$2
if [ -z ${releaseurl+x} ] ; then  printf "${ERR}You need to set release URL releaseurl. Exiting..${NC}" && exit 1 ; fi
releaseroot=$3
if [ -z ${releaseroot+x} ] ; then  printf "${ERR}You need to set YOUR own domain. Exiting..${NC}" && exit 1 ; fi
dbrootpassword=$4
if [ -z ${dbrootpassword+x} ] ; then  printf "${ERR}You need to set DB-root password. Exiting..${NC}" && exit 1 ; fi
dbrootusername=$5
if [ -z ${dbrootusername+x} ] ; then printf "${WARN}will try with DB-root user name 'root'.${NC}";dbrootusername='root'; fi
db2drop=$6
if [ -z ${db2drop+x} ] ; then printf "${WARN}No previous DB and DB-USER will be dropped'.${NC}"; fi
user2drop=$7

webroot=/var/www/$mydomain/public

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
  
#curl -s https://raw.githubusercontent.com/radiocab/nginx-opencart-setup/refs/heads/main/install-opencart.sh | bash -s -- $mydomain $releaseurl $releaseroot
 
datetime=$(date "+%F@%T")
cp -a $webroot/. $webroot-saved-$datetime/
rm -r $webroot/* || true
 
cp -a /var/www/$mydomain/storage/. /var/www/$mydomain/storage-saved-$datetime/
rm -r /var/www/$mydomain/storage/* || true 
 
scripturl=https://raw.githubusercontent.com/radiocab/nginx-opencart-setup/refs/heads/main/install-opencart.sh
scriptname="${scripturl##*/}"
random=scriptname."$(pwgen -1 -s 5)"

curl -s $scripturl  -o $random
chmod a+x ./$random
echo "running $random"
source ./$random $mydomain $releaseurl $releaseroot 
echo "exited $random"
rm -f $random


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

printf "${OK}${BELL} 
 *      OPENCART SERVER IS READY!!! 
 * We have reached end of installation with 'set -e' restriction, so all seems to be OK
 * Installation details in $HOME/log.txt
 * DO NOT DELETE THIS FILE BEFORE COPYING THE DATA
 * You can access through your domain name '$1' or public ip address.${NC}"
