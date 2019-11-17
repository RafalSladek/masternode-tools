#!/bin/bash

if [ -z "$1" ]
then
    COIN=cropcoin
else
    COIN=$1
fi
USER=$COIN
COINDIR=.cropcoin
COINSTATUSCMD=cropstatus

echo stoping service $COIN ...
systemctl stop $COIN

echo removing old files from :
rm -rvf /home/$USER/$COINDIR/{blocks,backups,database,smsgDB,txleveldb}
rm -rvf /home/$USER/$COINDIR/{*.conf,*.log,.lock,*.dat,*.pid,*.ini}

echo dir after deletion
pushd /home/$USER/$COINDIR/ && ln -s ../$COIN.conf && popd
chown -R $USER:$USER /home/$USER/
ls -alh /home/$USER/$COINDIR/

echo starting service $COIN ...
systemctl start $COIN && sleep 10 && systemctl status $COIN && $COINSTATUSCMD