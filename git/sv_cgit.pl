#!/usr/bin/perl

# Generate the a list of Git repositories for CGit

# Copyright (C) 2009  Sylvain Beucler

# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.

# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see
# <http://www.gnu.org/licenses/>.


# Get description partly from the database (for repo groups), partly
# from project-list (for repo owners), partly from *.git/description
# (for repo description).

# Hopefully at a point we'll have a way to manage multiple
# repositories per project in Savane, in which case all those files
# (project-list, cgitrepos, description) will be generated from the
# database.

use strict;
use Savane;

# Locks: This script should not run concurrently
AcquireReplicationLock();

my %group_type;
my %repos;
my @db = GetDBLists("groups JOIN group_type ON groups.type=group_type.type_id",
  "status='A' AND use_git=1 ORDER BY unix_group_name",
  "unix_group_name,group_name,group_type.dir_git");

sub htmlspecialchars {
    $_ = $_[0];
    s/&/&amp;/g;
    s/</&lt;/g;
    s/>/&gt;/g;
    return $_;
}

sub urldecode {
    my $url = $_[0];
    $url =~ tr/+/ /;
    $url =~ s/%([a-fA-F0-9]{2})/chr(hex($1))/eg;
    return $url;
}

open(GITWEB_LIST, "</srv/git/project-list") or warn $!;
my %gitweb_owners = {};
while (<GITWEB_LIST>)
{
    my ($repo,$owner) = split(' ');
    $owner = urldecode($owner);
    $gitweb_owners{$repo} = $owner;
}
close(GITWEB_LIST);

open(OUT, ">/srv/git/cgitrepos") or die $!;
foreach my $line (@db) {
    my ($unix_group_name, $group_name, $dir_git) = @{$line};
    my $path = $dir_git;
    $path =~ s/%PROJECT/$unix_group_name/;

    next if (! -e $path); # not replicated yet

    my $desc = '';
    open(DESC, "<$path/description") or warn $!;
    $desc = <DESC>;
    close(DESC);
    chomp($desc);
    $desc = '' if $desc eq 'Unnamed repository; edit this file to name it for gitweb.';

    my $gitweb_owner = $gitweb_owners{"$unix_group_name.git"};

    $desc = htmlspecialchars($desc);
    $gitweb_owner = htmlspecialchars($gitweb_owner);

    print OUT <<EOF;
repo.group=$group_name
repo.url=$unix_group_name.git
repo.path=$path
repo.desc=$desc
repo.readme=README.html
repo.owner=$gitweb_owner
EOF
    my $subrepos_dir = $path;
    $subrepos_dir =~ s/.git$//;
    if (-d $subrepos_dir)
    {
	chdir($subrepos_dir);
	foreach my $subrepo (<*/>)
	{
	    chop($subrepo);

	    open(DESC, "<$subrepos_dir/$subrepo/description") or warn $!;
	    $desc = <DESC>;
	    close(DESC);
	    chomp($desc);
	    $desc = '' if $desc eq 'Unnamed repository; edit this file to name it for gitweb.';

	    $gitweb_owner = $gitweb_owners{"$unix_group_name/$subrepo"};

	    $desc = htmlspecialchars($desc);
	    $gitweb_owner = htmlspecialchars($gitweb_owner);

	    print OUT <<EOF;
repo.url=$unix_group_name/$subrepo
repo.path=$subrepos_dir/$subrepo
repo.desc=$desc
repo.readme=README.html
repo.owner=$gitweb_owner
EOF
	}
    }
}
close(OUT);
