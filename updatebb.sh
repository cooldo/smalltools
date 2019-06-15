#!/bin/bash
CPDIR=
cp center-console-*.tar.gz    "$CPDIR"/example-center-console/files/
cp discovery-hud-*.tar.gz     "$CPDIR"/example-discovery-hud/files/
cp discovery-rse-*.tar.gz     "$CPDIR"/example-rse-demo/files/
cp kria-cluster-2d-*.tar.gz   "$CPDIR"/example-kria-cluster-2d/files/
cp ts-cluster-*.tar.gz        "$CPDIR"/example-ts-cluster/files/

APPNAME=$(ls *.tar.gz)
cd "$CPDIR"

for DEST in $APPNAME
do
    SOURCE=${DEST%-2019*}
    BBFILE=$(find -name "*.bb" | xargs grep -nr "$SOURCE" | grep "tar.gz" | cut -d":" -f1)
    if [[ $BBFILE == "" ]];then
        continue
    fi
    sed -n "s|file://"$SOURCE".*tar.gz|file://"$DEST"|p" "$BBFILE"
done

