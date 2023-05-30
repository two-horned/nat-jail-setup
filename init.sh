#!/bin/sh

netdev_name=$2
domain=$1

zfs_dir="zroot/jails"
jail_dir="/$zfs_dir"
zfs_base_dir="$zfs/base"
base_dir="/$zfs_base_dir"

# Create Data Pools
zfs create $zfs
zfs create $zfs_base_dir

# Fetch Base System
fetch https://download.freebsd.org/ftp/releases/amd64/13.2-RELEASE/base.txz -o $base_dir/13.2-RELEASE-base.txz

# Create Snapshot of the base
zfs snapshot $zfs_base@template

# Setting up /etc/jail.conf
echo "host.hostname=\${name}.$domain;" >> /etc/jail.conf
echo "path=$jail_dir/\${name};" >> /etc/jail.conf
cat << EOF >> /etc/jail.conf
exec.start="/bin/sh /etc/rc";
exec.stop="/bin/sh /etc/rc.shutdown";
exec.clean;
interface=lo1;

EOF

# Enable Jails
sysrc jail_enable="YES"
sysrc jail_parallel_start="YES"

# Enable Gateway
sysrc gateway_enable="YES"
sysrc cloned_interfaces="lo1"

# Enable Firewall
sysrc pf_enable="YES"

# Write Firewall
cat << EOF >> /etc/pf.conf
netdev="$(netdev_name)"
scrub in all fragment reassemble
set skip on lo0
set skip on lo1


nat on $netdev from lo1:network to any -> ($netdev)
EOF

