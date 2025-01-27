#!/usr/bin/env bash
set -e
export PATH=$PATH:/home/$(whoami)/.local/bin

MIRROR=$1
if [ $MIRROR = "tencent" ];then
    MIRROR_URL=mirrors.tencent.com
elif [ $MIRROR = "aliyun" ];then
    MIRROR_URL=mirrors.aliyun.com
fi

echo "Install and upgrade packages via package manager. MIRROR URL:$MIRROR_URL"

### CENTOS
if [ -n "$(command -v yum)" ];then
    if [ -n $MIRROR_URL ];then
        sudo curl -o /etc/yum.repos.d/docker-ce.repo https://$MIRROR_URL/docker-ce/linux/centos/docker-ce.repo
        sudo sed -i "s+download.docker.com+$MIRROR_URL/docker-ce+" /etc/yum.repos.d/docker-ce.repo
    fi
    sudo yum update -y
    sudo yum upgrade -y
    sudo yum install -y epel-release yum-utils git wget python3-pip unzip tcpdump ntp ntpdate ntp-doc openssh-server net-tools bind-utils
    sudo yum install -y docker-ce docker-ce-cli containerd.io
    sudo systemctl enable --now firewalld
### UBUNTU
elif [ -n "$(command -v apt)" ];then
    if [ -n $MIRROR_URL ];then
        sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak
        sudo sed -i "s/archive.ubuntu.com/$MIRROR_URL/g" /etc/apt/sources.list
    fi
    sudo apt update -y
    sudo apt install -y software-properties-common git firewalld curl python3-pip unzip docker.io tcpdump ntp openssh-server
    sudo apt full-upgrade -y
    sudo systemctl enable --now firewalld
else
    echo "Your Linux package manager hasn't support"
    exit 1
fi

### Setup Docker
DOCKER_USERNAME=$2
DOCKER_PASSWORD=$3
DOCKER_REGISTRY=$4
if [ $? = 0 ]; then
    sudo usermod -aG docker $(whoami)
    sudo systemctl enable docker
    sudo systemctl restart docker
    sudo docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD $DOCKER_REGISTRY
else
    echo "Install docker-ce failed, Please retry or install with mirror."
    exit 1
fi


### Upgrade pip
echo "Upgrade pip."
if [ -n $MIRROR_URL ];then
    sudo sh -c "python3 -m pip install --upgrade -i https://$MIRROR_URL/pypi/simple pip"
else
    sudo sh -c "python3 -m pip install --upgrade pip"
fi

### Install terraform
if [ -n "$(command -v yum)" ];then
    sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
    sudo yum -y install terraform
elif [ -n "$(command -v apt)" ];then
    curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
    sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
    sudo apt-get update && sudo apt-get install terraform
else
    echo "Your Linux package manager hasn't support"
    exit 1
fi



## post installation
mkdir configs
ssh-keygen  -t rsa -P '' -f $HOME/.ssh/identity

## Alias
alias pip="python3 -m pip"