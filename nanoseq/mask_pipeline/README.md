# Mouse-specific SNP and noise mask generation

## Overview

A genomic mask was generated from matched normal (tail) DNA samples to exclude
germline SNPs and recurrent noise sites from NanoSeq somatic variant calling.
The pipeline was developed by Adrian Baez-Ortega (Cagan Lab, University of Cambridge)
and comprises four sequential steps.

## Input

A tab-delimited file with no header and four columns:

| Column | Description |
|--------|-------------|
| species | Species name (used to name output directories) |
| sample CSV | Path to NanoSeq sample sheet CSV |
| reference FASTA | Path to reference genome FASTA |
| NanoSeq working directory | Path to NanoSeq Nextflow output directory |

## Pipeline steps

### Step 1 — Coverage profiling (`1_CoverageHist.sh`)
Runs `bedtools genomecov` on each matched normal CRAM file to produce a
per-sample coverage histogram (`<sample>.covhist.txt`).

### Step 2 — Variant calling (`2_VariantCalling.sh`)
Calls all variant sites in each matched normal CRAM using `bcftools mpileup`,
producing a per-sample pileup VCF (`<sample>.pileup.vcf.gz`).
Can be run in parallel with Step 1.

### Step 3 — Mask building (`3_bsub_command.sh` → `3_MaskBuilding.R`)
Submits one R job per chromosome. For each sample and chromosome, identifies:
- **SNP sites**: 1-bp substitutions with NR ≥ 10, NR ≤ 98th coverage percentile,
  NV ≥ 3, VAF ≥ 0.2
- **Noise sites**: variants with NV ≥ 2 and VAF ≥ 0.01, OR variants with NV ≥ 1
  and VAF ≥ 0.01 seen in ≥ 2 samples

SNP sites are a subset of noise sites. The combined noise mask is written as a
per-chromosome BED file.

> For reference genomes with large numbers of contigs, use
> `3_bsub_command_with_contig_merger.sh` instead, which batches 50 contigs per job.

### Step 4 — Mask merging (`4_MaskMerging.sh`)
Concatenates, sorts, and merges all per-chromosome BED files using `bedtools merge`.
Produces a single indexed `SNP+NOISE.<species>.bed.gz` file ready for use as the
`--noise_bed` parameter in the NanoSeq pipeline.

## Usage

Should be run from the NanoSeq working directory (or a directory with the same
subdirectory structure).

```bash
INPUT=/path/to/SPECIES_INFO.txt
WORKDIR=/path/to/nanoseq/working/directory

cd $WORKDIR

# Step 1: Coverage profiling
bash nanoseq/mask_pipeline/1_CoverageHist.sh $INPUT

# Step 2: Variant calling (can run in parallel with Step 1)
bash nanoseq/mask_pipeline/2_VariantCalling.sh $INPUT

# Step 3: Mask building (run after Steps 1 and 2 complete)
bash nanoseq/mask_pipeline/3_bsub_command.sh $INPUT

# Step 4: Merge mask files (run after Step 3 completes)
bash nanoseq/mask_pipeline/4_MaskMerging.sh $INPUT
```

## Dependencies

| Tool | Version |
|------|---------|
| bedtools | 2.29.0 |
| bcftools | 1.9 |
| bgzip / tabix | — |
| R | ≥ 4.0 |
| R packages | stringr, Biostrings, GenomicRanges |

## Output

`output/MASKS/SNP+NOISE.NV2.SeenNV1.<species>.bed.gz` — final merged mask file  
`output/MASKS/SNP+NOISE.NV2.SeenNV1.<species>.bed.gz.tbi` — tabix index

## Notes

- Steps 1 and 2 can be run simultaneously
- Step 3 submits one LSF job per chromosome 
- Step 4 must not be launched until all Step 3 jobs are complete
