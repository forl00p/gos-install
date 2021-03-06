#!/bin/sh

# Usage: build.sh sdXX

###
# Need to add a bit to unmask packages
###

DISK=$1
STAGE3_DATE="20130822"
ARCH="amd64"
FILELOC=`pwd`

MSGPREFIX=" !!!"


if ["$1" == '']; then
    echo "Specify disk"
    exit 0;
fi

echo "$MSGPREFIX Creating filesystem"
mkfs.ext3 -q /dev/$DISK

echo "$MSGPREFIX Mounting filesystem"
mount /dev/$DISK /mnt/gentoo
cd /mnt/gentoo

echo "$MSGPREFIX Fetching stage3"
wget http://distfiles.gentoo.org/releases/${ARCH}/current-stage3/stage3-${ARCH}-${STAGE3_DATE}.tar.bz2

echo "$MSGPREFIX Unpacking stage3"
tar -xf stage3*

echo "$MSGPREFIX Mounting system directories"
cd /
mount -t proc proc /mnt/gentoo/proc
mount --rbind /dev /mnt/gentoo/dev
mount --rbind /sys /mnt/gentoo/sys
cp -L /etc/resolv.conf /mnt/gentoo/etc/

echo "$MSGPREFIX Installing stage 2"
printf "DISK=${DISK}\n\n" > /mnt/gentoo/build_stage2.sh
cat ${FILELOC}/build_stage2.sh >> /mnt/gentoo/build_stage2.sh
chmod +x /mnt/gentoo/build_stage2.sh

echo "$MSGPREFIX Creating another make.conf and patching"
cp /mnt/gentoo/etc/portage/make.conf /mnt/gentoo/etc/portage/make2.conf
cat $FILELOC/make >> /mnt/gentoo/etc/portage/make2.conf

echo "$MSGPREFIX Chrooting"
echo "$MSGPREFIX Stage 1 complete. Please run build_stage2.sh to continue"
chroot /mnt/gentoo /bin/bash
