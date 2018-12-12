#!/bin/bash
set -xuo

echo "setting up everthing ..."

SCRIPT=$(readlink -f "$0")
SCRIPTPATH=$(dirname "$SCRIPT")
TARGETPATH=/usr/local/bin

for i in `ls -l | awk '{ if ( $1 ~ /x/ ) {print $NF}}'`; 
    do
    if [ -x $i ]
	then
        rm -rf $TARGETPATH/$i && echo "removed old $TARGETPATH/$i"
        ln -s $SCRIPTPATH/$i $TARGETPATH/$i && echo "linked new $SCRIPTPATH/$i"
    fi
done

cd $TARGETPATH && ls -lhaF | grep ^l