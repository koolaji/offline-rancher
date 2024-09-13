#!/bin/bash

# copy bashrc file to change prompt
cp .bashrc ~/
source ~/.bashrc

# create this path for second node to put config file 
mkdir -p /etc/rancher/rke2/

# configure repo list for apt and install some files
cp sources.list /etc/apt/sources.list

apt update && apt upgrade -y

apt install -y curl vim sudo iptables

# get some files for installation
declare -a arr=("rke2-images.linux-amd64.tar.zst" "rke2.linux-amd64.tar.gz" "sha256sum-amd64.txt" "rke2-images-core.linux-amd64.tar.gz" "rke2-images-cilium.linux-amd64.tar.gz")

for i in "${arr[@]}"
do
    file="$i"
    [ -f "$file" ] || curl -OL https://github.com/rancher/rke2/releases/download/v1.30.4%2Brke2r1/$i
done

# download install script if not present
file=install.sh
[ -f "$file" ] || curl -sfL https://get.rke2.io --output install.sh

# function to set up server
setup_server() {
    INSTALL_RKE2_ARTIFACT_PATH=/root/rancher sh install.sh --cni=cilium

    # Server Part
    cp rke2-server.service /usr/local/lib/systemd/system/rke2-server.service
    systemctl daemon-reload
    systemctl enable rke2-server.service
    systemctl start rke2-server.service

    echo "Server setup complete."
}

# function to set up agent
setup_agent() {
    INSTALL_RKE2_ARTIFACT_PATH=/opt/offline-rancher INSTALL_RKE2_TYPE="agent" sh install.sh

    # Agent Part
    systemctl enable rke2-agent.service
    systemctl restart rke2-agent.service

    # Wait until rke2.yaml is created
    until [ -f /etc/rancher/rke2/rke2.yaml ]
    do
        sleep 5
    done

    # Set up kube config
    file=~/.kube
    [ -d "$file" ] || mkdir ~/.kube
    ln -sf /etc/rancher/rke2/rke2.yaml ~/.kube/config

    echo "Agent setup complete."
}

# Add rancher binary path to profile
grep -qF 'rancher' /etc/profile || echo 'export PATH="/var/lib/rancher/rke2/bin/:$PATH"' >> /etc/profile

# Decide between server and agent setup based on input
if [ "$1" == "server" ]; then
    setup_server
elif [ "$1" == "agent" ]; then
    setup_agent
else
    echo "Please specify either 'server' or 'agent' as an argument."
    exit 1
fi

# Final journalctl command for server
echo "journalctl -u rke2-server -f"
