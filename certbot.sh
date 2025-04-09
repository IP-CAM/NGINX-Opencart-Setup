#!/bin/bash

set -e
   
#mydomain=$1  # e.g.reallymydomain.site
: ${mydomain:=$1}
: ${dry_run:=$2}


# accordingly to https://www.digitalocean.com/community/tools/nginx?global.security.securityTxt=true&global.logging.errorLogEnabled=true&global.logging.logNotFound=true

printf "${INFO}Commenting out SSL related directives in the configuration
 and adding a temporary 'ssl off;' directive to ensure 
 that SSL directives are not active. ${NC}"
printf "${WARN}This may cause NGINX to emit several warnings below, which are safe to ignore.${NC}"
printf "${INFO}The directive 'ssl off;' will be removed once Certbot is configured.${NC}"
sed -i -r 's/(listen .*443)/\1; #/g; s/(ssl_(certificate|certificate_key|trusted_certificate) )/#;#\1/g; s/(server \{)/\1\n    ssl off;/g' /etc/nginx/sites-available/$mydomain.conf
# cat /etc/nginx/sites-available/$mydomain.conf


printf "${INFO}Starting your NGINX server to be able issue certificate
 (need to see http://$mydomain/.well-known/acme-challenge/  to validate domain)${NC}"
sudo nginx -t && sudo systemctl stop nginx && sudo systemctl start nginx

sudo snap install --classic certbot
printf "${INFO}Certbot installed over snap${NC}"
sudo systemctl stop snapd
printf "${INFO}To speed up snapd temporaly stoped${NC}"
# ‐‐dry‐run
if  [ "$dry_run" = "--dry-run" ] ; then 
 printf "${INFO}Dry-run for certbot SSL certificates from Let's Encrypt using Certbot${NC}"
 certbot certonly --webroot -d $mydomain --email info@$mydomain \
   -w /var/www/_letsencrypt -n --agree-tos --force-renewal --dry-run --quiet
 mkdir -p  /etc/letsencrypt/live/$mydomain
else
 printf "${INFO}Obtaining SSL certificates from Let's Encrypt using Certbot${NC}"
 certbot certonly --webroot -d $mydomain --email info@$mydomain \
   -w /var/www/_letsencrypt -n --agree-tos --force-renewal
# --pre-hook "service nginx stop" --post-hook "service nginx start"
fi
 
printf "${INFO}Uncommenting SSL related directives in the configuration back${NC}"

#sed -i -r -z 's/#?; ?#//g; s/(server \{)\n    ssl off;/\1/g' /etc/nginx/sites-available/example.com.conf
sed -i -r -z 's/#?; ?#//g; s/(server \{)\n    ssl off;/\1/g' /etc/nginx/sites-available/$mydomain.conf



printf "${INFO}Reloading NGINX server${NC}"

sudo nginx -t && sudo systemctl reload nginx

printf "${INFO}Configuring Certbot to reload NGINX when it successfully renews certificates${NC}"
echo -e '#!/bin/bash\nnginx -t && systemctl reload nginx' | sudo tee /etc/letsencrypt/renewal-hooks/post/nginx-reload.sh

sudo chmod a+x /etc/letsencrypt/renewal-hooks/post/nginx-reload.sh
printf "${OK} Certbot script ended without errors${NC}"