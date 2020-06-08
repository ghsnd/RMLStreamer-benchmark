#!/usr/bin/env bash

apt-get update
apt-get install -y apt-transport-https software-properties-common bash
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo deb https://packages.cloud.google.com/apt/ kubernetes-xenial main > /etc/apt/sources.list.d/kubernetes.list
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
apt-get update
swapoff -a
apt-get install -y docker-ce=17.06.0~ce-0~ubuntu containerd.io

# Next apt-get is a bit version critical
# 1. working on 2019-07-17
#apt-get install -y kubelet kubeadm kubectl kubernetes-cni
# 2. working on 2020-02-27 (remark: versions increased, no more entry for kubernetes-cni)
apt-get install -y kubelet=1.14* kubeadm=1.14* kubectl=1.14*

rm -rf /var/lib/kubelet/*

# This is necessary for create-db
sysctl -w vm.max_map_count=262144
