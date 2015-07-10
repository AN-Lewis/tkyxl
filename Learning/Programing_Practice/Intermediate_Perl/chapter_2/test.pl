use warnings;
use strict;
use File::Basename; # !!!
use 5.010;


my $fname = "/usr/local/here/junk.txt";
my ($name, $path, $suffix1) = fileparse($fname, qr'\.[^\.]*'); # !!!
say $name;
say $suffix1;


my $file = "/usr/local/bin/test.pl";

say basename($file);
say dirname($file);


use File::Spec;

my $filespec = File::Spec -> catfile('web_doc','photos','USS.gif');
say $filespec;

use Math::BigInt;

my $value = Math::BigInt -> new(2);
$value -> bpow(1000);

say $value-> bstr;


use Spreadsheet::WriteExcel;

my $workbook = Spreadsheet::WriteExcel -> new('perl.xls');

my $worksheet = $workbook->add_worksheet();
$worksheet ->write('A1',"HELLO WORLD");