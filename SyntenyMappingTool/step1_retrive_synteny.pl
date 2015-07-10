#!/usr/bin/perl
=for comment
A wrapper to retrive (mouse) synteny region for human loci.
The script used the Ensembl Perl API.
=cut

use strict;
use warnings;

use Bio::EnsEMBL::Registry;
use Bio::EnsEMBL::Utils::Exception qw(throw);
use Bio::SimpleAlign;
use Bio::AlignIO;
use Bio::LocatableSeq;
use Getopt::Long;

my $species = "human";
my $coord_system = "chromosome";
my $set_of_species = "human:mouse";
my $output_file = undef;
my $input = undef;

GetOptions
(
    "species=s" => \$species,
    "coord_system=s" => \$coord_system,
    "seq_region=s" => \$seq_region,
    "seq_region_start=i" => \$seq_region_start,
    "seq_region_end=i" => \$seq_region_end,
    "alignment_type=s" => \$alignment_type,
    "set_of_species=s" => \$set_of_species,
    "output_format=s" => \$output_format,
    "output=s" => \$output_file,
    "input=s" => \$input_file,
);




if ($output_file)
{
	open(STDOUT, ">$output_file") or die ("can not save to $output_file");
}

# Connect to the Ensembl server
Bio::EnsEMBL::Registry->load_registry_from_db
(-host => 'asiadb.ensembl.org', -user => 'anonymous');

# Getting all the Bio::EnsEMBL::Compara::GenomeDB objects

my $genome_db_adaptor = Bio::EnsEMBL::Registry->get_adaptor
('Multi', 'compara', 'GenomeDB');

throw("Cannot connect to Compara") if (!$genome_db_adaptor);

my $genome_dbs;
foreach my $this_species (split(":", $set_of_species)) {
    my $this_meta_container_adaptor = Bio::EnsEMBL::Registry->get_adaptor(
        $this_species, 'core', 'MetaContainer');

    throw("Registry configuration file has no data for connecting to <$this_species>")
        if (!$this_meta_container_adaptor);

    my $this_production_name = $this_meta_container_adaptor->get_production_name;

    # Fetch Bio::EnsEMBL::Compara::GenomeDB object
    my $genome_db = $genome_db_adaptor->fetch_by_name_assembly($this_production_name);

    # Add Bio::EnsEMBL::Compara::GenomeDB object to the list
    push(@$genome_dbs, $genome_db);
}

# Fetch the slice 
sub retrive 
{
	my ($seq_region,$seq_region_start,$seq_region_end) = @_;
	
	# Fetching the query Slice:
	my $slice_adaptor = Bio::EnsEMBL::Registry->get_adaptor($species, 'core', 'Slice');
	
	throw("Registry configuration file has no data for connecting to <$species>")
		if (!$slice_adaptor);
	
	my $query_slice = $slice_adaptor->fetch_by_region('toplevel', $seq_region, $seq_region_start, $seq_region_end);
	
	throw("No Slice can be created with coordinates $seq_region:$seq_region_start-"."$seq_region_end") 
		if (!$query_slice);
	
	
	# Prepare the synergy 
	my $synteny_region_adaptor =
	    Bio::EnsEMBL::Registry->get_adaptor(
	      "Multi", "compara", "SyntenyRegion");
	
	my $method_link_species_set_adaptor = Bio::EnsEMBL::Registry->get_adaptor(
	    'Multi', 'compara', 'MethodLinkSpeciesSet');
	    
	my $human_mouse_synteny_mlss = $method_link_species_set_adaptor->
	    fetch_by_method_link_type_registry_aliases(
	      "SYNTENY", ["Homo sapiens", "Mus musculus"]);
	
	my $synteny_regions = $synteny_region_adaptor->
	      fetch_all_by_MethodLinkSpeciesSet_Slice($human_mouse_synteny_mlss, $query_slice);
	
	my $count = @$synteny_regions;
	print "$count \n";
	
	foreach my $this_synteny_region (@$synteny_regions) 
	{
	    my $these_dnafrag_regions = $this_synteny_region->get_all_DnaFragRegions();
	    
		foreach my $this_dnafrag_region (@$these_dnafrag_regions)
		{
	      print $this_dnafrag_region->dnafrag->genome_db->name, ": ", $this_dnafrag_region->slice->name, "\t";
	    }
	    
		print "\n";
	} 
	print "---------------------------------------------------\n";

}


open (IN,$input_file);
while(<IN>)
{
	chomp;
	@array = split;
	print "$array[3]:$array[4]\tchr$array[0]:$array[1]-$array[2]\tsynteny count=";	
	&retrive($array[0],$array[1],$array[2]);
		
}





