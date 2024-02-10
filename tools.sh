#!/bin/bash
#set -xe
NC='\033[0m' # no color, reset

RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
BLUE='\033[0;34m'

function runCommandWithUser() {
    COINUSER=$1
    COMMAND=$2
    sudo -u $COINUSER -H sh -c "$COMMAND"
}

function fail2banJailStatus() {
    JAILS=($(sudo fail2ban-client status | grep "Jail list" | sed -E 's/^[^:]+:[ \t]+//' | sed 's/,//g'))
    for JAIL in ${JAILS[@]}
    do
        echo -e "${RED}--------------- 👀  JAIL STATUS: $JAIL ... ---------------${NC}"
        sudo fail2ban-client status $JAIL
        echo -e "${RED}--------------- ... ---------------${NC}"
    done
}

function mypublicip(){
    ip=$(dig +short myip.opendns.com @resolver1.opendns.com)
    if [ -z "$ip" ]; then
       ip=$(curl -s ipinfo.io/ip)
    fi
    echo $ip
}
