#!/bin/sh
#
# Backup a virtual hard drive that is in use, to a remote server
#
# Written by:	Julian Price, http://www.incharge.co.uk/centos
# Last Changed:	2009-03-25
#

################################################################################
# Constant Definitions
# Change the values in this section to match your setup

# Connection details of the remote backup server
REMOTEIP=192.168.1.1
REMOTEDIR=/home/store/backup
REMOTEUSERNAME=backup
REMOTEPORT=22
# The private key file on the host that gains access to the backup server.
REMOTEKEY=~/.ssh/backup
# Note: The public key must have been added to the authorized keys of
# the REMOTEUSERNAME account on the backup server

# Location of the LVM logical volumes where virtual hard drives are stored
LVMDEV=/dev/vm
# Location where the logical volumes are mounted
MOUNTPOINT=/media

# Note: Names of VMs, logical volumes and directories
# It is assumed that the same vm name is given to the logical volume
# and it's mount point. e.g. The VM called 'vm01' has the
# logical volume ${LVMDEV}/vm01 which is mounted as ${MOUNTPOINT}/vm01
# The same naming convention is used for the snapshots except that
# the suffix '-snapshot' is added to the vm name

# The maximum size of the snapshot
# For the paranoid, this should be the same size as the volume being copied.
# The size actually required depends on the number of sectors changed
# by the guest during the backup.  The faster the network connection and the
# lower the disk activity then the smaller SNAPSHOTSIZE needs to be.
SNAPSHOTSIZE=32G

LOGFILE=~/backup.log
ERRFILE=~/backup.err

################################################################################
# Function definitions

# Connect to the database and lock it
database_lock() {
	local sqlhandle

	echo 'Getting mysql handle' >>$LOGFILE
	sqlhandle=`shmysql host=$3 port=$4 user=$1 password=$2`

	echo 'Beginning SQL' >>$LOGFILE
	shsql $sqlhandle "begin"

	echo 'Locking database' >>$LOGFILE
	shsql $sqlhandle 'FLUSH TABLES WITH READ LOCK;'

	echo $sqlhandle
}

# Unlock the database and close the connection
database_unlock() {
	local sqlhandle=$1

	echo 'Unocking database' >>$LOGFILE
	shsql $sqlhandle 'UNLOCK TABLES;'

	echo 'Ending SQL' >>$LOGFILE
	shsqlend $sqlhandle
}

# Create an LVM snapshot of the VM
start_snapshot() {
	local vmname=$1

	echo 'Creating snapshot' >>$LOGFILE
	mkdir ${MOUNTPOINT}/${vmname}-snapshot/
	lvcreate --size ${SNAPSHOTSIZE} --snapshot --name ${vmname}-snapshot ${LVMDEV}/${vmname} >>$LOGFILE 2>>$ERRFILE
	mount ${LVMDEV}/${vmname}-snapshot ${MOUNTPOINT}/${vmname}-snapshot >>$LOGFILE 2>>$ERRFILE
}

# Remove the LVM snapshot of the VM
stop_snapshot() {
	local vmname=$1

	if [ -e "${MOUNTPOINT}/${vmname}-snapshot" ]
	then
		echo 'Removing snapshot' >>$LOGFILE
		umount ${MOUNTPOINT}/${vmname}-snapshot/
		lvremove --force ${LVMDEV}/${vmname}-snapshot >>$LOGFILE 2>>$ERRFILE
		rmdir ${MOUNTPOINT}/${vmname}-snapshot/
	fi
}

# Use rsync to synchronise the virtual disk file
synchronise() {
	local vmname=$1
	local diskname=$2

	# For testing, put a small test file in ${MOUNTPOINT}/${vmname}
	# and sync this file instead of the virtual disk
	# diskname=test.txt

	echo `date --rfc-2822` ': Synchronizing file' >>$LOGFILE
	rsync --inplace --ignore-times --bwlimit=12800 --verbose --stats --human-readable --progress --rsh "ssh -p 22 -l $REMOTEUSERNAME -i $REMOTEKEY" ${MOUNTPOINT}/${vmname}-snapshot/${diskname} ${REMOTEIP}:${REMOTEDIR}/${diskname} >>$LOGFILE 2>>$ERRFILE
	echo `date --rfc-2822` ': Synchronized file' >>$LOGFILE
}

################################################################################
# This is the main part of the script.

echo 'Starting backup at' `date --rfc-2822` > $LOGFILE
echo 'Starting backup at' `date --rfc-2822` > $ERRFILE

# If there are multiple VMs to be backed up
# then repeat the following backup section

# If the guest is not running a database then
# delete the database_lock and database_unlock lines.
# If there are multiple database instances running on multiple ports
# then the database_lock and database_unlock lines can be repeated.

########################################
# Backup vm01

# Set the name of the VM i.e. the name of the folder under ${MOUNTPOINT}
# that contains the virtual hard disk file
VMNAME=vm01

# Remove the snapshot if it is left over from a previous failed run
stop_snapshot ${VMNAME}

# Do the backup
sqlhandle=$(database_lock 'backup' 'password-goes-here' '192.168.1.4' '3306')
start_snapshot $VMNAME
database_unlock $sqlhandle
synchronise $VMNAME 'vm01-hda.raw'
stop_snapshot $VMNAME

