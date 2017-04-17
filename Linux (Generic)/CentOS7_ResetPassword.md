# Reset root CentOS 7 password

Add to grub with e

```command
rd.break enforcing=0
```

```bash
mount
mount -o remount,rw /sysroot
chroot /sysrootpasswd
```

