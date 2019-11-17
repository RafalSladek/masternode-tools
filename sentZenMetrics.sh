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
myPublicIp=$(mypublicip)

metricname="node.blocks"
value=$(/usr/bin/$coincli getblockcount)
sentMetric $host $coin $metricname $value $role $username

metricname="node.connections"
value=$(/usr/bin/$coincli getconnectioncount)
sentMetric $host $coin $metricname $value $role $username

metricname="node.enabled"
apiInfo=$(/usr/bin/curl --silent "https://$zensystembaseurl/api/nodes/$zensystemnodeid/detail?key=$ZEN_SYSTEM_API_KEY")
status=$(echo $apiInfo | jq -r .status)
nodeIp4=$(echo $apiInfo | jq -r .ip4)
nodefqdn=$(echo $apiInfo | jq -r .fqdn)

success=0
if [ 'up' == $status ] && [ $myPublicIp == $nodeIp4 ] && [ $nodefqdn == $FQDN ]; then
    success=1
fi
sentMetric $host $coin $metricname $success $role $username

metricname="node.status"
netinfo=$(/usr/bin/$coincli getnetworkinfo)
tlsVerified=$(echo $netinfo | jq -r .tls_cert_verified)
nodePublicIp=$(echo $netinfo | jq -r .localaddresses[].address)
success=0
if [ 'true' == $tlsVerified ] && [ $myPublicIp == $nodePublicIp ]; then
    success=1
fi
sentMetric $host $coin $metricname $success $role $username