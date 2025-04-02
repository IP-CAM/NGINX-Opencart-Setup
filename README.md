# nginx-opencart-setup



NGINX setup for OPENCART based on 
[DigitalOcean Recommendations](https://www.digitalocean.com/community/tools/nginx/) 

and on this [discussion](https://github.com/opencart/opencart.github.io/issues/335)

Tested on Ubuntu 20.4


To install just run in terminal 
```shell
curl -s https://raw.githubusercontent.com/radiocab/nginx-opencart-setup/refs/heads/main/setup.sh \
| bash -s -- MyLovelyOpencart.site
```
with your own domain instead of MyLovelyOpencart.site 

Besause Let's Encrypt allows no more than 50 certificates 
to be issued per registered domain per week, for testing 
you can try this script with "dry-run" (then no real certificate will be issued).
 
The dry-run succeed if either the certificate already was once issued on your testing host,
or your need to copy your issued certificate from your previuos domain.
As a hint for the second case: you can download all 3 certificate files from previuos host
(fullchain.pem, chain.pem and privkey.pem) and place them on one 
your secret [GIST](https://gist.github.com) on your github account.
Then you can run on followng command on your testing host terminal to transfer them 
here (obviously, you will have your own URL to your gist's ZIP) : 

```shell

# set your domain like:
# mydomain=reallymydomain.site

# set path to your secret gist's ZIP like:
# gistkeyszip=https://gist.github.com/yourgithubacc/cf5csomefakeurlca5/archive/bc2morefakerurl9g.zip

if  [ -z ${mydomain+x} ] || [ "$mydomain" = "reallymydomain.site" ] ; then 
 printf "\n\nSet mydomain=reallymydomain.site first. Do nothing..\n\n"  
else   
 if [ ! -f /etc/letsencrypt/live/$mydomain/fullchain.pem ]; then 
   curl -Lo keys.zip $gistkeyszip
   mkdir -p  /etc/letsencrypt/live/$mydomain
   unzip keys.zip  -d ./keys
   find  ./keys -name "*.pem" -type f -exec cp {} /etc/letsencrypt/live/$mydomain/  \;
   rm -r ./keys
 else 
  printf "\n\nSome cert keys already exist. Do nothing not to damage\n\n" 
 fi
fi 

rm keys.zip
```

Not forget then to change the A record in DNS to your new IP address for testing host.
 
After that you can try with "dry-run":
 
https://gist.github.com/radiocab/cf5csomefakeurlca5b173e94/archive/bcd255morefakerurl9fd.zip
For "dry-run" of the Letsencrypt bot run in terminal 
```shell
# set your domain like:
# mydomain=reallymydomain.site

curl -s https://raw.githubusercontent.com/radiocab/nginx-opencart-setup/refs/heads/main/setup.sh \
| bash -s -- $mydomain --dry-run
```
with your own domain instead of MyLovelyOpencart.site 


See also start point for all this as [DigitalOcean configuration](https://www.digitalocean.com/community/tools/nginx?global.security.securityTxt=true&global.logging.errorLogEnabled=true&global.logging.logNotFound=true)

To install Opencart into so prepared environment use
```shell
# set your domain like:
# mydomain=reallymydomain.site

# if ommited will install 3.0.4.0:
releaseurl='https://github.com/opencart/opencart/releases/download/3.0.3.2/opencart-3.0.3.2.zip'
curl -s https://raw.githubusercontent.com/radiocab/nginx-opencart-setup/refs/heads/main/install-opencart.sh \
| bash -s -- $mydomain $releaseurl upload-3040
```

If you prepairing LEMP setup from scratch for new server 
(on cloud you can even try this as cloud-init script ) 
you can use for the whole

 - in dry-run case:
```shell
#!/bin/sh


# set your domain like:
# mydomain=reallymydomain.site

# set path to your secret gist's ZIP like:
gistkeyszip=https://gist.github.com/radiocab/cf5c96361b78171b741bc0ca5b173e94/archive/bcd255612af9a4acf27962d33dbc3ad73f5cf9fd.zip

if  [ -z ${mydomain+x} ] || [ "$mydomain" = "reallymydomain.site" ] ; then 
 printf "\n\nSet mydomain="reallymydomain.site" first. Do nothing..\n\n"  
else   
 if [ ! -f /etc/letsencrypt/live/$mydomain/fullchain.pem ]; then 
   curl -Lo keys.zip $gistkeyszip
   mkdir -p  /etc/letsencrypt/live/$mydomain
   sudo apt-get install unzip
   unzip keys.zip  -d ./keys
   find  ./keys -name "*.pem" -type f -exec cp {} /etc/letsencrypt/live/$mydomain/  \;
   rm -r ./keys
 else 
  printf "\n\nSome cert keys already exist. Do nothing not to damage\n\n" 
 fi
fi 

curl https://raw.githubusercontent.com/radiocab/nginx-opencart-setup/refs/heads/main/install-lemp.sh \
| bash -s -- $mydomain --dry-run

```

- in real issuing of Let's Encrypt certificate:
```shell
#!/bin/sh

# set your domain like:
# mydomain=reallymydomain.site
if  [ -z ${mydomain+x} ] || [ "$mydomain" = "reallymydomain.site" ] ; then 
 printf "\n\nSet mydomain="reallymydomain.site" first. Do nothing..\n\n"  
else 
 curl https://raw.githubusercontent.com/radiocab/nginx-opencart-setup/refs/heads/main/install-lemp.sh \
  | bash -s -- $mydomain  
fi 

```