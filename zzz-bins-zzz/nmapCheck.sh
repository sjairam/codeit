#!/bin/bash
version=0.8
##REPORT_EMAIL_TO="SSLChecker@DomesticandGeneral.onmicrosoft.com"
######################

REPORT_EMAIL_TO="sanjay.jairam.eu@gmail.com"
REPORT_SMTP_RELAY="appsmtp.domesticandgeneral.com"
######################

###########################################################
#	Script : nmapCheck
#	0.1		SJ	Initial version
#   0.2 	SJ	Added nmapListing
#	0.3 	SJ	Changed ordering
# 	0.4		SJ	Added emailing
#   0.5     SJ 	Removal of old REPORTS
#   0.6 	SJ 	Addition of pre-reqs for Neil
#   0.7		SJ 	Add macOS check
# 	0.8		SJ	Add DEBUG & macOS flags
###########################################################
#######################################
## Location of system binaries
#######################################

AWK=$(command -v awk)
DATE=$(command -v date)
FIND=$(command -v find)
GREP=$(command -v grep)
NMAP=$(command -v nmap)
SED=$(command -v sed)
TEE=$(command -v tee)
UNAME=$(command -v uname)

#######################################
## CONSTANTS
#######################################

## dateTime=`date +%d-%m-%Y-%H-%M-%S`   
dateTime=`date +%Y%m%d`
##dir=/Users/jairams/madmin/logs/nmapCheck
TODAY_DATE=`date +%Y%m%d`

report_email_body="/Users/jairams/was/madmin/props/nmapEmail.props"
report_email_from="applicationservices.middleware@domesticandgeneral.com"
report_email_subject=`echo "SSL Checker"`

start=`date +%s.%N`
timeHours=`date +%H%M%S | cut -c1-2`
timeMin=`date +%H%M%S | cut -c3-4`
timeLog=$timeHours":"$timeMin

YESTERDAY_DATE=`date -d yesterday +%Y%m%d`

#######################
## checkOS
#######################

checkOS ()  {
    SYS=`uname -o 2>/dev/null`

    if [ $? -eq 0 ]; then
        echo " --> ola, en windows "
        macOS="FALSE"
    else
        echo " --> ola, en macOS "
        macOS="TRUE"
    fi
}

#######################
## sendReportEmail
#######################

sendReportEmail () {
	if [ "${DEBUG}" = "true" ]; then
		echo "DEBUG ON - Not sending the Report Email"
	else
		mailx -a ${REPORT_FILE} -S smtp=${REPORT_SMTP_RELAY} -r ${report_email_from} -s "${report_email_subject}" -v ${REPORT_EMAIL_TO} < ${report_email_body}
	fi
}

#######################
## usage
#######################

usage()
{
	echo " "
	echo " You need to pass in a True or False flag for debugging "
    echo " nmapCheck <<true or false>> "
    echo ""
}

#######################
## MAIN
#######################

if [ "$#" -ne 1 ]; then
    echo " You have to pass in the correct parameters "
	usage
    exit 3;
fi

clear 

if [ "${DEBUG}" = "true" ]; then
	echo " --> checking pre-reqs"
fi 

#####################
## Pre-REQS
#####################
#### AWK
#### Check to make sure the awk utility is available
if [ ! -f "${AWK}" ]; then
    echo "ERROR: Unable to locate the awk binary."
    echo "FIX: Please modify the \${AWK} variable in the program header."
    exit 1
fi

#### DATE
#### Check to make sure the date utility is available
if [ ! -f "${DATE}" ]; then
    echo "ERROR: Unable to locate the date binary."
    echo "FIX: Please modify the \${DATE} variable in the program header."
    exit 1
fi

#### GREP
#### Check to make sure the grep utility is available
if [ ! -f "${GREP}" ]; then
    echo "ERROR: Unable to locate the grep binary."
    echo "FIX: Please modify the \${GREP} variables in the program header."
    exit 1
fi

#### NMAP
#### Check to make sure the nmap utility is available
if [ ! -f "${NMAP}" ]; then
    echo "ERROR: Unable to locate the nmap binary."
    echo "FIX: Please modify the \${NMAP} variables in the program header."
    exit 1
fi

#### TEE
#### Check to make sure the tee is available
if [ ! -f "${TEE}" ]; then
    echo "ERROR: Unable to locate the tee binary."
    echo "FIX: Please modify the \${TEE} variables in the program header."
    exit 1
fi

#### UNAME
#### Check to make sure the uname utility is available
if [ ! -f "${UNAME}" ]; then
    echo "ERROR: Unable to locate the uname binary."
    echo "FIX: Please modify the \${UNAME} variables in the program header."
    exit 1
fi

checkOS

if [ $1 = "TRUE" ] || [ $1 = "true" ]; then
    DEBUG="TRUE"
else 
    DEBUG="FALSE"
fi


if [ ${macOS} = "TRUE" ]; then
        if [ ${DEBUG} = "TRUE" ]; then
            echo " --> if macOS : true "
        fi

        LOGDIR=$dir/$file-$dateTime.csv

        PROPS_LIST="/Users/jairams/was/madmin/props/nmapList.txt"
        REPORT_DIR="/Users/jairams/was/madmin/logs/nmapCheck"
        REPORT_FILE="${REPORT_DIR}/nmapCheck-${TODAY_DATE}.csv"
        TEMP_FILE="${REPORT_DIR}/nmapCheck-${TODAY_DATE}-A.csv"

        if [ ${DEBUG} = "TRUE" ]; then
            echo " --> if macOS : true "
            echo " --> logDir " ${LOGDIR}
            echo " --> reportDir " ${REPORT_DIR}
            echo " --> reportFile " ${REPORT_FILE}
            echo " --> temp File " ${TEMP_FILE}
        fi
    else
        if [ ${DEBUG} = "TRUE" ]; then
            echo " --> if macOS : false "
        fi

        LOGDIR=$dir/$file-$dateTime.csv
        PROPS_LIST="/was/madmin/props/nmapList.txt"
        REPORT_DIR="/was/madmin/logs/nmapCheck"
        REPORT_FILE="${REPORT_DIR}/nmapCheck-${TODAY_DATE}.csv"
        TEMP_FILE="${REPORT_DIR}/nmapCheck-${TODAY_DATE}-A.csv"
        if [ ${DEBUG} = "TRUE" ]; then
            echo " --> if macOS : false "
            echo " --> logDir " ${LOGDIR}
            echo " --> reportDir " ${REPORT_DIR}
            echo " --> reportFile " ${REPORT_FILE}
            echo " --> temp File " ${TEMP_FILE}
        fi

fi

if [ ! -d ${REPORT_DIR} ]; 
then
	mkdir ${REPORT_DIR}
fi 


sleep 4
echo "Time is "  $timeLog | tee -a ${TEMP_FILE}

for server in `more ${PROPS_LIST}`
do
	sNMAP=$(nmap -p 443 --script ssl-cert $server | grep after | awk '{print $5,$6,$7}' )
	echo " $server , $sNMAP                             " | tee -a ${TEMP_FILE}
      
done | column -t
echo "-------------------------------------------"

sleep 2
end=`date +%s.%N`

cat ${TEMP_FILE} | sort -k 2 >> ${REPORT_FILE}

sendReportEmail

sleep 2 

rm ${TEMP_FILE}
