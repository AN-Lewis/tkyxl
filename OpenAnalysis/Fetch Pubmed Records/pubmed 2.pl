# Code modified based on Entrez Programming Utilities from PubMed
# http://eutils.ncbi.nlm.nih.gov/
# Usage: perl pubfetch.pl
use 5.010;
use LWP::Simple;
use utf8;
use Text::Unidecode;


print "Please Enter The Keyword for Fetch: "; # ask for keyword to search
my $keyword = <>;
chomp $keyword; 
$keyfile = $keyword;
$keyfile =~ s/\s/_/g;


my $year = 2000; # From which year to fetch
open (COUNT,">$keyfile.count.txt")  or die "could not write to count file  $!";
open (RESULT,">$keyfile.result.txt") or die "could not write tob result file  $!";

for ($year; $year<=2015; $year++){
 my $utils = "http://eutils.ncbi.nlm.nih.gov/entrez/eutils/";
 my $db     = "Pubmed";
 my $query  = $keyword;
 my $report = "abstract";
 my $esearch = "$utils/esearch.fcgi?" .
              "db=$db;retmax=1;usehistory=y;maxdate=$year;mindate=$year;term=";
 $output=get($esearch ."\"".$query."\"");
 $hash{$year}=$output;
 my $web = $1 if ($output =~ /<WebEnv>(\S+)<\/WebEnv>/);
 my $key = $1 if ($output =~ /<QueryKey>(\d+)<\/QueryKey>/);
 my $count=$1 if ($output =~ /(\d+)<\/Count>/);
# say "$web $key $count";
 
 print "The total number of publication for $keyword in year $year is $count;\n";
 print COUNT "$year $count\n";

 if ( $count != 0 )
 {
	 my $efetch = "$utils/efetch.fcgi?" .
	               "rettype=$report&retmode=text&retstart=0&retmax=10000&" .
	               "db=$db&query_key=$key&WebEnv=$web";
	 my $efetch_result = get($efetch);
	 $efetch_result =~ s/([^[:ascii:]]+)/unidecode($1)/ge;
     print RESULT "$efetch_result";
 }  

}



close RESULT;
close COUNT;


my $idcount=0;
open ID, "<$keyfile.result.txt";
open IDRESULT,">$keyfile.IDlist.txt";

while (<ID>){
if (m/^PMID:\s(\d*)/){
 print IDRESULT "$1\n" ;
 push (my @array,"$1");
 $idcount++;
 
 }
}

print "the total number of the publication fetched is $idcount\n";


