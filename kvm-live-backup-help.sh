#!/bin/bash

#Some quick examples and their expected output
#List the disk associated with a VM:

bash kvm-live-backup.sh -n Test03 -l
# Test03 contains the following disk(s):
/VMs/Test03.img
Create a snapshot of VM “Test03”:

bash kvm_backup.sh -n Test03 -c test_snapshot
Creating snapshot for disk /VMs/Test03.img
Snapshot test_snapshot created for disk /VMs/Test03.img at Sun Mar  9 16:28:42 CET 2014
List snapshots for the VMs disk(s):

1
2
3
4
5
./kvm_backup.sh -n Test03 -s
Listing (possible) snapshots for Test03:
Snapshot list:
ID        TAG                 VM SIZE                DATE       VM CLOCK
1         test_snapshot             0 2014-03-09 16:28:38   00:00:00.000
Delete a specific snapshot from VM (define either ID of TAG of the snapshot):

1
2
3
./kvm_backup.sh -n Test03 -d test_snapshot
Deleting snapshot test_snapshot for disk /VMs/Test03.img
Snapshot test_snapshot deleted at Sun Mar  9 16:28:56 CET 2014
If your VM has multiple disks, the listing will look like this:

1
2
3
4
./kvm_backup.sh -n Test04 -l
Test04 contains the following disk(s):
/VMs/Test04.img
/VMs/Test04-disk02.img