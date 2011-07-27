#!/bin/bash

# VServer host (=~ dom0) - Savannah2004
# Unplugged 2009-02-09 - sayonara!
#rsync --quiet --archive --hard-links --sparse --delete-excluded --numeric-ids --exclude '/dev/pts/*' --exclude '/proc/*' --exclude '/sys/*' --exclude '/dev/shm/*' --exclude '/mnt/*/*' --exclude '/media/*/*' --include '/var/cache/apt/archives/partial' --exclude '/var/cache/apt/archives/*' --exclude '/tmp/*' root@savannah2004.savannah.gnu.org:/ /mnt/backup/host/copy/ --exclude '/root/Trash/*' --exclude '/root/deleted-projects/*' --include '/vservers/.*' --exclude '/vservers/*' --exclude '/root/10_old_root'

# Xen Dom0 - Savannah2009
rsync --quiet --archive --hard-links --sparse --delete-excluded --numeric-ids --exclude '/dev/pts/*' --exclude '/proc/*' --exclude '/sys/*' --exclude '/dev/shm/*' --exclude '/mnt/*/*' --exclude '/media/*/*' --include '/var/cache/apt/archives/partial' --exclude '/var/cache/apt/archives/*' --exclude '/tmp/*' root@colonialone.fsf.org:/ /mnt/backup/colonialone-dom0/copy/ --exclude '/root/Trash/*' --exclude '/root/deleted-projects/*' --exclude '/root/10_old_root' --exclude '/root/compromise-2010/suspect-root'

# vcs-noshell - Savannah2004
#rsync --quiet --archive --hard-links --sparse --delete-excluded --numeric-ids --exclude '/dev/pts/*' --exclude '/proc/*' --exclude '/sys/*' --exclude '/dev/shm/*' --exclude '/mnt/*/*' --exclude '/media/*/*' --include '/var/cache/apt/archives/partial' --exclude '/var/cache/apt/archives/*' --exclude '/tmp/*' root@savannah.gnu.org:/vservers/vcs-noshell/ /mnt/backup/vcs-noshell/copy/ --exclude '/home/*' --exclude '/var/cache/cgit/*' --exclude '/var/lock/cvs/*'
# vcs-noshell - Savannah2009
rsync --quiet --archive --hard-links --sparse --delete-excluded --numeric-ids --exclude '/dev/pts/*' --exclude '/proc/*' --exclude '/sys/*' --exclude '/dev/shm/*' --exclude '/mnt/*/*' --exclude '/media/*/*' --include '/var/cache/apt/archives/partial' --exclude '/var/cache/apt/archives/*' --exclude '/tmp/*' root@colonialone.fsf.org:/mnt/snapshots/vcs-noshell/ /mnt/backup/vcs-noshell/copy/ --exclude '/var/cache/cgit/*' --exclude '/var/lock/cvs/*'

# sftp - Savannah2009
rsync --quiet --archive --hard-links --sparse --delete-excluded --numeric-ids --exclude '/dev/pts/*' --exclude '/proc/*' --exclude '/sys/*' --exclude '/dev/shm/*' --exclude '/mnt/*/*' --exclude '/media/*/*' --include '/var/cache/apt/archives/partial' --exclude '/var/cache/apt/archives/*' --exclude '/tmp/*' root@colonialone.fsf.org:/mnt/snapshots/sftp/ /mnt/backup/sftp/copy/

# builder - Savannah2009
rsync --quiet --archive --hard-links --sparse --delete-excluded --numeric-ids --exclude '/dev/pts/*' --exclude '/proc/*' --exclude '/sys/*' --exclude '/dev/shm/*' --exclude '/mnt/*/*' --exclude '/media/*/*' --include '/var/cache/apt/archives/partial' --exclude '/var/cache/apt/archives/*' --exclude '/tmp/*' root@colonialone.fsf.org:/mnt/snapshots/builder/ /mnt/backup/builder/copy/

# frontend
#rsync --quiet --archive --hard-links --sparse --delete-excluded --numeric-ids --exclude '/dev/pts/*' --exclude '/proc/*' --exclude '/sys/*' --exclude '/dev/shm/*' --exclude '/mnt/*/*' --exclude '/media/*/*' --include '/var/cache/apt/archives/partial' --exclude '/var/cache/apt/archives/*' --exclude '/tmp/*' root@savannah.gnu.org:/vservers/frontend/ /mnt/backup/frontend/copy/
rsync --quiet --archive --hard-links --sparse --delete-excluded --numeric-ids --exclude '/dev/pts/*' --exclude '/proc/*' --exclude '/sys/*' --exclude '/dev/shm/*' --exclude '/mnt/*/*' --exclude '/media/*/*' --include '/var/cache/apt/archives/partial' --exclude '/var/cache/apt/archives/*' --exclude '/tmp/*' root@colonialone.fsf.org:/mnt/snapshots/frontend/ /mnt/backup/frontend/copy/

# internal
#rsync --quiet --archive --hard-links --sparse --delete-excluded --numeric-ids --exclude '/dev/pts/*' --exclude '/proc/*' --exclude '/sys/*' --exclude '/dev/shm/*' --exclude '/mnt/*/*' --exclude '/media/*/*' --include '/var/cache/apt/archives/partial' --exclude '/var/cache/apt/archives/*' --exclude '/tmp/*' root@savannah.gnu.org:/vservers/internal/ /mnt/backup/internal/copy/ --exclude '/var/cache/approx/*'
rsync --quiet --archive --hard-links --sparse --delete-excluded --numeric-ids --exclude '/dev/pts/*' --exclude '/proc/*' --exclude '/sys/*' --exclude '/dev/shm/*' --exclude '/mnt/*/*' --exclude '/media/*/*' --include '/var/cache/apt/archives/partial' --exclude '/var/cache/apt/archives/*' --exclude '/tmp/*' root@colonialone.fsf.org:/mnt/snapshots/internal/ /mnt/backup/internal/copy/ --exclude '/var/cache/approx/*'
