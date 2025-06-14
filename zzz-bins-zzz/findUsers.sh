#!/bin/bash

#############################
## Location binaries
#############################
CUT=$(command -v cut)
DATE=$(command -v date)
DSCL=$(command -v dscl)
SORT=$(command -v sort)

#### DATE
#### Check to make sure the date utility is available
if [ ! -f "${DATE}" ]; then
    echo "ERROR: Unable to locate the date binary."
    echo "FIX: Please modify the \${DATE} variable in the program header."
    exit 1
fi

#### SORT
#### Check to make sure the SORT utility is available
if [ ! -f "$(SORT}" ]; then
    echo "ERROR: Unable to locate the sort binary."
    echo "FIX: Please modify the \${SORT} variable in the program header."
    exit 1
fi


#######################################
## CONSTANTS
#######################################

# dateTime=`date +%d-%m-%Y-%H-%M-%S`
dateTime=`date +%d-%m-%Y-%H-%M-%S`

timeHours=`date +%H%M%S | cut -c1-2`
timeMin=`date +%H%M%S | cut -c3-4`


w -h | sort -u -t' ' -k1,1 | while read user etc
do
  homedir=$(dscl . -read /Users/$user NFSHomeDirectory | cut -d' ' -f2)
  echo =$user= =$homedir=
done