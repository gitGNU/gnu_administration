#!/bin/bash
 
ss_path=/var/lib/bind/jail

mkdir -p -m 755 $ss_path
cd $ss_path

echo "Populating /dev"
mkdir -m 755 dev/
mknod dev/null c 1 3
mknod dev/random c 1 8
chmod 666 dev/{null,random}

echo "Populating /etc"
mkdir -m 755 etc/
cp /etc/localtime etc/
# Let's copy instead of move - /etc/bind becomes a skel directory
# If it's a symlink it's probably already pointing to a chroot'd bind
if [ ! -L /etc/bind ]; then
    cp -a /etc/bind etc/
    cat > /etc/bind/README.IMPORTANT <<EOF
This directory is unused.
Check $ss_path instead.
EOF
fi
rm -f etc/bind/README.IMPORTANT
mkdir -p -m 750 etc/bind/zones/
mkdir -m 770 etc/bind/slave/
chgrp bind etc/bind etc/bind/zones/ etc/bind/slave/

echo 'Populating /var'
mkdir -p -m 755 var/run/bind/
mkdir -m 770 var/run/bind/run/
mkdir -m 755 var/cache/
mkdir -m 770 var/cache/bind/
chgrp bind var/run/bind/run/ var/cache/bind/

chattr +i etc etc/localtime var

echo 'Overwriting /etc/default/bind9'
cp /etc/default/bind9 /etc/default/bind9.bak
cat > /etc/default/bind9 <<EOF
OPTIONS="-t $ss_path -u bind"
EOF
echo 'Trying to set SYSLOGD="-a $ss_path/dev/log"'
echo '  in /etc/init.d/sysklogd'
sed -i 's|SYSLOGD=""|SYSLOGD="-a '$ss_path'/dev/log"|' /etc/init.d/sysklogd
