#!/usr/bin/bash

#BSUB -J Delly
#BSUB -o /logs/Delly_example.out
#BSUB -e /logs/Delly_example.err
#BSUB -W 20:00
#BSUB -n 4
#BSUB -R "span[hosts=1]  rusage[mem=8000]" -M 8000
#BSUB -N


SIMG_DELLY=/path/to/delly_v1.1.5.sif

OUTPUT_DIR="/.../delly_output/sampleX"
OUTPUT_BCF="/.../delly_output/sampleX/sampleX_delly.bcf"
REF="/.../GRCm38mm10_PhiX.fa"
TUMOR_BAM="/.../colony.bam"
CONTROL_BAM="/.../tail.bam"
EXCLUDE_REGIONS="/.../exclude_regions/Delly-exclude-template_mm10.tsv"



LSF_THREADS_SETUP=$LSB_DJOB_NUMPROC
set +e

singularity exec --cleanenv --workdir $OUTPUT_DIR --pwd $OUTPUT_DIR $SIMG_DELLY\
		delly call -x $EXCLUDE_REGIONS -o $OUTPUT_BCF -g $REF $TUMOR_BAM $CONTROL_BAM
