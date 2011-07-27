#!/bin/bash
exec nice -n 19 ionice -n 7 rsync --server --sender ${SSH_ORIGINAL_COMMAND#*rsync }
