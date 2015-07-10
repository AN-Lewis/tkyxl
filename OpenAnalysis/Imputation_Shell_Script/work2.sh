#! /bin/bash

#for condnum in 1 2
#do
	#please type your file name without file extention (.bed .bam .fam)
	
	#./divide-chromo.sh ./data_files/koa ./data_files/koa-chr

	#for i in $(seq 1 22) 
	#do
	#	gtool -P --ped ./data_files/koa-chr${i}.ped --map ./data_files/koa-chr${i}.map --og ./data_files/koa-chr${i}.gen --os ./data_files/koa-chr${i}.sam
	#done

	cat ./data_files/koa-l-2.txt | while read rsnumber
	do 
		plink --bfile ./data_files/koa --snp ${rsnumber} --window 2000 --recode --out ./data_files/koa-${rsnumber}
	done

#plink association testの結果を得る
	cat ./data_files/koa-l-2.txt | while read i	
	do 
		rs_number=$i
		chromosome=`head -n 1 ./data_files/koa-${rs_number}.map | gawk '{print $1}'`
		first_position=`head -n 1 ./data_files/koa-${rs_number}.map | gawk '{print $4}'`
		second_position=`tail -n 1 ./data_files/koa-${rs_number}.map | gawk '{print $4}'`
		#echo ${chromosome} ${first_position} ${second_position} ${rs_number} ${condnum}
		./phasing_job.sh ${chromosome} ${first_position} ${second_position} ${rs_number}
		./imputation.sh ${chromosome} ${first_position} ${second_position} ${rs_number}
		gtool -G --g ./results/gwas_data-${rs_number}.best_guess_haps_imputation.impute2 --s ./data_files/koa-chr${chromosome}.sam --ped ./results/koa-${rs_number}.ped --map ./results/koa-${rs_number}.map --sex sex --phenotype phenotype --chr ${chromosome}
		plink --noweb --file ./results/koa-${rs_number} --assoc --ci 0.95 --adjust --out ./results/koa-${rs_number}.out
	done
#done
