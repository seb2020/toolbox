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
# Script: letsencrypt-haproxy.sh
# Purpose : Auto create or renew certificate with LE for HAProxy
# Example : /scripts/letsencryt-haproxy.sh sub1.domain.com
# Infos : Add it to cron with : 30 2 * * 1 /scripts/letsencryt-haproxy.sh sub1.domain.com >> /var/log/le-renewal.log
################################################################################

# Path to the letsencrypt-auto tool
LE_TOOL=/opt/letsencrypt/letsencrypt-auto

# Directory where the acme client puts the generated certs
LE_OUTPUT=/etc/letsencrypt/live

# Concat the requested domains
DOMAINS=""
for DOM in "$@"
do
    DOMAINS+=" -d $DOM"
done

# Create or renew certificate for the domain(s) supplied for this tool
$LE_TOOL --agree-tos --renew-by-default --standalone --standalone-supported-challenges http-01 --http-01-port 54321 --email email@domain.com certonly $DOMAINS

# Cat the certificate chain and the private key together for haproxy
cat $LE_OUTPUT/$1/{fullchain.pem,privkey.pem} > /etc/haproxy/ssl/${1}.pem

# Reload the haproxy daemon to activate the cert
systemctl reload haproxy