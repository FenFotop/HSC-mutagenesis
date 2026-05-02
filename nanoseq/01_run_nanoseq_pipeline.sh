#!/bin/bash
# ============================================================
# 01_run_nanoseq_pipeline.sh
# Launch the NanoSeq Nextflow pipeline for mouse HSC samples
#
# Dependencies:
#   - NanoSeq Nextflow pipeline (Abascal et al., Nature 2021)
#     https://github.com/cancerit/NanoSeq
#   - Nextflow 22.04.5
#   - Singularity 3.9.0
#   - R 4.1.0
#   - samtools 1.19.2
#
# Reference genome: GRCm39
#
# Usage: bsub < 01_run_nanoseq_pipeline.sh
# ============================================================

#BSUB -q basement
#BSUB -J NF_nanoseq_mouse
#BSUB -n 1
#BSUB -R "select[mem>5000] rusage[mem=5000]" -M5000
#BSUB -o log.nf.%J

# USER-DEFINED PATHS — update these for your system
INPUT=/path/to/sample_sheet.csv     # CSV sample sheet (see NanoSeq documentation for format)
REF=/path/to/GRCm39/genome.fa       # GRCm39 reference genome fasta
TRINUC=/path/to/GRCm39/ref_freqs.txt # Trinucleotide frequencies for GRCm39
MASK=/path/to/SNP+NOISE.mouse.bed.gz # Mouse-specific SNP and noise mask (see 02_generate_mask.sh)
NANOSEQ=/path/to/NanoSeq_main.nf    # Path to NanoSeq Nextflow script
OUTPUT=$PWD/output

mkdir -p $OUTPUT

# Load modules (adjust for your HPC environment)
module purge
module add R
module add singularity
module add samtools
module add nextflow
export NXF_VER=22.04.5

# Validate inputs
if [ -z "$INPUT" ] || [ -z "$OUTPUT" ] || [ -z "$REF" ] || [ -z "$MASK" ] || [ -z "$TRINUC" ]; then
    echo -e "\nERROR: One or more required variables are missing: INPUT, OUTPUT, REF, MASK, TRINUC\n"
    exit 1
fi

# Launch NanoSeq pipeline
nextflow run $NANOSEQ \
    --jobs 200 \
    -qs 20000 \
    -profile lsf_singularity \
    -resume \
    --sample_sheet $INPUT \
    --outDir $OUTPUT \
    --ref $REF \
    --noise_bed $MASK \
    --post_triNuc $TRINUC
