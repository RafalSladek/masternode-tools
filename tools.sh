#!/bin/bash
#set -xe

function runCommandWithUser() {
    COINUSER=$1
    COMMAND=$2
    sudo -u $COINUSER -H sh -c "$COMMAND"
}

function fail2banJailStatus() {
    JAILS=($(sudo fail2ban-client status | grep "Jail list" | sed -E 's/^[^:]+:[ \t]+//' | sed 's/,//g'))
    for JAIL in ${JAILS[@]}
    do
        echo "--------------- 👀  JAIL STATUS: $JAIL ... ---------------"
        sudo fail2ban-client status $JAIL
        echo "--------------- ... ---------------"
    done
}

function mypublicip(){
    echo $(curl -s ifconfig.me/ip)
}

function getZenBalancesByAddress() {
    address=%1
    balance=$(zen-cli z_getbalance $address)
    echo "$address,$balance"
}