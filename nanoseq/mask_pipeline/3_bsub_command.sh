#!/bin/bash
# ============================================================
# 3_bsub_command.sh
# Cross-species NanoSeq: SNP mask pipeline — Step 3 wrapper
# Submits one mask-building job per chromosome/contig
#
# Author: Adrian Baez-Ortega, 2023
# Adapted for use in: HSC mutagenesis study (Cagan Lab)
#
# Usage: bash 3_bsub_command.sh SPECIES_INFO.txt
#
# Input: tab-delimited file, no header, 4 columns:
#   species | path to sample CSV | path to reference FASTA | path to NanoSeq working directory
#
# Output: one BED file per chromosome (written by 3_MaskBuilding.R)
#
# Note: Do NOT launch until all jobs from Steps 1 and 2 are complete.
#       For species with large numbers of contigs, use
#       3_bsub_command_with_contig_merger.sh instead (batches 50 contigs per job)
#
# Dependencies: R (see 3_MaskBuilding.R)
# ============================================================

INPUT=$1

MEM=20000
QUEUE=long

LOG=logs_3
mkdir -p $LOG

while read SPECIES SAMPLES REF NFDIR; do

    # Count contigs in reference genome
    NCHR=$(wc -l < $REF.fai)
    echo -e "\nSpecies: $SPECIES ($NCHR contigs)"

    for CHR in $(seq $NCHR); do
        CMD="Rscript /path/to/3_MaskBuilding.R $SPECIES $REF $CHR"
        bsub -o $LOG/log.%J -q $QUEUE -n 1 \
            -R "span[hosts=1] select[mem>=$MEM] rusage[mem=$MEM]" -M $MEM "$CMD"
    done

done < $INPUT

echo
echo Done
