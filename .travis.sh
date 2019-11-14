#!/bin/bash

set -eu

OSSUTIL_BIN=./ossutil64
GIT_HEAD_FILE=.travis_HEAD
GIT_HEAD=""

# --------------------------------------
# config ossutil
$OSSUTIL_BIN config -c oss_config \
    --output-dir oss_out/ \
    -e $OSS_endpoint -i $OSS_accessKeyID -k $OSS_accessKeySecret

# --------------------------------------
# get prev HEAD ID 
if $OSSUTIL_BIN cp -c oss_config -f oss://$OSS_bucket/$GIT_HEAD_FILE ./; then
    read GIT_HEAD < $GIT_HEAD_FILE
fi

# --------------------------------------
# deal with changed files
while read -r status name1 name2; do
    case $status in
        # files added or modified
        A*|M*)
            echo "OSS> UPLOAD: $name1"
            $OSSUTIL_BIN cp -c oss_config -f "$name1" oss://$OSS_bucket/$name1
            ;;

        # files deleted
        D*)
            echo "OSS> DELETE: $name1"
            $OSSUTIL_BIN rm -c oss_config -f oss://$OSS_bucket/$name1
            ;;

        # files renamed
        R*)
            echo "OSS> RENAME: $name1 --> $name2"
            $OSSUTIL_BIN rm -c oss_config -f oss://$OSS_bucket/$name1
            $OSSUTIL_BIN cp -c oss_config -f "$name2" oss://$OSS_bucket/$name2
            ;;

        # others, return error
        *)
            echo "GIT> UNKNOWN: $status:$name1:$name2"
            exit -1
            ;;
    esac
done < <(git diff --name-status $GIT_HEAD HEAD)

# --------------------------------------
# update current HEAD ID
git rev-parse HEAD > $GIT_HEAD_FILE
$OSSUTIL_BIN cp -c oss_config -f $GIT_HEAD_FILE oss://$OSS_bucket/

# remove tmp files
rm -rf oss_config oss_out/ ossutil64
