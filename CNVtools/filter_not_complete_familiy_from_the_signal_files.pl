use 5.010;


use Getopt::Long;

GetOptions( 
	'fam|f=s'=> \$fam ,
);


if ($fam){
	open (IN,$fam);
	while(<IN>)
	{
#		say $_;
		($id,$fam,$role)= split ;
		$trio{$fam}{$role}=$id;
	}
}else
{print STDERR "Usage: perl denovocheck.pl --fam/f --in/i --out/o \n"}


foreach $family ( keys %trio ) {
	unless (-e $trio{$family}{P} && -e $trio{$family}{F} && -e $trio{$family}{M} )
		{

#		print "$trio{$family}{P} && $trio{$family}{F} && $trio{$family}{M}\n";
#		&trio_cnv($family,$trio{$family}{F},$trio{$family}{M},$trio{$family}{P})

		say "$family is not complete";

		}


} 

#detect_cnv.pl -trio -hmm lib/hh550.hmm -pfb lib/hh550.hg18.pfb -cnv sampleall.rawcnv sample1.txt sample2.txt sample3.txt -out sampleall.triocnv

sub trio_cnv
{   
	$path="/usr/local/bin/penncnv/";
	$cdf_file = $path."lib/GenomeWideSNP_6.cdf";
	$model_file = $path."lib/GenomeWideSNP_6.birdseed.models ";
	$special_file = $path."lib/GenomeWideSNP_6.specialSNPs ";
	$hapnorm = $path."lib/hapmap.quant-norm.normalization-target.txt";
	$pfb_file =$path."lib/affygw6.hg18.pfb";
	$pfb_file_our =$path."lib/184.pfb";
	$hmm_file =$path."lib/affygw6.hmm";
	$gc_mode_file =$path."lib/affygw6.hg18.gcmodel";
	$fam_id=$_[0];
	$detect_cnv ="detect_cnv.pl -trio -hmm $hmm_file ";
	$detect_cnv .="-pfb $pfb_file_our -cnv asdtrio.rawcnv $_[1] $_[2] $_[3] -gcmodel $gc_mode_file ";
	$detect_cnv .=" -log $fam_id.log -out $fam_id.rawcnv";
  
	system ($detect_cnv );
	
}