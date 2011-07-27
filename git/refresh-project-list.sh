#!/bin/bash
cd /srv/git && (ls -d *.git/ */*.git/ | sed 's,/$,,') | while read repo; do if ! grep ^$repo project-list > /dev/null; then echo "$repo " >> project-list; fi; done; sort project-list > t; \mv t project-list
