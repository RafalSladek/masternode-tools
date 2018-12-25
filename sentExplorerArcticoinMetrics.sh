#!/bin/bash
#set -xe
source /usr/local/bin/ddhelper.sh

host=$(hostname)
coin="arcticcoin"
role="masternode"
username=$(whoami)

highestBlock=$(curl -s http://explorer.arcticcoin.org/api/getblockcount)
metricname="explorer.blocks"
value=$highestBlock
    sentMetric $host $coin $metricname $value $role $username