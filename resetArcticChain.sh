#!/bin/bash

set -xue

sudo systemctl stop arcticcoin

cd /home/arcticcoin/.arcticcore
ls -al
sudo rm -vf *.log *.dat .lock
sudo rm -vrf backups blocks chainstate database
ls -al
sudo systemctl start arcticcoin
watch arcticstatus
