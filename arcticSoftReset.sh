#!/bin/bash
set -xue
source /usr/local/bin/tools.sh

COINUSER=arcticcoin
COINEXPLORER=http://explorer.arcticcoin.org/api/getblockcount
COINPATH=/home/$COINUSER/.arcticcore

function reindexing() {
    cd $COINPATH
    echo "coin daemon $COINUSER is reindexing ..."
    runCommandWithUser $COINUSER 'arcticcoind -reindex'
}

localBlock=$(runCommandWithUser $COINUSER 'arcticcoin-cli getblockcount')
globalBlock=$(curl -sk "$COINEXPLORER")

if [[ "$localBlock" == "$globalBlock" ]]; then
    echo "Yeee, your arcticcoin is in sync"
    arcticstatus
else
    echo "local blocks:  $localBlock"
    echo "global blocks: $globalBlock"
    sudo systemctl stop arcticcoin &&  reindexing
    arcticstatus
fi
