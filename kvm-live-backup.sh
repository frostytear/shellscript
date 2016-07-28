#!/bin/bash

#Script to backup KVM-machines using snapshots.
#Written by Jonas "Drakfot" Andersson

#Changelog
# Version 1.1
#20140309 - Initial scripting started.
#20140316 - Fixed an issue where a nonmounted drive (CD) could cause the script to fail.
#also sorted the part where the converted image will end up. Now the file is written
#directly to the destination instead of moved there after the conversion.

#Info:
#This script uses a combination of "virsh" and "qemu-img" to discover
#the disk images attached to a VM. When doing a backup  a snapshot is
#done for each disk used by the VM and each snapshot is then exported
#as a .qcow2 file for backup.
#NOTE: This script do only backup the disk image file, not the entire
#VM. The idea behind this is that it is quick to create a new KVM-
#machine and specify the backup image as harddrive for the new machine.

### License ###
#KVM_Backup.sh - Quick script to backup KVM-machines without downtime.
#Copyright (C) 2014 Jonas Andersson

#This program is free software; you can redistribute it and/or modify
#it under the terms of the GNU General Public License as published by
#the Free Software Foundation; either version 3 of the License, or
#(at your option) any later version.
#
#This program is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.
#
#You should have received a copy of the GNU General Public License
#along with this program; if not, write to the Free Software Foundation,
#Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301  USA


#Prerequisites
#KVM being used as VM hypervisor.
#qemu-img path specified in the variable below.
#virsh path specified in the variable below.

#Variables
BACKUPDIR=/backup
BACKUPNAME=backup_`date +%Y%m%d%HH%MM`
VIRSHBIN=/usr/bin/virsh
QEMUIMG=/usr/bin/qemu-img
VIRTUAL_DISKS=""
VMDOMAIN=""


#Functions!
function get_domain_disk () {
		N=0
		for i in `$VIRSHBIN domblklist $1 | tail -n+3 | sed -e 's/^\-$//g' | awk '{print $2}'` ; do
			VIRTUAL_DISKS[$N]="$i"
			let "N= $N + 1"
		done
}

function create_snapshot () {
		for disk in ${VIRTUAL_DISKS[*]}
		do
		echo "Creating snapshot for disk $disk"
			$QEMUIMG snapshot -c $BACKUPNAME $disk
		echo "Snapshot $BACKUPNAME created for disk $disk at `date`"
		done
}	

function convert_snapshot_qcow2 () {
		for disk in ${VIRTUAL_DISKS[@]}
		do
		echo "Converting snapshot for disk $disk"
		$QEMUIMG convert -f qcow2 -O qcow2 -s $BACKUPNAME $disk $BACKUPDIR/$VMDOMAIN.$BACKUPNAME.qcow2
		#mv $disk.$BACKUPNAME.qcow2 $BACKUPDIR
		echo "Snapshot for $disk converted at `date` and placed at $BACKUPDIR"
		done
}

function delete_snapshot () {
		for disk in ${VIRTUAL_DISKS[@]}
		do
		echo "Deleting snapshot $BACKUPNAME for disk $disk"
		$QEMUIMG snapshot -d $BACKUPNAME $disk
		echo "Snapshot $BACKUPNAME deleted at `date`"
		done
}

function check_vmname () {
		if [ -z $VMDOMAIN ]
		then
		echo "No VM specified, please input the name using $0 -n VMName <options>"
		exit
		fi
}

function list_disks () {
                echo "$VMDOMAIN contains the following disk(s):"
		for disk in ${VIRTUAL_DISKS[@]}
                do
		echo "$disk"
		done
}

function list_snapshots () {
		echo "Listing (possible) snapshots for $VMDOMAIN:"
		for disk in ${VIRTUAL_DISKS[@]}
                do
                $QEMUIMG snapshot -l $disk
                done
}

function multiple_servers () {
		echo "File with multiple server names specified"
		cat $SERVERLIST |while read line
			do
			VMDOMAIN=$line
			echo "Backing up $VMDOMAIN"
                        get_domain_disk $VMDOMAIN
                        create_snapshot
                        convert_snapshot_qcow2
                        delete_snapshot
		done
}			 

#Let's check the args input and decide what functions to call based on them
while getopts ":n:blsc:d:hm:" opt; do
	case "$opt" in
		n)
			if [ -a $OPTARG ]
				then
				SERVERLIST=$OPTARG
				multiple_servers
				exit
			fi
			VMDOMAIN=$OPTARG
			;;
		m)
                        BACKUPDIR=$OPTARG
                        echo "Backup destination set to $OPTARG"
                        ;;
		l)
			check_vmname
			get_domain_disk $VMDOMAIN
			list_disks
			;;
		s)
			get_domain_disk $VMDOMAIN
			list_snapshots
			;;
		c)
			get_domain_disk $VMDOMAIN
			BACKUPNAME=$OPTARG
			create_snapshot
			;;
		d)
			get_domain_disk $VMDOMAIN
			BACKUPNAME=$OPTARG
			delete_snapshot
			;;	
		:)
			echo "option -$OPTARG requires an argument."
			;;
		h)
			echo "Usage: $0 -n VMname is required for useage."
			echo "======================= Options available for $0: ======================="
			echo "-b : Creates a snapshot of the disk, converts it to a qcow2 file and then moves it"
			echo "     to the backup destination, default is /backup."
			echo "     If a file with serverenames, one per row, is specified the script will loop"
			echo "     through the file and back up each server and its disk(s). No other options"
			echo "     will be parsed."
			echo "-l : Lists the disks in the specified VM."
			echo "-s : Lists the snapshots for the specified VM."
			echo "-c : Creates snapshot(s) for the disk(s)in the specified VM. Requires an argument"
			echo "     to use as name for the snapshot. Eg -c snapshot_test"
			echo "-d : Deletes the specified snapshot from the VM's disk(s). Requires an argument"
			echo "     to use as name / ID specifying which snapshot to remove."
			echo "     Eg -d snapshot_test  OR -d 1"
			echo "-m : Specifies the destination where the backup will be saved. Default is /backup"
			echo "     NOTE: This option must be specified BEFORE the "-b" option to take effect!"
			echo "     Eg: -m /tmp/ -b"
			;;
                b)
                        echo "Backing up $VMDOMAIN"
                        get_domain_disk $VMDOMAIN
                        create_snapshot
                        convert_snapshot_qcow2
                        delete_snapshot
                        ;;
		\?)
			echo "Invalid option: -$OPTARG. Use $0 -h to display the syntax."
			;;

	esac
done