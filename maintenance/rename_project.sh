#!/bin/bash
# Rename some project-related directories
# Copyright (C) 2005, 2006  Sylvain Beucler
# Copyright (C) 2006  Steven Robson

# Savane is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2, or (at your option)
# any later version.

# Savane is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with program; see the file COPYING. If not, write to the Free
# Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA
# 02110-1301, USA.

# Print progress
set -x
# Stop on error
#set -e

function usage() {
echo "Usage: $0 from to";
exit 1;
}

from=$1
if [ -z "$from" ]; then usage; fi
if ! ssh root@vcs-noshell.in.sv.gnu.org getent group "$from" > /dev/null ; then echo "$from doesn't exist."; exit 2; fi

to=$2
if [ -z "$to" ]; then usage; fi
if ssh root@vcs-noshell.in.sv.gnu.org getent group "$to" > /dev/null ; then echo "$to already exists."; exit 2; fi

##
# CVS
##

# Sources
ssh root@vcs-noshell.in.sv.gnu.org mv /srv/cvs/sources/$from /srv/cvs/sources/$to &&
ssh root@vcs-noshell.in.sv.gnu.org mv /srv/cvs/sources/$to/$from /srv/cvs/sources/$to/$to
ssh root@vcs-noshell.in.sv.gnu.org mv /var/lock/cvs/sources/$from /var/lock/cvs/sources/$to &&
ssh root@vcs-noshell.in.sv.gnu.org mv /var/lock/cvs/sources/$to/$from /var/lock/cvs/sources/$to/$to

ssh root@vcs-noshell.in.sv.gnu.org chattr -i /srv/cvs/sources/$to/CVSROOT
ssh root@vcs-noshell.in.sv.gnu.org sed -i -e \""s:\(^LockDir=/var/lock/cvs/sources/\)$from:\1$to:"\" \
  /srv/cvs/sources/$to/CVSROOT/config
ssh root@vcs-noshell.in.sv.gnu.org chattr +i /srv/cvs/sources/$to/CVSROOT

# Web
ssh root@vcs-noshell.in.sv.gnu.org mv /srv/cvs/web/$from /srv/cvs/web/$to &&
ssh root@vcs-noshell.in.sv.gnu.org mv /srv/cvs/web/$to/$from /srv/cvs/web/$to/$to
ssh root@vcs-noshell.in.sv.gnu.org mv /var/lock/cvs/web/$from /var/lock/cvs/web/$to &&
ssh root@vcs-noshell.in.sv.gnu.org mv /var/lock/cvs/web/$to/$from /var/lock/cvs/web/$to/$to

ssh root@vcs-noshell.in.sv.gnu.org chattr -i /srv/cvs/web/$to/CVSROOT
ssh root@vcs-noshell.in.sv.gnu.org sed -i -e \""s:\(^LockDir=/var/lock/cvs/web/\)$from:\1$to:"\" \
  /srv/cvs/web/$to/CVSROOT/config
ssh root@vcs-noshell.in.sv.gnu.org chattr +i /srv/cvs/web/$to/CVSROOT

##
# Download
##

ssh root@sftp.in.sv.gnu.org mv /srv/download/$from /srv/download/$to

## GPG Keyring
#from_first=`echo $from | cut -b1`
#from_second=`echo $from | cut -b1,2`
#to_first=`echo $to | cut -b1`
#to_second=`echo $to | cut -b1,2`
#vnamespace -e $accounts_xid mkdir -m 755 -p /vservers/accounts/home/savane-keyrings/$to_first/$to_second &&
#vnamespace -e $accounts_xid mv /vservers/accounts/home/savane-keyrings/$from_first/$from_second/$from.gpg /vservers/accounts/home/savane-keyrings/$to_first/$to_second/$to.gpg &&
#vnamespace -e $accounts_xid rm -f /vservers/accounts/home/savane-keyrings/$from_first/$from_second/$from.gpg~


##
# SVN
##

ssh root@vcs-noshell.in.sv.gnu.org mv /srv/svn/$from /srv/svn/$to

##
# Git
##

ssh root@vcs-noshell.in.sv.gnu.org mv /srv/git/$from.git /srv/git/$to.git &&
ssh root@vcs-noshell.in.sv.gnu.org mv /srv/git/$from /srv/git/$to

##
# Hg
##

ssh root@vcs-noshell.in.sv.gnu.org mv /srv/hg/$from /srv/hg/$to

##
# Arch
##

ssh root@sftp.in.sv.gnu.org mv /srv/arch/$from /srv/arch/$to

##
# bzr
##

ssh root@sftp.in.sv.gnu.org mv /srv/bzr/$from /srv/bzr/$to


###
# TODO
##

# rename the project groups in /etc/group
# Not necessary since we use libnss-mysql-bg
#vnamespace -e $accounts_xid chroot /vservers/accounts groupmod -n $to $from

# rename the group name in the Savannah DB
# TODO: error handling?
ssh root@internal.in.sv.gnu.org "mysql savane -e \"UPDATE groups SET unix_group_name='$to' WHERE unix_group_name='$from';\""

# TODO: GNU|www.gnu.org|translation-team or non-GNU|GUG?
echo curl http://www.gnu.org/new-savannah-project/new.py -F type='gnu|non-gnu' -F project=$to
