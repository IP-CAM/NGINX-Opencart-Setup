#!/bin/bash

# example of using arguments to a script
echo "Fist arg is $1"
echo "Second arg is $2"
echo "Total number of arguments is $#" 

# accordingly to https://www.digitalocean.com/community/tools/nginx?global.security.securityTxt=true&global.logging.errorLogEnabled=true&global.logging.logNotFound=true

echo "${INFO}Commenting out SSL related directives in the configuration${NC}"
sed -i -r 's/(listen .*443)/\1; #/g; s/(ssl_(certificate|certificate_key|trusted_certificate) )/#;#\1/g; s/(server \{)/\1\n    ssl off;/g' /etc/nginx/sites-available/example.com.conf

# The above command will add a temporary ssl off directive to ensure 
# that SSL directives are not active. 
# This may cause NGINX to emit a warning, which is safe to ignore. 
# The directive will be removed once Certbot is configured.

echo "${INFO}Starting your NGINX server to be able issue certificate (need to see http://example.com/.well-known/acme-challenge/)${NC}"
sudo nginx -t && sudo systemctl reload nginx

sudo snap install --classic certbot

echo "${INFO}Obtaining SSL certificates from Let's Encrypt using Certbot${NC}"
certbot certonly --webroot -d example.com --email info@example.com -w /var/www/_letsencrypt -n --agree-tos --force-renewal 
# --pre-hook "service nginx stop" --post-hook "service nginx start"

echo "${INFO}Uncommenting SSL related directives in the configuration back${NC}"

sed -i -r -z 's/#?; ?#//g; s/(server \{)\n    ssl off;/\1/g' /etc/nginx/sites-available/example.com.conf

echo "${INFO}Reloading your NGINX server${NC}"

sudo nginx -t && sudo systemctl reload nginx

# Configure Certbot to reload NGINX when it successfully renews certificates:

echo -e '#!/bin/bash\nnginx -t && systemctl reload nginx' | sudo tee /etc/letsencrypt/renewal-hooks/post/nginx-reload.sh

sudo chmod a+x /etc/letsencrypt/renewal-hooks/post/nginx-reload.sh
