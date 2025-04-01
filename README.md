# nginx-opencart-setup



NGINX setup for OPENCART based on 
[DigitalOcean Recommendations](https://www.digitalocean.com/community/tools/nginx/) 

and on this [discussion](https://github.com/opencart/opencart.github.io/issues/335)

Tested on Ubuntu 20.4

For "dry-run" of the Letsencrypt bot run in terminal 
```shell
curl -s https://raw.githubusercontent.com/radiocab/nginx-opencart-setup/refs/heads/main/setup.sh \
| bash -s -- MyLovelyOpencart.site --dry-run
```
with your own domain instead of MyLovelyOpencart.site 



To install just run in terminal 
```shell
curl -s https://raw.githubusercontent.com/radiocab/nginx-opencart-setup/refs/heads/main/setup.sh \
| bash -s -- MyLovelyOpencart.site
```
with your own domain instead of MyLovelyOpencart.site 


See also start point for all this as [DigitalOcean configuration](https://www.digitalocean.com/community/tools/nginx?global.security.securityTxt=true&global.logging.errorLogEnabled=true&global.logging.logNotFound=true)