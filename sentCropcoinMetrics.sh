#!/bin/bash
#set -xe
source /usr/local/bin/ddhelper.sh
source /usr/local/bin/tools.sh

host=$(hostname)
coin="cropcoin"
role="masternode"
username=$(whoami)
coindaemon="cropcoind"
coincli=""
publicIp=$(mypublicip)

metricname="node.highestblock"
value=$(/usr/local/bin/$coindaemon getblockcount)
sentMetric $host $coin $metricname $value $role $username

metricname="node.connections"
value=$(/usr/local/bin/$coindaemon getconnectioncount)
sentMetric $host $coin $metricname $value $role $username

metricname="node.active"
value=$(/usr/local/bin/$coindaemon masternode list full | /bin/grep $publicIp | /bin/grep -w ENABLED | /usr/bin/wc -l)
sentMetric $host $coin $metricname $value $role $username

metricname="node.status"
status=$(/usr/local/bin/$coindaemon masternode status | jq .status)
value=0
if [ '9' == $status ]; then
    value=0
fi
sentMetric $host $coin $metricname $value $role $username