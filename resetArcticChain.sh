#!/bin/bash

set -xue

source /usr/local/bin/tools.sh

COINUSER=arcticcoin
COINEXPLORER=http://explorer.arcticcoin.org/api/getblockcount

function wipeArcticoinChain() {
    cd /home/arcticcoin/.arcticcore
    ls -al
    sudo rm -vf *.log *.dat .lock
    sudo rm -vrf backups blocks chainstate database
    ls -al
}
localBlock=$(runCommandWithUser $COINUSER 'arcticcoin-cli getblockcount')
globalBlock=$(curl -sk "$COINEXPLORER")

if [[ "$localBlock" == "$globalBlock" ]]; then
    echo "Yeee, your arcticcoin is in sync"
    runCommandWithUser $COINUSER 'arcticcoin-cli stop'
    sudo systemctl start arcticcoin
    arcticstatus
else
    runCommandWithUser $COINUSER 'arcticcoin-cli stop'
    runCommandWithUser $COINUSER 'arcticcoind -rescan'
    #runCommandWithUser $COINUSER 'arcticcoind -reindex' 
    arcticstatus
    localBlock=$(runCommandWithUser $COINUSER 'arcticcoin-cli getblockcount')
    globalBlock=$(curl -sk "$COINEXPLORER")
    if [[ "$localBlock" == "$globalBlock" ]]; then
        echo "Yeee, your arcticcoin is in sync after second try"
        runCommandWithUser $COINUSER 'arcticcoin-cli stop'
        sudo systemctl start arcticcoin
    else
        echo "hard way..."
    fi
fi
