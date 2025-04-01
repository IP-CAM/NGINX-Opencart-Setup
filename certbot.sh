#!/bin/bash

set -e
   
mydomain=$1

# accordingly to https://www.digitalocean.com/community/tools/nginx?global.security.securityTxt=true&global.logging.errorLogEnabled=true&global.logging.logNotFound=true

printf "${INFO}Commenting out SSL related directives in the configuration
 and adding a temporary 'ssl off;' directive to ensure 
 that SSL directives are not active. 
 This may cause NGINX to emit a warning, which is safe to ignore. 
 The directive will be removed once Certbot is configured.${NC}"
sed -i -r 's/(listen .*443)/\1; #/g; s/(ssl_(certificate|certificate_key|trusted_certificate) )/#;#\1/g; s/(server \{)/\1\n    ssl off;/g' /etc/nginx/sites-available/example.com.conf
cat /etc/nginx/sites-available/example.com.conf


printf "${INFO}Starting your NGINX server to be able issue certificate
 (need to see http://example.com/.well-known/acme-challenge/  to validate domain)${NC}"
sudo nginx -t && sudo systemctl stop nginx && sudo systemctl start nginx

sudo snap install --classic certbot

printf "${INFO}Obtaining SSL certificates from Let's Encrypt using Certbot${NC}"
certbot certonly --webroot -d example.com --email info@example.com -w /var/www/_letsencrypt -n --agree-tos --force-renewal 
# --pre-hook "service nginx stop" --post-hook "service nginx start"

printf "${INFO}Uncommenting SSL related directives in the configuration back${NC}"

sed -i -r -z 's/#?; ?#//g; s/(server \{)\n    ssl off;/\1/g' /etc/nginx/sites-available/example.com.conf

printf "${INFO}Reloading NGINX server${NC}"

sudo nginx -t && sudo systemctl reload nginx

printf "${INFO}Configuring Certbot to reload NGINX when it successfully renews certificates${NC}"
echo -e '#!/bin/bash\nnginx -t && systemctl reload nginx' | sudo tee /etc/letsencrypt/renewal-hooks/post/nginx-reload.sh

sudo chmod a+x /etc/letsencrypt/renewal-hooks/post/nginx-reload.sh
printf "${OK} Certbot script ended without errors${NC}"