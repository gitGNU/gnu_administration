# ViewVC

Alias /viewcvs-doc /var/www/off-site/viewvc/templates/docroot

# ViewCVS old config
#ScriptAlias /viewcvs /usr/lib/cgi-bin/viewcvs.cgi
# Redirection:
RewriteEngine on
RewriteRule ^/viewcvs/(.*) /viewvc/$1 [redirect,last]

# Entry point
ScriptAlias /viewvc /var/www/off-site/viewvc/bin/cgi/viewvc.cgi
# If somebody knows how to tell mod_python to serve /viewvc directly,
# please replace this mod_rewrite hack:
RewriteRule ^/viewvc-mp/ /viewvc-mp-files/viewvc.py/ [passthrough]

# ViewVC mod_python config
# Don't use because it breaks old links like
# /viewvc/emacs/emacs/lisp/autoinsert.el (ie no ?root= parameter) :'(
# Also it still write links as /viewvc-mp-files, maybe:
# PythonOption Location /viewvc
# More tricks at http://moinmoin.wikiwikiweb.de/HelpOnInstalling/ApacheWithModPython

#Alias /viewvc-mp-files /var/www/off-site/viewvc/bin/mod_python
#<Directory "/var/www/off-site/viewvc/bin/mod_python/">
#  AddHandler python-program .py
#  PythonHandler handler
#  PythonDebug On
#  # Doesn't work:
#  PythonOption Location /viewvc
#</Directory>
#
## Attempt to make it run at the top-level
#<Location "/viewvc-mp-direct">
#  SetHandler python-program
#  PythonPath "['/var/www/off-site/viewvc/bin/mod_python'] + sys.path"
##  PythonHandler MoinMoin.request::RequestModPy.run
#  PythonHandler handler.handler
#  PythonOption Location /viewvc
#</Location>


# ViewCVS mod_python version: gave too much troubles to be worth the
# (existing?) performance boost.
#Alias /viewcvs /var/www/viewcvs-mod_python/sources/viewcvs.py
## I can't make this other instance use another config file :/
## The goal is to have root=?projectname for web repos as well
## (this permits to include a link back to project in the template)
## ViewCVS vhosts are not supported either.
##Alias /viewcvs.web /var/www/viewcvs-mod_python/web/viewcvs.py
#<Directory "/var/www/viewcvs-mod_python">
#  AddHandler mod_python .py
#  PythonHandler apache
#  PythonPath "[r'/usr/lib/python2.3/site-packages/viewcvs/']+sys.path"
#  PythonDebug On
#</Directory>
