#!/bin/bash -ex
# Copy Dom0's keys to the Xen instances
scp -pr ~root/.ssh/authorized_keys root@builder.in.sv.gnu.org:.ssh/
scp -pr ~root/.ssh/authorized_keys root@frontend.in.sv.gnu.org:.ssh/
scp -pr ~root/.ssh/authorized_keys root@internal.in.sv.gnu.org:.ssh/
scp -pr ~root/.ssh/authorized_keys root@sftp.in.sv.gnu.org:/etc/ssh/authorized_keys/root
scp -pr ~root/.ssh/authorized_keys root@vcs-noshell.in.sv.gnu.org:/etc/ssh/authorized_keys/root
