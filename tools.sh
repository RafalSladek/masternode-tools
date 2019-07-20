#!/bin/bash
#set -xe

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

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
    echo -e "${RED}$(curl -s ifconfig.me/ip)${NC}"
}