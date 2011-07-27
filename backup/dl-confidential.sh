#!/bin/bash

# Confidential files

rsync -avHS root@colonialone.fsf.org:/ confidential/colonialone.fsf.org/ \
  --include '/root/' \
  --include '/root/.ssh/' \
  --include '/root/.ssh/authorized_keys' \
  --include '/home/' \
  --include '/home/syncaliases/' \
  --include '/home/syncaliases/.ssh/' \
  --include '/home/syncaliases/.ssh/authorized_keys' \
  --include '/root/mirrors-contacts.txt' \
  --exclude '*'

rsync -avHS root@savannah-backup.gnu.org:/ confidential/savannah-backup.gnu.org/ \
  --include '/root/' \
  --include '/root/.ssh/' \
  --include '/root/.ssh/authorized_keys' \
  --exclude '*'
