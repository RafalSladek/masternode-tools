#!/bin/bash
#set -xe
source /usr/local/bin/ddhelper.sh

host=$(hostname)
coin="arcticcoin"
role="masternode"
username=$(whoami)
coindaemon="arcticcoind"
coincli="arcticcoin-cli"

metricname="blocks"
value=$(/usr/local/bin/$coincli getblockcount)
sentMetric $host $coin $metricname $value $role $username

metricname="connections"
value=$(/usr/local/bin/$coincli getconnectioncount)
sentMetric $host $coin $metricname $value $role $username

metricname="enabled"
publicip=$(curl -s ipecho.net/plain)
value=$(/usr/local/bin/$coincli goldminenode list full | /bin/grep $publicip | /bin/grep -w ENABLED | /bin/grep -v PRE-ENABLED | /usr/bin/wc -l)
sentMetric $host $coin $metricname $value $role $username

metricname="status"
value=$(/usr/local/bin/$coincli goldminenode status | /bin/grep status | /usr/bin/awk -F'"' '{printf "%s",$4}' | /usr/bin/tr -d ",")
success=0
if [[ 'Goldminenode successfully started' == $value ]]; then
    success=1
fi
sentMetric $host $coin $metricname $success $role $username
