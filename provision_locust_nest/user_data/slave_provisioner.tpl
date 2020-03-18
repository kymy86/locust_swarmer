#!/usr/bin/env bash

until [[ -f /var/lib/cloud/instance/boot-finished ]]; do
  sleep 1
done

sleep 1 | telnet ${master_ip} 8089

cd /home/locust

sudo aws s3 cp s3://${locust_config_bucket}/${locust_file_name} .
nohup locust -f ${locust_file_name} --slave --master-host=${master_ip} &
sleep 5