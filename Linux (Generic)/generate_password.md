# Generate password for /etc/shadow

```bash
echo "MonSuperMotDePasse" | makepasswd --clearfrom=- --crypt-md5 |awk '{ print $2 }'
```
