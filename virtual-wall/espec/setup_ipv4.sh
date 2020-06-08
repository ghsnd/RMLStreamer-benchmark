#!/usr/bin/env bash

if hostname | grep -q -F wall1.ilabt.iminds.be; then
  echo 'wall1'
 route del default gw 10.2.15.254
 route add default gw 10.2.15.253
 route add -net 10.11.0.0 netmask 255.255.0.0 gw 10.2.15.254
 route add -net 10.2.32.0 netmask 255.255.240.0 gw 10.2.15.254
else
  echo 'not wall1'
fi
if hostname | grep -q -F wall2.ilabt.iminds.be; then
  echo 'wall2'
  route del default gw 10.2.47.254
  route add default gw 10.2.47.253
  route add -net 10.11.0.0 netmask 255.255.0.0 gw 10.2.47.254
  route add -net 10.2.0.0 netmask 255.255.240.0 gw 10.2.47.254
else
  echo 'not wall2'
fi
