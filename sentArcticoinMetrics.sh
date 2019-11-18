#!/bin/bash
#set -xe
source /usr/local/bin/ddhelper.sh
source /usr/local/bin/tools.sh

host=$(hostname)
coin="arcticcoin"
role="masternode"
username=$(whoami)
coindaemon="arcd"
coincli="arc-cli"
publicIp=$(mypublicip)
coinexplorerurl=http://explorer.advtech.group/api/getblockcount

metricname="node.highestblock"
value=$(/usr/local/bin/$coincli getblockcount)
sentMetric $host $coin $metricname $value $role $username

metricname="node.connections"
value=$(/usr/local/bin/$coincli getconnectioncount)
sentMetric $host $coin $metricname $value $role $username

metricname="node.active"
value=$(/usr/local/bin/$coincli goldminenode list full $publicIp | /bin/grep -w ENABLED | /bin/grep -v PRE-ENABLED | /usr/bin/wc -l)
sentMetric $host $coin $metricname $value $role $username

metricname="node.status"
status=$(/usr/local/bin/$coincli mnsync status | jq .IsSynced)
value=0
if [ 'true' == $status ]; then
    value=1
fi
sentMetric $host $coin $metricname $value $role $username

metricname="explorer.highestblock"
highestBlock=$(curl -sk $coinexplorerurl)
value=$highestBlock
sentMetric $host $coin $metricname $value $role $username