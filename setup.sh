#!/bin/bash
#set -xuo

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

cd zen

for i in `ls -l | awk '{ if ( $1 ~ /x/ ) {print $NF}}'`;
do
    if [ -x $i ]
    then
        rm -rf $TARGETPATH/$i && echo "removed old $TARGETPATH/$i"
        ln -s $SCRIPTPATH/$i $TARGETPATH/$i && echo "linked new $SCRIPTPATH/$i"
    fi
done

cd $TARGETPATH
echo "deleting invalid links..."
find . -xtype l -exec rm {} \;

echo "verify deletion of invalid links"
find . -xtype l

echo "list of exisintg links.."
ls -lhaF | grep ^l

source /usr/local/bin/tools.sh