# Merge overlapping CNVs into unique CNV
# The 
# Xiaoxi Liu 
# Department of Human Genetics, University of Tokyo
# 2012-2-9 ; 2012-4-28; 
#
# Input:
#	1-----4
#		2--------6
#			4-------------------------10
#		                                   13-------------------------------------19
# Output:
#   1---------------------------------10   13-------------------------------------19
#

use 5.010;
#use Data::Dumper;
use Getopt::Long;

GetOptions(
	# the pass CNV file from step1 : ****_pass file  
	'in|i=s'            => \$input,
#   out_base.missmatch -> the Copy Number Not Matched in different algorithem
#	out_base.main 	   -> the main output file
#	out_base.detail	   -> contain more detail of each merged region

	'out|o=s'     =>\$out_base,
);

if ($input)
{
	open (IN,"<$input");
	while (<IN>)
	{
		next if /alg/;
		@array = split ;
#	sample	alg chr sta end type length probe score penn bird quanti penn_perc bird_perc quanti_perc
# 	2140010B02 1 1 150822330 150853218 0 30888 35 3 1 1 1 100
		($sample,$alg,$chr,$sta,$end,$type)=@array[0,1,2,3,4,5];
		$lossorgain = "loss" if $type <2 ;
		$lossorgain= gain if $type >2 ;
		$list={	sample => $sample,
			chr => $chr,
			sta => $sta,
			end => $end,
			type=> $type,
			alg => $alg,
			sus => "no",
			lossorgain => $lossorgain,
			note => "$alg $sta $end $type",
			};
#       Hash of Hash of Array of Hash
#   $mat->$sample->chr->[cnv1,cnv2,cnv3]
#     
	push @{$mat{$sample}{$chr}}, $list;
	push @{$cnv{$sample}{$alg}}, $list;
	
	}
}else{say STDERR "Please provide the raw CNV file\nUsage: perl cnvmerge.pl -i -o"; exit}
		
if ($out_base)
{
$out=$out_base.".main";
$missmatch=$out_base.".mismatch";
$detailed=$out_base.".detail";
$bed_file=$out_base.".bed";
open (OUT,">$out") or die "could not write to the $out file";
open (MISS,">$missmatch") or die "could not write to the target file";
open (OUTDETAIL,">$detailed") or die "could not write to the $out file";
open (BED,">$bed_file") or die "could not write to the $bed_file file";
say BED 'track name=my_bed_file description="CNVs in bed format" visibility=4 priority=1 itemRgb="On"';
}else{say STDERR "Please provide the raw CNV file\nUsage: perl cnvmerge.pl -i -o";exit}


