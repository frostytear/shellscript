#!/bin/bash

LISTA=$(ls *.jpg)

if [ $? -eq 1 ]
then
  exit 1
else
  for FILE in $LISTA
  do
    mv ${FILE} $(date +%F)-${FILE}
    echo "moving ${FILE} to $(date +%F)-${FILE}"
  done
  echo "Done!"
  exit 0
fi
