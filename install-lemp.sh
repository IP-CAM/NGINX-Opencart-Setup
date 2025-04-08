#!bin/sh

ls -l `which sh`

mydomain=$1

OK=$(tput setaf 2)"\n 👌: " 	# green
ERR=$(tput setaf 1)"\n 💩: " 	# red
WARN=$(tput setaf 3)"\n 👽: " 	# yellow
INFO=$(tput setaf 4)"\n 👣: " 	# blue
NC=$(tput sgr0)"\n"  			# unset
BELL=$(tput bel)  				# play a bell

startinstall() {
  echo -e "${INFO} * Starting installation... ${NC}"
  touch $HOME/log.txt
  echo "Unattended installation of LEMP Server for Opencart" | tee -a $HOME/log.txt
}

# Update repository and install latest packages.
updateupgrade() {
  echo "$(date "+%F - %T") - Update the list of repositories..." | tee -a $HOME/log.txt
  sudo apt-get -y -qq update
  echo "$(date "+%F - %T") - Installing latest packages..." | tee -a $HOME/log.txt
  sudo apt-get -y -qq upgrade
  echo "$(date "+%F - %T") - Installing pwgen password generator." | tee -a $HOME/log.txt
  sudo apt-get install -qq pwgen curl unattended-upgrades
}
    
# Install NGINX web server.
installnginx() {
  echo "$(date "+%F - %T") - Installing NGINX." | tee -a $HOME/log.txt
  sudo apt-get -qq install nginx
}

# Install PHP modules.
installphp() {
  # Opencart requirement : Please make sure the PHP extensions listed below are installed:
  # Database  GD  cURL  OpenSSL  ZLIB	ZIP	 DOM/XML Hash XMLWriter	JSON
  
  # install php-fpm first to not install occidentally apache2 with php: 
  #  https://serverfault.com/questions/1009961/why-does-the-command-apt-install-php-try-to-install-apache
  sudo apt-get -qq install php-fpm
  sudo apt-get -qq install php php-mysql \
  php-common php-cli php-opcache php-readline \
  php-mbstring php-gd php-zip php-curl php-xml
  # php-json php-dom 

  
  
################################################
#  bash <(curl -s https://raw.githubusercontent.com/radiocab/nginx-opencart-setup/refs/heads/main/tune_php_ini.sh)
echo '# 👣 Running tune_php_ini.sh:\n' >> $HOME/log.txt
printf "\n
 👣 Running tune_php_ini.sh:\n"	
scripturl='https://raw.githubusercontent.com/radiocab/nginx-opencart-setup/refs/heads/main/tune_php_ini.sh'	
scriptname="${scripturl##*/}"
random=$scriptname."$(pwgen -1 -s 5)"

curl -s $scripturl  -o $random
chmod a+x ./$random
echo "running $random ..."
. ./$random $mydomain $2
echo "exited $random !"
rm -f $random
printf "\nScript tune_php_ini.shh finished\n"
echo '# \nScript tune_php_ini.sh finished\n' >> $HOME/log.txt
################################################
  
  echo "$(date "+%F - %T") - Installing PHP modules." | tee -a $HOME/log.txt
 }

# Install MariaDB Server.
# Generate key for root user.
# Remove anonymous users, remove remote access and delete 'test' database if exists.
installconfigmariadb() {
  DB_ROOT_NAME='root'
  echo "$(date "+%F - %T") - Installing MariaDB." | tee -a $HOME/log.txt
  sudo apt-get install -qq mariadb-server

  echo "$(date "+%F - %T") - Generating root password for MariaDB." | tee -a $HOME/log.txt
  DB_ROOT_PASS="$(pwgen -1 -s 16)"
  
  echo "$(date "+%F - %T") - Setting root password for MariaDB." | tee -a $HOME/log.txt
  sudo mysql -e "UPDATE mysql.global_priv SET priv=json_set(priv, '$.plugin', \
    'mysql_native_password', '$.authentication_string', \
    PASSWORD('$DB_ROOT_PASS')) WHERE User='$DB_ROOT_NAME';"

  echo "$(date "+%F - %T") - Applying privileges to MariaDB root user." | tee -a $HOME/log.txt    
  sudo mysql -e "FLUSH PRIVILEGES;"  

  echo "$(date "+%F - %T") - Deleting anonymous users in MariaDB." | tee -a $HOME/log.txt
  sudo mysql -u $DB_ROOT_NAME -p$DB_ROOT_PASS -e "DELETE FROM mysql.user WHERE User='';"
  echo "$(date "+%F - %T") - Removing remote access to databases." | tee -a $HOME/log.txt
  sudo mysql -u $DB_ROOT_NAME -p$DB_ROOT_PASS -e "DELETE FROM mysql.user WHERE User='$DB_ROOT_NAME' AND Host NOT IN ('localhost', '127.0.0.1', '::1');"
  echo "$(date "+%F - %T") - Deleting test database." | tee -a $HOME/log.txt
  sudo mysql -u $DB_ROOT_NAME -p$DB_ROOT_PASS -e "DROP DATABASE IF EXISTS test;"
  sudo mysql -u $DB_ROOT_NAME -p$DB_ROOT_PASS -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';"

  echo "$(date "+%F - %T") - Creating Opencart database." | tee -a $HOME/log.txt
  echo "$(date "+%F - %T") - Generating Opencart user,password and DB name." | tee -a $HOME/log.txt
  OPENCART_USER_PASS="$(pwgen -1 -s 16)" 
  OPENCART_USER_NAME="admin"
  OPENCART_DATABASE="db$(pwgen -1 -s 2)"
  sudo mysql -u $DB_ROOT_NAME -p$DB_ROOT_PASS -e "CREATE DATABASE $OPENCART_DATABASE;
      CREATE USER '$OPENCART_USER_NAME'@'localhost' IDENTIFIED BY '$OPENCART_USER_PASS';
      GRANT ALL PRIVILEGES on $OPENCART_DATABASE.* TO '$OPENCART_USER_NAME'@'localhost' IDENTIFIED BY '$OPENCART_USER_PASS' WITH GRANT OPTION;"
  
  echo "$(date "+%F - %T") - Applying changes." | tee -a $HOME/log.txt
  sudo mysql -u $DB_ROOT_NAME -p$DB_ROOT_PASS -e "FLUSH PRIVILEGES;"	  
}


