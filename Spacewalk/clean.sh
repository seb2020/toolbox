#!/bin/sh
# Clean packages with no link to channel
# 02.01.2017
#
# vi /etc/cron.daily/spacewalk_sync.cron


spacewalk-data-fsck -r -S -C -O