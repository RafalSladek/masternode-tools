#!/bin/bash
#set -xe
source /usr/local/bin/ddhelper.sh

host=$(hostname)
coin="chaincoin"
role="masternode"
coindaemon="chaincoind"
coincli="chaincoin-cli"

metricname="blocks"
value=$(/usr/local/bin/$coincli getblockcount)
    sentMetric $host $coin $metricname $value $role

metricname="connections"
value=$(/usr/local/bin/$coincli getconnectioncount)
    sentMetric $host $coin $metricname $value $role

metricname="enabled"
pubicip=$(curl -s ipecho.net/plain)
value=$(/usr/local/bin/$coincli masternode list full | /bin/grep $PUBLIC_IP | /bin/grep -w ENABLED | /usr/bin/wc -l)
    sentMetric $host $coin $metricname $value $role

metricname="status"
value=$(/usr/local/bin/$coincli mnsync status | /bin/grep AssetID | /usr/bin/awk -F' ' '{printf "%s",$2}' | /usr/bin/tr -d ",")
    sentMetric $host $coin $metricname $value $role