#!/bin/bash
#set -xe
source /usr/local/bin/ddhelper.sh

host=$(hostname)
coin="cropcoin"
role="masternode"
username=$(whoami)
coinexplorerurl=https://cropcoin.blockxplorer.info/api/getblockcount

highestBlock=$(curl -sk $coinexplorerurl)
metricname="explorer.blocks"
value=$highestBlock
    sentMetric $host $coin $metricname $value $role $username