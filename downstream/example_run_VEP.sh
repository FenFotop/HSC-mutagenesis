#!/bin/bash

#BSUB -J variant_annotation
#BSUB -o /logs/VEP.out
#BSUB -e /logs/VEP.err
#BSUB -W 02:00
#BSUB -n 2
#BSUB -R "span[hosts=1] select[mem>10000] rusage[mem=10000]" -M 10000
#BSUB -N
#BSUB -B

module load vep/102.0
module load bcftools/1.9

# Directories and tools
VCF_DIR="/.../filtered_vcfs_to_merge"
OUT_DIR="/.../VEP_final_results"
MERGED_DIR="/.../final_merged_vcfs_per_sample"
VEP="/path/to/software/vep/102.0/vep"
FASTA="/.../Mus_musculus.GRCm38.dna.primary_assembly.fa.gz"

# Step 1: Merge SNV, Indel, and SV vcf files per sample (= colony)
readarray -t filtered_snv_files < <(find ${VCF_DIR}/SNVs/ | grep "vcf\.gz$")

for snvs in "${filtered_snv_files[@]}"; do
  # Extract sample name
  name=$(echo $snvs | grep -oP "(?<=\/SNVs\/).*(?=_filtered_snvs\.vcf\.gz$)")

  # Find corresponding indels and SVs if they exist
  indels=""
  structural=""
  [[ -f "${VCF_DIR}/Indels/${name}_filtered.vcf.gz" ]] && indels="${VCF_DIR}/Indels/${name}_filtered.vcf.gz"
  [[ -f "${VCF_DIR}/SVs/${name}.filtered.vcf.gz" ]] && structural="${VCF_DIR}/SVs/${name}.filtered.vcf.gz"

  # Document matches
  echo $snvs
  echo $indels
  echo $structural
  echo "-----------------------"

  # Concatenate files and remove duplicates (by position)
  bcftools concat --allow-overlaps --rm-dups all \
    --output ${OUT_DIR}/${name}_filtered_all.vcf.gz -O z \
    $snvs $indels $structural
done

# Step 2: Run VEP annotation on merged files
# NOTE: --format vcf is required for empty VCFs and BND structural variants
# BND variants are annotated incorrectly -->filter out afterwards
readarray -t concat_vcf_files < <(find ${OUT_DIR}/ | grep "vcf\.gz$")

for vcf in "${concat_vcf_files[@]}"; do
  file_name=$(echo $vcf | grep -oP "(?<=\/final_merged_vcfs_per_sample\/).*(?=_filtered)")

  $VEP -i $vcf -o ${OUT_DIR}/${file_name}_variant_effects.txt \
    --species "mus_musculus" --flag_pick \
    --offline --sift b --ccds --hgvs --symbol --numbers --domains \
    --regulatory --canonical --protein --biotype --af --pubmed \
    --uniprot --variant_class --gene_phenotype --mirna \
    --fasta $FASTA --format vcf --tab --max_sv_size 150000
done
