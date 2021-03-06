#!/bin/bash

if [ -z "$1" ]
then
    COIN=arcticcoin
else
    COIN=$1
fi
USER=$COIN
COINDIR=.arc
COINSTATUSCMD=arcticstatus

echo stoping service $COIN ...
systemctl stop $COIN

echo removing old files from :
rm -rvf /home/$USER/$COINDIR/{blocks,chainstate,backups,database}
rm -rvf /home/$USER/$COINDIR/{*.conf,*.log,.lock,*.dat,*.pid}

echo dir after deletion
pushd /home/$USER/$COINDIR/ && ln -s ../$COIN.conf && popd
chown -R $USER:$USER /home/$USER/
ls -alh /home/$USER/$COINDIR/

echo starting service $COIN ...
systemctl start $COIN && sleep 10 && systemctl status $COIN && $COINSTATUSCMD