#!/bin/ksh
# main idempotent script version at /root/ on "p", last update 2024 dec 09
# dd the newest stable OpenBSD IMG install to a USB flashdrive
# delete and re-create the "k" partition "/home" to max size
# install fully OFFLINE, no network (is the set partition mounted? "no")
# and install without the game/bsd/comp set, "-g; -bsd; -comp*"
# and FDE (full disc encryption) on an SSD
# using "p" as local normal user

################################
# check for internet access for mirror

	# TODO: /etc/installurl

################################
# install and enable MATE GUI, configure displays
# /usr/local/share/doc/pkg-readmes/mate

	/usr/sbin/pkg_add mate
	/usr/sbin/rcctl enable messagebus xenodm
	echo '/usr/X11R6/bin/xrandr --output DP-2 --primary --mode 1920x1080 --output eDP-1 --off
	exec /usr/local/bin/ck-launch-session /usr/local/bin/mate-session' > /home/p/.xsession
	chown p:p /home/p/.xsession

################################
# install basic ports

/usr/sbin/pkg_add firefox \
	libreoffice-i18n-hu \
	p7zip \
	$(/usr/sbin/pkg_info -Q keepassxc|egrep -v 'brow|yubi'|head -1|cut -d ' ' -f1) \
	sshfs-fuse \
	jhead

################################
# remove unused ports 

	# TODO

################################
# update installed ports 

	/usr/sbin/pkg_add -u 

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
	ls /etc/fstab-BACKUP* 2>/dev/null || cp /etc/fstab /etc/fstab-BACKUP-$(date +%F-%Hh-%Mm-%Ss)

	# remove wxallowed: https://man.openbsd.org/mount#wxallowed
	sed -i 's/wxallowed//g; s/,,/,/g' /etc/fstab

################################
# sync to disk

	/bin/sync

################################
