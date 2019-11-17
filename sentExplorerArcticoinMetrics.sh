#!/bin/bash
#set -xe
source /usr/local/bin/ddhelper.sh

host=$(hostname)
coin="arcticcoin"
role="masternode"
username=$(whoami)
coinexplorerurl=http://explorer.advtech.group/api/getblockcount

highestBlock=$(curl -sk $coinexplorerurl)
metricname="explorer.blocks"
value=$highestBlock
sentMetric $host $coin $metricname $value $role $username