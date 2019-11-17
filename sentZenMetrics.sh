#!/bin/bash
#set -xe
source /usr/local/bin/ddhelper.sh
source /usr/local/bin/tools.sh

host=$(hostname)
coin="zen"
role="securenode"
username=$(whoami)
coindaemon="zend"
coincli="zen-cli"
publicIp=$(mypublicip)
coinexplorerurl=https://explorer.horizen.global/insight-api-zen/sync

metricname="node.highestblock"
value=$(/usr/bin/$coincli getblockcount)
sentMetric $host $coin $metricname $value $role $username

metricname="node.connections"
value=$(/usr/bin/$coincli getconnectioncount)
sentMetric $host $coin $metricname $value $role $username

metricname="node.active"
apiInfo=$(/usr/bin/curl --silent "https://$zensystembaseurl/api/nodes/$zensystemnodeid/detail?key=$ZEN_SYSTEM_API_KEY")
status=$(echo $apiInfo | jq -r .status)
nodeIp4=$(echo $apiInfo | jq -r .ip4)
nodefqdn=$(echo $apiInfo | jq -r .fqdn)
value=0
if [ 'up' == $status ] && [ $publicIp == $nodeIp4 ] && [ $nodefqdn == $FQDN ]; then
    value=1
fi
sentMetric $host $coin $metricname $value $role $username

metricname="node.status"
netinfo=$(/usr/bin/$coincli getnetworkinfo)
tlsVerified=$(echo $netinfo | jq -r .tls_cert_verified)
nodePublicIp=$(echo $netinfo | jq -r .localaddresses[].address)
success=0
if [ 'true' == $tlsVerified ] && [ $publicIp == $nodePublicIp ]; then
    success=1
fi
sentMetric $host $coin $metricname $success $role $username

metricname="explorer.highestblock"
highestBlock=$(curl -sk $coinexplorerurl | jq .blockChainHeight)
value=$highestBlock
sentMetric $host $coin $metricname $value $role $username