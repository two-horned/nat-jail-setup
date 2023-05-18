#!/bin/sh

jail_name="myjail"
netdev_name="eth0"

mkdir -p /usr/jail/$(jail_name)
fetch https://download.freebsd.org/ftp/releases/amd64/13.2-RELEASE/base.txz -o /usr/jail/13.2-RELEASE-base.txz
tar xpf /usr/jail/13.1-RELEASE-base.txz -C /usr/jail/$(jail_name)
cat << EOF >> /etc/jail.conf
exec.start = "/bin/sh /etc/rc";
exec.stop = "/bin/sh /etc/rc.shutdown";
exec.clean;
host.hostname = ${name}; path = /usr/jail/${name};
path = /usr/jail/${name};

$(jail_name) {
  mount.devfs;
  devfs_ruleset = 30;
  interface = lo1;
  allow.raw_sockets;
  ip4.addr = 127.0.1.1;
}

EOF

cat << EOF >> /etc/pf.conf
netdev="$(netdev_name)" scrub in all fragment reassemble set skip on lo0 set skip on lo1

nat on $netdev from lo1:network to any -> ($netdev)
EOF

cat << EOF >> /etc/rc.conf
# Jails
jail_enable="YES" jail_parallel_start=YES jail_list="$(jail_name)"
# Gateway
gateway_enable="YES" #for ipv4
ipv6_gateway_enable="YES" #for ipv6
cloned_interfaces="lo1"
ipv4_addrs_lo1="127.0.1.1-9/29"
pf_enable="YES"
EOF

rm /usr/jail/$(jail_name)/etc/resolv.conf
ln /etc/resolv.conf /usr/jail/$(jail_name)/etc/resolv.conf
