#!/bin/ksh
# 2024 dec 03
# install without the games set "-g*" and FDE (full disc encryption) on an SSD

# check for internet access
# TODO

# install basic softwares
/usr/sbin/pkg_add firefox libreoffice gnome-extras $(/usr/sbin/pkg_info -Q keepassxc|head -1)

# enable GNOME, info from: /usr/local/share/doc/pkg-readmes/gnome
/usr/sbin/rcctl disable xenodm
/usr/sbin/rcctl enable multicast messagebus avahi_daemon gdm

# update erratas: https://www.openbsd.org/errata.html
/usr/sbin/syspatch

# sync to disk
/bin/sync
