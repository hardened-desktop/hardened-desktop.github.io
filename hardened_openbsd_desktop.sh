#!/bin/ksh
# main idempotent script version at /root/ on "p", last update 2024 dec 05
# install without the games set "-g*" and without single cpu bsd set "-bsd"
# and FDE (full disc encryption) on an SSD

# check for internet access
	# TODO

# install basic softwares
/usr/sbin/pkg_add firefox \
	libreoffice \
	gnome-extras \
	$(/usr/sbin/pkg_info -Q keepassxc|egrep -v 'brow|yubi'|head -1|cut -d ' ' -f1) \
	sshfs-fuse \
	jhead

# enable GNOME, info from: /usr/local/share/doc/pkg-readmes/gnome
	/usr/sbin/rcctl disable xenodm
	/usr/sbin/rcctl enable multicast messagebus avahi_daemon gdm

# update erratas: https://www.openbsd.org/errata.html
	/usr/sbin/syspatch

# strict malloc: https://man.openbsd.org/free.3#S
	/usr/bin/sed -i '/vm.malloc_conf/d' /etc/sysctl.conf && \
	echo 'vm.malloc_conf=S' >> /etc/sysctl.conf

# sync to disk
	/bin/sync
