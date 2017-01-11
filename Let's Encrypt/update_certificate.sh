#!/bin/sh

# ..######.
# .##....##
# .##......
# ..######.
# .......##
# .##....##
# ..######.

#################################################################################
#
# Script: update_certificate.sh
# Purpose : Renew SSL certificate from Let's Encrypt with cerbot and reload nginx
# Link :
# Example : certbot renew --webroot -w /usr/share/nginx/html/ --dry-run >> /var/log/le-renew.log
#
# Remove --dry-run in production !
################################################################################


/usr/bin/certbot renew --webroot -w /usr/share/nginx/html/ --dry-run >> /var/log/le-renew.log
/usr/bin/systemctl reload nginx