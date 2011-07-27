# Savane

DocumentRoot /var/www/savane/frontend/php

<Directory "/var/www/savane/frontend/php/">
  # PHP conf
  php_admin_flag register_globals off
  php_admin_flag magic_quotes_gpc off
  php_admin_flag file_uploads on

  php_admin_flag allow_url_fopen off
  php_admin_flag display_errors on
  # Still check for warnings in /var/log/apache/error.log
  php_admin_flag log_errors on
  # Set error_reporting=E_ALL|E_NOTICE:
  php_admin_value error_reporting 8191
  php_admin_value disable_functions exec,passthru,popen,shell_exec,system

  DirectoryIndex index.php index.html
</Directory>

<Files ~ "^(users|us|u|projects|pr|p|file)$">
  SetHandler application/x-httpd-php
</Files>
ErrorDocument 404 /404.php

# Restrict access into include/
<Directory "/var/www/savane/frontend/php/include/">
  Order Allow,Deny
  Deny from all
</Directory>

# Tracker export
Alias /export /var/cache/savane/
<Directory "/var/cache/savane/">
  Options Indexes FollowSymLinks
  AllowOverride None
  <IfModule mod_php4.c>
    php_flag engine off
  </IfModule>
</Directory>


# Overlay
Alias /favicon.ico /var/www/overlay/favicon.ico

# Services that moved or disappeared
Redirect permanent /cgi-bin/viewcvs http://cvs.savannah.gnu.org/viewvc

# The FSF has received a DMCA takedown notice for the eliot project.
# We have to comply with the notice so as not to loose the safeharbor
# protection.
# Temporarily (?) disabled downloads, while contacting the developers.
# See RT #567057 and #567701. Ward, 2010-04-21
RedirectTemp /download/eliot http://download.savannah.gnu.org/releases-noredirect/eliot

Redirect permanent /download http://download.savannah.gnu.org/releases
Alias /rsync-access.html /var/www/overlay/rsync-access.html
<Location "/cvs-backup">
	# The last arg is an _URL_
	ErrorDocument 404 /rsync-access.html
</Location>

# Package identifier list to be used by other GNU teams
Alias /cooperation /var/www/overlay/cooperation/
<Directory "/var/www/overlay/cooperation/">
  Options Indexes
  AllowOverride None

  # Disable script engines
  # Method 1:
  ForceType text/plain

  # Method 2:
  <IfModule mod_php5.c>
    # Tested with Apache2 + mod-php5
    php_flag engine off
  </IfModule>
  <IfModule sapi_apache2.c>
    # Not working with Apache1 + mod-php5
    php_flag engine off
  </IfModule>
  <IfModule mod_perl.c>
    # Disable mod_perl
  </IfModule>
  # Disable mod_python...
</Directory>


Alias /register /var/www/savane/frontend/php/register2/
<Location "/register">
  php_admin_value post_max_size 52428800
  php_admin_value upload_max_filesize 52428800
</Location>
Alias /submissions_uploads /var/www/submissions_uploads/
<Directory "/var/www/submissions_uploads/">
  Options Indexes
  AllowOverride None

  # Disable script engines
  # Method 1:
  #ForceType application/octet-stream

  # Method 2:
  <IfModule mod_php5.c>
    # Tested with Apache2 + mod-php5
    php_admin_flag engine off
  </IfModule>
  <IfModule sapi_apache2.c>
    # Not working with Apache1 + mod-php5
    php_admin_flag engine off
  </IfModule>
  <IfModule mod_perl.c>
    # Disable mod_perl
  </IfModule>
  # Disable mod_python...

  # Method 3:
  <FilesMatch ".">
    SetHandler default-handler
  </FilesMatch>
</Directory>

# FAQ move
RewriteEngine on
RewriteCond %{QUERY_STRING} (group_id=5802&)?question=CVS_-_How_do_I_start_using_the_repository.txt
RewriteRule ^/faq/(index.php)? http://savannah.gnu.org/maintenance/CvsGettingStarted? [redirect,last]
RewriteCond %{QUERY_STRING} (group_id=5802&)?question=CVS_-_How_can_I_access_a_repository_from_behind_a_firewall_or_proxy.txt
RewriteRule ^/faq/(index.php)? http://savannah.gnu.org/maintenance/CvsFromBehindFirewall? [redirect,last]
RewriteCond %{QUERY_STRING} (group_id=5802&)?question=CVS_-_How_can_I_import_an_existing_repository.txt
RewriteRule ^/faq/(index.php)? http://savannah.gnu.org/maintenance/CvsImportExistingRepo? [redirect,last]
RewriteCond %{QUERY_STRING} (group_id=5802&)?question=CVS_-_How_can_I_import_my_project.txt
RewriteRule ^/faq/(index.php)? http://savannah.gnu.org/maintenance/CvsImportExistingProject? [redirect,last]
RewriteCond %{QUERY_STRING} (group_id=5802&)?question=CVS_-_How_to_do_anonymous_access.txt
RewriteRule ^/faq/(index.php)? http://savannah.gnu.org/maintenance/CvsAnonymous? [redirect,last]
RewriteCond %{QUERY_STRING} (group_id=5802&)?question=CVS_-_Is_it_possible_to_receive_an_email_for_each_commit.txt
RewriteRule ^/faq/(index.php)? http://savannah.gnu.org/maintenance/CvsEmailOnCommit? [redirect,last]

