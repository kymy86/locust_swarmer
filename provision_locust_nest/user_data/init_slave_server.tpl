#!/usr/bin/env bash

sudo apt-get update -y
sudo apt-get install build-essential -y --fix-missing
sudo apt-get install python3.7 -y
sudo apt-get install python3-pip -y
sudo pip3 install --upgrade pip
sudo pip3 install awscli --upgrade
sudo pip3 install locustio

sudo mkdir -p /home/locust

#set-up slave
sleep 1 | telnet ${master_ip} 8089

cd /home/locust

sudo aws s3 cp s3://${locust_config_bucket}/${locust_file_name} .
nohup locust -f ${locust_file_name} --slave --master-host=${master_ip} &
sleep 5