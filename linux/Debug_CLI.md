# Debug CLI

```bash
uptime (shows loadavg quickly)
df -h
free
```

## Targeted troubleshooting/diagnostic tools:

### processing

```bash
ps (ps -ef | grep <name or pid of process>)
top
atop
lsof (lsof -p<pid>)
```

### networking

```bash
lsof (lsof -i4; lsof -i6)
ss (ss -tupln; ss -an)
ip (ip address show; ip link show; ip route show (ip r); ip route get <ip addr>)
host (host google.com)
dig (dig google.com @<ip of resolver>)
whois
traceroute
curl
iftop
```

### files

```bash
ftop
```
