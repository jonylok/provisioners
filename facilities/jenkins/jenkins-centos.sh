#!/usr/bin/env bash
sudo yum install -y wget git java-11-openjdk
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
sudo yum install -y jenkins
sudo usermod -aG docker vagrant
sudo cat /var/lib/jenkins/secrets/initialAdminPassword