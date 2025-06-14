#!/bin/bash

timeSec=4

clear
sleep $timeSec

echo " -->  Goto ARGOCD"
cd ~/Documents/ARGOCD/
sleep $timeSec

echo " -->  Goto DEV"
cd ~/Documents/ARGOCD/DEV
sleep $timeSec

echo " -->  Goto DEV / Jason-Tom"
cd ~/Documents/ARGOCD/DEV/Jason-Tom
sleep $timeSec

echo " --> Apply ConfigMaps"
kubectl apply -f configmaps.\#v1/argocd/argocd-cm.json
sleep $timeSec

echo " --> Apply RBAC"
kubectl apply -f configmaps.\#v1/argocd/argocd-rbac-cm.json
sleep $timeSec

echo " --> Secrets  / Repos "
kubectl apply -f secrets.\#v1/argocd/.
sleep $timeSec