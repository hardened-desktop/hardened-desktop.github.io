#!/bin/ksh
# https://hardened-desktop.com/
# to harden an OpenBSD install for general GUI desktop use
# why? to inspire people for the possibilities!
# and to keep me sane :D
# license: do what you want

	################################
	# still INPRG, 
	# just started at the end of 2024 
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

# TODO: automate manual steps
# you have to MANUALLY configure : 

# Firefox (uBlock Origin, strict mode, etc. +don't use "Google Search")
# MATE panels, MATE bookmarks, MATE Pluma
# LibreOffice, its language pack
# display(s) and resolution with xrandr below
# variables in below here

# grsecurity isn't available for personal use on Linux, so using
# OpenBSD due to it has a much better security history anyways. 
# https://www.openbsd.org/
# https://en.wikipedia.org/wiki/OpenBSD
# sign up for security announcements: 
# https://lists.openbsd.org/cgi-bin/mj_wwwusr?user=&passw=&func=lists-long-full&extra=announce

# choosing MATE due to that for a desktop, we need a usable GUI,
# but not yet a bloated one (..) AND with classic start menu style
# https://mate-desktop.org/
# https://en.wikipedia.org/wiki/MATE_(desktop_environment)

################################
# show START logo

/usr/bin/printf '\n%.0s' `seq 1 26`
echo "
################################################################
STARTED /root/hardened_openbsd_desktop.sh

Last script update: 2025 jan 21

https://hardened-desktop.com/

                 LET'S GOOO! 
"

################################
# check used binaries in the script

# TODO

################################
echo '01/XX SCRIPT:    declaring variables'

LOCALUSER="p"
# check if local user exists or not
grep -q "^${LOCALUSER}:" /etc/passwd || (echo 'ERROR: local user not found'; exit 1)
# TODO: INFO there should be only one local user

LAST_CHK_HOURS="3"
LAST_CHK_SECONDS=$((${LAST_CHK_HOURS}*3600))
# test with: touch -d "2024-12-20 01:01:01" /root/hardened_openbsd_desktop.sh

DYNDNS="censored"
DYNDNS_PORT="censored"

ENABLED_RCCTLS=$(/usr/sbin/rcctl ls on)

PKGINFO=$(/usr/sbin/pkg_info | awk '{print $1}')

CORRECT_XPM_HASH="ada1bb251289191e8982a3e57ec86c374bbd9cacc6bc9dd41a0d63db7aa93729a427eebc790c7f2ff9d56afb2367b890760b5575399624feb0b0eebf1f903a55"

################################
echo '02/XX SCRIPT:    checking supported/tested OpenBSD version'
# OFF: I have a T450 laptop

/usr/bin/uname -r|grep -q ^7\.6$ || (echo 'ERROR: not supported OpenBSD version'; exit 1)

################################
echo '03/XX SCRIPT:    am i root? if not, exit 1'

if [ $(/usr/bin/id -u) -ne 0 ]; then echo 'ERROR: only run this script as root'; exit 1; fi

################################
echo '04/XX SCRIPT:    where am i? if wrong place OR cannot cd to it, exit 1'

cd /root/ 2>/dev/null || (echo 'ERROR: cannot cd to /root/'; exit 1)
if [ "$0" != "/root/hardened_openbsd_desktop.sh" ]; then echo 'ERROR: script name bad'; exit 1; fi

################################
echo '05/XX SCRIPT:    pre-sync to disk'

/bin/sync

################################
echo '06/XX SCRIPT:    chmod 600 and chown root:wheel myself'

/bin/chmod 600 /root/hardened_openbsd_desktop.sh
/sbin/chown root:wheel /root/hardened_openbsd_desktop.sh

################################
echo '07/XX SCRIPT:    am i in the /etc/rc.local at boot, if not i am puting myself there'
# better to run upgrades/policies at every boot vs. during usage of the OS/web browser or OS shutdown
    # of course this is for a desktop, so daily poweroff for the OS is the normal

# only update /etc/rc.local if not only having the needed cmd
CURRENT_RCLOCAL_HASH=$(/bin/sha512 -q /etc/rc.local 2>/dev/null)
GOOD_RCLOCAL_HASH="d9604a62181496a903f3c74cbfcbc9c30c9a83f5122c0ce8387e1c4ee518f8bbe72cea6c98e78fd55115b7a947b44273bdfe4fcf95fbfbb7144f58801b2aa27a"
if [ ${CURRENT_RCLOCAL_HASH} != ${GOOD_RCLOCAL_HASH} ]; then
echo '/bin/ksh /root/hardened_openbsd_desktop.sh' > /etc/rc.local
fi 2>/dev/null
 
