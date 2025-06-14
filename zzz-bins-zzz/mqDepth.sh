#!/bin/bash
###############################################################################
#	Script : mqDepth
#
#	1.0		Initial version
#   2.0		Added checkQM
###############################################################################

PATH=$PATH:$HOME/.local/bin:$HOME/bin:/bin:/usr/bin:/opt/mqm/bin

# CONSTANTS
brokerRepo=madmin
customerRepo=~
scriptName=mqDepth

# For testing - MAC
#brokerRepo=sjadmin
#customerRepo=/Users/snowjay

queueManagerList=$customerRepo/$brokerRepo/props/queueManagerList.txt
queueList=$customerRepo/$brokerRepo/props/queueList.txt

alertThreshold=$customerRepo/$brokerRepo/mqThreshold/alert.txt
threshold=$customerRepo/$brokerRepo/props/queueThreshold.txt

version=2.0

###############################################################################
## Check Queue Manager file
###############################################################################
function checkQM 
{
	if [ ! -f $queueManagerList ]
	then
		echo "Queue Manager List file not found.  Create file queuemanagerlist.txt containing list of Queue Managers, one per line."
		exit 2
	fi
}
###############################################################################
## Check Queue file
###############################################################################
function checkQueues
{
	if [ ! -f $queueList ]
	then
		echo "Queue List file not found.  Create file queueList.txt containing list of Queues, one per line."
		exit 2
	fi
}

###############################################################################
## Check Threshold 
###############################################################################
function checkThreshold
{ 
	while IFS= read -r mqPercentageThreshold
	do
		perc="$1"
		que="$2"
		if [ $perc -gt $mqPercentageThreshold ];
		then
			echo "$que" >"$alertThreshold"
		else
			sed -i "/\<$que\>/d" "$alertThreshold"
		fi
	done < "$threshold"
	sed -i '/^$/d' "$alertThreshold"
}
###############################################################################
## ARRANGE TABLE
## TODO - Clean up messy varaibles  
###############################################################################
function arrangeMe()
{
	if [ ! -d /tmp/.temp ];
	then
		mkdir -p /tmp/.temp
	fi
	cp $logFile /tmp/.temp/Temp.log
	sed -i '/^$/d' /tmp/.temp/Temp.log
	#sed -i 1,4d /tmp/.temp/Temp.log
	maxlen=`awk '{n=length($0)>n?length($0):n} END{print n}' $customerRepo/$brokerRepo/props/queueList.txt`
	
	#Add 2 to cater for larger queue names
	maxlen=$((maxlen+2))
	#echo "MAXLEN=$maxlen" >>/tmp/my_log
	i=1
	n=`wc -l </tmp/.temp/Temp.log`
	#time=`awk "NR==2" $logFile`
	echo "#############################################################################################" >/tmp/.temp/Temp2.log
	echo "Time is $timeLog" >>/tmp/.temp/Temp2.log
	printf "%-"$maxlen"s %-16s %20s %-20s %-10s\n" "QUEUE" "DATE      TIME" "CURRENT-DEPTH" "MAX-DEPTH" "PERCENTAGE" >>/tmp/.temp/Temp2.log
	echo "#############################################################################################" >>/tmp/.temp/Temp2.log
	while [ $i -le $n ]
	do
		value=`awk "NR==$i" /tmp/.temp/Temp.log`
		ishash=`echo "$value" | grep -i '####' | awk -F'|' '{print$1}'`
		if [ -n "$ishash" ];
		then
			while [ $i -le $n ]
			do
				echo "$value" >>/tmp/.temp/Temp2.log
				value=`awk "NR==$i" /tmp/.temp/Temp.log | awk -F'|' '{print$1}'`
				ishashh=`echo "$value" | grep -i '####'`
				if [ -n "$ishashh" ];
				then
					break
				fi
				i=$((i+1))
			done
		else
			queue=`echo "$value" | awk -F'|' '{print$1}'`
			isexists=`echo "$queue" | xargs | wc -c`
			if [ $isexists -gt 1 ];
			then
				dateTime=`echo "$value" | awk -F'|' '{print$2}'`
				isdateTime=`echo "$value" | awk -F'|' '{print$2}' | xargs`
				currentDepth=`echo "$value" | awk -F'|' '{print$3}'`
				maxDepth=`echo "$value" | awk -F'|' '{print$4}'`
				percent=`echo "$value" | awk -F'|' '{print$5}'`
				if [ ! -n "$isdateTime" ];
				then
					istime=`echo "$value" | grep -i 'time is'`
					if [ -n "$istime" ];
					then
						echo "$value" >>/tmp/.temp/Temp2.log
					else
						printf "%-"$maxlen"s %-16s %20s %-20s %-10s\n" "QUEUE" "DATE      TIME" "CURRENT-DEPTH" "MAX-DEPTH" "PERCENTAGE" >>/tmp/.temp/Temp2.log
					fi
				else
					printf "%-"$maxlen"s|%-16s|%20s|%-20s|%-10s|\n" "$queue" "$dateTime" "$currentDepth" "$maxDepth" "$percent" >>/tmp/.temp/Temp2.log
				fi
			fi
		fi
		i=$((i+1))
	done
	cp /tmp/.temp/Temp2.log $logFile
	sed -i '/^$/d' $logFile
	echo -e "\n\n\n\n========================" >>/tmp/my_log
	cat /tmp/.temp/Temp2.log >>/tmp/my_log
	if [ -d /tmp/.temp ];
	then
		rm -rf /tmp/.temp
	fi
	cat $logFile
}


