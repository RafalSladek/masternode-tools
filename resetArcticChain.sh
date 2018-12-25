#!/bin/bash

set -xue
COINUSER=arcticcoin

function wipeArcticoinChain() {
    cd /home/arcticcoin/.arcticcore
    ls -al
    sudo rm -vf *.log *.dat .lock
    sudo rm -vrf backups blocks chainstate database
    ls -al
}

function runCommandWithUser() {
    COINUSER=$1
    COMMAND=$2
    sudo -u $COINUSER -H sh -c "$COMMAND"
}

sudo systemctl stop arcticcoin

runCommandWithUser $COINUSER 'arcticcoind -rescan' && localBlock=$(runCommandWithUser $COINUSER 'arcticcoin-cli getblockcount')
globalBlock=$(curl -s http://explorer.arcticcoin.org/api/getblockcount)
if [[ "$localBlock" == "$globalBlock" ]]; then
    echo "Yeee, your arcticcoin is in sync"
    runCommandWithUser $COINUSER 'arcticcoin-cli stop'
    sudo systemctl start arcticcoin
    arcticstatus
else
    runCommandWithUser $COINUSER 'arcticcoin-cli stop'
    runCommandWithUser $COINUSER 'arcticcoind -reindex' 
    arcticstatus
    localBlock=$(runCommandWithUser $COINUSER 'arcticcoin-cli getblockcount')
    globalBlock=$(curl -s http://explorer.arcticcoin.org/api/getblockcount)
    if [[ "$localBlock" == "$globalBlock" ]]; then
        echo "Yeee, your arcticcoin is in sync after second try"
        runCommandWithUser $COINUSER 'arcticcoin-cli stop'
        sudo systemctl start arcticcoin
    else
        echo "hard way..."
    fi
fi
