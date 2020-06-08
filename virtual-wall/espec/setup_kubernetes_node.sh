#!/usr/bin/env bash
MASTER_NAME=master
MANIFEST_FILE=manifest.xml

read -r TOKEN_1<token-part1.txt
read -r TOKEN_2<token-part2.txt
TOKEN="$TOKEN_1.$TOKEN_2"
# convert to lowercase
TOKEN="${TOKEN,,}"
echo "TOKEN: $TOKEN"

sed -i '0,/ExecStart/s//Environment="KUBELET_EXTRA_ARGS=--max-pods=1000"\n&/' /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
echo "Nice=-15" >> /etc/systemd/system/kubelet.service.d/10-kubeadm.conf

systemctl daemon-reload
service kubelet restart

MASTER_HOSTNAME=$(xmllint --xpath "string(/*[local-name()='rspec']/*[local-name()='node'][@client_id='$MASTER_NAME']/*[local-name()='host']/@name)" $MANIFEST_FILE)
kubeadm join --discovery-token-unsafe-skip-ca-verification --token $TOKEN $MASTER_HOSTNAME:6443