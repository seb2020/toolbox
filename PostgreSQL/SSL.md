# SSL with PostgreSQL

## Check config

--with-openssl is required

```bash
postgres@SRVDB-01:/home/postgres/ [SITE1] pg_config | grep CONFIGURE
CONFIGURE = '--prefix=/u01/app/postgres/product/95/db_2' '--exec-prefix=/u01/app/postgres/product/95/db_2' '--bindir=/u01/app/postgres/product/95/db_2/bin' '--libdir=/u01/app/postgres/product/95/db_2/lib' '--sysconfdir=/u01/app/postgres/product/95/db_2/etc' '--includedir=/u01/app/postgres/product/95/db_2/include' '--datarootdir=/u01/app/postgres/product/95/db_2/share' '--datadir=/u01/app/postgres/product/95/db_2/share' '--with-pgport=5432' '--with-perl' '--with-python' '--with-tcl' '--with-openssl' '--with-pam' '--with-ldap' '--with-libxml' '--with-libxslt' '--with-segsize=2' '--with-blocksize=8' '--with-wal-segsize=16'
```

## Generate certificate

Common Name should match server name

```bash
postgres@SRVDB-01:/home/postgres/ [SITE1] openssl req -new -text -out server.req
```

Remove pass phrase for PostgreSQL autostart

```bash
postgres@SRVDB-01:/home/postgres/ [SITE1] openssl rsa -in privkey.pem -out server.key
Enter pass phrase for privkey.pem:
writing RSA key
postgres@SRVDB-01:/home/postgres/ [SITE1] rm privkey.pem

postgres@SRVDB-01:/home/postgres/ [SITE1] openssl req -x509 -in server.req -text -key server.key -out server.crt

postgres@SRVDB-01:/home/postgres/ [SITE1] chmod 600 server.key
```

## Install certificate

```bash
postgres@SRVDB-01:/home/postgres/ [SITE1] mv server.key server.crt $PGDATA/
```

```PostgreSQL
(postgres@[local]:5432) [postgres] > alter system set ssl='on';
ALTER SYSTEM
Time: 5.427 ms
```

```bash
postgres@SRVDB-01:/home/postgres/ [SITE1] pg_ctl -D $PGDATA restart -m fast
```

Add in pg_hba.conf

```bash
hostssl  all             all             127.0.0.1/32            md5
```

## Test

```bash
postgres@SRVDB-01:/home/postgres/ [SITE1] psql -h localhost -p 5432 postgres
psql (9.5.2)
SSL connection (protocol: TLSv1.2, cipher: ECDHE-RSA-AES256-GCM-SHA384, bits: 256, compression: off)
Type "help" for help.
```
