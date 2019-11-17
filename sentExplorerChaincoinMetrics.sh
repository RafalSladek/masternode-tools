#!/bin/bash
#set -xe
source /usr/local/bin/ddhelper.sh

host=$(hostname)
coin="chaincoin"
role="masternode"
username=$(whoami)
coinexplorerurl=https://api.chaincoinexplorer.co.uk/getBlockchainInfo

highestBlock=$(curl -sk $coinexplorerurl | jq .blocks)
metricname="explorer.blocks"
value=$highestBlock
sentMetric $host $coin $metricname $value $role $username