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
rm -rvf /home/$USER/$COINDIR/{blocks,chainstate,backups,database}
rm -rvf /home/$USER/$COINDIR/{*.log,.lock,fee_estimates.dat,peers.dat,*.conf,wallet.dat}

echo dir after deletion
pushd /home/$USER/$COINDIR/ && ln -s ../$COIN.conf && ln -s ../wallet.dat.strato1 wallet.dat && popd
chown -R $USER:$USER /home/$USER/
ls -alh /home/$USER/$COINDIR/

echo starting service $COIN ...
systemctl start $COIN && sleep 10 && systemctl status $COIN && $COINSTATUSCMD