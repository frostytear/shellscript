#!/bin/bash

DEFAULT_PREFIX=$(date +%F)

read -p "Please, enter a file extension: " FILE_EXTENSION
read -p "Please, enter a file prefix - {default: ${DEFAULT_PREFIX}}: " PREFIX

FILES_BY_EXTENSION=$(ls *.${FILE_EXTENSION})

if [ $? -eq 1 ]
then
  echo "File not found!"
  exit 1
fi

if [ "$PREFIX" = "" ]
then
  echo "No prefix setted, using the default prefix"
  for FILE in $FILES_BY_EXTENSION
  do
    mv ${FILE} ${DEFAULT_PREFIX}-${FILE}
    echo "moving ${FILE} to ${DEFAULT_PREFIX}-${FILE}"
  done
  exit 0
else
  echo "Prefix setted: ${PREFIX}"
  for FILE in $FILES_BY_EXTENSION
  do
    mv ${FILE} ${PREFIX}-${FILE}
    echo "moving ${FILE} to ${PREFIX}-${FILE}"
  done
  exit 0
fi
