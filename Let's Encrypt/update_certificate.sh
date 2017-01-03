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
# Purpose : Renew SSL certificate from Let's Encrypt with cerbot
# Link :
# Example : certbot renew --webroot -w /usr/share/nginx/html/ --dry-run >> /var/log/le-renew.log
#
################################################################################

# in crontab -e

30 2 * * 1 /usr/bin/certbot renew --webroot -w /usr/share/nginx/html/ >> /var/log/le-renew.log
35 2 * * 1 /usr/bin/systemctl reload nginx