###############################################################################
## MAIN MAIN 
###############################################################################

. /opt/ibm/mqsi/9.0/bin/mqsiprofile

clear
sleep 2

## Check Queue Manger
checkQM

## Check Queues
checkQueues

## Check Threshold
checkThreshold

#Removing for logging to the same file.
#dateTime=`date +%Y%m%d_%H%M%S`

dateTime=`date +%Y%m%d`
timeHours=`date +%H%M%S | cut -c1-2`
timeMin=`date +%H%M%S | cut -c3-4`
timeLog=$timeHours":"$timeMin
logFile=$customerRepo/$brokerRepo/logs/$scriptName/$dateTime.log

echo " Date is "$dateTime

while IFS= read -r queueManager
do
	echo "##############################################################################################" 	| tee -a ${logFile}
	echo "Time is " $timeLog | tee -a ${logFile}
	echo " QUEUE                 DATE   TIME          CURRENT-DEPTH       MAX-DEPTH    PERCENTAGE   " 		| tee -a ${logFile}
	echo "##############################################################################################" 	| tee -a ${logFile}
	currentDepth=0
	maxDepth=0
	while IFS= read -r queue
	do
		currentDepth=$((currentDepth+1))
		maxDepth=$((maxDepth+1))
					
		currentDepth=` echo "DISPLAY QL($queue) CURDEPTH"  | runmqsc $queueManager |grep 'CURDEPTH('  |sed 's/.*CURDEPTH//'  | tr -d '()' `
		maxDepth=` echo "DISPLAY QL($queue) MAXDEPTH"  | runmqsc $queueManager |grep 'MAXDEPTH('  |sed 's/.*MAXDEPTH//'  | tr -d '()' `

		# Enhanced for OCDs - round up
		#percent=$(awk "BEGIN { pc=100*${currentDepth}/${q}; i=int(pc); print (pc-i<0.5)?i:i+1 }")
		percent=$(awk "BEGIN { pc=100*${currentDepth}/${maxDepth}; i=int(pc); print (pc-i<0.5)?i:i+1 }")
		
		#Padding 1
		printQueue=`printf "%-30s" $queue` 
		printCurrentDepth=`printf '%-6s' $currentDepth`
		printMaxDepth=`printf '%-6s' $maxDepth`
		
		#printf '%-5s %-20s %-20s %-20s %-15s %-10s\n' $pol_Id $src_Address $dst_Address "$pol_Service" "$pol_Action" "$pol_Name"
		printf '%-5s %-20s %-20s %-20s %-15s %-10s\n' $queue $dateTime $timelog "$currentDepth" "$maxDepth" "$percent"
		echo $queue "|" $dateTime $timeLog "|" $currentDepth "|" $maxDepth "|" $percent "|" | tee -a ${logFile} 
		
		#checking threshold
		checkThreshold "$percent" "$queue"	

		#echo $printQueue "|" $dateTime "|" $printCurrentDepth "|" $printMaxDepth "|" $percent | tee -a ${logFile} 
	done < "$queueList"
done < "$queueManagerList"

rm /tmp/my_log

## Arrange Log file
arrangeMe
