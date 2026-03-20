#!/bin/bash 
 
#BSUB -J callable_genome_caveman
#BSUB -o /logs/callable_genome_caveman.out
#BSUB -e /logs/callable_genome_caveman.err
#BSUB -W 01:00
#BSUB -n 1
#BSUB -R "span[hosts=1] rusage[mem=20000]" -M 20000
#BSUB -N 
#BSUB -B


module load bedtools/2.29.2


# list of callable genome sizes for each sample
callable_genome_sizes=/.../callable_genome_sizes_caveman.txt
# ignore file used in the caveman runs 
IGNORE_FILE=/.../genome.gap_v3.bed

# simple repeats bed file and centromeric repeats 
SIM_REP=/.../simple_repeats.bed.gz
CENT_REP=/.../centromeric_repeats.bed.gz


# CALCULATE CALLABLE GENOME---------------------------------------------------------------------------
# sample bed files with covergae 10-100x
readarray -t tumour_depth_files < <(find /.../mosdepth_100xdepth/bed_files_10-100x_depth/ -maxdepth 1 | grep "bed$" | grep -v "tail")

for tumour_depth_file in ${tumour_depth_files[@]}; do

	# extract file name and find corresponding files
	file_name=$(echo $tumour_depth_file | grep -oP "(?<=bed_files_10-100x_depth\/).*(?=_)")

	output=//intersected_with_reference_genome/${file_name}_10-100xdepth_intersect_TUMOUR+NORMAL.bed
	callable_file=/.../callable_genome_files/${file_name}_callable_genome.bed
	no_analysis=$(find /.../caveman_results/ -maxdepth 2 | grep "no_analysis\.bed$" | grep "${file_name}")
	long_name=$(echo $no_analysis | grep -oP "sample_colony.*(?=\.no_analysis\.bed)")
	uncallable=$(find /.../uncallable_filtered_variants/ -maxdepth 1 | 
		grep -v "unique" | grep "${long_name}")

	# subtract uncallable variants, simple repeats, centromeric repeats, ignore file and no_analysis file 
	bedtools subtract -a $output -b $uncallable \
		| bedtools subtract -a - -b $SIM_REP \
		| bedtools subtract -a - -b $CENT_REP \
		| bedtools subtract -a - -b $IGNORE_FILE \
		| bedtools subtract -a - -b $no_analysis > $callable_file 

	# add up all callable regions and save as a tab-seperated file
	size=$(cat $callable_file | awk -F'\t' 'BEGIN{SUM=0}{ SUM+=$3-$2 }END{print SUM}')
	printf "$file_name\t$size\tbp\n" >> $callable_genome_sizes


	# standard out
	echo "Sample: $file_name"
	echo "Genome with coverage 10-100x: $output"
	echo "Uncallable variants: $uncallable"
	echo "No_analysis file: $no_analysis"
	echo "Callable genome: $callable_file"
	echo "Callable genome size: $size"
	echo "-----------------------------------------------------------------------"

done 

