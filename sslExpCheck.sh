#!/bin/bash

serverName=$1
port=$2

certExpirationDate=$(echo|openssl s_client -servername $serverName -connect $1:$2 2>/dev/null | openssl x509 -text  2>/dev/null | grep 'Not After : ' | sed 's/^[^:]*://g' | sed 's/^[[:space:]]*//' ) 
curDate=$(date +"%F")
dateDiff=$(ruby -rdate -e "puts Date.parse('$certExpirationDate') - Date.parse('$curDate')")
daysLeft=$(cut -d'/' -f1 <<<"$dateDiff") 

if [[ $daysLeft -le 15 ]]; then
	echo "The SSL Certificate is expiring in $daysLeft days"
else
	echo "Do Nothing"
fi


######broken code###
#currentDate=$(date +"%b %d %T %Y %Z")
#echo "Cerficate Expiry Date : ${expirationDate}"
#echo "Current System Date   : ${currentDate}"
#$(date -j -f '%Y%m%d' "$1" +'%Y%m%d')
#expDate=$(date -j -f '%b %d %T %Y %Z' "$certExpirationDate" +"%F")
#dateDiff=$(ruby -rdate -e "puts Date.parse('$expirationDate') - Date.parse('$curDate')") #| cut -d '/' -f1)
#expDate=$($tempDate +"%F")
#sed 's/^[^:]*://g' #| cut -d / -f1)
