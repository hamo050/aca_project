#!/bin/bash
sudo yum install python3-pip -y
sudo yum install docker -y
sudo systemctl start docker
sudo systemctl enable docker
pip install docker==4.4.4
#pip install docker-py
#sudo yum install  docker -y 
#sudo systemctl start docker
#sudo systemctl enable docker
#pip install ansible
