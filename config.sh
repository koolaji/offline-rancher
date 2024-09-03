#!/bin/bash


# copy bashrc file to change promt 
cp .bashrc ~/
source ~/.bashrc
# create this path for second node to put config file 
mkdir -p /etc/rancher/rke2/

# configure repo list for apt and install some files
cp sources.list   /etc/apt/sources.list

apt update && apt upgrade -y

apt install -y curl vim sudo iptables

# get some file for installation
declare -a arr=("rke2-images.linux-amd64.tar.zst" "rke2.linux-amd64.tar.gz" "sha256sum-amd64.txt" "rke2-images-core.linux-amd64.tar.gz" "rke2-images-cilium.linux-amd64.tar.gz")

for i in "${arr[@]}"
do
file="$i"
[ -f "$file" ] || curl -OL https://github.com/rancher/rke2/releases/download/v1.30.4%2Brke2r1/$i

done

file=install.sh
[ -f "$file" ] ||  curl -sfL https://get.rke2.io --output install.sh
INSTALL_RKE2_ARTIFACT_PATH=/root/rancher sh install.sh --cni=cilium
cp  rke2-server.service  /usr/local/lib/systemd/system/rke2-server.service 
systemctl daemon-reload
systemctl enable rke2-server.service
systemctl start rke2-server.service

until [ -f /etc/rancher/rke2/rke2.yaml ]
do
     sleep 5
done
file=~/.kube
[ -d "$file" ] ||  mkdir ~/.kube
ln -sf /etc/rancher/rke2/rke2.yaml ~/.kube/config

grep -qF 'rancher' /etc/profile ||  echo 'export PATH="/var/lib/rancher/rke2/bin/:$PATH"' >> /etc/profile


echo "journalctl -u rke2-server -f"
