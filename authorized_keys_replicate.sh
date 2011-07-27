#!/bin/bash -ex
# Copy mgt vm's keys to the other instances
scp -pr ~root/.ssh/vm_authorized_keys root@frontend.savannah.gnu.org:.ssh/authorized_keys
scp -pr ~root/.ssh/vm_authorized_keys root@internal.savannah.gnu.org:.ssh/authorized_keys
scp -pr ~root/.ssh/vm_authorized_keys root@download.savannah.gnu.org:/etc/ssh/authorized_keys/root
scp -pr ~root/.ssh/vm_authorized_keys root@vcs.savannah.gnu.org:/etc/ssh/authorized_keys/root
