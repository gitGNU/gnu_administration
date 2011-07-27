<?php
$sys_default_domain="savannah.gnu.org";
$sys_https_host="$sys_default_domain";
$sys_brother_domain="savannah.nongnu.org";
$sys_dbhost="10.1.0.101";
$sys_dbname="savane";
$sys_dbuser="savannahscripts";
$sys_dbpasswd=rtrim(file_get_contents(dirname(__FILE__).'/savane.pass'));
$sys_incdir="/etc/savane/content/gnu-content";
$sys_name="Savannah";
$sys_unix_group_name="administration";
$sys_themedefault="Savannah";
$sys_logo_name="floating.png";
$sys_logo_name_width="148";
$sys_logo_name_height="125";
$sys_mail_domain="gnu.org";
$sys_mail_admin="savannah-reports-private";
$sys_mail_replyto="INVALID.NOREPLY";
$sys_mail_list="/etc/email-addresses";
$sys_mail_aliases="/etc/aliases";
$sys_userx_prefix="/usr/sbin";
#if ($_SERVER['REMOTE_ADDR'] == '82.238.35.175') {
#  $sys_debug_on = true;
#}
$sys_debug_sqlprofiler=true;
