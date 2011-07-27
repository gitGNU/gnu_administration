#!/bin/bash -ex
# Makes a backup copy
# Copyright (C) 2005, 2006, 2010  Sylvain Beucler, no rights reserved

group=$1
if [ -z "$group" -o "$group" = "--help" -o "$group" = "-h" ]; then echo "Usage: $0 group_name"; exit 1; fi
#if [ ! -e "/vservers/cvs/web/$group" ]; then echo "Group $group does not exist."; exit 1; fi
id=$(ssh root@internal.in.sv.gnu.org "mysql savane -B -e \"SELECT group_id FROM groups where unix_group_name='$group';\"" | tail -n +2)

ssh root@internal.in.sv.gnu.org "perl -MSavane -e 'DeleteGroup($group);'"
if [ ! -z "$id" ]; then
    ssh root@internal.in.sv.gnu.org "mysql savane -e \"DELETE FROM trackers_watcher WHERE group_id='$id';\""
fi

backup_dir=~/deleted-projects/$group
mkdir $backup_dir

ssh root@vcs-noshell.in.sv.gnu.org chattr -i /srv/cvs/sources/$group/CVSROOT
rsync -aHS root@vcs-noshell.in.sv.gnu.org:/srv/cvs/sources/$group/ $backup_dir/sources/
ssh root@vcs-noshell.in.sv.gnu.org rm -rf /srv/cvs/sources/$group/

rsync -aHS root@vcs-noshell.in.sv.gnu.org:/srv/cvs/web/$group/ $backup_dir/web/
# Empty the website - no need to ask sysadmin that way
ssh root@vcs-noshell.in.sv.gnu.org find /srv/cvs/web/$group/$group -type f -print0 \| xargs -0 --no-run-if-empty rm
echo "No more there." | ssh root@vcs-noshell.in.sv.gnu.org cat \> /srv/cvs/web/$group/$group/index.html
ssh root@vcs-noshell.in.sv.gnu.org ci -q -m'-' /srv/cvs/web/$group/$group/index.html < /dev/null
curl http://www.gnu.org/new-savannah-project/new.py -F type=non-gnu -F project=$group
ssh root@vcs-noshell.in.sv.gnu.org chattr -i /srv/cvs/web/$group/CVSROOT
ssh root@vcs-noshell.in.sv.gnu.org rm -rf /srv/cvs/web/$group/
ssh root@vcs-noshell.in.sv.gnu.org rm -rf /var/lock/cvs/web/$group
ssh root@vcs-noshell.in.sv.gnu.org rm -rf /var/lock/cvs/sources/$group

rsync -aHS root@sftp.in.sv.gnu.org:/srv/download/$group/ $backup_dir/download/
ssh root@sftp.in.sv.gnu.org rm -rf /srv/download/$group/

ssh root@vcs-noshell.in.sv.gnu.org chattr -i /srv/git/$group.git/hooks
rsync -aHS root@vcs-noshell.in.sv.gnu.org:/srv/git/$group.git/ $backup_dir/$group.git/
ssh root@vcs-noshell.in.sv.gnu.org rm -rf /srv/git/$group.git/

ssh root@vcs-noshell.in.sv.gnu.org chattr -f -i /srv/git/$group/*/hooks
rsync -aHS root@vcs-noshell.in.sv.gnu.org:/srv/git/$group/ $backup_dir/git/
ssh root@vcs-noshell.in.sv.gnu.org rm -rf /srv/git/$group/

rsync -aHS root@vcs-noshell.in.sv.gnu.org:/srv/hg/$group/ $backup_dir/hg/
ssh root@vcs-noshell.in.sv.gnu.org rm -rf /srv/hg/$group/


# GPG Keyring
#group_first=`echo $group | cut -b1`
#group_second=`echo $group | cut -b1,2`
#rm -f /vservers/accounts/home/savane-keyrings/$group_first/$group_second/$group.gpg*

# Not necessary since we use libnss-mysql-bg
#vserver accounts exec groupdel $group
