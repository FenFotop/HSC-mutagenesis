#!/bin/bash

#BSUB -J downsample_seed1_tail
#BSUB -o logs/%J.out 
#BSUB -e logs/%J.err 
#BSUB -W 60:00
#BSUB -n 1
#BSUB -R "span[hosts=1] select[mem>20000] rusage[mem=20000]" -M 20000

coverage="0.912" ###the fraction of the reads to be kept. probability = target coverage/ original coverage
sample="tail"
seed="1"

input_bam="/.../RB17-6_Tail_merged_use_sorted.bam"
output_bam="/.../RB176_downsampling/${sample}/${coverage}/RB17-6_${sample}_${coverage}_seed${seed}.bam"

module load picard/1.61; export JAVA_OPTIONS='-Xms32G -Xmx32G'; picard.sh DownsampleSam I=${input_bam} O=${output_bam} RANDOM_SEED=${seed} PROBABILITY=${coverage}
