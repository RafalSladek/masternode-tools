#!/bin/bash
#set -xue
source /usr/local/bin/tools.sh


if [ -z "$1" ]
then
    COINUSER=arcticcoin
else
    COINUSER=$1
fi

COINEXPLORER=http://explorer.advtech.group/api/getblockcount
COINPATH=/home/$COINUSER/.arc

function wipeArcticoinChain() {
    cd $COINPATH
    echo "deleting coinf files from $COINPATH in progress..."
    sudo rm -vf *.log *.dat .lock && \
    sudo rm -vrf backups blocks chainstate database && \
    sudo systemctl start $COINUSER && \
    echo "coin daemon $COINUSER is started ..."
}

localBlock=$(runCommandWithUser $COINUSER 'arc-cli getblockcount')
globalBlock=$(curl -sk "$COINEXPLORER")

if [[ "$localBlock" == "$globalBlock" ]]; then
    echo "Yeee, your arcticcoin is in sync"
    arcticstatus $COINUSER
else
    echo "local blocks:  $localBlock"
    echo "global blocks: $globalBlock"
    sudo systemctl stop $COINUSER &&  wipeArcticoinChain
    sleep 30
    arcticstatus $COINUSER
fi
