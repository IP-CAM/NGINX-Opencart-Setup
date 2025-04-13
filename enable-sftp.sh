#!/bin/sh

set -e

# please no multilines and trailing CR(\n) as second argument
tuneconfigfile() {
 echo "Checking config in '$2'"
 sshdcfg="$1"
 # '/etc/ssh/sshd_config'
 touch -a "$1" 
 content=$(<$sshdcfg)
 joined=${content//$'\n'/\\n}
 seton="$2"
 #'Subsystem       sftp    /usr/lib/openssh/sftp-server'
 trimmedseton=$(echo "$seton" | tr -d '\t \n')
 sftpcommentedout=$(echo "$joined" | tr -d '\t '|grep "#""$trimmedseton")
 sftpseton=$(echo "$joined" | tr -d '\t \n'|grep "$trimmedseton")
 if [ "$sftcommentedout" = "" ] && [ "$sftpseton" != "" ]; then 
   echo "Nothing to do: '$2' was already set in '$sshdcfg'"
 else
   echo -e "$seton" >> $sshdcfg
 fi 
}

# see https://sftpcloud.io/learn/sftp/how-to-setup-sftp-server-on-ubuntu-22-04  :
echo "Ensuring your system is up-to-date"
sudo apt update && sudo apt upgrade -y
echo "Installing OpenSSH Server if not yet installed"
sudo apt install openssh-server -y
#$(echo $string | tr -d ' ')
#$(cat '/etc/ssh/sshd_config' | tr -d ' ')
# grep example '/etc/ssh/sshd_config'
# Replace all  \n by \\n
 echo "Configuring SSH for SFTPd"
 sshdcfgfile='/etc/ssh/sshd_config'
 tuneconfigfile "$sshdcfgfile"  'Subsystem       sftp    /usr/lib/openssh/sftp-server'
 
 echo "Lets create a specific SFTP group and user for SFTP access only, without SSH access." 
 echo "Creating a Group for SFTP Users"
 sudo groupadd sftpusers
 echo "Adding a User 'sftpuser' to Be Part of the SFTP Group"
 # https://askubuntu.com/questions/80444/how-to-set-user-passwords-using-passwd-without-a-prompt
 
 sudo apt-get install pwgen -qq >/dev/null
 SFTPUSER_NAME=sftpuser"$(pwgen -1 -s 3)"
 SFTPUSER_NEW_PASSWORD="$(pwgen -1 -s 16)"
 sudo useradd -m -G sftpusers -s /usr/sbin/nologin $SFTPUSER_NAME
 usermod --password $(echo $SFTPUSER_NEW_PASSWORD | openssl passwd -1 -stdin) $SFTPUSER_NAME
 echo "# ===== NEW SFTPUSER NAME          : $SFTPUSER_NAME" >> $HOME/log.txt
 echo "# ===== NEW SFTPUSER_NAME PASSWORD: $SFTPUSER_NEW_PASSWORD" >> $HOME/log.txt
 echo '# =====' >> $HOME/log.txt
 # not use the root user, 
 # especially if you want to give the access credentials to another person.
 echo "Configuring the SFTP Directory"
 # Change the user's home directory to prevent access to the entire file system:
 sudo mkdir -p /home/$SFTPUSER_NAME/sftpfiles
 sudo chown root:root /home/$SFTPUSER_NAME
 sudo chmod 755 /home/$SFTPUSER_NAME
 sudo chown $SFTPUSER_NAME:sftpusers /home/$SFTPUSER_NAME/sftpfiles
 sudo adduser $SFTPUSER_NAME www-data
 echo "Updating SSH Configuration for SFTP Isolation"
 tuneconfigfile "$sshdcfgfile" '# Configuration for SFTP Isolation:'
 tuneconfigfile "$sshdcfgfile" 'Match Group sftpusers'
 tuneconfigfile "$sshdcfgfile" 'ChrootDirectory %h'
 tuneconfigfile "$sshdcfgfile" 'ForceCommand internal-sftp'
 tuneconfigfile "$sshdcfgfile" 'AllowTcpForwarding no' 
 tuneconfigfile "$sshdcfgfile" 'X11Forwarding no'  

# >> /etc/ssh/sshd_config
echo "Restarting the SSH service to apply the changes"
sudo systemctl restart ssh
# Security Considerations:
# Firewall Settings: Ensure your firewall allows SFTP connections (usually on port 22).
# Regular Updates: Keep your server software up-to-date to mitigate vulnerabilities.
# Use SSH Keys: For added security, configure SSH key-based authentication for SFTP users.

printf "\n\n${OK}SFTP server is ready to transfer files\n\n${NC}"
