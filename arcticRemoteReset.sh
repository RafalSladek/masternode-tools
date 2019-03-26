#!/bin/bash
#set -xue
source /usr/local/bin/tools.sh

COINUSER=arcticcoin
SSHUSER=rsladek
SSHCMD=arcticSoftReset.sh

function main(){
    config=$(runCommandWithUser $COINUSER 'arcticcoin-cli goldminenode list-conf')
    ipToReset=$(echo $config | sed -e 's/{/[/1' | sed -e 's/}$/]/1' | sed -e 's/:7209//g' | sed -e 's/\"goldminenode\"://g' | jq -r '.[] | select(.status!="ENABLED") | .address')

    echo "Starting remote masternode daemons..."
    for ip in $(echo $ipToReset)
    do
            echo "ssh and remote $SSHCMD on $ip ..."
            ssh -t $SSHUSER@$ip "$SSHCMD"
    done

    aliasesReset=$(echo $config | sed -e 's/{/[/1' | sed -e 's/}$/]/1' | sed -e 's/:7209//g' | sed -e 's/\"goldminenode\"://g' | jq -r '.[] | select(.status!="ENABLED") | .alias')
    for alias in $(echo $aliasesReset)
    do
            echo "starting masternode $alias ..."
            runCommandWithUser $COINUSER "arcticcoin-cli walletpassphrase ${ARC_PASS_WALLET} 99999999 && arcticcoin-cli goldminenode start-alias ${alias} && arcticcoin-cli walletlock"
    done
     echo "Finished remote masternode daemons..."
}
main