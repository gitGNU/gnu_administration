#!/bin/bash

# Copyright (C) 2006, 2009  Sylvain Beucler
# No rights deserved

function usage() {
echo "Usage: $0 from to";
exit 1;
}

from=$1
if [ -z "$from" ]; then usage; fi
if ! chroot /vservers/accounts getent passwd "$from" > /dev/null; then echo "$from doesn't exist."; exit 2; fi

to=$2
if [ -z "$to" ]; then usage; fi
if chroot /vservers/accounts getent passwd "$to" > /dev/null; then echo "$to already exists."; exit 2; fi


vserver internal exec mysql savane -e "UPDATE user SET user_name='$to' WHERE user_name='$from';"
vserver internal exec mysql savane -e "UPDATE group_history SET old_value='$to' WHERE field_name='Added User' AND old_value='$from';"
vserver internal exec mysql savane -e "UPDATE group_history SET old_value='$to' WHERE field_name='Approved User' AND old_value='$from';"
vserver internal exec mysql savane -e "UPDATE group_history SET old_value='$to' WHERE field_name='User Requested Membership' AND old_value='$from';"

from_first=`echo $from | cut -b1`
from_second=`echo $from | cut -b1,2`
to_first=`echo $to | cut -b1`
to_second=`echo $to | cut -b1,2`
mkdir -p -m 775 /vservers/accounts/home/$to_first/$to_second/

# Not necessary since libnss-mysql-bg support
#chroot /vservers/accounts usermod -l $to -d /home/$to_first/$to_second/$to -m $from
