INDEX=1
while [ $INDEX -lt 6 ]
do
	echo "Creating project-${INDEX}"
	mkdir /usr/local/project-${INDEX}
	((INDEX++))
done

while ping -c 1 app1 >/dev/null
do
	echo "app1 still up..."
	sleep 5
done

echo "app1 down, continuing."

# Reading a file, line-by-line

LINE_NUM=1
while read LINE
do
	echo "${LINE_NUM}: ${LINE}"
	((LINE_NUM++))
done < /etc/fstab

# another example

grep xfs /etc/fstab | while read LINE
do
	echo "xfs: ${LINE}"
done

# another example

FS_NUM=1
grep xfs /etc/fstab | while read FS MP REST
do
	echo "%{FS_NUM}: file system: ${FS}"
	echo "${FS_NUM}: mount point: ${MP}"
	((FS_NUM++))
done

# creating a menu example

while true
do
	read -p "1: Show disk usage. 2: Show uptime." CHOICE
	case "${CHOICE}" in
		1)
			df -h
			;;
		2)
			uptime
			;;
		*)
			break
			;;
	esac
done

# using the continue statment

mysql -BNe 'show databases' | while read databases
do
	db-backed-up-recently $databases
	if [ "$?" -eq "0" ]
	then
		continue
	fi
	backup $databases
done
