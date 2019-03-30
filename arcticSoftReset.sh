#!/bin/bash
#set -xue
source /usr/local/bin/tools.sh

COINUSER=arcticcoin
COINEXPLORER=http://explorer.arcticcoin.org/api/getblockcount
COINPATH=/home/$COINUSER/.arcticcore

function copying() {
    cd $COINPATH
    echo "coin daemon $COINUSER is copying and linking ..."
    runCommandWithUser $COINUSER "cd $COINPATH && rm -rf * && rm -rf .lock"
    runCommandWithUser $COINUSER "cd $COINPATH && cp -r /tmp/.arcticcore/* ."
    runCommandWithUser $COINUSER "cd $COINPATH && ln -s ../arcticcoin.conf"
}

function main(){
    localBlock=$(runCommandWithUser $COINUSER 'arcticcoin-cli getblockcount')
    globalBlock=$(curl -sk "$COINEXPLORER")

    if [[ "$localBlock" == "$globalBlock" ]]; then
        echo "Yeee, your arcticcoin is in sync"
        arcticstatus
    else
        echo "local blocks:  $localBlock"
        echo "global blocks: $globalBlock"
        sudo systemctl stop arcticcoin && copying && sudo systemctl start arcticcoin
        arcticstatus
    fi
}

main