#!/bin/bash
#set -xe
source /usr/local/bin/ddhelper.sh

host=$(hostname)
coin="zen"
role="forgernode"
username=$(whoami)
coinexplorerurl=https://explorer.horizen.global/insight-api-zen/sync

metricname="explorer.highestblock"
response=$(curl -sk $coinexplorerurl)
value=$(echo $response | jq .blockChainHeight)
sentMetric $host $coin $metricname $value $role $username

