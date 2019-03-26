#!/bin/bash
#set -xue
source /usr/local/bin/tools.sh

COINUSER=arcticcoin
SSHUSER=rsladek
SSHCMD=arcticSoftReset.sh

function main(){
    config=$(runCommandWithUser $COINUSER 'arcticcoin-cli goldminenode list-conf')
    ipToReset=$(echo $config | sed -e 's/{/[/1' | sed -e 's/}$/]/1' | sed -e 's/:7209//g' | sed -e 's/\"goldminenode\"://g' | jq -r '.[] | select(.status!="ENABLED") | .address')

    for ip in $(echo $ipToReset)
    do
            echo "ssh and remote $SSHCMD on $ip ..."
            ssh -t $SSHUSER@$ip "$SSHCMD"
    done
    echo "FINISHED"
}
main