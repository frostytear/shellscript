#!/bin/bash

line_number=1
while read line
do
	echo "${line_number}: ${line}"
	((line_number++))
done < /etc/passwd