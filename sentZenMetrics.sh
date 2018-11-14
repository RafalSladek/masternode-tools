#!/bin/bash
#set -xe
source /usr/local/bin/ddhelper.sh

host=$(hostname)
coin="zen"
role="masternode"
username=$(whoami)
coindaemon="zend"
coincli="zen-cli"

metricname="blocks"
value=$(/usr/local/bin/$coincli getblockcount)
    sentMetric $host $coin $metricname $value $role $username

metricname="connections"
value=$(/usr/local/bin/$coincli getconnectioncount)
    sentMetric $host $coin $metricname $value $role $username

metricname="enabled"
zensystemnodeid=81783
zensystembaseurl=securenodes2.eu.zensystem.io
value=$(/usr/bin/curl --silent "https://$zensystembaseurl/api/nodes/$zensystemnodeid/detail?key=$ZEN_SYSTEM_API_KEY" 2>&1 | | jq '.["status"]' | sed "s/\"//g")
success=0
if [[ 'up' == $value ]]; then
    success=1
fi
    sentMetric $host $coin $metricname $value $role $username

metricname="status"
value=$(/usr/local/bin/$coincli getnetworkinfo | /bin/grep tls_cert_verified | /usr/bin/awk -F' ' '{printf "%s",$2}' | /usr/bin/tr -d ",")
success=0
if [[ 'true' == $value ]]; then
    success=1
fi
    sentMetric $host $coin $metricname $value $role $username