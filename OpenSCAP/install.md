# OpenSCAP on CentOS 7

## Install

```bash
yum install openscap-scanner scap-security-guide
```

## Security Policy

```bash
ls -1 /usr/share/xml/scap/ssg/content/ssg-*-ds.xml
oscap info /usr/share/xml/scap/ssg/content/ssg-centos7-ds.xml
```

## Evaluation

```bash
oscap xccdf eval \
 --profile xccdf_org.ssgproject.content_profile_common \
 --report report.html \
 --fetch-remote-resources  \
 /usr/share/xml/scap/ssg/content/ssg-centos7-ds.xml
```

## Audit Rules

```bash
auditctl -l
```