#!/usr/bin/env bash

sudo apt-get update -y
sudo apt-get install build-essential -y --fix-missing
sudo apt-get install python3.7 -y
sudo apt-get install python3-pip -y
sudo pip3 install --upgrade pip
sudo pip3 install awscli --upgrade
sudo pip3 install locustio

sudo mkdir -p /home/locust