#!/bin/bash

timeSec=4

clear
sleep $timeSec

echo " -->  Goto ISTIO"
cd ~/istio-1.23.4/
sleep $timeSec

echo " --> Apply Grafana"
kubectl apply -f apply -f samples/addons/grafana.yaml
sleep $timeSec
