#!/usr/bin/perl
#
#    On commit email notification.
#    Copyright (C) 2005  Michael J. Flickinger <mjflick@gnu.org>
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program; if not, write to the Free Software
#    Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
#



my $archive_path = "/archives/|/srv/arch/";
my $archive_setup = "/archives/";
my $HOSTNAME = "savannah.gnu.org";
my $ENVELOP_SENDER = 'savannah-bounces@gnu.org';

my $path = $ARGV[0];

my $mailname;
my $fullname;
my $sendmail = 0;

if ($path =~ /\/base-([0-9]+)|\/patch-([0-9]+)/)
{
    my $project;

    $project = $path;
    $project =~ s/$archive_path//;
    ($project, undef) = split(/\//, $project);

    open(CONFIG, $archive_setup . "/$project/setup.conf");
    my @config = <CONFIG>;
    close(CONFIG);

    my $email;
    for (@config)
    {
        my ($key, $data) = split(/ /, $_);

        if ($key eq 'email-on-commit')
        {
	    chomp($data);
            $email = $data;
            $sendmail = 1;
        }
    }

    local ($login, $gecos);

    if ($sendmail)
    {
        $login = $ENV{'USER'};
        open (PASSWD, "/etc/passwd") || die "passwd open failed";
        while (<PASSWD>) {
            next unless /^${login}:.+:.+:.+:(.+):.+:.+$/;
	$gecos = $1;
	last if defined $gecos;
	}
	close PASSWD;
	
# Determine the mailname and fullname.
        if ($gecos =~ /^([^<]*\s+)<(\S+@\S+)>/)
        {
            $fullname = $1;
            $mailname = $2;
            $fullname =~ s/\s+$//;
        }
        else
        {
            $fullname = $gecos;
            $fullname =~ s/,.*$//;

            $mailname = "$login\@$HOSTNAME";
        }

	open(LOG, "$path/log");
	my @log = <LOG>;
	close(LOG);
	
	my $revision = $log[0];
	chomp($revision);
	
	my $subject = "Commit: $revision";
	mail_notification($email, $subject, @log);
    }
}


sub mail_notification {
    local($email, $subject, @text) = @_;

    my @mailcmd = ("/usr/lib/sendmail", "-i", "-t");
    open MAIL, "|-" or exec @mailcmd;

    # Parent.
    $SIG{'PIPE'} = sub {die "whoops, pipe broke."};

    print MAIL "To: $email\n";
    print MAIL "From: $fullname <$mailname>\n";
    print MAIL "Subject: $subject\n";
    print MAIL "\n";
    print MAIL join ("\n", @text);
    print MAIL "\n";
    print MAIL ".\n";
    
    close MAIL or warn "child exited $?";
}
