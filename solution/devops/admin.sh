#!/usr/bin/env bash
PATH=$PATH:/home/$(whoami)/.local/bin
export CLUSTER_IP=$1
echo "Cluster IP: $CLUSTER_IP"

sudo firewall-cmd --zone=public --permanent --add-port=80/tcp # http
sudo firewall-cmd --zone=public --permanent --add-port=443/tcp # ssl
sudo firewall-cmd --zone=public --permanent --add-port=389/tcp # ldap
sudo firewall-cmd --zone=public --permanent --add-port=636/tcp # ldap
sudo firewall-cmd --zone=public --permanent --add-port=3001/tcp # ldap-admin
sudo firewall-cmd --zone=public --permanent --add-port=2000/tcp # wekan
sudo firewall-cmd --zone=public --permanent --add-port=3000/tcp # gitea
sudo firewall-cmd --zone=public --permanent --add-port=8001/tcp # nuxus
sudo firewall-cmd --zone=public --permanent --add-port=8080/tcp # jenkins
sudo firewall-cmd --zone=public --permanent --add-port=50000/tcp # jenkins
sudo firewall-cmd --reload

if [ -n "$(command -v setsebool)" ];then
    sudo setsebool -P httpd_can_network_connect 1
fi
sh -c "./vagrant/facility/jenkins/jenkins.sh"
docker-compose -f /vagrant/facility/openldap/docker-compose.yml up -d
docker-compose -f /vagrant/facility/wekan/docker-compose.yml up -d
docker-compose -f /vagrant/facility/gitea/docker-compose.yml up -d
docker-compose -f /vagrant/facility/nexus/docker-compose.yml up -d


