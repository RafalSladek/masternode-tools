#!/bin/bash
#set -xe
source /usr/local/bin/ddhelper.sh
source /usr/local/bin/tools.sh

host=$(hostname)
coin="evmapp"
role="forgernode"
username=$(whoami)
infoCmd='docker exec evmapp gosu user curl -sX POST http://127.0.0.1:9545/node/info -H "accept: application/json"'
blockCmd='docker exec evmapp gosu user curl -sX POST http://127.0.0.1:9545/block/best -H "accept: application/json"'

info=$(runEvamppCall "node/info")

value=$(echo $info | jq -r .result.nodeName)
metricname="$coin.nodeName"
sentMetric $host $coin $metricname $value $role $username


value=$(echo $info | jq -r .result.nodeVersion)
metricname="$coin.nodeVersion"
sentMetric $host $coin $metricname $value $role $username

value=$(echo $info | jq -r .result.scBlockHeight)
metricname="$coin.scBlockHeight"
sentMetric $host $coin $metricname $value $role $username

value=$(echo $info | jq -r .result.numberOfConnectedPeers)
metricname="$coin.numberOfConnectedPeers"
sentMetric $host $coin $metricname $value $role $username

value=$(echo $info | jq -r '.result.errors | length')
metricname="$coin.numberOfErrors"
sentMetric $host $coin $metricname $value $role $username

value=$(runEvamppCall "block/best" | jq .result.height)
metricname="$coin.highestBlock"
sentMetric $host $coin $metricname $value $role $username