RewriteCond %{QUERY_STRING} (group_id=5802&)?question=Download_Area_-_How_do_I_add_files.txt
RewriteRule ^/faq/(index.php)? http://savannah.gnu.org/maintenance/DownloadArea? [redirect,last]

RewriteCond %{QUERY_STRING} (group_id=5802&)?question=Homepage_-_Are_PHP_and_MySQL_available.txt
RewriteRule ^/faq/(index.php)? http://savannah.gnu.org/maintenance/HomepageAvailabilityOfPhpAndMysql? [redirect,last]
RewriteCond %{QUERY_STRING} (group_id=5802&)?question=Homepage_-_How_do_I_upload_my_homepage.txt
RewriteRule ^/faq/(index.php)? http://savannah.gnu.org/maintenance/HomepageUpload? [redirect,last]

RewriteCond %{QUERY_STRING} (group_id=5802&)?question=Mail_-_How_to_reset_list_admin_password.txt
RewriteRule ^/faq/(index.php)? http://savannah.gnu.org/maintenance/MailListAdminPasswordReset? [redirect,last]
RewriteCond %{QUERY_STRING} (group_id=5802&)?question=Mail_-_Is_there_a_searchable_list_of_mailing_lists.txt
RewriteRule ^/faq/(index.php)? http://savannah.gnu.org/maintenance/MailListOfAvailableMailingLists? [redirect,last]
RewriteCond %{QUERY_STRING} (group_id=5802&)?question=Mail_-_Lost_Mailman_password.txt
RewriteRule ^/faq/(index.php)? http://savannah.gnu.org/maintenance/MailLostMailmanPassword? [redirect,last]
RewriteCond %{QUERY_STRING} (group_id=5802&)?question=Mail_-_Where_can_I_retreive_mailing_lists_mboxes.txt
RewriteRule ^/faq/(index.php)? http://savannah.gnu.org/maintenance/MailAccessToMailinglistMboxes? [redirect,last]
RewriteCond %{QUERY_STRING} (group_id=5802&)?question=Mail_-_Why_do_I_not_receive_email_from_Savannah.txt
RewriteRule ^/faq/(index.php)? http://savannah.gnu.org/maintenance/MailWhyNoMailFromSavannah? [redirect,last]

RewriteCond %{QUERY_STRING} (group_id=5802&)?question=Project_-_How_do_I_add_searchterms.txt
RewriteRule ^/faq/(index.php)? http://savannah.gnu.org/maintenance/HowDoIAddSearchTerms? [redirect,last]
RewriteCond %{QUERY_STRING} (group_id=5802&)?question=Project_-_How_do_I_set_up_a_FAQ.txt
RewriteRule ^/faq/(index.php)? http://savannah.gnu.org/maintenance/HowDoISetUpAProjectFAQ? [redirect,last]
RewriteCond %{QUERY_STRING} (group_id=5802&)?question=Project_-_How_to_get_it_approved_quickly.txt
RewriteRule ^/faq/(index.php)? http://savannah.gnu.org/maintenance/HowToGetYourProjectApprovedQuickly? [redirect,last]
RewriteCond %{QUERY_STRING} (group_id=5802&)?question=Project_-_Is_there_a_way_to_clean_it_all.txt
RewriteRule ^/faq/(index.php)? http://savannah.gnu.org/maintenance/HowDoIResetMyProject? [redirect,last]
RewriteCond %{QUERY_STRING} (group_id=5802&)?question=Project_-_What_does_it_mean_to_become_a_GNU_package.txt
RewriteRule ^/faq/(index.php)? http://savannah.gnu.org/maintenance/WhatDoesItMeanToBecomeAGNUPackage? [redirect,last]
RewriteCond %{QUERY_STRING} (group_id=5802&)?question=Project_-_What_is_the_registration_process.txt
RewriteRule ^/faq/(index.php)? http://savannah.gnu.org/maintenance/WhatIsTheRegistrationProcess? [redirect,last]
RewriteCond %{QUERY_STRING} (group_id=5802&)?question=Project_-_What_is_the_status_of_my_project_registration.txt
RewriteRule ^/faq/(index.php)? http://savannah.gnu.org/maintenance/WhatIsTheStatusOfMyProjectRegistration? [redirect,last]

