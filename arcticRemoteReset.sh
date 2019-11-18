#!/bin/bash
#set -xue
source /usr/local/bin/tools.sh

if [ -z "$1" ]
then
    COINUSER=arcticcoin
else
    COINUSER=$1
fi

SSHUSER=rsladek
SSHCMD=arcticSoftReset.sh

function main(){
    config=$(runCommandWithUser $COINUSER 'arc-cli goldminenode list-conf')
    json_config=$(echo $config | sed -e 's/{/[/1' | sed -e 's/}$/]/1' | sed -e 's/:7209//g' | sed -e 's/\"goldminenode\"://g')
    number_of_masternode_to_restart=$(echo $json_config | jq -r '.[] | select([.status] | inside(["ENABLED", "PRE_ENABLED"]) | not) | length')
    ipsToReset=$(echo $json_config | jq -r '.[] | select([.status] | inside(["ENABLED", "PRE_ENABLED"]) | not) | .address')
    
    echo "Starting ${number_of_masternode_to_restart} remote masternode daemons..."
    for ip in $(echo $ipsToReset)
    do
        echo "ssh and remote $SSHCMD on $ip ..."
        ssh -t $SSHUSER@$ip "$SSHCMD"
    done
    
    aliasesReset=$(echo $json_config | jq -r '.[] | select([.status] | inside(["ENABLED", "PRE_ENABLED"]) | not) | .alias')
    for alias in $(echo $aliasesReset)
    do
        echo "starting masternode $alias ..."
        runCommandWithUser $COINUSER "arc-cli walletpassphrase ${ARC_PASS_WALLET} 99999999 && arc-cli goldminenode start-alias ${alias} && arc-cli walletlock"
    done
    echo "Finished remote masternode daemons..."
}
main