#!/bin/bash

COIN=arcticcoin
COINDIR=.arcticcore
COINSTATUSCMD=arcticstatus

echo stoping service $COIN ...
systemctl stop $COIN

echo removing old files from :
rm -rvf /home/$COIN/$COINDIR/{blocks,chainstate,backups,database,goldminenode.conf,*.log,.lock,*.dat,*.pid}

echo dir after deletion
ls -alh /home/$COIN/$COINDIR/

echo starting service $COIN ...
systemctl start $COIN && sleep 10 && systemctl status $COIN && $($COINSTATUSCMD)