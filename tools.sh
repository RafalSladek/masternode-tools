#!/bin/bash
#set -xe

function runCommandWithUser() {
    COINUSER=$1
    COMMAND=$2
    sudo -u $COINUSER -H sh -c "$COMMAND"
}