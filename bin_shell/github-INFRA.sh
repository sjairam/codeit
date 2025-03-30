#!/bin/bash

start_time=$(date +%s)

month=`date +%b`

year=`date +%y`

clear

timeSec=2

echo " ==>> Creating repos "

cd ~/Documents/GitHub/
mkdir APPS-INFRA
cd APPS-INFRA

echo " --> A to L"

git clone git@github.huit.harvard.edu:LTS/ACORN-INFRA.git
sleep $timeSec

git clone git@github.huit.harvard.edu:LTS/application-INFRA.git
sleep $timeSec

git clone git@github.huit.harvard.edu:LTS/aqueduct-INFRA.git
sleep $timeSec

git clone git@github.huit.harvard.edu:LTS/archecker-INFRA.git
sleep $timeSec

git clone git@github.huit.harvard.edu:LTS/argoCD-INFRA.git
sleep $timeSec

git clone git@github.huit.harvard.edu:LTS/aspace-INFRA.git
sleep $timeSec

git clone git@github.huit.harvard.edu:LTS/bibdatalookup-INFRA.git
sleep $timeSec

git clone git@github.huit.harvard.edu:LTS/booklabeler-INFRA.git
sleep $timeSec

git clone git@github.huit.harvard.edu:LTS/curiosity-INFRA.git
sleep $timeSec

git clone git@github.huit.harvard.edu:LTS/DAIS-INFRA.git
sleep $timeSec

git clone git@github.huit.harvard.edu:LTS/DRS2-INFRA.git
sleep $timeSec

git clone git@github.huit.harvard.edu:LTS/devsecops-INFRA.git
sleep $timeSec

git clone git@github.huit.harvard.edu:LTS/fts-INFRA.git
sleep $timeSec

git clone git@github.huit.harvard.edu:LTS/HDForms-INFRA.git
sleep $timeSec

git clone git@github.huit.harvard.edu:LTS/hgl-INFRA.git
sleep $timeSec

git clone git@github.huit.harvard.edu:LTS/IDS-INFRA.git
sleep $timeSec

git clone git@github.huit.harvard.edu:LTS/imgconv-INFRA.git
sleep $timeSec

git clone git@github.huit.harvard.edu:LTS/jobmonitor-INFRA.git
sleep $timeSec

git clone git@github.huit.harvard.edu:LTS/JSTOR-INFRA.git
sleep $timeSec

git clone git@github.huit.harvard.edu:LTS/LISTVIEW-INFRA.git
sleep $timeSec

git clone git@github.huit.harvard.edu:LTS/lts-pipelines-INFRA.git
sleep $timeSec

echo " --> M to Z"

git clone git@github.huit.harvard.edu:LTS/mds-INFRA.git
sleep $timeSec

git clone git@github.huit.harvard.edu:LTS/mps-INFRA.git
sleep $timeSec

git clone git@github.huit.harvard.edu:LTS/mpsadm-INFRA.git
sleep $timeSec

git clone git@github.huit.harvard.edu:LTS/nrs-INFRA.git
sleep $timeSec

git clone git@github.huit.harvard.edu:LTS/nrsadm-INFRA.git
sleep $timeSec

git clone git@github.huit.harvard.edu:LTS/olivia-INFRA.git
sleep $timeSec

git clone git@github.huit.harvard.edu:LTS/OCFL-Validator-Infra.git
sleep $timeSec

git clone git@github.huit.harvard.edu:LTS/policy-INFRA.git
sleep $timeSec

git clone git@github.huit.harvard.edu:LTS/presto-INFRA.git
sleep $timeSec

git clone git@github.huit.harvard.edu:LTS/SDS-and-Wowza-INFRA.git
sleep $timeSec

git clone git@github.huit.harvard.edu:LTS/viewer-INFRA.git
sleep $timeSec

end_time=$(date +%s)

elapsed_time=$(( end_time - start_time ))

# Convert elapsed time to minutes and seconds
elapsed_minutes=$(( elapsed_time / 60 ))
elapsed_seconds=$(( elapsed_time % 60 ))

echo " ====================================================== "
# Output the result
echo "Elapsed time: $elapsed_minutes minutes and $elapsed_seconds seconds"
