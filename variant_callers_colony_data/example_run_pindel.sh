#!/bin/bash 

#BSUB -J colonyX_pindel
#BSUB -o /logs/pindel_run.out 
#BSUB -e /logs/pindel_run.err  
#BSUB -W 60:00
#BSUB -n 16
#BSUB -R "span[hosts=1] select[mem>48000] rusage[mem=48000]" -M 48000
#BSUB -N 
#BSUB -B

SIMG_PINDEL=/.../cgppindel_v3.3.0.sif ##should be the 3.9 version

OUTDIR=""
REF_INDEX="/.../GRCm38mm10.fa"
TUMOUR_BAM="/.../colony.bam" 
NORMAL_BAM="/.../tail.bam"
# provide the bed file with the simple repeats
SIM_REP="/.../simpleRepeats.bed.gz"
# filtering instructions. More info here: https://github.com/cancerit/cgpPindel/wiki/VcfFilters
FILTER="/.../WGS_Rules.lst"
GENES="/.../codingexon_regions.indel.bed.gz"
UNMATCHED="/.../pindel_np_v1.gff3.gz"
SEQ_TYPE="WGS"
# Unreliable regions for indel calling, origin: Wellcome Sanger
BAD_LOCI="/.../extremedepth_v2.bed.gz"
SOFTFIL="/.../softRulesFragment.lst"
CPU_TO_USE="6"
SPECIES="Mouse"
ASSEMBLY="GRCm38mm10"

LSF_THREADS_SETUP=$LSB_DJOB_NUMPROC
set +e

singularity exec --cleanenv --workdir $OUTDIR --pwd $OUTDIR --home $OUTDIR  $SIMG_PINDEL \
		pindel.pl -o $OUTDIR  -r $REF_INDEX -t $TUMOUR_BAM -n $NORMAL_BAM -s $SIM_REP \
		-f $FILTER -g $GENES -u $UNMATCHED -st $SEQ_TYPE -b $BAD_LOCI \
	 	-sf $SOFTFIL -c $CPU_TO_USE -sp $SPECIES -as $ASSEMBLY && date > pindel.out

