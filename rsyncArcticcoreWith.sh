#!/bin/bash

function rsyncArcticCoreWith() {
    
    SOURCE=/home/arcticcoin/.arcticcore
    TARGET=/tmp
    TARGET_IP=$1
    TARGET_USER=rsyncuser
    INCLUDE_FILE=include-list.txt
  cat << EOF > $INCLUDE_FILE
blocks
chainstate
database
EOF
    
    /usr/bin/rsync \
        --log-file=/var/log/rsyncArcticCoreWith.log \
        --archive \
        --safe-links \
        --checksum \
        --ignore-times \
        --progress \
        --stats \
        --include-from= $INCLUDE_FILE \
        --timeout=60 \
        -e "ssh" \
        --rsync-path="sudo rsync" $SOURCE $TARGET_USER@${TARGET_IP}:$TARGET
}

rsyncArcticCoreWith '81.169.223.222'
rsyncArcticCoreWith '107.150.7.213'