#!/bin/bash
#set -xe
source /usr/local/bin/ddhelper.sh

host=$(hostname)
coin="cropcoin"
role="masternode"
username=$(whoami)
coindaemon="cropcoind"
coincli=""

metricname="node.blocks"
value=$(/usr/local/bin/$coindaemon getblockcount)
sentMetric $host $coin $metricname $value $role $username

metricname="node.connections"
value=$(/usr/local/bin/$coindaemon getconnectioncount)
sentMetric $host $coin $metricname $value $role $username

metricname="node.enabled"
pubilcip=$(curl -s ipecho.net/plain)
value=$(/usr/local/bin/$coindaemon masternode list full | /bin/grep $pubilcip | /bin/grep -w ENABLED | /usr/bin/wc -l)
sentMetric $host $coin $metricname $value $role $username

metricname="node.status"
value=$(/usr/local/bin/$coindaemon masternode status | /bin/grep status | /usr/bin/awk -F' ' '{printf "%s",$3}' | /usr/bin/tr -d ",")
success=0
if [ '9' == $value ]; then
    success=1
fi
sentMetric $host $coin $metricname $value $role $username