#!/bin/bash

OSSUTIL_BIN=./ossutil64
GIT_HEAD_ID_FILE=.travis_HEAD

# config ossutil
$OSSUTIL_BIN config -c oss_config -e $OSS_endpoint -i $OSS_accessKeyID -k $OSS_accessKeySecret

# get prev HEAD ID and current HEAD ID
$OSSUTIL_BIN cp -c oss_config --output-dir oss_out/ $GIT_HEAD_ID_FILE .

if [ -f $GIT_HEAD_ID_FILE ]; then
  read PREV_HEAD < $GIT_HEAD_ID_FILE
fi

# update changed files
while read -r file; do
  $OSSUTIL_BIN cp -c oss_config --output-dir oss_out/ \
    "$file" oss://$OSS_bucket/$(dirname "$file")
done < <(git diff --name-only $PREV_HEAD HEAD)

# update current head id
git rev-parse HEAD > $GIT_HEAD_ID_FILE

$OSSUTIL_BIN cp -c oss_config --output-dir oss_out/ \
  $GIT_HEAD_ID_FILE oss://$OSS_bucket/

rm -rf oss_config oss_out/ ossutil64
