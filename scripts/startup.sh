#!/bin/bash

/usr/sbin/init
systemctl start sshd
systemctl start redis
systemctl start sensu-server
systemctl start sensu-api
systemctl start uchiwa

/usr/bin/supervisord