#!/bin/bash
#set -xe
source /usr/local/bin/ddhelper.sh

host=$(hostname)
coin="zen"
role="securenode"
username=$(whoami)
coinexplorerurl=https://explorer.horizen.global/insight-api-zen/sync

highestBlock=$(curl -sk $coinexplorerurl | jq .blockChainHeight)
metricname="explorer.blocks"
value=$highestBlock
sentMetric $host $coin $metricname $value $role $username