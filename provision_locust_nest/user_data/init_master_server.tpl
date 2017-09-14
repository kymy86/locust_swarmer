#!/bin/bash

sudo apt-get update
DEBIAN_FRONTEND=noninteractive apt-get upgrade -yq
sudo apt-get install build-essential -y --fix-missing
sudo apt-get install python-pip -y
sudo pip install --upgrade pip
sudo pip install awscli --upgrade
sudo pip install locustio
sudo pip install pyzmq

sudo mkdir -p /home/locust

cd /home/locust
aws s3 cp s3://${locust_config_bucket}/${locust_file_name} .
locust -f ${locust_file_name} --master --host=${swarmed_url}
