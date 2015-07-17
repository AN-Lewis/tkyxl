#!/usr/bin/perl
use strict;
use 5.010;
use File::Basename qw/fileparse/;
use POSIX qw/strftime/;

# ----------------------------------------------------------------------
# Basic Information
# ----------------------------------------------------------------------
# For RNA-Seq Analysis of snoRNA-Knockdown experiment  
# @ RIKEN BSI, Mental Biology Team
# @ Author 	: Xiaoxi Liu
# @ Date	: 2015-05-22
# @ Software Versions
# Tophat 	: 2.014
# Bowtie 2	: 2.2.3
# cufflinks : 2.2.1
# samtools 	: 0.1.19
# GFOLD		: 
# ----------------------------------------------------------------------


# ----------------------------------------------------------------------
# FASTQ samples - in fastq.gz format
# ----------------------------------------------------------------------
# GFP_B6_DIV4.fastq.gz
# GFP_ICR_DIV10.fastq.gz
# GFP_ICR_DIV4.fastq.gz
# MBII52_B6_DIV4.fastq.gz
# MBII52_ICR_DIV10.fastq.gz
# MBII52_ICR_DIV4.fastq.gz
# MBII85_B6_DIV4.fastq.gz
# MBII85_ICR_DIV10.fastq.gz
# MBII85_ICR_DIV4.fastq.gz
# ----------------------------------------------------------------------



# ----------------------------------------------------------------------
# Files and Parameters
# ----------------------------------------------------------------------
# my $simulate = 0; # run the program
  my $simulate = 1; # only show the simulated run and commands

  my $GTF_file 				=	"genes.gtf";	# UCSC GTF
  my $Genome_Fasta_Prefix 	=	"genome";		# mm10 
  my $Genome_Fasta_file 	=	"genome.fa";	# m10 whole genome fasta 
  
  my $assemblies_file 	= "assemblies_2.txt"; # desired assemblies output file 

  my $tophat_threads	= 11;
  my $cufflinks_thread 	= 11;
  my $cuffmerge_thread 	= 11;
# ----------------------------------------------------------------------




# ----------------------------------------------------------------------
# Run Tophat - Cufflinks 
# ----------------------------------------------------------------------
open(ASSEMBLIES, ">$assemblies_file");

my @gzfiles = <*.fastq.gz>;
my @accpeted_bam_files; 




foreach my $file (@gzfiles) 
{ 	
	my ($basename, $path, $suffix) = fileparse($file, qw/.fastq.gz/);
	my $current_time    = strftime('%Y-%m-%d %H:%M:%S',localtime);
	
	my $tophat_output_dir = $basename."_tophat_out";
	my $cufflinks_output_dir = $basename."_cufflinks_out";
	
	
	say "[$current_time]\tNow is processing $file";	
	
	my $accepted_bam = "./$tophat_output_dir/accepted_hits.bam";
	push @accpeted_bam_files, $accepted_bam;
	
	my $tophat_command 		= "tophat2 -p $tophat_threads -G $GTF_file -o $tophat_output_dir ".
						    "$Genome_Fasta_Prefix $file";
						  
	my $cufflinks_command 	= "cufflinks -p $cufflinks_thread -o $cufflinks_output_dir ".
							"$tophat_output_dir/accepted_hits.bam";
	
	if ($simulate)
	{	say($tophat_command);
		say($cufflinks_command);
	} else{
		system($tophat_command);
		system($cufflinks_command);
	}
	say ASSEMBLIES "./$cufflinks_output_dir/transcripts.gtf";
	sleep (1);
}

close ASSEMBLIES;
my $current_time    = strftime('%Y-%m-%d %H:%M:%S',localtime);
say "----------------------------------------------------------------------";
say "[$current_time] Finished Tophat - Cufflinks Process"					;
say "----------------------------------------------------------------------";
# ----------------------------------------------------------------------



# ----------------------------------------------------------------------
# Run Cuffmerge to create a signle merged transcritome annotation
# ----------------------------------------------------------------------

my $cuffmerge_command =	"cuffmerge -g $GTF_file -s $Genome_Fasta_file -p $cuffmerge_thread $assemblies_file";

if ($simulate){say($cuffmerge_command)} 
else{system($cuffmerge_command)}

my $current_time    = strftime('%Y-%m-%d %H:%M:%S',localtime);
say "----------------------------------------------------------------------";
say "[$current_time] Finished CuffMerge Process"							;
say "----------------------------------------------------------------------";

# ----------------------------------------------------------------------




# ----------------------------------------------------------------------
# Run CuffQuant 
# ----------------------------------------------------------------------
my $merged_assemble_file = "./merged_asm/merged.gtf";
my $cuffquant_thread 	= 11;

foreach my $bam_file (@accpeted_bam_files)
{
	my ($basename, $path, $suffix) = fileparse($bam_file, qw/.bam/);
	$path =~ s/_tophat_out\///g;
	my $cuffquant_output_dir = $path."_cuffquants_out";
	
	my $cuffquant_command	= "cuffquant -p $cuffquant_thread -o $cuffquant_output_dir ".
							"$merged_assemble_file $bam_file";
	
	if ($simulate){say($cuffquant_command)} 
	else{system($cuffquant_command)}
	sleep (1);
}

my $current_time    = strftime('%Y-%m-%d %H:%M:%S',localtime);
say "----------------------------------------------------------------------";
say "[$current_time] Finished CuffQuant Process"		;
say "----------------------------------------------------------------------";
# ----------------------------------------------------------------------



