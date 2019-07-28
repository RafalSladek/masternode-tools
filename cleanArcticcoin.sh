#!/bin/bash

if [ -z "$1" ]
then
    COIN=arcticcoin
else
    COIN=$1
fi

COINDIR=.arcticcore
COINSTATUSCMD=arcticstatus

echo stoping service $COIN ...
systemctl stop $COIN

echo removing old files from :
rm -rvf /home/$COIN/$COINDIR/{blocks,chainstate,backups,database}
rm -rvf /home/$COIN/$COINDIR/{goldminenode.conf,*.log,.lock,*.dat,*.pid}

echo dir after deletion
ls -alh /home/$COIN/$COINDIR/

echo starting service $COIN ...
systemctl start $COIN && sleep 10 && systemctl status $COIN && $COINSTATUSCMD