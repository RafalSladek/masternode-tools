#!/bin/bash

set -euo pipefail
source /usr/local/bin/ddhelper.sh
source /usr/local/bin/tools.sh

host=$(hostname)
coin="evmapp"
role="forgernode"
username=$(whoami)
explorerCmd="curl -sX GET https://eon-explorer-api.horizenlabs.io/api/v2/blocks?type=block -H 'accept: application/json'"

info=$(runEvamppCall "node/info")

value=$(echo $info | jq -r .result.nodeName)
metricname="$coin.node.name"
sentMetric $host $coin $metricname $value $role $username

value=$(echo $info | jq -r .result.nodeVersion)
metricname="$coin.node.version"
sentMetric $host $coin $metricname $value $role $username

value=$(echo $info | jq -r .result.numberOfConnectedPeers)
metricname="$coin.node.numberOfConnectedPeers"
sentMetric $host $coin $metricname $value $role $username

value=$(echo $info | jq -r '.result.errors | length')
metricname="$coin.node.numberOfErrors"
sentMetric $host $coin $metricname $value $role $username

value=$(runEvamppCall "block/best" | jq .result.height)
metricname="$coin.node.highestBlock"
sentMetric $host $coin $metricname $value $role $username

value=$(eval $explorerCmd | jq -r .next_page_params.block_number)
metricname="$coin.explorer.highestblock"
sentMetric $host $coin $metricname $value $role $username
