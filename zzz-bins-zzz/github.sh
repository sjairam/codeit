#!/bin/bash

start_time=$(date +%s)

month=`date +%b`

year=`date +%y`

clear

echo " ==>> Creating repos "

cd ~/Documents/GitHub/
mkdir APPS
cd APPS

echo " --> A to L"

echo " --> ACORN "
git clone git@github.huit.harvard.edu:LTS/acorn-server.git

echo " --> Archecker"  
git clone git@github.com:harvard-lts/archivesspace-checker-private.git

# git clone git@github.huit.harvard.edu:LTS/argoCD-INFRA.git

echo " --> Aspace "
git clone git@github.com:harvard-lts/aspace-local.git

echo " --> Bibdata "
git clone git@github.huit.harvard.edu:LTS/bibdatalookup.git

echo " --> Booklabeler"
git clone git@github.huit.harvard.edu:LTS/booklabeler.git

echo " --> Curiosity"
git clone git@github.com:harvard-lts/CURIOSity.git

echo " --> DAIS"
git clone 

echo " --> DRS Tools"
git clone git@github.huit.harvard.edu:LTS/drstools.git

echo " --> DRS Set Manager"
git clone git@github.huit.harvard.edu:LTS/drssetmgr.git

echo " --> DRS2 Services"
git clone git@github.huit.harvard.edu:LTS/drs2_services.git

echo " --> DRS WebAdmin"
git clone git@github.huit.harvard.edu:LTS/drs2_webadmin.git


git clone git@github.huit.harvard.edu:LTS/DRS2-INFRA.git

git clone git@github.huit.harvard.edu:LTS/devsecops-INFRA.git

git clone git@github.huit.harvard.edu:LTS/fts-INFRA.git

git clone git@github.huit.harvard.edu:LTS/HDForms-INFRA.git

git clone git@github.huit.harvard.edu:LTS/hgl-INFRA.git

git clone git@github.huit.harvard.edu:LTS/IDS-INFRA.git

git clone git@github.huit.harvard.edu:LTS/imgconv-INFRA.git

git clone git@github.huit.harvard.edu:LTS/jobmonitor-INFRA.git

git clone git@github.huit.harvard.edu:LTS/JSTOR-INFRA.git

git clone git@github.huit.harvard.edu:LTS/LISTVIEW-INFRA.git

git clone git@github.huit.harvard.edu:LTS/lts-pipelines-INFRA.git

echo " --> M to Z"

git clone git@github.huit.harvard.edu:LTS/mds-INFRA.git

git clone git@github.huit.harvard.edu:LTS/mps-INFRA.git

git clone git@github.huit.harvard.edu:LTS/mpsadm-INFRA.git

git clone git@github.huit.harvard.edu:LTS/nrs-INFRA.git

git clone git@github.huit.harvard.edu:LTS/nrsadm-INFRA.git

git clone git@github.huit.harvard.edu:LTS/olivia-INFRA.git

git clone git@github.huit.harvard.edu:LTS/policy-INFRA.git

git clone git@github.huit.harvard.edu:LTS/presto-INFRA.git

git clone git@github.huit.harvard.edu:LTS/SDS-and-Wowza-INFRA.git

git clone git@github.huit.harvard.edu:LTS/talkwithhollis-INFRA.git

git clone git@github.huit.harvard.edu:LTS/viewer-INFRA.git

end_time=$(date +%s)

elapsed_time=$(( end_time - start_time ))

# Convert elapsed time to minutes and seconds
elapsed_minutes=$(( elapsed_time / 60 ))
elapsed_seconds=$(( elapsed_time % 60 ))

echo " ====================================================== "
# Output the result
echo "Elapsed time: $elapsed_minutes minutes and $elapsed_seconds seconds"