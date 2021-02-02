#!/bin/bash
set -e

hdd="/dev/sdb /dev/sdc"
num=2

for i in $hdd
do
    parted $i --script mklabel gpt
    parted $i --script mkpart primary 0% 100%
    parted $i --script print
done

vgcreate VolGroup01 /dev/sd[b,c]1 -v
lvcreate -l 100%VG -i${num} -I 131072 VolGroup01 -n LogVol00
lvdisplay -m

#mkfs.ext4 /dev/mapper/VolGroup01-LogVol00
mke2fs -O 64bit,has_journal,extents,huge_file,flex_bg,uninit_bg,dir_nlink,extra_isize /dev/mapper/VolGroup01-LogVol00

grep -vq "VolGroup01-LogVol00" /etc/fstab && echo "/dev/mapper/VolGroup01-LogVol00      /var/data  ext4    defaults        0 0" >> /etc/fstab