################################
echo '08/XX SCRIPT:    check for internet access using mirror. if no net, just warn'

if ! /usr/bin/timeout 31 /usr/bin/nc -w 30 -z $(grep '^https:' /etc/installurl | head -1 | cut -d'/' -f3) 443 >/dev/null 2>&1; then 
echo '    INFO: no internet connection! cannot download updates OR sync time. Are we AIR GAPPED?'; 

# avoid updates (with touch) if no internet
/usr/bin/touch /root/hardened_openbsd_desktop.sh
fi

################################
echo '09/XX HARDENING: disable NTPD and update system time'

# we don't need less security that ntpd is doing network traffic during all day
echo "${ENABLED_RCCTLS}" | grep -wq ntpd && /usr/sbin/rcctl disable ntpd

# sync clock only at boot time is enough for a basic desktop
# do it before setting securelevel to 2
/usr/bin/timeout 31 /usr/sbin/rdate -nc pool.ntp.org >/dev/null 2>&1 || (echo "    INFO: couldn't sync time")

################################
echo '10/XX GUI:       if not yet done: install and enable MATE GUI, configure displays with xrandr in .xsession'
# /usr/local/share/doc/pkg-readmes/mate

if ! echo "${PKGINFO}" | grep -q -- '^mate-[0-9]'; then
/usr/sbin/pkg_add mate
/usr/sbin/rcctl enable messagebus xenodm
echo '/usr/X11R6/bin/xrandr --output DP-2 --primary --mode 1920x1080 --output eDP-1 --off
exec /usr/local/bin/ck-launch-session /usr/local/bin/mate-session' > "/home/${LOCALUSER}/.xsession"
chown ${LOCALUSER}:${LOCALUSER} /home/${LOCALUSER}/.xsession
fi

# TODO: grep startup /etc/X11/xenodm/Xsession -> put it to /etc with correct perm.

################################
echo '11/XX EXTRA:     if not yet done: install additionally needed ports for a desktop'
# if package already installed, skip
# yeah, this part really lowers security...

echo "${PKGINFO}" | grep -q -- '^firefox-esr-[0-9]' || /usr/sbin/pkg_add firefox-esr 
echo "${PKGINFO}" | grep -q -- '^libreoffice-i18n-hu-[0-9]' || /usr/sbin/pkg_add libreoffice-i18n-hu
echo "${PKGINFO}" | grep -q -- '^p7zip-[0-9]' || /usr/sbin/pkg_add p7zip
echo "${PKGINFO}" | grep -- '^keepassxc-[0-9]' | egrep -vq 'brow|yubi' || /usr/sbin/pkg_add $(echo "${PKGINFO}"|grep ^keepassxc|egrep -v 'brow|yubi'|head -1|cut -d ' ' -f1)
echo "${PKGINFO}" | grep -- '^evince-[0-9]' | grep -q light || /usr/sbin/pkg_add $(echo "${PKGINFO}"|grep ^evince|grep light|head -1|cut -d ' ' -f1)
echo "${PKGINFO}" | grep -- '^ghostscript-[0-9]' | grep -vq gtk || /usr/sbin/pkg_add $(echo "${PKGINFO}"|grep -- '^ghostscript-[0-9]'|grep -v gtk|sort -r|head -1|cut -d ' ' -f1)
echo "${PKGINFO}" | grep -q -- '^gimp-[0-9]' || /usr/sbin/pkg_add $(echo "${PKGINFO}"|grep -- '^gimp-[0-9]'|sort -r|head -1|cut -d ' ' -f1)
# echo "${PKGINFO}" | grep -- '^chromium-[0-9]' | egrep -vq 'ungoogled|bsu' || /usr/sbin/pkg_add $(echo "${PKGINFO}"|grep chromium|egrep -v 'ungoogled|bsu'|head -1|cut -d ' ' -f1) # sadly chromium doesn't work with strict malloc, trying later..
echo "${PKGINFO}" | grep -q -- '^eom-[0-9]' || /usr/sbin/pkg_add eom
echo "${PKGINFO}" | grep -q -- '^mate-calc-[0-9]' || /usr/sbin/pkg_add mate-calc
echo "${PKGINFO}" | grep -q -- '^pluma-[0-9]' || /usr/sbin/pkg_add pluma
echo "${PKGINFO}" | grep -q -- '^sshfs-fuse-[0-9]' || /usr/sbin/pkg_add sshfs-fuse
echo "${PKGINFO}" | grep -q -- '^zenity-[0-9]' || /usr/sbin/pkg_add zenity
echo "${PKGINFO}" | grep -q -- '^ImageMagick-[0-9]' || /usr/sbin/pkg_add ImageMagick
echo "${PKGINFO}" | grep -q -- '^jhead-[0-9]' || /usr/sbin/pkg_add jhead

