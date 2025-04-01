#!/bin/bash

# example of using arguments to a script
echo "Fist arg is $1"
echo "Second arg is $2"
echo "Total number of arguments is $#" 

# accordingly to https://www.digitalocean.com/community/tools/nginx?global.security.securityTxt=true&global.logging.errorLogEnabled=true&global.logging.logNotFound=true

printf "${INFO}Commenting out SSL related directives in the configuration.
\nAdding a temporary ssl off directive to ensure 
\nthat SSL directives are not active. 
\nThis may cause NGINX to emit a warning, which is safe to ignore. 
\nThe directive will be removed once Certbot is configured.${NC}"
sed -i -r 's/(listen .*443)/\1; #/g; s/(ssl_(certificate|certificate_key|trusted_certificate) )/#;#aaa\1/g; s/(server \{)/\1\n    ssl off;/g' /etc/nginx/sites-available/example.com.conf
cat /etc/nginx/sites-available/example.com.conf


printf "${INFO}Starting your NGINX server to be able issue certificate"
echo "(need to see http://example.com/.well-known/acme-challenge/  to validate domain)${NC}"
sudo nginx -t && sudo systemctl reload nginx

sudo snap install --classic certbot

printf "\n${INFO}Obtaining SSL certificates from Let's Encrypt using Certbot${NC}"
certbot certonly --webroot -d example.com --email info@example.com -w /var/www/_letsencrypt -n --agree-tos --force-renewal 
# --pre-hook "service nginx stop" --post-hook "service nginx start"

echo "${INFO}Uncommenting SSL related directives in the configuration back${NC}"

sed -i -r -z 's/#?; ?#//g; s/(server \{)\n    ssl off;/\1/g' /etc/nginx/sites-available/example.com.conf

echo "${INFO}Reloading your NGINX server${NC}"

sudo nginx -t && sudo systemctl reload nginx

printf "${INFO}Configure Certbot to reload NGINX when it successfully renews certificates${NC}"
echo -e '#!/bin/bash\nnginx -t && systemctl reload nginx' | sudo tee /etc/letsencrypt/renewal-hooks/post/nginx-reload.sh

sudo chmod a+x /etc/letsencrypt/renewal-hooks/post/nginx-reload.sh
