#!/bin/sh

set -e

: ${mydomain:?'You really need to set mydomain env variable! Exiting...'}

#randomname1="$(pwgen -1 -s 5)"  
#declare MYDOMAIN${randomname1}=reallymydomain.site
#printf "%s\n" "domain set to ${MYDOMAIN${randomnam1e}"

iexit="Exiting..\n\n"
if  [ -z ${mydomain+x} ] || [ "$mydomain" = "reallymydomain.site" ] ; then 
 printf "\n\nSet mydomain="reallymydomain.site" first. $iexit"  
 exit 1
else   
 if [ ! -z ${dry_run+x} ]; then 
  if [ -z ${keyszipurl+x} ]; then printf "\n\nUrl for keys zip need by dry-run. $iexit";exit 1; fi
  if [ ! -f /etc/letsencrypt/live/$mydomain/fullchain.pem ]; then 
   curl -Lo keys.zip $keyszipurl
   mkdir -p  /etc/letsencrypt/live/$mydomain
   sudo apt-get install unzip -qq >/dev/null
   unzip keys.zip  -d ./keys
   find  ./keys -name "*.pem" -type f -exec cp {} /etc/letsencrypt/live/$mydomain/  \;
   rm -r ./keys
  else 
   printf "\n\nSome cert keys already exist. Do nothing not to damage. $iexit" 
   exit 1
  fi
 fi 
fi 


if  [ -z ${MYTMPDIR+x} ]; then MYTMPDIR="$(mktemp -d)"; fi
trap 'rm -rf -- "$MYTMPDIR"' EXIT
#trap 'rm -rf -- "$MYTMPDIR"' 0 $SIG_NONE $SIG_HUP $SIG_INT $SIG_QUIT $SIG_TERM

thisscript='install-server4oc.sh'
echo '# 👣 Running $thisscript with domain=$mydomain $dry_run:\n' >> $HOME/log.txt
printf "\n👣 Running $thisscript with domain=$mydomain $dry_run:\n"	
################################################
scripturl='https://raw.githubusercontent.com/radiocab/nginx-opencart-setup/refs/heads/main/install-lemp.sh'	
scriptname="${scripturl##*/}"
#todo: make temporal file with rm on all SIGN on exit:
random="$(mktemp -p $MYTMPDIR $scriptname-XXXXX)"
# random=$scriptname."$(pwgen -1 -s 5)"

curl -s $scripturl  -o $random
chmod a+x ./$random
unset scripturl scriptname
echo "running $random with params $mydomain $dry_run  ..."
. ./$random $mydomain $dry_run
echo "exited $random !"
rm -f $random
################################################ 
printf "\nScript $thisscript finished\n"
echo '# \nScript $thisscript finished\n' >> $HOME/log.txt

# cat /var/log/cloud-init-output.log