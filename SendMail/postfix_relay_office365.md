# Configuration relay with Office 365

## /etc/postfix/main.cf

```Configuration
relayhost = [smtp.office365.com]:587

inet_interfaces = all
inet_protocols = ipv4

smtp_sasl_auth_enable = yes
smtp_sasl_security_options = noanonymous
smtp_sasl_password_maps = hash:/etc/postfix/sasl_passwd

smtp_use_tls = yes
smtp_tls_security_level = may
smtp_tls_CAfile = /etc/ssl/certs/ca-certificates.crt

sender_canonical_classes = envelope_sender, header_sender
sender_canonical_maps = regexp:/etc/postfix/sender_canonical_maps
smtp_header_checks = regexp:/etc/postfix/header_check
```

## /etc/postfix/sasl_passwd

```Configuration
[smtp.office365.com]:587 login@domain.com:P4ssW0rd.
```

## /etc/postfix/sender_canonical_maps

```Configuration
/.+/  noreply@domain.ch
```

## /etc/postfix/header_check

```Configuration
/FROM:.*/ REPLACE From: noreply@domain.ch
```

## /etc/mailname

```Configuration
domain.ch
```

---

postmap /etc/postfix/sasl_passwd

service postfix restart

echo "This is a test" | mail -s "Relay test" me@mail.com