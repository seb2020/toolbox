# Infos #

## Install filebeat CentOS 7 clients ##

rpm --import http://packages.elastic.co/GPG-KEY-elasticsearch
wget https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-5.2.2-x86_64.rpm
rpm -ihv filebeat-5.2.2-x86_64.rpm
vi /etc/filebeat/filebeat.yml

copy certificate in /etc/pki/tls/certs

systemctl enable filebeat
systemctl start filebeat
tail -f /var/log/filebeat/filebeat

## Elastic API ##

Create index

```bash
curl -XPUT 'localhost:9200/winlogbeat-?v'
```

List index

```bash
curl 'localhost:9200/_cat/indices?v'
```

Delete index

```bash
curl -XDELETE 'localhost:9200/winlogbeat-?v'
```