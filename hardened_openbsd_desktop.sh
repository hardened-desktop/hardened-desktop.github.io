#!/bin/ksh
# main idempotent script version at /root/ on "p", last update 2024 dec 07
# dd the newest stable OpenBSD IMG install to a USB flashdrive
# install fully OFFLINE, no network (is the set partition mounted? "no")
# and install without the "game" set "-g*" and without the single cpu "bsd" set "-bsd"
# and FDE (full disc encryption) on an SSD

################################
# check for internet access for mirror

	# TODO: /etc/installurl

################################
# install basic softwares

/usr/sbin/pkg_add firefox \
	libreoffice \
	gnome-extras \
	$(/usr/sbin/pkg_info -Q keepassxc|egrep -v 'brow|yubi'|head -1|cut -d ' ' -f1) \
	sshfs-fuse \
	jhead

################################
# enable GNOME, info from: /usr/local/share/doc/pkg-readmes/gnome

	/usr/sbin/rcctl disable xenodm
	/usr/sbin/rcctl enable multicast messagebus avahi_daemon gdm

################################
# remove unused softwares

	# TODO

################################
# update erratas: https://www.openbsd.org/errata.html

	/usr/sbin/syspatch

################################
# strict malloc: https://man.openbsd.org/free.3#S

	# first delete, then add the correct "S"
	touch /etc/sysctl.conf && \
	/usr/bin/sed -i '/vm.malloc_conf/d' /etc/sysctl.conf && \
	echo 'vm.malloc_conf=S' >> /etc/sysctl.conf

################################
# stricter mount options

	# create a backup just one time, first run
	ls /etc/fstab-BACKUP* || cp /etc/fstab /etc/fstab-BACKUP-$(date +%F-%Hh-%Mm-%Ss)

	# remove wxallowed: https://man.openbsd.org/mount#wxallowed
	sed -i 's/wxallowed//g; s/,,/,/g' /etc/fstab

	# TODO: only gdm needs suid? 
	# TODO: audit this part later, +add noexec?
	# put the original fstab to a variable
	##FSTAB=$(egrep -w 'ffs|none' /etc/fstab)
	# swap
	##echo "$FSTAB" | awk '/swap/ {print $0}' > /etc/fstab && \
	# "/" can only have rw,nosuid,noatime
	##echo "$FSTAB" | awk '/ \/ / {print $1,$2,$3,"rw,nosuid,noatime",$5,$6}' >> /etc/fstab && \
	# "/usr" can only have rw,nodev,nosuid,noatime
	##echo "$FSTAB" | awk '/ \/usr / {print $1,$2,$3,"rw,nodev,nosuid,noatime",$5,$6}' >> /etc/fstab && \
	# all other local fs can have rw,nodev,nosuid,noatime
	##echo "$FSTAB" | awk '!/swap/&&!/ \/ /&&/ \//&&!/ \/usr / {print $1,$2,$3,"rw,nodev,nosuid,noatime",$5,$6}' >> /etc/fstab

################################
# sync to disk

	/bin/sync

################################

exit 0
# TODO: partition to full size missed
# TODO: full path for all the mentioned binaries
# TODO: lynis
# TODO: string all suid binaries for rel.paths
inet 192.168.1.7 255.255.255.0
192.168.1.6
nameserver 8.8.8.8
