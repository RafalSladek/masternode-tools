#!/bin/bash
#set -xe
source /usr/local/bin/ddhelper.sh
source /usr/local/bin/tools.sh

host=$(hostname)
coin="zen"
role="forgernode"
username=$(whoami)
coincli="docker compose -f /opt/compose-evm-simplified/deployments/forger/eon/docker-compose.yml exec zend gosu user zen-cli"
publicIp=$(mypublicip)

metricname="node.highestblock"
value=$($coincli getblockcount)
sentMetric $host $coin $metricname $value $role $username

netinfo=$($coincli getnetworkinfo)

nodeConnections=$(echo $netinfo | jq -r .connections)
metricname="node.connections"
sentMetric $host $coin $metricname $nodeConnections $role $username

nodeVersion=$(echo $netinfo | jq -r .version)
metricname="node.version"
sentMetric $host $coin $metricname $nodeVersion $role $username

nodeScore=$(echo $netinfo | jq -r .localaddresses[].score)
metricname="node.score"
sentMetric $host $coin $metricname $nodeScore $role $username

nodeIPv4Reachable=$(echo $netinfo | jq -r .networks[0].reachable)
metricname="node.nodeIPv4Reachable"
sentMetric $host $coin $metricname $nodeIPv4Reachable $role $username

nodeIPv6Reachable=$(echo $netinfo | jq -r .networks[1].reachable)
metricname="node.nodeIPv6Reachable"
sentMetric $host $coin $metricname $nodeIPv6Reachable $role $username

nodePublicIp=$(echo $netinfo | jq -r .localaddresses[].address)
success=0
if [ 'true' == "$nodeIPv4Reachable" ] && [ "$publicIp" == "$nodePublicIp" ]; then
    success=1
fi
metricname="node.status"
sentMetric $host $coin $metricname $success $role $username

