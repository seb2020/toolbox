# New Let's encrypt website

## Install

```bash
yum install certbot
```

## Create Nginx config

```nginx
server {
        listen 80;
        server_name data.domain.ch;

        location / {
                return 301 https://$host$request_uri;
        }

        # Allow access to the letsencrypt ACME Challenge
        location /.well-known/acme-challenge/ {
                root /usr/share/nginx/html/;
        }
}

server {
        listen 443 ssl;
        server_name data.domain.ch;

        ssl_certificate /etc/letsencrypt/live/data.domain.ch/fullchain.pem;
        ssl_certificate_key /etc/letsencrypt/live/data.domain.ch/privkey.pem;

        ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
        ssl_prefer_server_ciphers on;
        ssl_dhparam /etc/ssl/certs/dhparam.pem;
        ssl_ciphers 'ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-DSS-AES128-GCM-SHA256:kEDH+AESGCM:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA:ECDHE-ECDSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-DSS-AES128-SHA256:DHE-RSA-AES256-SHA256:DHE-DSS-AES256-SHA:DHE-RSA-AES256-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:AES128-SHA:AES256-SHA:AES:CAMELLIA:DES-CBC3-SHA:!aNULL:!eNULL:!EXPORT:!DES:!RC4:!MD5:!PSK:!aECDH:!EDH-DSS-DES-CBC3-SHA:!EDH-RSA-DES-CBC3-SHA:!KRB5-DES-CBC3-SHA';
        ssl_session_timeout 1d;
        ssl_session_cache shared:SSL:50m;
        ssl_stapling on;
        ssl_stapling_verify on;
        add_header Strict-Transport-Security max-age=15768000;

        location / {
                proxy_pass https://X.X.X.X:YYY;
                proxy_set_header Host $host;
                proxy_set_header X-Real-IP $remote_addr;
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                proxy_redirect off;
                proxy_buffering off;
        }

        access_log /var/log/nginx/data.domain.ch.access.log;
        error_log  /var/log/nginx/data.domain.ch.error.log;
}

```

## Generate certificate

```bash
certbot certonly --webroot -w /usr/share/nginx/html/ -d data.domain.ch
```

## Reload nginx

```bash
systemctl reload nginx
```