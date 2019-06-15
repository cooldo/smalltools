#!/bin/bash

VERSION="$1"
if [[ $# -lt 1 ]];then
    VERSION="v005"
fi

echo $VERSION

GITLIST="kria-cluster-3d-demo kria-cluster-2d-source discovery-hud-source ts-cluster-source multiscreen-demo-single-process-source rse-demo-source"

CURDIR=$(pwd)

rm -rf binary

mkdir binary
for item in $GITLIST
do
    DIR="$item"/*/git/
    if [[ ! -d $DIR ]];then
        echo "directory "$DIR" doesn't exist!!"
        exit 1
    fi
    # use subshell to change directory, this doesn't need to cd back after the end of each iteration
    (
    cd "$DIR"
    COMMIT_ID=$(git log | head -n 1 | tr -s ' ' | cut -d' ' -f2)
    ID=${COMMIT_ID:0:6}
    NAME=${item%-*}
    if [[ "$NAME" == "multiscreen-demo-single-process" ]];then
        NAME="center-console"
    fi
    if [[ "$NAME" == "rse-demo" ]];then
        NAME="discovery-rse"
    fi
    DATE=$(date -d today +"%Y%m%d")
    echo $NAME
    tar czvf "$CURDIR"/binary/"$NAME"-"$DATE"-"$VERSION"-"$ID".tar.gz -C ../image/ opt
    #cd "$CURDIR"
    )
done
