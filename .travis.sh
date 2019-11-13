#!/bin/bash

OSSUTIL_BIN=./ossutil64
GIT_HEAD_ID_FILE=.travis_HEAD

# config ossutil
$OSSUTIL_BIN config -c oss_config \
    -e $OSS_endpoint -i $OSS_accessKeyID -k $OSS_accessKeySecret

# get prev HEAD ID 
$OSSUTIL_BIN cp -c oss_config --output-dir oss_out/ -f \
    oss://$OSS_bucket/$GIT_HEAD_ID_FILE ./

if [ -f $GIT_HEAD_ID_FILE ]; then
    read PREV_HEAD < $GIT_HEAD_ID_FILE
fi

# upload changed files
while read -r file; do
    echo "UPLOAD: $file"

    # update oss_dir name
    #     .          ->  NULL
    #     ./sub/dir  ->  ./sub/dir/
    oss_dir=$(dirname "$file")
    #if [ "$oss_dir" == "." ]; then
    #    oss_dir=""
    #else
    #    oss_dir="$oss_dir/"
    #fi

    $OSSUTIL_BIN cp -c oss_config --output-dir oss_out/ -f \
        "$file" oss://$OSS_bucket/$oss_dir/
done < <(git diff --name-only $PREV_HEAD HEAD)

# update current head id
git rev-parse HEAD > $GIT_HEAD_ID_FILE

$OSSUTIL_BIN cp -c oss_config --output-dir oss_out/ -f \
    $GIT_HEAD_ID_FILE oss://$OSS_bucket/

# remove tmp files
rm -rf oss_config oss_out/ ossutil64
