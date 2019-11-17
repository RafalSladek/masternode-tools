#!/bin/bash
#set -xe
source /usr/local/bin/ddhelper.sh

host=$(hostname)
coin="arcticcoin"
role="masternode"
username=$(whoami)
coindaemon="arcticcoind"
coincli="arcticcoin-cli"
publicIp=$(mypublicip)
coinexplorerurl=http://explorer.advtech.group/api/getblockcount
highestBlock=$(curl -sk $coinexplorerurl)

metricname="node.highestblock"
value=$(/usr/local/bin/$coincli getblockcount)
sentMetric $host $coin $metricname $value $role $username

metricname="node.connections"
value=$(/usr/local/bin/$coincli getconnectioncount)
sentMetric $host $coin $metricname $value $role $username

metricname="node.enabled"
value=$(/usr/local/bin/$coincli goldminenode list full $publicip | /bin/grep -w ENABLED | /bin/grep -v PRE-ENABLED | /usr/bin/wc -l)
sentMetric $host $coin $metricname $value $role $username

metricname="node.status"
status=$(/usr/local/bin/$coincli goldminenode status | /bin/grep status | /usr/bin/awk -F'"' '{printf "%s",$4}' | /usr/bin/tr -d ",")
value=0
if [[ 'Goldminenode successfully started' == $status ]]; then
    value=1
fi
sentMetric $host $coin $metricname $value $role $username

metricname="explorer.highestblock"
value=$highestBlock
sentMetric $host $coin $metricname $value $role $username