#!/usr/bin/perl -T
# Savannah Mailman wrapper

# -T security boilerplate
$ENV{'PATH'} = '/var/mailman/bin:/bin:/usr/bin';
delete @ENV{'IFS', 'CDPATH', 'ENV', 'BASH_ENV'};


my %vars;
while (<>) {
    chomp;
    my ($variable, $value) = split('=');
    $vars{lc($variable)} = $value;
}

if (defined($vars{'list_full_name'})) {
    ($vars{'list_name'}, $vars{'virtual_domain'}) = split('@', $vars{'list_full_name'});
    undef $vars{'list_full_name'};
}


# Trace the calls for later debugging
open(LOG, '>> savannah_wrapper.log');
print LOG scalar(gmtime()) . "\n";
foreach my $cur_var (keys %vars) {
    print LOG "$cur_var = $vars{$cur_var}\n";
}
print LOG "\n";
close(LOG);


# Input validation
my %patterns = (
    'command' => '^[a-zA-Z0-9-_.]+$',
    'list_name' => '^[a-zA-Z0-9-]+$', # Savane group identifier
    'admin_mail' => '^[a-zA-Z0-9_.+-]+@(([a-zA-Z0-9-])+.)+[a-zA-Z0-9]+$', # simplist regexp
    'virtual_domain' => '^lists.(non)?gnu.org$',
    'password' => '^[a-zA-Z0-9.]+$', # Savane password that uses md5()
);

foreach my $cur_var (keys %patterns) {
    if (defined($vars{$cur_var})) {
	if ($vars{$cur_var} =~ /($patterns{$cur_var})/) {
	    $vars{$cur_var} = $1;
	} else {
	    print "Invalid $cur_var: $vars{$cur_var}\n";
	    exit 1;
	}
    }
}

if ($vars{"command"} eq 'newlist') {
  ## Create and configure the mailing list
  # All of this must be done successfully (transaction)
  (system('newlist',
	  '-q',
	  $vars{'list_name'} . '@' . $vars{'virtual_domain'},
	  $vars{'admin_mail'},
	  $vars{'password'})
   == 0) or die "newlist: $!";
  # Savannah-specific virtual domain support
  mkdir("/var/mailman/lists/$vars{'list_name'}/domains") or die "mkdir: $!";
  # host_name is derived from the virtual host we gave to newlist:
  # Fix this security-wise - use pipes:
  # Though, is there any risk of having $IFS changed in this context?
  my $domain = `(config_list -o - $vars{'list_name'}; echo 'print host_name') | python`;
  chomp($domain);
  if ($domain =~ /((non)?gnu.org)/) {
      $domain =$1;
  } else {
      die "Invalid domain: $domain";
  }
  (system('touch', "/var/mailman/lists/$vars{'list_name'}/domains/$domain") == 0) or die "touch: $!";
  # Bug workaround
  (system('/var/list/fix_moderation.py', $vars{'list_name'}) == 0) or die "fix_moderation: $!";
  # Sync lists list with monty-python
  (system('~/mailman-export') == 0) or die "mailman-export: $!";

} elsif ($vars{'command'} eq 'change_pw') {

  (system('change_pw',
	  '-l',  $vars{'list_name'},
	  '-p', $vars{'password'},
	  '--quiet')
   == 0) or die "change_pw: $!";

} elsif ($vars{'command'} eq 'rmlist') {

  chdir("/var/mailman/lists/$vars{'list_name'}/domains/") or die "Error accessing list $vars{'list_name'}: $!";
  opendir(DIR, '.');
  foreach (readdir DIR)
  {
    # Matching a subpattern of a regexp untaints the file names...
    if (/^([a-z][a-z.]+)$/) {
      $domain=$1;
      if ($domain !~ /-disabled$/) {
	  rename($1, "$1-disabled") or warn "Could not rename $1: $!";
      }
    }
  }
  closedir(DIR);
  print "Disabled $vars{'list_name'}.\n"
}
