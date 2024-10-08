#!/bin/bash
#set -xe
function sentEvent() {
    if [ -z "$DATADOG_API_KEY" ]
    then
        echo "ERROR: Please specify the DATADOG_API_KEY as env variable."
        exit -1
    fi
    
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
                echo "ERROR: Please specify the title as the third argument."
            else
                if [ -z "$4" ]
                then
                    echo "ERROR: Please specify the message as the fourth argument."
                else
                    if [ -z "$5" ]
                    then
                        echo "ERROR: Please specify the role as the fifth argument."
                    else
                        if [ -z "$6" ]
                        then
                            echo "ERROR: Please specify the username as the sixth argument."
                            exit -1
                        else
                            if [ -z "$7" ]
                            then
                                alertType=info
                            else
                                alertType=$7
                            fi
                            echo "$3=$4"
                            /usr/bin/curl -sX POST -H "Content-type: application/json" \
                            -d "{
								\"title\": \"[$3][$5][$2][$1]\",
								\"text\": \"$4\",
								\"priority\": \"normal\",
								\"tags\":[\"coin:$2\", \"role:$5\", \"user:$6\", \"eventType:$3\"],
								\"alert_type\": \"$alertType\"
                            }" \
                            "https://api.datadoghq.com/api/v1/events?api_key=$DATADOG_API_KEY" > /dev/null
                        fi
                    fi
                fi
            fi
        fi
    fi
}

function sentMetric() {
    
    if [ -z "$DATADOG_API_KEY" ]
    then
        echo "ERROR: Please specify the DATADOG_API_KEY as env variable."
        exit -1
    fi
    
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
                        if [ -z "$6" ]
                        then
                            echo "ERROR: Please specify the username as the sixth argument."
                            exit -1
                        else
                            currenttime=$(/bin/date +%s)
			    echo "$3=$4"
                            /usr/bin/curl -sX POST -H "Content-type: application/json" \
                            -d "{ \"series\" :
                            [{
                                    \"metric\":\"$3\",
                                    \"points\":[[$currenttime, $4]],
                                    \"type\":\"gauge\",
                                    \"host\":\"$1\",
                                    \"tags\":[\"coin:$2\", \"role:$5\", \"user:$6\"]
                                }]
                            }" \
                            "https://app.datadoghq.com/api/v1/series?api_key=$DATADOG_API_KEY" > /dev/null
                        fi
                    fi
                fi
            fi
        fi
    fi
}
