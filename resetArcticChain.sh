#!/bin/bash
set -xue
source /usr/local/bin/tools.sh

COINUSER=arcticcoin
COINEXPLORER=http://explorer.arcticcoin.org/api/getblockcount

function wipeArcticoinChain() {
    #runCommandWithUser $COINUSER 'arcticcoin-cli stop'
    #runCommandWithUser $COINUSER 'arcticcoind -rescan'
    #runCommandWithUser $COINUSER 'arcticcoind -reindex'
    cd /home/arcticcoin/.arcticcore
    ls -al
    sudo rm -vf *.log *.dat .lock
    sudo rm -vrf backups blocks chainstate database
    ls -al
    sudo systemctl start arcticcoin
}

localBlock=$(runCommandWithUser $COINUSER 'arcticcoin-cli getblockcount')
globalBlock=$(curl -sk "$COINEXPLORER")

if [[ "$localBlock" == "$globalBlock" ]]; then
    echo "Yeee, your arcticcoin is in sync"
    arcticstatus
else
    wipeArcticoinChain
fi
