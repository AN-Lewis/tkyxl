# A Universal CNV Comparision Tool looking for overlaping CNV
# Can read raw input from PennCNV, QuantiSNP, Birdsuite
# Xiaoxi Liu 
# Department of Human Genetics, University of Tokyo
# 2012-2-28 ; 2012-4-28; 


use 5.010;
use Getopt::Long;

GetOptions
(	
	# Main output base file 
    'outbase|o=s'        => \$outfile,
	
	# CNV raw input files , named as f1,f2,f3
    'f1=s'         		=> 	\$file1,
    'f2=s'        	    => 	\$file2,
	'f3=s'				=>	\$file3,
);


if ($outfile) {
	$main=$outfile."_main";
    
    open( OUT, ">$main" )
      or die "Error: cannot write to outfile $main: $!\n";
	print STDERR "NOTICE: The program main output is written to $main\n";
	
	
	$fail=$outfile."_fail";
	open( FAIL, ">$fail" )
      or die "Error: cannot write to outfile $failcnv: $!\n";
	print STDERR "NOTICE: The CNV < 2kb is written to $fail\n";
	
	$pass=$outfile."_pass";
	open( PASS, ">$pass" )
      or die "Error: cannot write to outfile $pass: $!\n";
	print STDERR "NOTICE: The CNV detected in more than 1 alg is written to $pass\n";


}else{
	print STDERR "Error Warning: Please provide the output file name \nUsage: perl comp.pl --outbase/-o -f1 -f2 -f3 \n";
	exit;
}





#If need to compare more than 3 algorithms, modify the below.
if ($file1){&readinput($file1,1)}
if ($file2){&readinput($file2,2)}
if ($file3){&readinput($file3,3)}

#########################################################################
# The &readinput determine the c of algorithm by identifying unique word in each algorithm's output's headline .
# PennCNV output headline has numsnp
# BirdSuite output headline has SCORE
# QuatniSNP output headline has Max
# So please keep the headline of each raw CNV file intact 
# A Hash of Array of Hash (HAH) was created to record the CNVs for each individual and each algorithm 
# the data structure looks like :
# $cnv->{sample}->[1,2,3]->{sta,end,CNumber}
#     hash       array (correspond to each algorithm)        hash
#
#########################################################################


sub readinput {
	$input_file=shift (@_);
	$number= shift (@_);

	open( FILE, "<$input_file" ) or die "couldn't open $cnv1file\n";
	@full_file = <FILE>;
	close FILE;
	
	if ( $full_file[0] =~ m/numsnp/ ) {
    say STDERR "$input_file format is penncnv format";
	$type{$number} = "Penn";
	foreach $line (@full_file) 
		{
			chomp;

			if ($line =~ m/numsnp/) 
			{
#			chr23:108477-2704240           numsnp=390    length=2,595,764   state3,cn=2 2140011A01 startsnp=CN_933644 endsnp=SNP_A-4261558
			$line =~ m/^chr(\d+):(\d+)-(\d+)\s+numsnp=(\d+)\s+length=([\d\,]+)\s+state\d+,cn=(\d+)\s+(\w+)\s+startsnp=(\S+)\s+endsnp=(\S+)/;
			$chr        = $1;
            $sta        = $2;
            $end        = $3;
            $length     = $end-$sta ;
            $copynumber = $6;
            $numsnp     = $4;
            $sample     = $7;
			say "$chr $sta $end $length $copynumber $numsnp $sample";
            $temp       = 
				{
					"alg"    => $number,
					"chr"    => $chr,
					"sta"    => $sta,
					"end"    => $end,
					"cn"   => $copynumber,
					"length" => $length,
					"probe"  => $numsnp
				};
			push @{$cnv{$sample}{$number}}, $temp;
			$count{$sample}{$number}++;
			}
		}

	}

if ( $full_file[0] =~ m/SCORE/ ) {
    say STDERR "$input_file is BirdSuite format";
	$type{$number} = "Bird";
    foreach (@full_file) {
        chomp;

        #FID IID CHR BP1 BP2 TYPE SCORE SITE
        @line = split;

        ( $sample, $chr, $sta, $end, $copynumber, $lodscore, $numsnp ) =
          @line[ 1 .. 7 ];
		  $len=  $end-$sta;
        my $temp = {
			"alg"    => $number,
            "chr"   => $chr,
            "sta"   => $sta,
            "end"   => $end,
            "cn"  => $copynumber,
            "probe" => $numsnp,
            "score" => $lodscore,
			"length" => $len,
        };
        push @{$cnv{$sample}{$number}}, $temp;
		$count{$sample}{$number}++;
    }
}

if ( $full_file[0] =~ m/Max/ ) {
    say STDERR "$input_file is QuantiSNP format";
	$type{$number} = "Quanti";
    foreach (@full_file) {
        chomp;

    #    Sample-Name	Chromosome	Start	End 	ID	ID	Length Probes	Copy Number
    #      0             1           2      3        4   5   6      7          8
        @line = split;

        ( $sample, $chr, $sta, $end, $length,$copynumber, $numsnp ) = @line[ 0 .. 3,6, 8, 7 ];
        my $temp = {
			"alg"    => $number,
            "chr"    => $chr,
            "sta"    => $sta,
            "end"    => $end,
            "cn"   => $copynumber,
            "probe" => $numsnp,
			"length" => $length,
        };
        push @{$cnv{$sample}{$number}}, $temp;
		$count{$sample}{$number}++;
    }
}

}

