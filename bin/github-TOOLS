#!/bin/bash

start_time=$(date +%s)

month=`date +%b`

year=`date +%y`

clear

timeSec=2

echo " => Creating TOOLS "
cd ~/Documents/GitHub/
mkdir TOOLS

cd TOOLS

echo " ==>> Creating repos "
echo "  --> alertmanager "
git clone git@github.com:prometheus/alertmanager.git
sleep $timeSec

echo " --> argocd"
git clone git@github.com:argoproj/argo-cd.git
sleep $timeSec

echo " --> aws ebs driver"
git clone git@github.com:kubernetes-sigs/aws-ebs-csi-driver.git
sleep $timeSec

echo " --> csi nfs driver"
git clone git@github.com:kubernetes-csi/csi-driver-nfs.git
sleep $timeSec

echo " --> helm "
git clone git@github.com:helm/helm.git
sleep $timeSec

echo " --> iamlive"
git clone git@github.com:iann0036/iamlive.git
sleep $timeSec

echo " --> ISTIO" 
git clone git@github.com:istio/istio.git
sleep $timeSec

echo " --> istio.io"
git clone git@github.com:istio/istio.io.git
sleep $timeSec

echo " --> jaeger"
git clone git@github.com:jaegertracing/jaeger.git
sleep $timeSec

echo " --> Krew plugins"
git clone git@github.com:kubernetes-sigs/krew.git
sleep $timeSec

echo " --> popeye"
git clone git@github.com:derailed/popeye.git
sleep $timeSec

echo " --> samber/prometheus"
git clone git@github.com:samber/awesome-prometheus-alerts.git
sleep $timeSec

end_time=$(date +%s)

elapsed_time=$(( end_time - start_time ))

# Convert elapsed time to minutes and seconds
elapsed_minutes=$(( elapsed_time / 60 ))
elapsed_seconds=$(( elapsed_time % 60 ))

echo " ====================================================== "
# Output the result
echo "Elapsed time: $elapsed_minutes minutes and $elapsed_seconds seconds"
