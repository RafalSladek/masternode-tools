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

metricname="blocks"
value=$(/usr/bin/$coincli getblockcount)
sentMetric $host $coin $metricname $value $role $username

metricname="connections"
value=$(/usr/bin/$coincli getconnectioncount)
sentMetric $host $coin $metricname $value $role $username

metricname="enabled"
value=$(/usr/bin/curl --silent "https://$zensystembaseurl/api/nodes/$zensystemnodeid/detail?key=$ZEN_SYSTEM_API_KEY" 2>&1 |  jq '.["status"]' | sed "s/\"//g")
success=0
if [[ 'up' == $value ]]; then
    success=1
fi
sentMetric $host $coin $metricname $success $role $username

metricname="status"
netinfo=$(zen-cli getnetworkinfo)
tlsVerified=$(echo $netinfo | jq -r .tls_cert_verified)
nodePublicIp=$(echo $netinfo | jq -r .localaddresses[].address)
myPublicIp=$(mypublicip)
success=0
if [[ 'true' == $tlsVerified ]] && [[ $myPublicIp == $nodePublicIp ]]; then
    success=1
fi
sentMetric $host $coin $metricname $success $role $username