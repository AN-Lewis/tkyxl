use strict;
use warnings;
use version;
use File::Spec;
use Getopt::Long qw/GetOptions/;

sub usage;

my $conf = do "$ENV{HOME}/.pswrc" || do "$ENV{HOME}/_pswrc" || {};

my $base_dir = $conf->{base_dir} || 'C:/';
my $dir_name = $conf->{dir_name} || 'strawberry';
my $current_version = version->new($]);

GetOptions(
    'l|list' => \my $list,
    'h|help' => \my $help,
) or usage;

usage if $help;

show_list() && exit if $list;

main: {
    my $target = shift || usage;

    my $target_version = version->new($target);
    if ($target_version eq $current_version) {
        warn "$target is current version\n";
        exit 1;
    }

    my $target_dir = find_target_dir($target_version);
    unless ($target_dir) {
        warn "$target_version is not installed!\n";
        exit 1;
    }

    switch($target_dir);

    print "switched\n";

    exit;
}

sub show_list {
    opendir my $dh, $base_dir or die $!;
    for my $dir (grep /^$dir_name/o, readdir $dh) {
        my $version = find_version($dir);
        print $version eq $current_version ? '* ' : '  ', $version, "\n";
    }
    closedir $dh;
}

sub find_target_dir {
    my $target_version = shift;
    my $target_dir;
    opendir my $dh, $base_dir or die $!;
    for my $dir (grep /^$dir_name/o, readdir $dh) {
        my $version = find_version($dir);
        if ($version eq $target_version) {
            $target_dir = $dir;
            last;
        }
    }
    closedir $dh;
    
    return $target_dir;
}

sub find_version {
    my $dir = shift;
    my $cmd = File::Spec->catfile($base_dir, $dir, 'perl/bin/perl');
    my $result = `$cmd -v`;
    my ($version) = $result =~ /(v[0-9]+\.[0-9]+\.[0-9]+)/smx;
    return version->new($version);
}

sub switch {
    my ($dir) = @_;
    my $target_dir  = File::Spec->catfile($base_dir, $dir);
    my $current_dir = File::Spec->catfile($base_dir, $dir_name);
    my $swap_dir    = File::Spec->catfile($current_dir. "-$current_version");
    
    _rename($current_dir, $swap_dir);
    _rename($target_dir, $current_dir);
}

sub _rename {
    my ($from, $to) = @_;
    rename $from, $to or die "rename failed! $from -> $to: $!";
}

sub usage {
    print << 'USAGE';
multiple perl switch utility for strawberry-perl

usage:
    psw.pl [options] 5.12.1

options:
    -l, --list   Display installed perl list
    -h, --help   Show this message

USAGE

    exit 1;
}