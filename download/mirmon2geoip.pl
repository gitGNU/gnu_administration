#!/usr/bin/env perl
use strict;
use warnings;
use File::Copy;

my $path_mirmon_state = '/var/lib/mirmon/state';
my $path_mirmon_mirrors = '/srv/download/00_MIRRORS.txt';
my $path_geoip_mirrors = '/usr/local/share/GeoIP/download.txt';

my $sites;
my $ok = 2*60*60*24;
my $time = time;
open(my $state, "<$path_mirmon_state") or die qq{Cannot open $path_mirmon_state: $!};
while (my $line = <$state>) {
    chomp $line;
    my @a = split ' ', $line;
    next unless ($a[1] =~ /^[0-9.]*$/);
    my $diff = $time - $a[1];
    next unless ($ok - $diff > 0);
    $sites->{$a[0]}++;
}
close $state;
open(my $list, "$path_mirmon_mirrors") or die qq{Cannot open $path_mirmon_mirrors: $!};
while (my $line = <$list>) {
  next if $line =~ /^#/;
  chomp $line;
  my ($type, $country, $url) = split ' ', $line;
  next if $country =~ /partial/i;
  next if $type =~ /ftp/i;
  if (defined $sites->{$url}) {
      $sites->{$url} = $country;
  }
}
close $list;
#$sites->{'ftp://ftp.dante.de/tex-archive/'} = 'de';
#$sites->{'ftp://ftp.tex.ac.uk/tex-archive/'} = 'gb';
#$sites->{'ftp://tug.ctan.org/tex-archive/'} = 'us';
open(my $txt, ">$path_geoip_mirrors") or die qq{Cannot open $path_geoip_mirrors: $!};
foreach my $key(keys %$sites) {
    (my $site = $key) =~ s/\/$//;
    my $cc = $sites->{$key};
    next unless $cc =~ /^[a-z]+$/;
    #next if ($site =~ m{(http|ftp)://tug.ctan.org});
    print $txt "$site $cc\n";
}
close $txt;
#if (-e '/home/randy/bin/ctan.txt') {
#  copy('/home/randy/bin/ctan.txt', '/usr/local/share/GeoIP/ctan.txt')
#      or warn "Cannot cp ctan.txt to /usr/local/share/GeoIP: $!";
#}
