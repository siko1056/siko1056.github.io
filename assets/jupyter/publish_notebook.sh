#!/bin/bash

POSTS_DIR="../../_posts"
BLOG_IMG_DIR="../blog"

jupyter-nbconvert \
  --output-dir=$POSTS_DIR \
  --to markdown \
  $1

notebook_name=${1%.ipynb}
TMP_IMG_DIR="$POSTS_DIR/${notebook_name}_files"

if [ -d ${TMP_IMG_DIR} ]
then
  echo "Move images to ${BLOG_IMG_DIR}."
  cp -R ${TMP_IMG_DIR}/* ${BLOG_IMG_DIR}
  rm -Rf ${TMP_IMG_DIR}
else
  echo "[error] Cannot move images to ${BLOG_IMG_DIR}."
fi