# Set rules on the firewall to give access to ssh, http, https.
configfirewall() {
  echo "$(date "+%F - %T") - Setting firewall rules for ports 22, 80 and 443." | tee -a $HOME/log.txt
  sudo ufw default deny incoming
  sudo ufw allow ssh
  sudo ufw allow 80 
  sudo ufw allow 8080  
  sudo ufw allow http
  sudo ufw allow https
  
  
  sudo echo y | sudo ufw enable
  # For Oracle Cloud, comment out the above values and uncomment the following:
  # sudo iptables -I INPUT 6 -m state --state NEW -p tcp --dport 443 -j ACCEPT
  # sudo iptables -I INPUT 6 -m state --state NEW -p tcp --dport 80 -j ACCEPT
  # sudo netfilter-persistent save
}

# Clean installation cache and files that are no longer needed.
finishcleanrestart() {
  echo "$(date "+%F - %T") - Assigning permissions to the web directory." | tee -a $HOME/log.txt
  sudo adduser $USER www-data
  sudo chmod g+w /var/www/$mydomain -R
  sudo chown -R www-data:www-data /var/www/$mydomain
  # echo -e "ServerName localhost" | sudo tee -a /etc/apache2/apache2.conf
  echo "$(date "+%F - %T") - Clearing package cache an restart web service." | tee -a $HOME/log.txt
  sudo apt-get clean
  sudo apt-get autoclean
  sudo systemctl restart nginx
}

startinstall
updateupgrade
installnginx
installphp
installconfigmariadb
configfirewall
finishcleanrestart

sudo apt-get -qq install pwgen
################################################
# curl -s https://raw.githubusercontent.com/radiocab/nginx-opencart-setup/refs/heads/main/setup.sh | bash -s -- $mydomain  $2
echo '# 👣 Running setup.sh:\n' >> $HOME/log.txt
printf "\n
 👣 Running setup.sh:\n"	
scripturl='https://raw.githubusercontent.com/radiocab/nginx-opencart-setup/refs/heads/main/setup.sh'	
scriptname="${scripturl##*/}"
random=$scriptname."$(pwgen -1 -s 5)"

curl -s $scripturl  -o $random
chmod a+x ./$random
echo "running $random ..."
. ./$random $mydomain $2
echo "exited $random !"
rm -f $random
printf "\nScript setup.sh finished\n"
echo '# \nScript setup.sh finished\n' >> $HOME/log.txt
################################################



echo -e '\n' >> $HOME/log.txt
echo '# ============ MARIADB ROOT PASSWORD ============' >> $HOME/log.txt
echo '# =====' >> $HOME/log.txt
echo "# ===== MARIADB ROOT PASSWORD: $DB_ROOT_PASS" >> $HOME/log.txt
echo '# =====' >> $HOME/log.txt

echo -e '\n' >> $HOME/log.txt
echo '# ============ OPENCART USER PASSWORD AND NAME============' >> $HOME/log.txt
echo '# =====' >> $HOME/log.txt
echo "# ===== OPENCART USER PASSWORD: $OPENCART_USER_PASS" >> $HOME/log.txt
echo "# ===== OPENCART USER NAME: $OPENCART_USER_NAME" >> $HOME/log.txt
echo "# ===== OPENCART DATABASE NAME: $OPENCART_DATABASE" >> $HOME/log.txt
echo '# =====' >> $HOME/log.txt

 
printf "${OK}${BELL} 
 *      LEMP SERVER TUNED FOR OPENCART IS READY!!! 
 * We have reached end of installation with 'set -e' restriction, so all seems to be OK
 * Installation details in '$HOME/log.txt'
 * DO NOT DELETE THIS FILE BEFORE COPYING THE DATA
 * You can access through your domain name $1 or public IP address.${NC}"
