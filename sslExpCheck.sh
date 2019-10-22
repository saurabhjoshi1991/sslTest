#!/bin/bash


serversList=$1 #"www.google.com:443,stlrck-vdrh001.wsgc.com:9443,qa2.wsgc.com:18443"
parseServers=$(echo $serversList | tr "," "\n")
tableBodyStart="<HTML><TABLE border=1><TH>SERVER</TH><TH>Expiry Date</TH><TH>Expires In</TH>"
tableBodyEnd="</TABLE></HTML>"
tableBody=""
for curServer in $parseServers
do
	curServerHost=$(cut -d':' -f1 <<<"$curServer")
	curServerPort=$(cut -d':' -f2 <<<"$curServer")
	nc -vz $curServerHost $curServerPort 2>/dev/null
	if [ $? != 0 ]
	then
		tableBody="${tableBody}<TR><TD>$curServer</TD><TD>Server not reachable</TD><TD>N.A.</TD></TR>"
		#echo "$curServer is not reachable at the moment"
	else
		#echo "$curServer seems OK"
		certExpirationDate=$(echo|openssl s_client -servername $curServerHost -connect $curServer 2>/dev/null | openssl x509 -text  2>/dev/null | grep 'Not After : ' | sed 's/^[^:]*://g' | sed 's/^[[:space:]]*//' ) 
		curDate=$(date +"%F")
		dateDiff=$(ruby -rdate -e "puts Date.parse('$certExpirationDate') - Date.parse('$curDate')")
		daysLeft=$(cut -d'/' -f1 <<<"$dateDiff") 
		if [[ $daysLeft -le 100 ]]; then
			tableBody="${tableBody}<TR bgcolor="red"><TD>$curServer</TD><TD>$certExpirationDate</TD><TD>$daysLeft days</TD></TR>" ##implement color code here
		else
			tableBody="${tableBody}<TR bgcolor="green"><TD>$curServer</TD><TD>$certExpirationDate</TD><TD>$daysLeft days</TD></TR>"
			#echo "SSL Certificates looks fine on $curServer server"
		fi
	fi
done

toAddress="sjoshi1@wsgc.com"
emailBody=$tableBodyStart$tableBody$tableBodyEnd

#BODY=<TR><TD>$curServer</TD><TD>$certExpirationDate</TD><TD>$daysLeft</TD></TR>" #The SSL Certificate on $curServer server is expiring in $daysLeft days on $certExpirationDate."
#echo ${BODY} | mail -a "From: me@example.com" -a "MIME-Version: 1.0" -a "Content-Type: text/html" -s "Alert - SSL Certificate Expiring Soon" ${TO_ADDRESS} 
echo ${emailBody} | mail -s "$(echo -e "Info SSL Certificates Check \nContent-Type: text/html")"  ${toAddress}  #<  $BODY


#######Working#############

#serverName=$1
#port=$2

#serverName=$@ #abc:123 pwr:678 yuui:8765
#port=$2


#nc -vz $1 $2 2>/dev/null

#if [[ $? = 0 ]]; then
	#statements
#	certExpirationDate=$(echo|openssl s_client -servername $serverName -connect $1:$2 2>/dev/null | openssl x509 -text  2>/dev/null | grep 'Not After : ' | sed 's/^[^:]*://g' | sed 's/^[[:space:]]*//' ) 
#	curDate=$(date +"%F")
#	dateDiff=$(ruby -rdate -e "puts Date.parse('$certExpirationDate') - Date.parse('$curDate')")
#	daysLeft=$(cut -d'/' -f1 <<<"$dateDiff") 

#	if [[ $daysLeft -le 25000 ]]; then
#		TO_ADDRESS="sjoshi1@wsgc.com"
#		BODY="The SSL Certificate on $1:$2 server is expiring in $daysLeft days"
#		echo ${BODY}| mail -s "Alert - SSL Certificate Expiring Soon" ${TO_ADDRESS} 
#	else
#		echo "SSL Certificates looks fine on $1:$2 server"
#	fi
#else
#	echo "Server $1:$2 is not reachable at the moment"
#fi




######trial code###
#currentDate=$(date +"%b %d %T %Y %Z")
#echo "Cerficate Expiry Date : ${expirationDate}"
#echo "Current System Date   : ${currentDate}"
#$(date -j -f '%Y%m%d' "$1" +'%Y%m%d')
#expDate=$(date -j -f '%b %d %T %Y %Z' "$certExpirationDate" +"%F")
#dateDiff=$(ruby -rdate -e "puts Date.parse('$expirationDate') - Date.parse('$curDate')") #| cut -d '/' -f1)
#expDate=$($tempDate +"%F")
#sed 's/^[^:]*://g' #| cut -d / -f1)
#-- -r ${FROM_ADDRESS}
#echo ${BODY}| mail -s ${SUBJECT} ${TO_ADDRESS} -- -r ${FROM_ADDRESS}
#echo "The SSL Certificate is expiring in $daysLeft days"
