#!/bin/bash

function prepareExcludeList() {
    EXCLUDE_FILE=exclude-list.txt
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
}


function rsync() {
    sourcedir=$1
    targetuser=rsyncuser
    targetip=$2
    targetdir=/tmp
    
    /usr/bin/rsync \
    --log-file=rsync.log \
    --archive \
    --progress \
    --human-readable \
    --stats \
    --delete-excluded \
    --exclude-from=$EXCLUDE_FILE \
    --timeout=60 \
    -e "ssh" \
    --rsync-path="sudo rsync" $sourcedir $targetuser@$targetip:$targetdir
}


prepareExcludeList
rsync /home/zen/.zen 81.169.223.222