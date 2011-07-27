#!/usr/bin/env python
#
# An example CGI script to export multiple hgweb repos,
# edit as necessary

# enable importing on demand to reduce startup time
from mercurial import demandimport; demandimport.enable()

# send python tracebacks to the browser if an error occurs:
import cgitb
cgitb.enable()

# Note that this will cause your .hgrc files to be interpreted in
# UTF-8 and all your repo files to be displayed using UTF-8.
import os
os.environ["HGENCODING"] = "UTF-8"

from mercurial.hgweb.hgwebdir_mod import hgwebdir
from mercurial.hgweb.request import wsgiapplication
import mercurial.hgweb.wsgicgi as wsgicgi

def make_web_app():
    return hgwebdir("/etc/mercurial/hgwebdir.conf")

application = wsgiapplication(make_web_app)
