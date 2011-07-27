#!/bin/bash
# SSH_ORIGINAL_COMMAND="rsync --server --sender -vlHogDtprSe.iLs --numeric-ids . /mnt/snapshots/builder/"
set -e
name=$(echo $SSH_ORIGINAL_COMMAND | grep -oE '[^/ ]*/$')
name=${name%/}
if [ -z "$name" ]; then
    # dom0 backup
    exec nice -n 19 ionice -n 7 rsync --server --sender ${SSH_ORIGINAL_COMMAND#*rsync }
else
    # Create a LVM snapshot from which to backup safely
    lvcreate -s /dev/vg_savannah/$name-disk -n $name-snapshot -L100G > /dev/null
    mkdir -p -m 700 /mnt/snapshots/$name
    mount -o ro /dev/vg_savannah/$name-snapshot /mnt/snapshots/$name
    nice -n 19 ionice -n 7 rsync --server --sender ${SSH_ORIGINAL_COMMAND#*rsync } || true
    umount /mnt/snapshots/$name
    lvremove --force /dev/vg_savannah/$name-snapshot > /dev/null
fi
