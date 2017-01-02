# PostgreSQL Hot-Standby

## Preparing the master server

```PostgreSQL
postgres=# alter system set max_replication_slots=5; 
ALTER SYSTEM 
postgres=# alter system set wal_level='hot_standby'; 
ALTER SYSTEM 
postgres=# alter system set hot_standby='on'; 
ALTER SYSTEM
```

Create the replication slot
```PostgreSQL
postgres=# select * from pg_create_physical_replication_slot('standby1'); 
slot_name | xlog_position 
-----------+--------------- 
standby1 | 
(1 row)
```

## Base backup of the primary database

```bash
[root@SRVDB-01 ~]# mkdir /data/backup 
[root@SRVDB-01 ~]# chown postgres:postgres /data/backup/ 
[root@SRVDB-01 ~]# logout 
[postgres@SRVDB-01:][LOGIVALSIERRESITE1] pg_basebackup -D /data/backup/ --xlog --format=t WARNING: skipping special file "./pg_log" WARNING: skipping special file "./postgresql.conf" WARNING: skipping special file "./pg_hba.conf" 
[postgres@SRVDB-01:] [LOGIVALSIERRESITE1] ls -la /data/backup/
total 38876 
drwxr-xr-x. 2 postgres postgres 4096 Apr 4 11:42 . 
drwxr-xr-x. 7 root root 4096 Apr 4 11:42 .. 
-rw-r--r--. 1 postgres postgres 39797760 Apr 4 11:42 base.tar 
[postgres@SRVDB-01: [LOGIVALSIERRESITE1]
```

## Transferring the base backup to the standby server

```bash
[postgres@SRVDB-01:] [LOGIVALSIERRESITE1] scp /data/backup/base.tar SRVDB-02:/data/pgdata/LOGIVALSIERRESITE2/ 
postgres@SRVDB-02's password: 
base.tar 100% 38MB 38.0MB/s 00:00
```

## Recovery.conf file on the standby server

Add slave_recovery.conf to $PGDATA/recovery.conf

## Start the standby database and begin streaming

```
2016-04-04 15:26:07.168 GMT - 3 - 9189 - @ LOG: redo starts at 0/B000028 
2016-04-04 15:26:07.168 GMT - 4 - 9189 - @ LOG: consistent recovery state reached at 0/C000000 
2016-04-04 15:26:07.168 GMT - 5 - 9187 - @ LOG: database system is ready to accept read only connections 
2016-04-04 15:26:07.177 GMT - 1 - 9193 - @ LOG: started streaming WAL from primary at 0/C000000 on timeline 1 
2016-04-04 15:31:07.199 GMT - 1 - 9190 - @ LOG: restartpoint starting: time 
2016-04-04 15:31:07.413 GMT - 2 - 9190 - @ LOG: restartpoint complete: wrote 3 buffers (0.0%); 0 transaction log file(s) added, 0 removed, 0 recycled; write=0.205 s, sync=0.003 s, total=0.214 s; sync files=3, longest=0.003 s, average=0.001 s
```