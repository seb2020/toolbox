# Find linux version

## CentOS

```bash
[root@SRVPROXY-01 ~]# hostnamectl
   Static hostname: SRVPROXY-01.domain.local
         Icon name: computer-vm
           Chassis: vm
        Machine ID: a958deae5c5b4853972beaf4a4eeba99
           Boot ID: 8787cfcaab734390925a4a87cc4be8b1
    Virtualization: microsoft
  Operating System: CentOS Linux 7 (Core)
       CPE OS Name: cpe:/o:centos:centos:7
            Kernel: Linux 3.10.0-514.2.2.el7.x86_64
      Architecture: x86-64

[root@SRVPROXY-01 ~]# uname -a
Linux SRVPROXY-01.domain.local 3.10.0-514.2.2.el7.x86_64 #1 SMP Tue Dec 6 23:06:41 UTC 2016 x86_64 x86_64 x86_64 GNU/Linux

[root@SRVPROXY-01 ~]# cat /etc/redhat-release
CentOS Linux release 7.3.1611 (Core)
```

## Ubuntu

```bash
[root@SRVPROXY-01 ~]# uname -a
```