say OUT "sample	alg chr sta end type length probe score $type{1} $type{2} $type{3} $type{1} $type{2} $type{3} ";
say PASS "sample alg chr sta end type length probe score $type{1} $type{2} $type{3} $type{1} $type{2} $type{3} ";


#####################################################################################################
# The Main loop for CNV comparision 
# CNVs < 2kb will be discarded 
# The threshold of overlaping rate is set at 50% 
# 
#
#####################################################################################################


foreach $sample ( keys %cnv ) 
{	
    for $algnum (sort keys %{$cnv{$sample}})
	{	
		$newalgnum= $algnum +10;
		$size = scalar @{ $cnv{$sample}{$algnum} } - 1;
		for $i ( 0 .. $size )
		{	
			if ($cnv{$sample}{$algnum}->[$i]->{length} <= 2000){say FAIL "$sample $algnum $cnv{$sample}{$algnum}->[$i]->{chr} $cnv{$sample}{$algnum}->[$i]->{sta} $cnv{$sample}{$algnum}->[$i]->{end} $cnv{$sample}{$algnum}->[$i]->{cn} $cnv{$sample}{$algnum}->[$i]->{length} $cnv{$sample}{$algnum}->[$i]->{probe}"}else
			{
				$cnv{$sample}{$algnum}->[$i]->{1} = $cnv{$sample}{$algnum}->[$i]->{2} = $cnv{$sample}{$algnum}->[$i]->{3}=0; 
				
				$cnv{$sample}{$algnum}->[$i]->{11} = $cnv{$sample}{$algnum}->[$i]->{12} = $cnv{$sample}{$algnum}->[$i]->{13}=0; 
				$cnv{$sample}{$algnum}->[$i]->{$algnum} = 1;
				$cnv{$sample}{$algnum}->[$i]->{$newalgnum} = 100;
	
			
				for $algnum2 (sort keys %{$cnv{$sample}})
				{   
					next if $algnum ==$algnum2;
					$newalgnum2=$algnum2 +10;
					$status           = 0;
					$total_percentage = 0;
				
					$size2 = scalar @{$cnv{$sample}{$algnum2}} - 1;
					for $j ( 0 .. $size2 )
					{	next unless ($cnv{$sample}{$algnum}->[$i]->{chr} == $cnv{$sample}{$algnum2}->[$j]->{chr} ) ;
						$length = $cnv{$sample}{$algnum}->[$i]->{end} - $cnv{$sample}{$algnum}->[$i]->{sta};
						if($cnv{$sample}{$algnum2}->[$j]->{sta} <= $cnv{$sample}{$algnum}->[$i]->{sta} and $cnv{$sample}{$algnum2}->[$j]->{end} > $cnv{$sample}{$algnum}->[$i]->{sta} )
						{
							if ( $cnv{$sample}{$algnum2}->[$j]->{end} < $cnv{$sample}{$algnum}->[$i]->{end} )
							{
							$overlaping =$cnv{$sample}{$algnum2}->[$j]->{end} -$cnv{$sample}{$algnum}->[$i]->{sta};
							$pencentage = ( $overlaping / $length ) * 100;
							$pencentage = sprintf( "%4.2f", $pencentage );
							say "hit1 $sample $algnum $cnv{$sample}{$algnum}->[$i]->{chr} $cnv{$sample}{$algnum}->[$i]->{sta} $cnv{$sample}{$algnum}->[$i]->{end} $cnv{$sample}{$algnum}->[$i]->{length} $cnv{$sample}{$algnum}->[$i]->{probe}  $cnv{$sample}{$algnum}->[$i]->{cn} $algnum2 $cnv{$sample}{$algnum2}->[$j]->{chr} $cnv{$sample}{$algnum2}->[$j]->{sta} $cnv{$sample}{$algnum2}->[$j]->{end} $cnv{$sample}{$algnum2}->[$j]->{length} $cnv{$sample}{$algnum2}->[$j]->{probe} $cnv{$sample}{$algnum2}->[$j]->{cn} $pencentage%";
							$status           = 1;
							$total_percentage = $total_percentage + $pencentage;
							}

							if ( $cnv{$sample}{$algnum2}->[$j]->{end} >= $cnv{$sample}{$algnum}->[$i]->{end} )
							{
							$pencentage = 100;
							$pencentage = sprintf( "%4.2f", $pencentage );
							say "hit2 $sample $algnum $cnv{$sample}{$algnum}->[$i]->{chr} $cnv{$sample}{$algnum}->[$i]->{sta} $cnv{$sample}{$algnum}->[$i]->{end} $cnv{$sample}{$algnum}->[$i]->{length} $cnv{$sample}{$algnum}->[$i]->{probe} $cnv{$sample}{$algnum}->[$i]->{cn} $algnum2 $cnv{$sample}{$algnum2}->[$j]->{chr} $cnv{$sample}{$algnum2}->[$j]->{sta} $cnv{$sample}{$algnum2}->[$j]->{end} $cnv{$sample}{$algnum2}->[$j]->{length} $cnv{$sample}{$algnum2}->[$j]->{probe} $cnv{$sample}{$algnum2}->[$j]->{cn} $pencentage%";
							$status           = 1;
							$total_percentage = $total_percentage + $pencentage;
							}
						}
					
					if ($cnv{$sample}{$algnum2}->[$j]->{sta} > $cnv{$sample}{$algnum}->[$i]->{sta} and $cnv{$sample}{$algnum2}->[$j]->{end} <= $cnv{$sample}{$algnum}->[$i]->{end} )
						{
						$overlaping = $cnv{$sample}{$algnum2}->[$j]->{end} - $cnv{$sample}{$algnum2}->[$j]->{sta};
						$pencentage = ( $overlaping / $length ) * 100;
						$pencentage = sprintf( "%4.2f", $pencentage );
						say "hit3 $sample $algnum $cnv{$sample}{$algnum}->[$i]->{chr} $cnv{$sample}{$algnum}->[$i]->{sta} $cnv{$sample}{$algnum}->[$i]->{end} $cnv{$sample}{$algnum}->[$i]->{length} $cnv{$sample}{$algnum}->[$i]->{probe} $cnv{$sample}{$algnum}->[$i]->{cn} $algnum2 $cnv{$sample}{$algnum2}->[$j]->{chr} $cnv{$sample}{$algnum2}->[$j]->{sta} $cnv{$sample}{$algnum2}->[$j]->{end} $cnv{$sample}{$algnum2}->[$j]->{length} $cnv{$sample}{$algnum2}->[$j]->{probe} $cnv{$sample}{$algnum2}->[$j]->{cn} $pencentage%";
						$status = 1;
						$total_percentage = $total_percentage + $pencentage;
						}

						if (    $cnv{$sample}{$algnum2}->[$j]->{sta} > $cnv{$sample}{$algnum}->[$i]->{sta}
						and $cnv{$sample}{$algnum2}->[$j]->{end} > $cnv{$sample}{$algnum}->[$i]->{end}
						and $cnv{$sample}{$algnum2}->[$j]->{sta} < $cnv{$sample}{$algnum}->[$i]->{end} )
						{
						$overlaping = $cnv{$sample}{$algnum}->[$i]->{end} - $cnv{$sample}{$algnum2}->[$j]->{sta};
						$pencentage = ( $overlaping / $length ) * 100;
						$pencentage = sprintf( "%4.2f", $pencentage );
						say "hit4 $sample $algnum $cnv{$sample}{$algnum}->[$i]->{chr} $cnv{$sample}{$algnum}->[$i]->{sta} $cnv{$sample}{$algnum}->[$i]->{end} $cnv{$sample}{$algnum}->[$i]->{length} $cnv{$sample}{$algnum}->[$i]->{probe}  $cnv{$sample}{$algnum}->[$i]->{cn} $algnum2 $cnv{$sample}{$algnum2}->[$j]->{chr} $cnv{$sample}{$algnum2}->[$j]->{sta} $cnv{$sample}{$algnum2}->[$j]->{end} $cnv{$sample}{$algnum2}->[$j]->{length} $cnv{$sample}{$algnum2}->[$j]->{probe} $cnv{$sample}{$algnum2}->[$j]->{cn} $pencentage%";
						$status = 1;
						$total_percentage = $total_percentage + $pencentage;
						}
					
					}
			
					if ($total_percentage >50 ){$cnv{$sample}{$algnum}->[$i]->{$algnum2} = 1 } else {$cnv{$sample}{$algnum}->[$i]->{$algnum2} = 0 } 
					$cnv{$sample}{$algnum}->[$i]->{$newalgnum2} = $total_percentage;
				}
				$value=$cnv{$sample}{$algnum}->[$i]->{1} +$cnv{$sample}{$algnum}->[$i]->{2}+$cnv{$sample}{$algnum}->[$i]->{3};
				if ($value >= 2){say PASS "$sample $algnum $cnv{$sample}{$algnum}->[$i]->{chr} $cnv{$sample}{$algnum}->[$i]->{sta} $cnv{$sample}{$algnum}->[$i]->{end} $cnv{$sample}{$algnum}->[$i]->{cn} $cnv{$sample}{$algnum}->[$i]->{length} $cnv{$sample}{$algnum}->[$i]->{probe} $value $cnv{$sample}{$algnum}->[$i]->{1} $cnv{$sample}{$algnum}->[$i]->{2} $cnv{$sample}{$algnum}->[$i]->{3} $cnv{$sample}{$algnum}->[$i]->{11} $cnv{$sample}{$algnum}->[$i]->{12} $cnv{$sample}{$algnum}->[$i]->{13}";}
				say OUT "$sample $algnum $cnv{$sample}{$algnum}->[$i]->{chr} $cnv{$sample}{$algnum}->[$i]->{sta} $cnv{$sample}{$algnum}->[$i]->{end} $cnv{$sample}{$algnum}->[$i]->{cn} $cnv{$sample}{$algnum}->[$i]->{length} $cnv{$sample}{$algnum}->[$i]->{probe} $value $cnv{$sample}{$algnum}->[$i]->{1} $cnv{$sample}{$algnum}->[$i]->{2} $cnv{$sample}{$algnum}->[$i]->{3} $cnv{$sample}{$algnum}->[$i]->{11} $cnv{$sample}{$algnum}->[$i]->{12} $cnv{$sample}{$algnum}->[$i]->{13}";
			}
		}
	}
print "\n";
}
