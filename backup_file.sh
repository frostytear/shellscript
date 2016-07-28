#!/bin/bash

function backup_file(){
	if [ -f $1 ]
	then
		echo "Creating backup file..."
		tar cvfz ${1}.backup.$(date +%F).tar.gz $1
	fi
}

backup_file $1
if [ $? -eq 0 ]
then
	echo "Backup succeedes!"
	exit 0
else
	echo "Backup failed!"
	exit 1
fi
