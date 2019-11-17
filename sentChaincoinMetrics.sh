#!/bin/bash
#set -xe
source /usr/local/bin/ddhelper.sh

host=$(hostname)
coin="chaincoin"
role="masternode"
username=$(whoami)
coindaemon="chaincoind"
coincli="chaincoin-cli"
publicIp=$(mypublicip)
coinexplorerurl=https://api.chaincoinexplorer.co.uk/getBlockchainInfo
highestBlock=$(curl -sk $coinexplorerurl | jq .blocks)

metricname="node.highestblock"
value=$(/usr/local/bin/$coincli getblockcount)
sentMetric $host $coin $metricname $value $role $username

metricname="node.connections"
value=$(/usr/local/bin/$coincli getconnectioncount)
sentMetric $host $coin $metricname $value $role $username

metricname="node.enabled"
status=$(/usr/local/bin/$coincli masternode list json $publicIp | jq .[].status)
value=0
if [ 'ENABLED' == $status ]; then
    value=1
fi
sentMetric $host $coin $metricname $value $role $username

metricname="node.status"
value=$(/usr/local/bin/$coincli mnsync status | jq .AssetID)
value=0
if [ '999' == $status ]; then
    value=1
fi
sentMetric $host $coin $metricname $value $role $username

metricname="explorer.highestblock"
value=$highestBlock
sentMetric $host $coin $metricname $value $role $username