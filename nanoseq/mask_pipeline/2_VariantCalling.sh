#!/bin/bash
# ============================================================
# 2_VariantCalling.sh
# Cross-species NanoSeq: SNP mask pipeline — Step 2
# Call all variant sites in each matched normal using mpileup
#
# Author: Adrian Baez-Ortega, 2023
# Adapted for use in: HSC mutagenesis study (Cagan Lab)
#
# Usage: bash 2_VariantCalling.sh SPECIES_INFO.txt
#
# Input: tab-delimited file, no header, 4 columns:
#   species | path to sample CSV | path to reference FASTA | path to NanoSeq working directory
#
# Output: output/<species>/<sample>.pileup.vcf.gz for each normal sample
#
# Note: Can be launched simultaneously with Step 1 (1_CoverageHist.sh)
#
# Dependencies: bcftools 1.9, bgzip
# ============================================================

INPUT=$1

MEM=5000
QUEUE=long

LOG=logs_2
mkdir -p $LOG

while read SPECIES SAMPLES REF NFDIR; do

    echo
    echo "Species: $SPECIES"
    mkdir -p output/$SPECIES

    for NORMAL in $(tail -n +2 $SAMPLES | cut -f3 -d, | sort -u | sed 's/.*://g'); do

        echo $NORMAL
        CRAM=$NFDIR/work/*/*/dedup/$NORMAL.neat.cram

        if [ -s $CRAM ]; then
            CMD="module load bcftools-1.9; \
                 bcftools mpileup -Ov -d999 -f $REF $CRAM \
                 | grep -Pv \"\t<\*>\t\" \
                 | bgzip > output/$SPECIES/$NORMAL.pileup.vcf.gz"
            bsub -o $LOG/log.%J -q $QUEUE -n 1 \
                -R "span[hosts=1] select[mem>=$MEM] rusage[mem=$MEM]" -M $MEM "$CMD"
        else
            echo " - No dedup CRAM found: $CRAM"
        fi

    done

done < $INPUT

echo
echo Done
