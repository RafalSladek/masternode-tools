#!/bin/bash
#set -xe

source tools.sh

function prepareExcludeList() {
    EXCLUDE_FILE=exclude-list.txt
cat << EOF > $EXCLUDE_FILE
*wallet.dat*
*banlist.dat*
*fee_estimates.dat*
*gmcache.dat*
*governance.dat*
*gmpayments.dat*
*netfulfilled.dat*
*peers.dat*
debug.log
db.log
backups*
.lock
*.pid
*.conf
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

function main(){
    prepareExcludeList
    ips=('81.169.223.222')
    for ip in "${ips[@]}"
    do
        echo -e "${GREE}rsync starting for $ip ...${NC}"
        rsync /home/zen/.zen $ip
    done
}

main