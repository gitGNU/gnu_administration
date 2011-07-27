#!/usr/bin/perl

# Generates all projects CVSROOT/commitinfo and CVSROOT/loginfo.

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

use strict;
use Savane;

# Locks: This script should not run concurrently
AcquireReplicationLock();

my %group_type;
my %repos;
my @db = GetDBLists("groups JOIN group_type ON groups.type=group_type.type_id",
  "((group_type.can_use_cvs=1 AND groups.use_cvs=1) OR (group_type.can_use_homepage AND groups.use_homepage))"
  . " AND status='A'",
  "unix_group_name,type,group_type.can_use_cvs,groups.use_cvs,group_type.can_use_homepage,groups.use_homepage");

foreach my $line (@db) {
    my ($name, $type, $can_use_cvs, $use_cvs, $can_use_homepage, $use_homepage) = @{$line};
    $group_type{$name} = $type;
    $repos{$name} = {};
    $repos{$name}{'sources'} = 1 if ($can_use_cvs and $use_cvs);
    $repos{$name}{'web'}     = 1 if ($can_use_homepage and $use_homepage);
}

my %loginfo;
my %commitinfo;
our $dbd;
# Only considering repositories to update:
#my $hooks_ref = $dbd->selectall_hashref("
#	SELECT groups.unix_group_name, cvs_hooks.*, cvs_hooks_log_accum.*
#	FROM groups JOIN cvs_hooks ON groups.group_id = cvs_hooks.group_id
#                    JOIN cvs_hooks_log_accum ON cvs_hooks.id = cvs_hooks_log_accum.hook_id
#	WHERE needs_refresh=1",
#					'hook_id');

# Updating all repositories (no 'needs_refresh=1' filter):
my $hooks_ref = $dbd->selectall_hashref("
	SELECT groups.unix_group_name, cvs_hooks.*, cvs_hooks_log_accum.*
	FROM groups JOIN cvs_hooks ON groups.group_id = cvs_hooks.group_id
                    JOIN cvs_hooks_log_accum ON cvs_hooks.id = cvs_hooks_log_accum.hook_id",
					'hook_id');

# Builds the loginfo and commitinfo configuration, then writes it
foreach my $hook_id (keys %{$hooks_ref}) {
    # TODO: support per-list diff options
    my ($project, $repo, $match_type, $dir_list, $emails_notif, $diff_on, $emails_diff, $branches)
	= ($hooks_ref->{$hook_id}->{'unix_group_name'},
	   $hooks_ref->{$hook_id}->{'repo_name'},
	   $hooks_ref->{$hook_id}->{'match_type'},
	   $hooks_ref->{$hook_id}->{'dir_list'},
	   $hooks_ref->{$hook_id}->{'emails_notif'},
	   $hooks_ref->{$hook_id}->{'enable_diff'},
	   $hooks_ref->{$hook_id}->{'emails_diff'},
	   $hooks_ref->{$hook_id}->{'branches'});
    
    my $log_accum = '';
    my @dirs = split(',', $dir_list);
    
    # Check for spaces in dir names - this could be used to insert
    # a custom command, such as rm -rf...
    foreach my $dir (@dirs) {
	# Use POSIX [:space:] instead of \s for completeness
	# (check man perlre)
	if ($dir =~ /[[:space:]]/) {
	    warn "Project $project: There is a space character in the regular expression.";
	    next;
	}
    }
    
    # Computes the regexp
    my $regexp;
    if ($match_type eq 'ALL' || $match_type eq 'DEFAULT') {
	$regexp = $match_type;
    } elsif ($match_type eq 'dir_list') {
	if (scalar(@dirs) == 0) {
	    next;
	} elsif (scalar(@dirs) == 1) {
	    $regexp = '^' . $dirs[0] . '\(/\|$\)';
	} else {
	    $regexp = '^\(' . join('\|', @dirs) . '\)\(/\|$\)';
	}
    } else {
	warn "Unknown match type: $match_type";
    }
    $log_accum .= $regexp;
    $log_accum .= ' ';
    
    $log_accum .= '/usr/local/bin/log_accum.pl';
    $log_accum .= ' ';
    
    if ($emails_notif eq '') {
	warn "No emails_notif for project $project - skipping...";
	next;
    } else {
	my @emails = split(',', $emails_notif);
	$log_accum .= join('', map { "--mail-to $_ " } @emails);
    }

    if ($diff_on == 1) {
	$log_accum .= '--send-diff';
	$log_accum .= ' ';
	if ($emails_diff ne '') {
	    my @emails = split(',', $emails_diff);
	    $log_accum .= join('', map { "--separate-diffs $_ " } @emails);
	}
    } else {
	$log_accum .= '--no-send-diff';
	$log_accum .= ' ';
    }
    
    if ($branches ne '') {
	$log_accum .= join('', map { "--only-tag $_ " } split(',', $branches));
    }
    
    # Give a unique prefix for temporary files for each line. Some
    # lines may run concurrently (eg. when regexp='ALL').
    $log_accum .= '--file-prefix ' . $project . '_' . $hook_id;
    $log_accum .= ' ';
    
    my $config_file;
    if ($repo eq 'sources') {
	$config_file = 'log_accum-sources.config';
    } else {
	$config_file = 'log_accum-web.config';
    }
    $log_accum .= "--config /etc/$config_file";
    $log_accum .= ' ';
    
    $log_accum .= "%p %{sVv}";
    $log_accum .= "\n";
    
    my $commit_prep = "$regexp /usr/local/bin/commit_prep.pl ";
    $commit_prep .= '-T ' . $project . '_' . $hook_id;
    $commit_prep .= " %p\n";
    
    $loginfo{$repo}{$project} .= $log_accum;
    $commitinfo{$repo}{$project} .= $commit_prep;
}


