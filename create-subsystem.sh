#!/bin/bash
# Creates a subsystem suitable for Savannah
# Depends: debootstrap

if [ -z $1 ]; then
    echo "Usage: create-subsystem.sh subsystem_name"
    exit 1
fi

ss_path=`pwd`/$1
ss_name=`basename $1`

echo "debootstrap'ing the base system"
debootstrap \
    sarge $ss_path http://localhost:9999/debian \
|| (echo "deboostrap failed" && exit 1)
#    --exclude=dhcp-client,fdutils,tasksel,telnet,info,man,lilo,mbr,syslinux,ppp,pppconfig,pppoe,pppoeconf \
# other excludes: mawk->gawk, manpages, ipchains, gcc3

echo "Installing default configuration files"
cat > $ss_path/etc/apt/sources.list <<'EOF'
deb ftp://127.0.0.1:10021 /
deb http://savannah.gnu.org:9999/security sarge/updates main
deb http://savannah.gnu.org:9999/debian sarge main
#deb-src http://savannah.gnu.org:9999/debian sarge main
#deb-src http://savannah.gnu.org:9999/security sarge/updates main
EOF
cat > $ss_path/etc/apt/preferences <<'EOF'
Explanation: Higher priority than default distros, but no downgrading
Package: *
Pin: release a=Savannah
Pin-Priority: 991
EOF
echo "127.0.0.1	$ss_name" > $ss_path/etc/hosts

cat > $ss_path/root/.bashrc <<'EOF'
# Perl will complain if the inherited locale is not installed in the subsystem
unset LANGUAGE LANG LC_ALL
umask 022

# You may uncomment the following lines if you want `ls' to be colorized:
export LS_OPTIONS='--color=auto'
eval "`dircolors`"
alias ls='ls $LS_OPTIONS'
alias ll='ls $LS_OPTIONS -l'
alias l='ls $LS_OPTIONS -lA'

# Some more alias to avoid making mistakes:
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*|screen*)
EOF

echo '    PROMPT_COMMAND='\''echo -ne "\033]0;'sv_$1': ${PWD}\007"'\' \
    >> $ss_path/root/.bashrc

cat >> $ss_path/root/.bashrc <<'EOF'
    ;;
esac
EOF

echo 'export PS1='\'sv_$1':\w\$ '\' >> $ss_path/root/.bashrc


echo "Cleaning-up '/dev'"
cd $ss_path || exit 1
rm -rf dev
mkdir -m 755 dev
cd dev || exit 1
# Basic special files
mknod -m 666 full c 1 7
mknod -m 666 null c 1 3
mknod -m 666 zero c 1 5
# SSL is not happy without some random
mknod -m 666 random  c 1 8
mknod -m 444 urandom c 1 9
# For interactive applications (ncurses)?
mknod -m 666 tty c 5 0
# Permissions/ownership
chown root:root full null random urandom zero
chown root:tty tty
# Check /sbin/MAKEDEV for more information


echo "Upgrading the system"
chroot $ss_path aptitude update
chroot $ss_path aptitude --without-recommends --assume-yes upgrade

# * Configure passwd, activate md5, shadow, set timezone to Paris.

#   dpkg-reconfigure passwd
#   dpkg-reconfigure libc6 && tzconfig
# Note: that does need to be automated, not interactive


# Make unavailable the root password

#   mv /etc/shadow /etc/shadow.bak
#   cat /etc/shadow.bak | sed s/^root.*/root:\!:12420:0:99999:7:::/g > /etc/shadow

# Note: root:*:0:0:root:/root:/bin/bash  ?
# We could also configure PAM to reject any local authentication (via login, su...)


# * Each chroot got an exim installation. Only the mail system exim config should accept mail for non local interface.

# exim installs on the machine that host the mail system must have the following in the smtp routers:

#     self = send

# Otherwise, sending a mail to the mail.gna.org system would be rejected. 



# ToDo: add /etc/init.d/subsystem-$1; remind the user to edit it and
# then run rcconf
