#!/bin/ksh
# last update: 2024 dec 20
# https://hardened-desktop.com/
# to harden an OpenBSD install for general GUI desktop use
# why? to inspire people for the possibilities!


################################
# still INPRG, started at the end of 2024, 
# but always in a usable state
################################


################################
# install hints

	# dd the newest stable OpenBSD ".img" to a USB flash drive
	# https://www.openbsd.org/faq/faq4.html#Download

	# install fully OFFLINE, no network to be more secure

	# don't start sshd at boot, but start "X Window" with xenodm
	# FDE (full disc encryption) on an SSD
	# delete and re-create the "k" partition "/home" to max size
	# is the set partition mounted? "no"
	# install without the game/bsd/comp set: "-g; -bsd; -comp*"

	# clean reinstall (backup/restore data) with every stable release
	# which happens in every May and November, in every 6 months

################################
# other info

	# MANUALLY you have to configure : 

		# Firefox (uBlock Origin, strict mode, etc. +don't use "Google Search")
		# MATE panels, MATE bookmarks
		# LibreOffice, its language pack
		# display(s) and resolution with xrandr below
		# variables in below here

	# grsecurity isn't available for personal use on Linux, so using
	# OpenBSD due to it has a much better security history anyways. 
	# https://www.openbsd.org/
	# https://en.wikipedia.org/wiki/OpenBSD
	# DONATE: https://www.openbsdfoundation.org/

	# choosing MATE due to that for a desktop, we need a usable GUI,
	# but not yet a bloated one AND with classic start menu style
	# https://mate-desktop.org/
	# https://en.wikipedia.org/wiki/MATE_(desktop_environment)
	# DONATE: https://mate-desktop.org/donate/

################################
# variables, change it to your needs

	LOCALUSER="p"
		# check if local user exists or not
		grep -q "^${LOCALUSER}:" /etc/passwd || (echo 'ERROR: local user not found'; exit 1)

################################
# check supported/tested OpenBSD version

	/usr/bin/uname -r|grep -q ^7\.6$ || (echo 'ERROR: not supported OpenBSD version'; exit 1)

################################
# check that am i root? if not, exit 1

	# TODO

################################
# check that where am i? if wrong place, exit 1 

	# TODO

################################
# check that am i in the cron, if not i am puting myself there

	# TODO
 
################################
# check for internet access using mirror. if no net, exit 1

	# TODO: /etc/installurl

################################
# install and enable MATE GUI, configure displays
# /usr/local/share/doc/pkg-readmes/mate

	/usr/sbin/pkg_add mate
	/usr/sbin/rcctl enable messagebus xenodm
	echo '/usr/X11R6/bin/xrandr --output DP-2 --primary --mode 1920x1080 --output eDP-1 --off
exec /usr/local/bin/ck-launch-session /usr/local/bin/mate-session' > "/home/${LOCALUSER}/.xsession"
	chown ${LOCALUSER}:${LOCALUSER} /home/${LOCALUSER}/.xsession

# TODO: if binary already there, don't check with pkg_add

################################
# install extra ports, more risk

/usr/sbin/pkg_add \
	firefox-esr \
	libreoffice-i18n-hu \
	p7zip \
	$(/usr/sbin/pkg_info -Q keepassxc|grep ^keepassxc|egrep -v 'brow|yubi'|head -1|cut -d ' ' -f1) \
	$(/usr/sbin/pkg_info -Q evince|grep ^evince|grep light|head -1|cut -d ' ' -f1) \
	$(/usr/sbin/pkg_info -Q ghostscript|grep -- '^ghostscript-[0-9]'|grep -v gtk|sort -r|head -1|cut -d ' ' -f1) \
	$(/usr/sbin/pkg_info -Q gimp|grep -- '^gimp-[0-9]'|sort -r|head -1|cut -d ' ' -f1) \
	eom \
	sshfs-fuse \
	zenity \
	ImageMagick \
	jhead

# TODO: if binary already there, don't check with pkg_add

################################
# remove unused ports 

	# TODO

################################
# update installed ports 

	/usr/sbin/pkg_add -u 

# TODO: if last check was less than 6h ago, don't run pkg_add -u 

################################
# update erratas: https://www.openbsd.org/errata.html

	/usr/sbin/syspatch

# TODO: if last check was less than 6h ago, don't run syspatch 

################################
# update firmware: https://man.openbsd.org/fw_update

	# TODO

# TODO: if last check was less than 30 days ago, don't run fw_update

################################
# disable xconsole at boot

	echo > /etc/X11/xenodm/Xsetup_0

################################
# HARDENING: strict malloc: https://man.openbsd.org/free.3#S

	# first delete, then add the correct "S"
	touch /etc/sysctl.conf && \
	/usr/bin/sed -i '/vm.malloc_conf/d' /etc/sysctl.conf && \
	echo 'vm.malloc_conf=S' >> /etc/sysctl.conf

################################
# HARDENING: mount options

	# create a backup just one time, first run
	ls /etc/fstab-BACKUP* 2>/dev/null || cp /etc/fstab /etc/fstab-BACKUP-$(date +%F-%Hh-%Mm-%Ss)

	# remove wxallowed: https://man.openbsd.org/mount#wxallowed
	sed -i 's/wxallowed//g; s/,,/,/g' /etc/fstab

################################
# sync to disk

	/bin/sync

################################

exit 0

################################
