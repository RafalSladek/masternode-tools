#!/bin/bash
#set -xe

function sentMetric() {

	if [ -z "$1" ]
	then
	echo "ERROR: Please specify the host as the first argument."
	else
		if [ -z "$2" ]
		then
		echo "ERROR: Please specify the coin as the second argument."
		else
			if [ -z "$3" ]
			then
			echo "ERROR: Please specify the metricname as the third argument."
			else
				if [ -z "$4" ]
				then
				echo "ERROR: Please specify the value as the fourth argument."
				else
					if [ -z "$5" ]
					then
					echo "ERROR: Please specify the role as the fifth argument."
					else
						currenttime=$(/bin/date +%s)
						/usr/bin/curl --silent -X POST -H "Content-type: application/json" \
						-d "{ \"series\" :
								[{
								\"metric\":\"$5.$3\",
								\"points\":[[$currenttime, $4]],
								\"type\":\"gauge\",
								\"host\":\"$1\",
								\"tags\":[\"coin:$2\", \"role:$5\"]
								}]
							}" \
						"https://app.datadoghq.com/api/v1/series?api_key=$DATADOG_API_KEY" > /dev/null
					fi
				fi
			fi
		fi
	fi
}
