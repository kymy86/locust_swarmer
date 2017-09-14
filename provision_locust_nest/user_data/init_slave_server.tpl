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