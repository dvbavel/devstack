#!/bin/bash -x
# Parameters
INSTANCENAME="$1"

# Variable
UBUNTUURL="https://cloud-images.ubuntu.com/daily/server/trusty/current/trusty-server-cloudimg-amd64-disk1.img"
MOUNTDIR="/tmp/ubuntumount"
INSTANCEIMAGE="devstack-$INSTANCENAME.img"
INSTANCECFGDRIVE="$INSTANCENAME-config.iso"

# Check if mount folder exists
if [ -d "$MOUNTDIR" ]
then
    echo "Directory $MOUNTDIR exists."
else
    echo "Error: Directory $MOUNTDIR does not exists."
    mkdir -p $MOUNTDIR
fi

# Check for nbd mod
lsmod | grep nbd >& /dev/null

if [ $? -eq 0 ]
then
	echo "nbd has been loaded"
else
        modprobe nbd max_part=16
fi

# Get latest Ubuntu image
wget $UBUNTUURL

# Copy new image
cp trusty-server-cloudimg-amd64-disk1.img $INSTANCEIMAGE

# Resize image
qemu-img resize $INSTANCEIMAGE +10GB

# Create cloud config drive
genisoimage -o $INSTANCECFGDRIVE.iso -V cidata -r -J files/meta-data files/user-data

# Copy image to libvirt
cp $INSTANCEIMAGE /var/lib/libvirt/images
cp $INSTANCECFGDRIVE /var/lib/libvirt/images

# Cleanup build folder
rm $INSTANCEIMAGE
rm $INSTANCECFGDRIVE
