# Rsync

## command

```code
-z, --compress compress file data during the transfer
-a, --archive archive mode; equals -rlptgoD (no -H,-A,-X)
-v, --verbose increase verbosity
-h, --human-readable output numbers in a human-readable format
```

```bash
rsync -avzh --progress foldersource folderdestination
```