################################
echo '12/XX HARDENING: remove unused packages (ports)'

# TODO

################################
echo '13/XX PRIVACY:   delete user trash/corefiles AND "/var/log/*.gz"+"/var/log/*.old"'

/bin/rm -fr /home/${LOCALUSER}/.local/share/Trash
/bin/rm -fr /home/${LOCALUSER}/*.core

/bin/rm -fr /var/log/*.gz
/bin/rm -fr /var/log/*.old

# TODO: any other logfile? 

################################
echo '14/XX UPDATES:   update firmware: https://man.openbsd.org/fw_update if due'
# but only if it was checked more than "LAST_CHK_SECONDS" * 200 seconds ago 

LAST_CHK_SECONDS_FW=$((${LAST_CHK_HOURS}*3600*200))
if [ $(/usr/bin/stat -f %m /root/hardened_openbsd_desktop.sh) -le $(( $(/bin/date +%s) - ${LAST_CHK_SECONDS_FW} )) ]; then \
echo '
running "fw_update"'
/usr/sbin/fw_update
echo
fi

################################
echo '15/XX GUI:       disable xconsole at boot and create custom xenodm login'

# set the xenodm login screen back to black
echo '#!/bin/sh
/usr/X11R6/bin/xsetroot -solid black' > /etc/X11/xenodm/Xsetup_0

# get a custom puffy with hardhat, to show it is "hardened" (and respect to the masonry workers)
EXISTING_XPM_HASH=$(/bin/sha512 -q /etc/X11/xenodm/pixmaps/OpenBSD_15bpp.xpm 2>/dev/null)
if ! [ ${EXISTING_XPM_HASH} = ${CORRECT_XPM_HASH} ]; then
# TODO: only download from git if there is internet connection
/usr/bin/timeout 31 /usr/bin/ftp -M 'https://raw.githubusercontent.com/hardened-desktop/hardened-desktop.github.io/refs/heads/main/OpenBSD_15bpp.xpm' >/dev/null 2>&1
DOWN_XPM_HASH=$(/bin/sha512 -q /root/OpenBSD_15bpp.xpm 2>/dev/null)
if [ ${DOWN_XPM_HASH} = ${CORRECT_XPM_HASH} ]; then
/bin/mv /root/OpenBSD_15bpp.xpm /etc/X11/xenodm/pixmaps/OpenBSD_15bpp.xpm; 
else echo '    INFO: hash for XPM failed, not moving it'; fi 2>/dev/null
/bin/chmod 444 /etc/X11/xenodm/pixmaps/OpenBSD_15bpp.xpm
fi

# TODO: request hardhat puffy xpm license usage from Theo

################################
echo '16/XX HARDENING: disable unused rc services'

echo "${ENABLED_RCCTLS}" | grep -wq pflogd && /usr/sbin/rcctl disable pflogd 
echo "${ENABLED_RCCTLS}" | grep -wq syslogd && /usr/sbin/rcctl disable syslogd 

# TODO: any other? 

################################
echo '17/XX HARDENING: strict "S" malloc: https://man.openbsd.org/free.3#S'

echo 'vm.malloc_conf=S' > /etc/sysctl.conf
/sbin/sysctl -q -w vm.malloc_conf=S

################################
echo '18/XX HARDENING: increase stack gap: https://man.openbsd.org/sysctl.2#KERN_STACKGAPRANDOM~2'

echo 'kern.stackgap_random=16777216' >> /etc/sysctl.conf
/sbin/sysctl -q -w kern.stackgap_random=16777216

################################
echo '19/XX HARDENING: increase default securelevel from 1 to 2: https://man.openbsd.org/securelevel'
# cannot put it in sysctl.conf due to network issues
# can only apply it with "-w"

/sbin/sysctl -q -w kern.securelevel=2

################################
# HARDENING mount options

echo '20/XX SCRIPT:    create an fstab backup at the first run'
ls /etc/fstab-BACKUP* 2>/dev/null >/dev/null 2>&1 || /bin/cp /etc/fstab /etc/fstab-BACKUP-$(date +%F-%Hh-%Mm-%Ss)

echo '21/XX HARDENING: remove wxallowed: https://man.openbsd.org/mount#wxallowed'
# only when wxallowed is in fstab
if grep -wq wxallowed /etc/fstab 2>/dev/null; then 
sed -i 's/wxallowed//g; s/,,/,/g' /etc/fstab
fi

################################
echo '22/XX EXTRA:     mount the SSHFS if specified'

if ! echo "${DYNDNS} ${DYNDNS_PORT}"|grep -iq censor; then
if ! /usr/bin/timeout 31 /bin/df -h|grep -q ${DYNDNS}; then 
if /usr/bin/timeout 31 /usr/bin/nc -w 30 -z ${DYNDNS}.duckdns.org ${DYNDNS_PORT} >/dev/null 2>&1; then 
mkdir /${DYNDNS}/ 2>/dev/null
/usr/bin/timeout 31 /usr/local/bin/sshfs -p ${DYNDNS_PORT} -o IdentityFile="/home/${LOCALUSER}/.ssh/id_rsa" -o idmap=user,allow_other,uid=1000,gid=1000 ${DYNDNS}@${DYNDNS}.duckdns.org:/ /${DYNDNS}/
ls "/home/${LOCALUSER}/Desktop/${DYNDNS}" >/dev/null 2>&1 || /bin/ln -s "/${DYNDNS}/${DYNDNS}/" "/home/${LOCALUSER}/Desktop/${DYNDNS}" 2>/dev/null 
ls "/home/${LOCALUSER}/Desktop/todo.txt" >/dev/null 2>&1 || /bin/ln -s "/${DYNDNS}/.todo.txt" "/home/${LOCALUSER}/Desktop/todo.txt" 2>/dev/null 
fi
fi
fi

################################
# LAST STEP (due to rebooot): updates

echo "23/XX UPDATES:   update installed ports AND syspatch if due (if last check was more than ${LAST_CHK_HOURS} hours ago)"
# but only if it was checked more than "LAST_CHK_SECONDS" ago 
# erratas: https://www.openbsd.org/errata.html

if [ $(/usr/bin/stat -f %m /root/hardened_openbsd_desktop.sh) -le $(( $(/bin/date +%s) - ${LAST_CHK_SECONDS} )) ]; then

echo '
running "pkg_add -u"'
# pkg_add's doesn't require rebooots in this phase of the boot process
/usr/sbin/pkg_add -u 

echo '
running "syspatch"'
/usr/sbin/syspatch
echo

# update modification time for this script to make the stat work
/usr/bin/touch /root/hardened_openbsd_desktop.sh

fi

################################
echo '24/XX SCRIPT:    sync to disk and end script'

echo "
FINISHED: /root/hardened_openbsd_desktop.sh

Please don't forget to DONATE: 

 https://www.openbsd.org/donations.html
 https://www.openbsdfoundation.org/
 https://mate-desktop.org/donate/
 https://foundation.mozilla.org/en/donate/
 https://keepass.info/donate.html
 https://www.libreoffice.org/donate/
 https://letsencrypt.org/donate/
 https://github.com/libfuse/sshfs/graphs/contributors

or just audit code, fix bugs. Thanks!

################################################################
"

# if last syspatch time is newer than current time minus 5 mins then rebooot
LAST_SYSPATCH_TIME=$(/usr/bin/stat -f %m  $(ls -1t /var/syspatch/*|head -1|cut -d':' -f1))
CURRENT_TIME_MINUS_5M=$(( $(/bin/date +%s) - 300 ))
if [[ ${LAST_SYSPATCH_TIME} -gt ${CURRENT_TIME_MINUS_5M} ]]; then 
echo 'Automatically reboooting in a few seconds due to syspatch update(s)' 
/bin/sync
/bin/sleep 10
# sync a second time to be sure
/bin/sync
/sbin/reboot
fi

# TODO: write ifconfig, arp -a 

/bin/sync
/bin/sleep 10
/usr/bin/printf '\n%.0s' `seq 1 26`

exit 0

################################
