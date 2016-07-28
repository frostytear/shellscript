#!/bin/bash

while true; do
	echo
	echo " ------  Action Menu  ------  "
	echo " 1) Show disk usage  			"
	echo " 2) Show uptime on the system "
	echo " 3) Show logged users			"
	echo " q) Quit						"
	read -p " > " option
	echo
	case $option in
		1)
			df -h
			;;
		2)
			uptime
			;;
		3)
			who
			;;
		q)
			echo "Goodbye" && break
			;;
		*)
			echo "Invalid option"
			;;
	esac
done