RewriteCond %{QUERY_STRING} (group_id=5802&)?question=Savannah_-_Are_there_some_URL_shortcuts.txt
RewriteRule ^/faq/(index.php)? http://savannah.gnu.org/maintenance/SavannahURLShortcuts? [redirect,last]
RewriteCond %{QUERY_STRING} (group_id=5802&)?question=Savannah_-_Are_there_some_delays_on_update.txt
RewriteRule ^/faq/(index.php)? http://savannah.gnu.org/maintenance/SavannahUpdateDelays? [redirect,last]
RewriteCond %{QUERY_STRING} (group_id=5802&)?question=Savannah_-_Are_there_some_places_on_internet_to_get_more_information.txt
RewriteRule ^/faq/(index.php)? http://savannah.gnu.org/maintenance/SavannahMoreInfo? [redirect,last]
RewriteCond %{QUERY_STRING} (group_id=5802&)?question=Savannah_-_Hey_this_is_not_valid_HTML.txt
RewriteRule ^/faq/(index.php)? http://savannah.gnu.org/maintenance/SavannahInvalidHTML? [redirect,last]
RewriteCond %{QUERY_STRING} (group_id=5802&)?question=Savannah_-_How_do_I_get_help.txt
RewriteRule ^/faq/(index.php)? http://savannah.gnu.org/maintenance/GettingHelp? [redirect,last]
RewriteCond %{QUERY_STRING} (group_id=5802&)?question=Savannah_-_Is_there_any_restriction_on_cryptographic_software.txt
RewriteRule ^/faq/(index.php)? http://savannah.gnu.org/maintenance/SavannahCryptographicRestrictions? [redirect,last]
RewriteCond %{QUERY_STRING} (group_id=5802&)?question=Savannah_-_Where_can_I_find_information_regarding_the_TLS_certificates.txt
RewriteRule ^/faq/(index.php)? http://savannah.gnu.org/maintenance/SavannahTLSInfo? [redirect,last]
RewriteCond %{QUERY_STRING} (group_id=5802&)?question=Savannah_-_Why_chosing_Savannah.txt
RewriteRule ^/faq/(index.php)? http://savannah.gnu.org/maintenance/WhyChooseSavannah? [redirect,last]

RewriteCond %{QUERY_STRING} (group_id=5802&)?question=User_Account_-_How_do_I_configure_my_SSH_access.txt
RewriteRule ^/faq/(index.php)? http://savannah.gnu.org/maintenance/SshAccess? [redirect,last]
RewriteCond %{QUERY_STRING} (group_id=5802&)?question=User_Account_-_How_do_I_use_GPG.txt
RewriteRule ^/faq/(index.php)? http://savannah.gnu.org/maintenance/UsingGpg? [redirect,last]
RewriteCond %{QUERY_STRING} (group_id=5802&)?question=User_Account_-_Lost_password.txt
RewriteRule ^/faq/(index.php)? http://savannah.gnu.org/maintenance/LostPassword? [redirect,last]
RewriteCond %{QUERY_STRING} (group_id=5802&)?question=User_Account_-_Why_log_in.txt
RewriteRule ^/faq/(index.php)? http://savannah.gnu.org/maintenance/WhyLogin]? [redirect,last]

Redirect permanent /faq/ https://savannah.gnu.org/maintenance/FaQ


# Post 2003 compromise announcements
# Referenced in news items
Alias /statements /var/www/statements
<Directory "/var/www/statements/">
  Options Indexes
</Directory>



# Info about TLS/SSL certificates
Alias /tls /var/www/tls
<Directory "/var/www/tls/">
  AddType text/html .shtml
  AddHandler server-parsed .shtml
  Options IncludesNOEXEC FollowSymlinks
  DirectoryIndex index.shtml
</Directory>


# Zope (and ZWiki)
<Proxy *>
  Order deny,allow
  Allow from all
</Proxy>

# The following generates spurious warnings.
#[Sat Feb 28 22:59:09 2009] [warn] worker http://localhost:9673 already used by another worker
#[Sat Feb 28 22:59:09 2009] [warn] worker http://localhost:9673 already used by another worker
#[Sat Feb 28 22:59:09 2009] [warn] worker http://localhost:9673 already used by another worker
#[Sat Feb 28 22:59:09 2009] [warn] worker http://localhost:9673 already used by another worker
# This is a bug:
# https://issues.apache.org/bugzilla/show_bug.cgi?id=44350

ProxyPass /misc_ http://localhost:9673/misc_
ProxyPass /p_ http://localhost:9673/p_

ProxyPass /ZopeAdmin http://localhost:9673
ProxyPassReverse /ZopeAdmin http://localhost:9673

ProxyPass /maintenance http://localhost:9673/maintenance
ProxyPassReverse /maintenance http://localhost:9673/maintenance

RedirectMatch (/manage.*) https://savannah.gnu.org/ZopeAdmin$1
RedirectMatch (/zope_.*) https://savannah.gnu.org/ZopeAdmin$1


<Location /server-status>
  SetHandler server-status
</Location>

Alias /xcache /usr/share/xcache/admin

## Savane old version
#Alias /old /var/www/frontend-old/php/
#<Directory "/var/www/frontend-old/php/">
#  SetEnv SV_LOCAL_INC_PREFIX /etc/savane/conf-old
#  AllowOverride All
#</Directory>
#
#RewriteRule ^/new/(.*) /$1 [redirect,last]

Alias /webalizer /var/www/webalizer
ScriptAlias /awstats.pl /usr/lib/cgi-bin/awstats.pl
ScriptAlias /cgi-bin /usr/lib/cgi-bin

Include /etc/apache2/sites-available/crawlers.inc

CustomLog /var/log/apache2/access.log combined
