# SELinux

## Install software

```bash
yum install policycoreutils-python setroubleshoot setools
```

## Reactivate SELinux

```bash
 touch /.autorelabel
 reboot
```

## Test

```bash
vi /etc/ssh/sshd_config
systemctl restart sshd
tail -f /var/log/messages
```

## View port

```bash
semanage port -l | grep sshd
```

## Debug

```bash
sealert -a /var/log/audit/audit.log
```

## Email notification

```bash
yum install setroubleshoot{-server,-plugins,-doc}

vi /var/lib/setroubleshoot/email_alert_recipients
```

yum install setroubleshoot setools
sealert -a /var/log/audit/audit.log

admin@example.com filter_type=after_first

tail -f /var/log/audit/audit.log | audit2why


## Nginx

```bash
setsebool -P httpd_can_network_connect 1
```



