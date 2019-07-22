#!/bin/bash
if [ -z "$1" ]
then
    COIN=zen
else
    COIN=$1
fi

COINDIR=.zen
COINSTATUSCMD=zenstatus

echo stoping service $COIN ...
systemctl stop $COIN

echo removing old files
rm -rvf /home/$COIN/$COINDIR/{blocks,chainstate,backups,database}
rm -rvf /home/$COIN/$COINDIR/{*.log,.lock,fee_estimates.dat,peers.dat}

echo dir after deletion
ls -alh /home/$COIN/$COINDIR/

echo starting service $COIN ...
systemctl start $COIN && sleep 10 && systemctl status $COIN && $COINSTATUSCMD