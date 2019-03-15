#!/bin/bash

function rsyncArcticCoreWith() {
    
    SOURCE=/home/arcticcoin/.arcticcore
    TARGET=/tmp
    TARGET_IP=$1
    TARGET_USER=rsyncuser
    EXCLUDE_FILE=exclude-list.txt
  cat << EOF > $EXCLUDE_FILE
*.log
wallet.dat
banlist.dat
fee_estimates.dat
gmcache.dat
gmpayments.dat
governance.dat
netfulfilled.dat
peers.dat
*.pid
*.conf
.lock
backups
EOF
    
    /usr/bin/rsync --log-file=/var/log/rsyncArcticCoreWith.log -auP --exclude-from $EXCLUDE_FILE --no-compress --timeout=60 -e "ssh" --rsync-path="sudo rsync" $SOURCE $TARGET_USER@${TARGET_IP}:$TARGET
}

rsyncArcticCoreWith '81.169.223.222'
rsyncArcticCoreWith '107.150.7.213'