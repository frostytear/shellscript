#!/bin/bash

read -p "How many lines of /etc/passwd would you like to see? " like_to_see
number_of_lines=1
while read line
do
	echo "$line"
	if [ "$like_to_see" = "$number_of_lines" ]; then
		break
	fi
	((number_of_lines++))
done < /etc/passwd


