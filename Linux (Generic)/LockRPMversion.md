# How to restrict yum to install or upgrade a package to a fixed specific package version?

## Add lock

```bash
yum install yum-plugin-versionlock
yum versionlock gcc-*
yum versionlock list
```

## Remove lock

```bash
yum versionlock clear
```