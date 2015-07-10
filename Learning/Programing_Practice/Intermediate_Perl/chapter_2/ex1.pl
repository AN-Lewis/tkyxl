use strict;
use warnings;
use 5.010;
use File::Spec;
use Cwd;

my $dir = getcwd;
say $dir;


opendir (DIR, $dir) or die $!;
while (my $file = readdir(DIR)) {
	  my $full_path=File::Spec->catfile($dir, $file);
	  say $full_path;
}

closedir(DIR);
