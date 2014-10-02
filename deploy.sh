#!/bin/sh

if [ $# -lt 2 ]; then
    echo "Usage: $0 <release-tarball> <install-dir> [<predeploy arguments>, <postdeploy arguments>]"
    exit 1
fi

TARBALL=$1
INSTALL_DIR=$2
PRE_DEPLOY_ARGS=$3
POST_DEPLOY_ARGS=$4

if [ ! -d "$INSTALL_DIR" ]; then
    echo "$INSTALL_DIR must be a directory"
    exit 2
fi

if [ ! -f "$TARBALL" ]; then
    echo "$TARBALL doesn't exist!"
    exit 3
fi

RESULT_DIR=`echo "$TARBALL" | xargs basename | egrep ".+-[0-9]{14}-.+.tar.gz" | sed -e "s/\(.\+-[0-9]\{14\}-.\+\).tar.gz/\1/"`

if [ "$RESULT_DIR" = "" ]; then
    echo "Tarball $TARBALL doesn't seem to be a proper release file!"
    exit 5
fi

tar xzf "$TARBALL" -C "$INSTALL_DIR"
if [ "$?" -ne 0 ]; then
    echo "Extracting $TARBALL failed"
    exit 6
fi

if [ ! -d "$RESULT_DIR" ]; then
    echo "$RESULT_DIR is not present after extraction?"
    exit 7
fi

if [ -x "$RESULT_DIR/pre_deploy.sh" ]; then
    ./"$RESULT_DIR"/pre_deploy.sh
    if [ "$?" != 0 ]; then
        echo "Pre deploy failed with code $?"
        exit 8
    fi
fi

ln -nsf "$RESULT_DIR" "$INSTALL_DIR"/current
if [ "$?" != 0 ]; then
    echo "Linking to current failed!"
    exit 9
fi

if [ -x "$RESULT_DIR/post_deploy.sh" ]; then
    ./"$RESULT_DIR"/post_deploy.sh "$POST"
    if [ "$?" != 0 ]; then
        echo "Post deploy failed with code $?"
        exit 10
    fi
fi

PREFIX=`echo "$RESULT_DIR" | sed -e "s/\(.\+\)-[0-9]\{14\}-.\+/\1/"`
for i in `ls $INSTALL_DIR | egrep "^$PREFIX-[0-9]{14}-.+" | grep -v "$RESULT_DIR" | tac | tail -n+2`; do
    rm -r "$INSTALL_DIR"/"$i"
done
