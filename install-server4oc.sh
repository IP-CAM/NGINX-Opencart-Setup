#!/bin/sh

set -e

: ${mydomain:?You really need to set mydomain env variable! Exiting...}

#randomname1="$(pwgen -1 -s 5)"  
#declare MYDOMAIN${randomname1}=reallymydomain.site
#printf "%s\n" "domain set to ${MYDOMAIN${randomnam1e}"


if  [ -z ${mydomain+x} ] || [ "$mydomain" = "reallymydomain.site" ] ; then 
 printf "\n\nSet mydomain="reallymydomain.site" first. Do nothing..\n\n"  
 exit 1
else   
 if [ ! -z ${dry_run+x} ]; then
  if [ ! -f /etc/letsencrypt/live/$mydomain/fullchain.pem ]; then 
   curl -Lo keys.zip $gistkeyszip
   mkdir -p  /etc/letsencrypt/live/$mydomain
   sudo apt-get install unzip --qq >/dev/null
   unzip keys.zip  -d ./keys
   find  ./keys -name "*.pem" -type f -exec cp {} /etc/letsencrypt/live/$mydomain/  \;
   rm -r ./keys
  else 
   printf "\n\nSome cert keys already exist. Do nothing not to damage\n\n" 
   exit 1
  fi
 fi 
fi 

################################################
# curl https://raw.githubusercontent.com/radiocab/nginx-opencart-setup/refs/heads/main/install-lemp.sh | bash -s -- $mydomain --dry-run
thisscript='install-server4oc.sh'
echo '# 👣 Running $thisscript with domain=$mydomain $dry_run:\n' >> $HOME/log.txt
printf "\n👣 Running $thisscript with domain=$mydomain $dry_run:\n"	
scripturl='https://raw.githubusercontent.com/radiocab/nginx-opencart-setup/refs/heads/main/install-lemp.sh'	
scriptname="${scripturl##*/}"
random=$scriptname."$(pwgen -1 -s 5)"

curl -s $scripturl  -o $random
chmod a+x ./$random
echo "running $random with params $mydomain $dry_run  ..."
. ./$random $mydomain $dry_run
echo "exited $random !"
rm -f $random
printf "\nScript $thisscript finished\n"
echo '# \nScript $thisscript finished\n' >> $HOME/log.txt
################################################ 

# cat /var/log/cloud-init-output.log