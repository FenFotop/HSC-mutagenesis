#!/bin/bash

#BSUB -J filter_pindel_output
#BSUB -o logs/filter_pindel.out
#BSUB -e logs/filter_pindel.err
#BSUB -W 02:00
#BSUB -n 2
#BSUB -R "span[hosts=1] select[mem>2000] rusage[mem=2000]" -M 2000
#BSUB -N
#BSUB -B

# This script filters the raw Pindel calls based on qualitry metrics, VAF (FORMAT/FC divided by FORMAT/FD), simple repeats, depth (10-100x) in colony and matched normal, 
# autosomal chromosomes and the Sanger unmatched normal panel.
# Note that for the benchmarking, we will eliminate the depth < 100x criterion "| bcftools filter -e "FD>100" ""

# load required modules
module load bcftools/1.16

out_dir="/.../"

# get all unfiltered pindel output files
readarray -t vcf_files < <(find /path/to/unfiltered/pindel_output/  -maxdepth 2 | grep "\.flagged\.vcf\.gz$") 


for vcf in ${vcf_files[@]}; do  
   
        file_name=$(echo $vcf | grep -o "sample_control.*\.flagged") 
	output=${out_dir}${file_name}_filtered.vcf.gz

	# filter on depth 10-100x in colony and matched normal first, then sample, chromosomes, PASS (also removing samples that did not pass the unmatched normal panel filter 
	# FF010 and simple repeats FF017), VAF, quality filter
	bcftools filter -e "FD<10" $vcf | bcftools filter -e "FD>100" --output ${out_dir}${file_name}.temp.bcf 
	bcftools index ${out_dir}${file_name}.temp.bcf
	
	bcftools view -s TUMOUR -r 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21 ${out_dir}${file_name}.temp.bcf | bcftools filter -i "FILTER='PASS'" | 
	bcftools filter -i "(FC/FD)>=0.3" | bcftools filter -i "QUAL>=20" --output ${output}  

	# index the filtered vcf file 
        bcftools index --tbi $output

	# clear temp files 
	rm ${out_dir}${file_name}.temp.bcf ${out_dir}${file_name}.temp.bcf.csi


	# TO STANDARD OUT -------------------------------------------------------
	echo "File: $vcf"
	echo "Filtered, saved as:"
	echo $output
	echo "--------------------------------"
	# ----------------------------------------------------------------------- 
done 
