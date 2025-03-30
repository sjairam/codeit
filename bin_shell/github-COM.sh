#!/bin/bash

start_time=$(date +%s)

month=`date +%b`

year=`date +%y`

clear

timeSec=2

echo " => Creating GITHUB "
cd ~/Documents/GitHub/
mkdir GITHUB-COM

cd GITHUB-COM

echo " ==>> Creating repos "
echo " --> HUIT"
git clone git@github.com:HUIT-Cloud-Architecture/hcdo-cto-app-template-tf-oci.git
sleep $timeSec

git clone git@github.com:HUIT-Cloud-Architecture/hcdo-cto-app-template-tf-aws.git
sleep $timeSec

git clone git@github.com:HUIT-Cloud-Architecture/hcdo-cto-app-template-tf-azurerm.git
sleep $timeSec

git clone git@github.com:HUIT-Cloud-Architecture/hcdo-cto-module-repo-template-tf-aws.git
sleep $timeSec

git clone git@github.com:HUIT-Cloud-Architecture/hcdo-cto-module-repo-template-tf-oci.git
sleep $timeSec

git clone git@github.com:HUIT-Cloud-Architecture/hcdo-cto-module-repo-template-tf-azurerm.git
sleep $timeSec

echo " --> LTS"

git clone git@github.com:harvard-lts/ga-reusable-workflows.git
sleep $timeSec

git clone git@github.com:harvard-lts/ltsIAC.git
sleep $timeSec

end_time=$(date +%s)

elapsed_time=$(( end_time - start_time ))

# Convert elapsed time to minutes and seconds
elapsed_minutes=$(( elapsed_time / 60 ))
elapsed_seconds=$(( elapsed_time % 60 ))

echo " ====================================================== "
# Output the result
echo "Elapsed time: $elapsed_minutes minutes and $elapsed_seconds seconds"