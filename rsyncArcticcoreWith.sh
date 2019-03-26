#!/bin/bash

function rsyncArcticCoreWith() {
    
    SOURCE=/home/arcticcoin/.arcticcore
    TARGET=/tmp
    TARGET_IP=$1
    TARGET_USER=rsyncuser
    EXCLUDE_FILE=exclude-list.txt
  cat << EOF > $EXCLUDE_FILE
debug.log
db.log
wallet.dat
banlist.dat
fee_estimates.dat
gmcache.dat
gmpayments.dat
governance.dat
netfulfilled.dat
peers.dat
arcticcoin.conf
goldminenode.conf
arcticcoind.pid
.lock
backups
EOF
    
    /usr/bin/rsync \
        --log-file=/var/log/rsyncArcticCoreWith.log \
        --quiet \
        --archive \
        --safe-links \
        --checksum \
        --ignore-times \
        --progress \
        --stats \
        --exclude-from $EXCLUDE_FILE \
        --timeout=60 \
        -e "ssh" \
        --rsync-path="sudo rsync" $SOURCE $TARGET_USER@${TARGET_IP}:$TARGET
}

rsyncArcticCoreWith '81.169.223.222'
rsyncArcticCoreWith '107.150.7.213'