# nginx-opencart-setup



NGINX setup for OPENCART based on 
[DigitalOcean Recommendations](https://www.digitalocean.com/community/tools/nginx/) 

and on this [discussion](https://github.com/opencart/opencart.github.io/issues/335)

Tested on Ubuntu 20.4

To install just run in terminal 
```shell
curl https://raw.githubusercontent.com/radiocab/nginx-opencart-setup/refs/heads/main/setup.sh \
| bash -s -- mylovelyopencart.site
```
with your own domain


See also based [DigitalOcean configuration](https://www.digitalocean.com/community/tools/nginx?global.security.securityTxt=true&global.logging.errorLogEnabled=true&global.logging.logNotFound=true)