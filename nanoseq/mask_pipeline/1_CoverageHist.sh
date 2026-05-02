#!/bin/bash
# ============================================================
# 1_CoverageHist.sh
# Cross-species NanoSeq: SNP mask pipeline — Step 1
# Obtain genome coverage histograms for each matched normal
#
# Author: Adrian Baez-Ortega, 2023
# Adapted for use in: HSC mutagenesis study (Cagan Lab)
#
# Usage: bash 1_CoverageHist.sh SPECIES_INFO.txt
#
# Input: tab-delimited file, no header, 4 columns:
#   species | path to sample CSV | path to reference FASTA | path to NanoSeq working directory
#
# Output: output/<species>/<sample>.covhist.txt for each normal sample
#
# Note: The NanoSeq Nextflow pipeline works with CRAM files. bedtools
# supports CRAM but may require the reference genome set via the
# CRAM_REFERENCE environment variable if errors occur.
# ============================================================

INPUT=$1

MEM=5000
QUEUE=long

LOG=logs_1
mkdir -p $LOG

while read SPECIES SAMPLES REF NFDIR; do

    # Skip commented lines
    if [[ $SPECIES == \#* ]]; then
        echo
        echo "(Skipping: $SPECIES)"
    else

        echo
        echo "Species: $SPECIES"
        mkdir -p output/$SPECIES

        for NORMAL in $(tail -n +2 $SAMPLES | cut -f3 -d, | sort -u | sed 's/.*://g'); do

            echo $NORMAL
            CRAM=$NFDIR/work/*/*/dedup/$NORMAL.neat.cram

            if [ -s $CRAM ]; then
                CMD="bedtools genomecov -ibam $CRAM | grep genome > output/$SPECIES/$NORMAL.covhist.txt"
                bsub -o $LOG/log.%J -q $QUEUE -n 1 \
                    -R "span[hosts=1] select[mem>=$MEM] rusage[mem=$MEM]" -M $MEM "$CMD"
            else
                echo " - No dedup CRAM found: $CRAM"
            fi

        done

    fi

done < $INPUT

echo
echo Done
