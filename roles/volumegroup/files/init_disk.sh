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


