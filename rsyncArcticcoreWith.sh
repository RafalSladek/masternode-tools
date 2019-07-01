#!/bin/bash

function rsyncArcticCoreWith() {
    
    SOURCE=/home/arcticcoin/.arcticcore
    TARGET=/tmp
    TARGET_IP=$1
    TARGET_USER=rsyncuser
    EXCLUDE_FILE=exclude-list.txt
    INCLUDE_FILE=include-list.txt
    
cat << EOF > $EXCLUDE_FILE
*wallet.dat*
*.conf
debug.log
db.log
backups*
.lock
*.pid
*banlist.dat*
*fee_estimates.dat*
*gmcache.dat*
*governance.dat*
*gmpayments.dat*
*netfulfilled.dat*
*peers.dat*
EOF
    
cat << EOF > $INCLUDE_FILE
chainstate*
blocks*
database*
EOF
    
    /usr/bin/rsync \
    --log-file=/var/log/rsyncArcticCoreWith.log \
    --archive \
    --progress \
    --human-readable \
    --stats \
    --delete-excluded \
    --exclude-from=$EXCLUDE_FILE \
    --timeout=60 \
    -e "ssh" \
    --rsync-path="sudo rsync" $SOURCE $TARGET_USER@${TARGET_IP}:$TARGET
}

function main(){
    ips=('81.169.223.222')
    for ip in "${ips[@]}"
    do
        echo "rsync starting for $ip ..."
        rsyncArcticCoreWith $ip
    done
}

main