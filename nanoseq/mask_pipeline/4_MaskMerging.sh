#!/bin/bash
# ============================================================
# 4_MaskMerging.sh
# Cross-species NanoSeq: SNP mask pipeline — Step 4
# Merge per-chromosome mask BED files into a single BED.gz file
#
# Author: Adrian Baez-Ortega, 2023
# Adapted for use in: HSC mutagenesis study (Cagan Lab)
#
# Usage: bash 4_MaskMerging.sh SPECIES_INFO.txt
#
# Input: tab-delimited file, no header, 4 columns:
#   species | path to sample CSV | path to reference FASTA | path to NanoSeq working directory
#
# Output: output/MASKS/SNP+NOISE.NV2.SeenNV1.<species>.bed.gz
#         Tabix index: output/MASKS/SNP+NOISE.NV2.SeenNV1.<species>.bed.gz.tbi
#
# Note: Do NOT launch until all jobs from Step 3 are complete.
#
# Dependencies: bedtools 2.29.0, bgzip, tabix
# ============================================================

INPUT=$1

MEM=5000
QUEUE=long

LOG=logs_4
mkdir -p $LOG
mkdir -p output/MASKS

while read SPECIES SAMPLES REF NFDIR; do

    echo
    echo "Species: $SPECIES"

    CMD="module load bedtools2-2.29.0; \
         echo Concatenating and sorting...; \
         cat output/$SPECIES/SNP+NOISE.NV2.SeenNV1.* \
             | sort -k1,1 -k2,2n \
             | cut -f1-3 \
             | bgzip > output/$SPECIES/SNP+NOISE.NV2.SeenNV1.${SPECIES}_ALL.bed.gz; \
         echo Merging and indexing...; \
         bedtools merge -i output/$SPECIES/SNP+NOISE.NV2.SeenNV1.${SPECIES}_ALL.bed.gz \
             | bgzip > output/MASKS/SNP+NOISE.NV2.SeenNV1.$SPECIES.bed.gz; \
         tabix -p bed output/MASKS/SNP+NOISE.NV2.SeenNV1.$SPECIES.bed.gz; \
         echo Done;"

    bsub -o $LOG/log.%J -q $QUEUE -n 1 \
        -R "span[hosts=1] select[mem>=$MEM] rusage[mem=$MEM]" -M $MEM "$CMD"

done < $INPUT

echo
echo Done
