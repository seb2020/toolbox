# View replication lag in PostgreSQL servers

```sql
 select client_addr, pg_xlog_location_diff(pg_current_xlog_location(), sent_location) as sent_lag from pg_stat_replication;
 ```