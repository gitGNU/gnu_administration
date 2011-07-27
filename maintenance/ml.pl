#!/usr/bin/perl
use strict;
use Savane;
use Getopt::Long;

my $help;
my $group_name;
my $admin_name;
my $list_name;

my $getopt = GetOptions("help" => \$help,
			"group_name=s" => \$group_name,
			"admin_name=s" => \$admin_name,
			"list_name=s" => \$list_name);

if ($help or !($group_name && $admin_name && $list_name)) {
    print STDERR <<EOF;
Usage: $0 [OPTIONS] | mysql savane

Manually add a list in a group - workaround until we set up remote
mailing list creation - actually output the correct SQL query.

Options:
  -h, --help                 Show this help and exit

Mandatory options:
  -l, --list_name            The name of the list, without \@domain
  -g, --group_name           The group to attach to mailing list to
  -a, --admin_name           The user name of the admin of the list
                             [TODO: is it really needed?]
EOF
exit(1);
}

my $group_id = (GetDB("groups", "unix_group_name = '$group_name'", "group_id"))[0];
die "No such group: $group_name" unless ($group_id);

my $user_id = (GetDB("user", "user_name = '$admin_name'", "user_id"))[0];
die "No such user: $admin_name" unless ($user_id);

print "INSERT INTO mail_group_list VALUES (NULL, $group_id, '$list_name', 1, 'pass', $user_id , 5, '');\n";