foreach $id (keys %mat)
{	
	
	for $chr(sort keys %{$mat{$id}}) 
	{  
#		say $chr;
		@new=();
		$size = scalar @{ $mat{$id}{$chr}} - 1;
		@temp=@{ $mat{$id}{$chr}};
# Sort CNV according the start position 
		@sorted = sort { $$a{'sta'} <=> $$b{'sta'} } @temp;
		push @new,$sorted[0];
		
		for $i ( 1 .. $size )
		{
#			say "$sorted[$i]->{sta} $sorted[$i]->{end} $sorted[$i]->{alg} #### $new[-1]->{sta} $new[-1]->{end}";
#  $new[-1]       ----------------
#  $sorted[$i]               ------------------
		if ($sorted[$i]->{sta} <= $new[-1]->{end} )
		{
			
			if ($sorted[$i]->{end} > $new[-1]->{end})
			{   if($sorted[$i]->{end} - $new[-1]->{end} > 100000){say "warning"; say "$id $new[-1]->{alg} $new[-1]->{sta} $new[-1]->{end} $new[-1]->{type} $sorted[$i]->{alg} $sorted[$i]->{sta} $sorted[$i]->{end} $sorted[$i]->{type}" }
				if ($sorted[$i]->{lossorgain} ne $new[-1]->{lossorgain} ){
					$new[-1]->{sus} = "yes" ;
					$new[-1]->{note} .=  "\t$sorted[$i]->{alg} $sorted[$i]->{sta} $sorted[$i]->{end} $sorted[$i]->{type}";
#					say "warning cnv number not matched";
					say MISS "$id $new[-1]->{alg} $new[-1]->{sta} $new[-1]->{end} $new[-1]->{type} $sorted[$i]->{alg} $sorted[$i]->{sta} $sorted[$i]->{end} $sorted[$i]->{type}";
			}else
			{
				$new[-1]->{end} = $sorted[$i]->{end}};
				$new[-1]->{note} .=  "\t$sorted[$i]->{alg} $sorted[$i]->{sta} $sorted[$i]->{end} $sorted[$i]->{type}";
			}
			
			if ($sorted[$i]->{end} <= $new[-1]->{end})
			{
			$new[-1]->{note} .=  "\t$sorted[$i]->{alg} $sorted[$i]->{sta} $sorted[$i]->{end} $sorted[$i]->{type}";
			}
			
			
	    }
			
		if ($sorted[$i]->{sta} > $new[-1]->{end}) 
		{
			push @new, $sorted[$i]
		}
		
		
		}
		$size2 = scalar $#new;
		$cnvnumberperchr= $size2+1;
#		say "$cnvnumberperchr were found in chr $chr";
		$count{$id} =$count{$id}+ $cnvnumberperchr;
        for $i ( 0 .. $size2 )
		{
		
		
		say OUT "$new[$i]->{sample}\t$new[$i]->{chr}\t$new[$i]->{sta}\t$new[$i]->{end}\t$new[$i]->{type}\t$new[$i]->{sus}";
		if($new[$i]->{type} ==0 )
		{
			$RGB = "0,0,0";	
		}elsif($new[$i]->{type} ==1 ){
			$RGB = "255,0,0";
		}elsif($new[$i]->{type} > 2){
			$RGB = "0,0,255";
		}	
		#chr22 17052138 17386126 JYJ_8_SJH_JYJ_8_SJH 5.2 . 17052138 17386126 255,0,0
		$bed_format ="chr"."$new[$i]->{chr}\t";									#chr
		$bed_format  .="$new[$i]->{sta}\t$new[$i]->{end}\t";					#sta end
		$bed_format  .="$new[$i]->{sample}";									#sample_CN
		$bed_format  .="_";
		$bed_format  .="$new[$i]->{type}\t";
		$bed_format  .="0\t.\t$new[$i]->{sta}\t$new[$i]->{end}\t";
		$bed_format  .="$RGB";
		
		
		say BED $bed_format if $new[$i]->{sus} eq "no" ;
		$new[$i]->{size} = $new[$i]->{end} - $new[$i]->{sta};
		$list={	sample => $id,
		chr => $new[$i]->{chr},
		sta => $new[$i]->{sta},
		end => $new[$i]->{end},
		type=> $new[$i]->{type},
		size => $new[$i]->{size} ,
		alg => "4",
		lossorgain => $lossorgain,
		note => $new[$i]->{note},
		};
			
		push @{$cnv{$id}{"4"}}, $list;
			
	 }	
		
		
	}
	
#say "#############################";
#	print Dumper(@sorted);

}			
	
foreach $sample (keys %count){
say "$sample $count{$sample}"

}


