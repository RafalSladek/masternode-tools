#!/bin/bash
#set -xue
source /usr/local/bin/tools.sh

COINUSER=arcticcoin
COINEXPLORER=http://explorer.arcticcoin.org/api/getblockcount
COINPATH=/home/$COINUSER/.arcticcore

function wipeArcticoinChain() {
    cd $COINPATH
    echo "deleting coinf files from $COINPATH in progress..."
    sudo rm -vf *.log *.dat .lock && \
    sudo rm -vrf backups blocks chainstate database && \
    sudo systemctl start arcticcoin && \
    echo "coin daemon $COINUSER is started ..."
}

localBlock=$(runCommandWithUser $COINUSER 'arcticcoin-cli getblockcount')
globalBlock=$(curl -sk "$COINEXPLORER")

if [[ "$localBlock" == "$globalBlock" ]]; then
    echo "Yeee, your arcticcoin is in sync"
    arcticstatus
else
    echo "local blocks:  $localBlock"
    echo "global blocks: $globalBlock"
    sudo systemctl stop arcticcoin &&  wipeArcticoinChain
    arcticstatus
fi
