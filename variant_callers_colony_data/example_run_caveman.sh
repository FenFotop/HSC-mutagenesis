#!/bin/bash 

#BSUB -J 
#BSUB -o /logs/caveman_run.out
#BSUB -e /logs/caveman_run.err
#BSUB -W 80:00
#BSUB -n 16
#BSUB -R "span[hosts=1] select[mem>60000] rusage[mem=60000]" -M 60000
#BSUB -N 
#BSUB -B

SIMG_CAVEMAN=/.../cgpcavemanwrapper_1.16.0.sif

OUTDIR=""
REF_INDEX="/.../GRCm38mm10.fa.fai"
TUMOUR_BAM="/.../colony.bam"
NORMAL_BAM="/.../tail.bam"

#ignore repetitive regions of the mouse genome 
# origin: Wellcome Sanger
IGNORE_FILE="/.../genome.gap_v3.tab"

# empty files
TUMOUR_CN="/.../fake_HSC-cn.txt"
NORMAL_CN="/.../fake_normal-cn.txt"

SPECIES="Mouse"
SPECIES_ASSEMBLY="GRCm38mm10"

# Centromeric repeats and simple repeats (files from USCS) for flagging
FLAGGING_BED_DIR="/.../flagging/"

# empty Pindel results, not used as input
GERMLINE_INDEL="/.../empty.pindel.germline.bed.gz"

# unmatched normal
# origin: Wellcome Sanger
UNM_NORMAL_VCF_DIR="/.../unmatched_v2/"

SEQ_TYPE="genome"

# default values
NORMAL_CONTAMINATION=0.10
NORMAL_PROTOCOL="WGS"
TUMOUR_PROTOCOL="WGS"
TUMOUR_CN_DEF=5
NORMAL_CN_DEF=2
PRIOR_PROB_MUT=0.000006
PRIOR_PROB_SNP=0.0001

# flags to use in mouse WGS experiments
CONFIG_INI_FLAG="/.../flag.vcf.config.ini"
CONFIG_INI_VCF="/.../flag.to.vcf.convert.ini"

# Run
LSF_THREADS_SETUP=$LSB_DJOB_NUMPROC


set +e
singularity exec --cleanenv --workdir $OUTDIR --pwd $OUTDIR --home $OUTDIR $SIMG_CAVEMAN \
		caveman.pl -o $OUTDIR -r $REF_INDEX -tb $TUMOUR_BAM -nb $NORMAL_BAM -ig $IGNORE_FILE \
                -tc $TUMOUR_CN -nc $NORMAL_CN -s $SPECIES -sa $SPECIES_ASSEMBLY \
                -b $FLAGGING_BED_DIR -u $UNM_NORMAL_VCF_DIR -st $SEQ_TYPE -in $GERMLINE_INDEL \
                -k $NORMAL_CONTAMINATION -t $LSF_THREADS_SETUP -np $NORMAL_PROTOCOL -tp $TUMOUR_PROTOCOL  \
                -c $CONFIG_INI_FLAG -f $CONFIG_INI_VCF -td $TUMOUR_CN_DEF -nd $NORMAL_CN_DEF \
                -pm $PRIOR_PROB_MUT -ps $PRIOR_PROB_SNP  && date > cave.out

                                                                                                  