# For testing:
#for my $project ('testyten') {

# Only update projects that have new hooks (disabled for now because we need on-commit replication hook):
#for my $project (sort keys %{$commitinfo{'sources'}}, sort keys %{$commitinfo{'web'}}) {

# Update all projects (they all might need webpage on-commit replication):
for my $project (sort keys %group_type) {

#    print "Processing $project\n";

    my $commitinfo_sources = $commitinfo{'sources'}{$project};
    my $loginfo_sources = $loginfo{'sources'}{$project};

    my $commitinfo_web = $commitinfo{'web'}{$project};
    my $loginfo_web = $loginfo{'web'}{$project};
    my $type;
    # TODO: ugly hard-coding to remove
    if ($project eq 'www') {
	$type = 'www';
    } elsif ($group_type{$project} == 1
	|| $group_type{$project} == 3) {
	$type = 'gnu';
    } elsif ($group_type{$project} == 2
	     || $group_type{$project} == 4) {
	$type = 'non-gnu';
    } elsif ($group_type{$project} == 6) {
	$type = 'translations';
    } else {
	$type = 'unknown';
    }

    # Remote webpages update. Check node 'Keeping a checked out copy'
    # in cvs.texi. After some local tests, it appears that there are
    # no locking/concurrency issues, so no need to sleep+background
    # the process. You still need to read (cat) stdin.
    if ($type ne 'unknown')
    {
	$loginfo_web .= "ALL echo 'Triggering webpages update...'; cat > /dev/null; curl http://www.gnu.org/new-savannah-project/new.py -s -F type=$type -F project=`basename %r`\n";
    }

    # TODO: Technically, we should also rely on commit_prep (with a
    # different tempfile than log_accum) to detect commits that span
    # multiple repositories and only trigger one remote update.  In
    # practice, that doesn't matter much, since cvs deals well with
    # several update process in the same working copy - we should do
    # it nonetheless at a point. Ideally we would also pass which
    # repositories needs updating.


    sub update {
	my ($file, $replace_string) = @_;
	my $content;
	{
	    local $/;
	    undef $/; # slurp mode
	    open(IN, "< $file") || warn "Cannot open $file: $!";
	    $content = <IN>;
	    close(IN);
	}
	$content =~ s,^#<savane>\n.*^#</savane>($),#<savane>\n$replace_string#</savane>,sm;
	open(OUT, "> $file") || warn "Cannot open $file: $!";
	print OUT $content;
	close(OUT);   
    }

    if ($repos{$project}{'sources'}) {
	my $path = "/srv/cvs/sources/$project/CVSROOT";
	if (-e $path) {
	    update("$path/commitinfo", $commitinfo_sources);
	    update("$path/loginfo",    $loginfo_sources);
	} else {
	    # Don't send via cron - this may happen when a project is approved but not replicated yet
	    #warn "$path does not exist - won't write configs";
	}
    }
    
    if ($repos{$project}{'web'}) {
	my $path = "/srv/cvs/web/$project/CVSROOT";
	if (-e $path) {
	    update("$path/commitinfo", $commitinfo_web);
	    update("$path/loginfo",    $loginfo_web);
	} else {
	    # Don't send via cron - this may happen when a project is approved but not replicated yet
	    #warn "$path does not exist - won't write configs";
	}
    }
    
    $dbd->do("UPDATE groups, cvs_hooks, cvs_hooks_log_accum SET needs_refresh=0
                  WHERE groups.group_id = cvs_hooks.group_id
			AND cvs_hooks.id = cvs_hooks_log_accum.hook_id
			AND unix_group_name='$project'") || die "$!";
}
