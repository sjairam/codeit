#!/bin/bash

start_time=$(date +%s)

month=`date +%b`

year=`date +%y`

clear

timeSec=2

echo " => Creating personal "
cd ~/Documents/GitHub/
mkdir personal
cd personal

echo " ==>> Creating repos "
echo "  --> aws docker   "
git clone git@github.com:sjairam/aws-docker-githubActons-kubernetes-demo.git 
sleep $timeSec

echo " --> ci-cd intro   "
git clone https://github.com/Link-/ci-cd-intro
sleep $timeSec

echo " --> codeit        "
git clone git@github.com:sjairam/codeit.git
sleep $timeSec

echo " --> demo          "
git clone git@github.com:sjairam/demo-container-gh-actions.git
sleep $timeSec

echo " --> k8s coursee   "
git clone https://gitlab.com/twn-cka-course/latest/k8s-administrator-course
sleep $timeSec

echo " --> terraform github actions"
git clone git@github.com:sjairam/terraform-github-actions-aws.git
sleep $timeSec

end_time=$(date +%s)

elapsed_time=$(( end_time - start_time ))

# Convert elapsed time to minutes and seconds
elapsed_minutes=$(( elapsed_time / 60 ))
elapsed_seconds=$(( elapsed_time % 60 ))

echo " ====================================================== "
# Output the result
echo "Elapsed time: $elapsed_minutes minutes and $elapsed_seconds seconds"
