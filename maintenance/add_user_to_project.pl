#!/usr/bin/perl

my ($group, $user, $admin_name) = @ARGV;

my $onduty   = (grep { $_ eq 'onduty' } @ARGV) ? 1 : 0;
my $is_admin = (grep { $_ eq 'admin'  } @ARGV) ? 'A' : '';

die "usage: $0 [group] [user_to_add] [admin_name] onduty admin\n"
    if not $group or not $user or not $admin_name;

my (undef, $group_id)=`ssh root\@internal "mysql savane -B -e 'SELECT group_id FROM groups WHERE unix_group_name=\\"$group\\";'"`;
die "project $group does not exist\n" unless $group_id;

my (undef, $user_id)=`ssh root\@internal "mysql savane -B -e 'SELECT user_id FROM user WHERE user_name=\\"$user\\";'"`;
die "user $user does not exist\n" unless $user_id;

my (undef, $admin_id)=`ssh root\@internal "mysql savane -B -e 'SELECT user_id FROM user WHERE user_name=\\"$admin_name\\";'"`;
die "admin $user does not exist\n" unless $admin_id;

my (undef, $already_added)=`ssh root\@internal "mysql savane -B -e 'SELECT user_group_id FROM user_group WHERE user_id=$user_id AND group_id=$group_id;'"`;

die "$user is already added to $group (use the web interface for permission changes)\n"
    if $already_added;

`ssh root\@internal "mysql savane -B -e 'INSERT INTO user_group (user_id, group_id, onduty, admin_flags, cache_user_name) VALUES ($user_id, $group_id, $onduty, \\"$is_admin\\", \\"$user\\");'"`;

my $time = time;
`ssh root\@internal "mysql savane -B -e 'INSERT INTO group_history (group_id, field_name, old_value, mod_by, date) VALUES ($group_id, \\"Added User\\", \\"$user\\", $admin_id, $time);'"`;

print "$user added to $group by $admin_name\n";
