ServerAdmin savannah-hackers@gnu.org
ServerName cvs.savannah.gnu.org
ServerAlias web.cvs.savannah.gnu.org

DocumentRoot /var/www/cvs
<Directory />
  Options FollowSymLinks
  AllowOverride None
</Directory>
<Directory /var/www/cvs>
  Options None
  AllowOverride None
</Directory>

ScriptAlias /awstats.pl /var/www/cvs/awstats.pl

## Mozilla Doctor
#<Directory /var/www/cvs/doctor/>
#  Options ExecCGI FollowSymLinks
#  AddHandler cgi-script cgi
#  DirectoryIndex doctor.cgi
#</Directory>
#<Directory /var/www/cvs/htmlarea/>
#  Options ExecCGI FollowSymLinks
#  AddHandler cgi-script cgi
#  DirectoryIndex doctor.cgi
#</Directory>


Include sites-available/viewvc.inc


LogLevel warn
CustomLog /var/log/apache2/cvs/access.log combined
ErrorLog /var/log/apache2/cvs/error.log
