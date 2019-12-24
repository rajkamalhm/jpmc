#!/bin/bash

curl -s https://raw.githubusercontent.com/dhruvbehl/jsonTest/master/login.log > ./login.log
curl -s https://raw.githubusercontent.com/dhruvbehl/jsonTest/master/ipfilter.json > ./ipfilter.json

for IP in $(cat ./ipfilter.json | jq -r '.data[].ipAddress')
do
	if [[ $(grep $IP ./login.log) ]]
	then
		grep $IP ./login.log | while read line
		do
			date_directory=$(echo $line | awk '{print $1"_" $2"_" $3}')
			status=$(echo $line | cut -d" " -f 8 | sed 's/,//g')
			mkdir -p ./output/${date_directory}
			echo $line >> "./output/${date_directory}/${IP}_${status}.log"
		done
	fi
done
