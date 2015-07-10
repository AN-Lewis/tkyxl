#Top1:16p11.2	chr16:29484920-30420940	synteny count=1
#homo_sapiens: chromosome:GRCh37:16:29661006:31520748:1	mus_musculus: chromosome:GRCm38:7:126671255:128301303:1

use 5.010;
use strict;
use Bio::EnsEMBL::Registry;
use Bio::EnsEMBL::Utils::Exception qw(throw);
use Bio::SimpleAlign;
use Bio::AlignIO;
use Bio::LocatableSeq;
use Getopt::Long;

my $input_file = undef;

GetOptions
(
	"input=s" => \$input_file
);


########################################################
##Load the ENSEMBL CORE Components
our $species = "human";
our $coord_system = "chromosome";
our $alignment_type = "LASTZ_NET";
our $set_of_species = "human:mouse";
our $output_format = "clustalw";
########################################################


	
##########################################################
## The subroutine to fetch the clustaw 
sub fetch_clustalw 
{
		
	Bio::EnsEMBL::Registry->load_registry_from_db(-host => 'asiadb.ensembl.org', -user => 'anonymous');
	Bio::EnsEMBL::Registry->set_reconnect_when_lost(5);
	# Getting all the Bio::EnsEMBL::Compara::GenomeDB objects
	my $genome_dbs;
	my $genome_db_adaptor =  Bio::EnsEMBL::Registry ->	get_adaptor('Multi', 'compara', 'GenomeDB');
	
	throw("Cannot connect to Compara") if (!$genome_db_adaptor);
	
	foreach my $this_species (split(":", $set_of_species)) {
	    my $this_meta_container_adaptor = Bio::EnsEMBL::Registry->get_adaptor($this_species, 'core', 'MetaContainer');
	
	    throw("Registry configuration file has no data for connecting to <$this_species>") if (!$this_meta_container_adaptor);
	
	    my $this_production_name = $this_meta_container_adaptor->get_production_name;
	
	    # Fetch Bio::EnsEMBL::Compara::GenomeDB object
	    my $genome_db = $genome_db_adaptor->fetch_by_name_assembly($this_production_name);
	
	    # Add Bio::EnsEMBL::Compara::GenomeDB object to the list
	    push(@$genome_dbs, $genome_db);
	}
	
	# Getting Bio::EnsEMBL::Compara::MethodLinkSpeciesSet object
	my $method_link_species_set_adaptor = Bio::EnsEMBL::Registry->get_adaptor(
	    'Multi', 'compara', 'MethodLinkSpeciesSet');
	
	my $method_link_species_set = $method_link_species_set_adaptor->fetch_by_method_link_type_GenomeDBs(
	      $alignment_type, 
	      $genome_dbs);
	
	throw("The database do not contain any $alignment_type data for $set_of_species!")
	    if (!$method_link_species_set);
	
	# Fetching the query Slice:
	my $slice_adaptor = Bio::EnsEMBL::Registry->get_adaptor($species, 'core', 'Slice');
	
	throw("Registry configuration file has no data for connecting to <$species>")
	    if (!$slice_adaptor);	
		
	my($seq_region,$seq_region_start,$seq_region_end,$output) = @_; 
	next unless my $query_slice = $slice_adaptor->fetch_by_region('toplevel', $seq_region, $seq_region_start, $seq_region_end); 
	throw("No Slice can be created with coordinates $seq_region:$seq_region_start-". "$seq_region_end") if (!$query_slice);

	# Fetching all the GenomicAlignBlock corresponding to this Slice:
	next unless my $genomic_align_block_adaptor = Bio::EnsEMBL::Registry->get_adaptor('Multi', 'compara', 'GenomicAlignBlock');

	my $genomic_align_blocks =
    $genomic_align_block_adaptor->fetch_all_by_MethodLinkSpeciesSet_Slice(
    $method_link_species_set, 
    $query_slice);
	my $all_aligns;

# Get a Bio::SimpleAlign object from every GenomicAlignBlock
	foreach my $this_genomic_align_block (@$genomic_align_blocks) {
    	my $simple_align = $this_genomic_align_block->get_SimpleAlign;
    	push(@$all_aligns, $simple_align);
	}

# print all the genomic alignments using a Bio::AlignIO object
	my $alignIO = Bio::AlignIO->newFh(
    -interleaved => 0,
    -file => ">$output",
    -format => $output_format,
    -idlength => 10
	);
  
	foreach my $this_align (@$all_aligns)
	{
    print  $alignIO $this_align;
	}


}



################################################
open( IN, "<$input_file") or die "can not open the $input_file";
while (<IN>) 
{
    chomp;
    if ( $_ =~ /^(.op\d+):(.*)\tchr(\w+):(\d+)-(\d+)\tsynteny count=(\d+)/ ) 
    { 
		my $top         = $1;
     	my $cytoband    = $2;
      	my $chr_human   = $3;
      	my $start_human = $4;
      	my $end_human   = $5;
      	my $syteny      = $6;

      	for(my $i=1;$i<= $syteny; $i ++) 
      	{
            print "$top\t$cytoband\t$chr_human\t$start_human\t$end_human\t$syteny\t:\t";
            my $nextline = <IN>;
            if ( $nextline =~/(^.*)mus_musculus:\schromosome:GRCm38:(\w+):(\d+):(\d+):.*/ )
            {
                my $chr_mouse   = $2;
                my $start_mouse = $3;
                my $end_mouse   = $4;
              print "$chr_mouse\t$start_mouse\t$end_mouse\t: "; 
			  	my $out   = $top .".$i". ".clustalw";
                my $clean = $top .".$i". ".clean";
                my $final = $top .".$i". ".final";
                my $sort  = $top .".$i". ".sort";
				
			    eval { fetch_clustalw($chr_human,$start_human,$end_human,$out); };
			    if ($@) {
			      next
			    }
				
				
				
				my $command ="grep mus  $out | cut -d ".'" "' . " -f 1 | uniq > $clean";
			
               	system($command);
                open( MUS, "<$clean" ) or die "can not open $clean";
                open( OUT, ">$final" );

                while (<MUS>) {
                    if ( $_ =~ /^mus_musculus\/(\d+)\/(\d+)-(\d+)/ ) {
                        if (    $1 eq $chr_mouse
                            and $2 >= $start_mouse
                            and $3 <= $end_mouse )
                        {
                            say OUT "chr$1\t$2\t$3";
                        }
                    }

                    #	mus_musculus/5/37462291-37463118
                }
                close(MUS);
                close(OUT);
                system("sort -k1,1 -k2,2n $final > $sort");
                system("head -1  $sort | cut -f 1,2 | tr '\n' '\t' ");
                system("tail -1  $sort | cut -f 3");



	# insert code here please
            }
            else { say "no" }
	    
      }
    }
    else 
    {
      next; # to exclude lines like #################################
    }

# still in the while loop
}