foreach $sample ( keys %cnv ) 
{	
    $algnum = 4 ;
		
		$newalgnum= $algnum +10;
		$size = scalar @{ $cnv{$sample}{$algnum} } - 1;
		say $size;
		for $i ( 0 .. $size )
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
							say "hit1 $sample $algnum $cnv{$sample}{$algnum}->[$i]->{chr} $cnv{$sample}{$algnum}->[$i]->{sta} $cnv{$sample}{$algnum}->[$i]->{end} $cnv{$sample}{$algnum}->[$i]->{length} $cnv{$sample}{$algnum}->[$i]->{probe} $algnum2 $cnv{$sample}{$algnum2}->[$j]->{chr} $cnv{$sample}{$algnum2}->[$j]->{sta} $cnv{$sample}{$algnum2}->[$j]->{end} $cnv{$sample}{$algnum2}->[$j]->{length} $cnv{$sample}{$algnum2}->[$j]->{probe} $pencentage%";
							$status           = 1;
							$total_percentage = $total_percentage + $pencentage;
							}

							if ( $cnv{$sample}{$algnum2}->[$j]->{end} >= $cnv{$sample}{$algnum}->[$i]->{end} )
							{
							$pencentage = 100;
							$pencentage = sprintf( "%4.2f", $pencentage );
							say "hit2 $sample $algnum $cnv{$sample}{$algnum}->[$i]->{chr} $cnv{$sample}{$algnum}->[$i]->{sta} $cnv{$sample}{$algnum}->[$i]->{end} $cnv{$sample}{$algnum}->[$i]->{length} $cnv{$sample}{$algnum}->[$i]->{probe} $algnum2 $cnv{$sample}{$algnum2}->[$j]->{chr} $cnv{$sample}{$algnum2}->[$j]->{sta} $cnv{$sample}{$algnum2}->[$j]->{end} $cnv{$sample}{$algnum2}->[$j]->{length} $cnv{$sample}{$algnum2}->[$j]->{probe} $pencentage%";
							$status           = 1;
							$total_percentage = $total_percentage + $pencentage;
							}
						}
					
					if ($cnv{$sample}{$algnum2}->[$j]->{sta} > $cnv{$sample}{$algnum}->[$i]->{sta} and $cnv{$sample}{$algnum2}->[$j]->{end} <= $cnv{$sample}{$algnum}->[$i]->{end} )
						{
						$overlaping = $cnv{$sample}{$algnum2}->[$j]->{end} - $cnv{$sample}{$algnum2}->[$j]->{sta};
						$pencentage = ( $overlaping / $length ) * 100;
						$pencentage = sprintf( "%4.2f", $pencentage );
						say "hit3 $sample $algnum $cnv{$sample}{$algnum}->[$i]->{chr} $cnv{$sample}{$algnum}->[$i]->{sta} $cnv{$sample}{$algnum}->[$i]->{end} $cnv{$sample}{$algnum}->[$i]->{length} $cnv{$sample}{$algnum}->[$i]->{probe} $algnum2 $cnv{$sample}{$algnum2}->[$j]->{chr} $cnv{$sample}{$algnum2}->[$j]->{sta} $cnv{$sample}{$algnum2}->[$j]->{end} $cnv{$sample}{$algnum2}->[$j]->{length} $cnv{$sample}{$algnum2}->[$j]->{probe} $pencentage%";
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
						say "hit4 $sample $algnum $cnv{$sample}{$algnum}->[$i]->{chr} $cnv{$sample}{$algnum}->[$i]->{sta} $cnv{$sample}{$algnum}->[$i]->{end} $cnv{$sample}{$algnum}->[$i]->{length} $cnv{$sample}{$algnum}->[$i]->{probe} $algnum2 $cnv{$sample}{$algnum2}->[$j]->{chr} $cnv{$sample}{$algnum2}->[$j]->{sta} $cnv{$sample}{$algnum2}->[$j]->{end} $cnv{$sample}{$algnum2}->[$j]->{length} $cnv{$sample}{$algnum2}->[$j]->{probe} $pencentage%";
						$status = 1;
						$total_percentage = $total_percentage + $pencentage;
						}
					
					}
			
					if ($total_percentage >50 ){$cnv{$sample}{$algnum}->[$i]->{$algnum2} = 1 } else {$cnv{$sample}{$algnum}->[$i]->{$algnum2} = 0 } 
					$cnv{$sample}{$algnum}->[$i]->{$newalgnum2} = $total_percentage;
				}
				$value=$cnv{$sample}{$algnum}->[$i]->{1} +$cnv{$sample}{$algnum}->[$i]->{2}+$cnv{$sample}{$algnum}->[$i]->{3};
				if ($value >= 2){say PASS "$sample $algnum $cnv{$sample}{$algnum}->[$i]->{chr} $cnv{$sample}{$algnum}->[$i]->{sta} $cnv{$sample}{$algnum}->[$i]->{end} $cnv{$sample}{$algnum}->[$i]->{type} $cnv{$sample}{$algnum}->[$i]->{length} $cnv{$sample}{$algnum}->[$i]->{probe} $value $cnv{$sample}{$algnum}->[$i]->{1} $cnv{$sample}{$algnum}->[$i]->{2} $cnv{$sample}{$algnum}->[$i]->{3} $cnv{$sample}{$algnum}->[$i]->{11} $cnv{$sample}{$algnum}->[$i]->{12} $cnv{$sample}{$algnum}->[$i]->{13}";}
				say OUTDETAIL "$sample $algnum $cnv{$sample}{$algnum}->[$i]->{chr} $cnv{$sample}{$algnum}->[$i]->{sta} $cnv{$sample}{$algnum}->[$i]->{end} $cnv{$sample}{$algnum}->[$i]->{size} $cnv{$sample}{$algnum}->[$i]->{type} $cnv{$sample}{$algnum}->[$i]->{length} $cnv{$sample}{$algnum}->[$i]->{probe} $value $cnv{$sample}{$algnum}->[$i]->{1} $cnv{$sample}{$algnum}->[$i]->{2} $cnv{$sample}{$algnum}->[$i]->{3} $cnv{$sample}{$algnum}->[$i]->{11} $cnv{$sample}{$algnum}->[$i]->{12} $cnv{$sample}{$algnum}->[$i]->{13} $cnv{$sample}{$algnum}->[$i]->{note}";
			
		}
	
print "\n";
}

#print Dumper(@new);	
											
											
	