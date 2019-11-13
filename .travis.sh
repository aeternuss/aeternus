#!/bin/bash

OSSUTIL_BIN=./ossutil64
GIT_HEAD_ID_FILE=.travis_HEAD

# --------------------------------------
# config ossutil
$OSSUTIL_BIN config -c oss_config \
    --output-dir oss_out/ \
    -e $OSS_endpoint -i $OSS_accessKeyID -k $OSS_accessKeySecret

# --------------------------------------
# get prev HEAD ID 
$OSSUTIL_BIN cp -c oss_config -f oss://$OSS_bucket/$GIT_HEAD_ID_FILE ./

if [ -f $GIT_HEAD_ID_FILE ]; then
    read PREV_HEAD < $GIT_HEAD_ID_FILE
fi

# --------------------------------------
# upload changed files
while read -r status name1 name2; do
    case $status in
        # files added or modified
        A*|M*)
            echo "UPLOAD: $name1"
            $OSSUTIL_BIN cp -c oss_config -f "$name1" oss://$OSS_bucket/$name1
            ;;

        # files deleted
        D*)
            echo "DELETE: $name1"
            $OSSUTIL_BIN rm -c oss_config -f oss://$OSS_bucket/$name1
            ;;

        # files renamed
        R*)
            echo "DELETE: $name1"
            $OSSUTIL_BIN rm -c oss_config -f oss://$OSS_bucket/$name1

            echo "UPLOAD: $name2"
            $OSSUTIL_BIN cp -c oss_config -f "$name2" oss://$OSS_bucket/$name2
            ;;

        # others
        *)
            echo "UNKNOW: $name1:$name2"
            exit -1
            ;;
    esac
done < <(git diff --name-status $PREV_HEAD HEAD)

# --------------------------------------
# update current HEAD id
git rev-parse HEAD > $GIT_HEAD_ID_FILE
$OSSUTIL_BIN cp -c oss_config -f $GIT_HEAD_ID_FILE oss://$OSS_bucket/

# remove tmp files
rm -rf oss_config oss_out/ ossutil64
