#!/bin/bash

echo "setting up everthing ..."

SCRIPT=$(readlink -f "$0")
SCRIPTPATH=$(dirname "$SCRIPT")

for i in `ls -l | awk '{ if ( $1 ~ /x/ ) {print $NF}}'`; 
    do [ -x $i ] && echo "linking $SCRIPTPATH/$i ..."; 
done