#!/bin/sh

jail_name="$1"
jail_index="$2"

zfs_dir="zroot/jails"
zfs_jail="$zfs_dir/$jail_name"
zfs_base="$zfs_dir/base"

# Create Jail Environment
zfs clone $zfs_base@template $zfs_jail

# Create Entry in jail.conf
echo "$jail_name { ip4.addr = 127.0.1.$jail_index; } " >> /etc/jail.conf

# Add Jail to rc.conf
sysrc jail_list+="$jail_name"
