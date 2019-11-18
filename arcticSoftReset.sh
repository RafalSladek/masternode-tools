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

function copying() {
    cd $COINPATH
    echo "coin daemon $COINUSER is copying and linking ..."
    runCommandWithUser $COINUSER "cd $COINPATH && rm -rf * && rm -rf .lock"
    cd $COINPATH && cp -r /tmp/.arc/* . && chown -R $COINUSER:$COINUSER $COINPATH
    runCommandWithUser $COINUSER "rm -f /home/$COINUSER/.arc/arc.conf && cd $COINPATH && ln -s /home/$COINUSER/arc.conf"
}

function main(){
    localBlock=$(runCommandWithUser $COINUSER 'arc-cli getblockcount')
    globalBlock=$(curl -sk "$COINEXPLORER")
    
    if [[ "$localBlock" == "$globalBlock" ]]; then
        echo "Yeee, your $COINUSER is in sync"
        arcticstatus $COINUSER
    else
        echo "local blocks:  $localBlock"
        echo "global blocks: $globalBlock"
        sudo systemctl stop $COINUSER && copying && sudo systemctl start $COINUSER
        arcticstatus $COINUSER
    fi
}

main