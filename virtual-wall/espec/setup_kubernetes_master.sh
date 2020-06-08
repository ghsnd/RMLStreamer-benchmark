#!/usr/bin/env bash
MASTER_NAME=master
MANIFEST_FILE=manifest.xml

read -r TOKEN_1<token-part1.txt
read -r TOKEN_2<token-part2.txt
TOKEN="$TOKEN_1.$TOKEN_2"
# convert to lowercase
TOKEN="${TOKEN,,}"
echo "TOKEN: $TOKEN"


kubeadm init --pod-network-cidr 10.244.0.0/16 --token $TOKEN
sysctl net.bridge.bridge-nf-call-iptables=1
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/a70459be0084506e4ec919aa1c114638878db11b/Documentation/kube-flannel.yml --validate=false

kubectl --kubeconfig /etc/kubernetes/admin.conf create -f ~/kube-flannel.yml

USER=$(xmllint --xpath "string(/*[local-name()='rspec']/*[local-name()='node'][@client_id='$MASTER_NAME']/*[local-name()='services']/*[local-name()='login']/@username)" $MANIFEST_FILE)
chown -R $(id -u $USER):$(id -g $USER) ~/.kube/
cp /etc/kubernetes/admin.conf ~/.kube/config
chown $(id -u $USER):$(id -g $USER) ~/.kube/config
echo 'source <(kubectl completion bash)' >> ~/.bashrc
