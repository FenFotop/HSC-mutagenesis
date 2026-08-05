# HSC-mutagenesis

This repository contains code and data accompanying the manuscript: \
Fotopoulou, F. et al. *Dormancy, not apoptosis, restricts hematopoietic stem cell mutagenesis during aging.* bioRxiv https://doi.org/10.64898/2026.05.09.724021 **(2026)**.


---

## Overview

This repository contains the bioinformatic code used to analyse somatic mutation 
acquisition in murine long-term haematopoietic stem cells (LT-HSCs). It covers 
two sequencing approaches:
- Whole-genome sequencing (WGS) of *in vitro* expanded single LT-HSC colonies 
- NanoSeq duplex sequencing of LT-HSC mini-bulks

---

## Repository Structure

```
.
├── benchmarking/
├── downstream/
├── nanoseq/
├── variant_callers_colony_data/
└── [data tables]
```

---

## Folders

### `benchmarking/`
Scripts used to evaluate the effect of sequencing coverage on variant detection. BAM files from a deeply sequenced colony and matching tail were downsampled to increments of 10X to identify the optimal coverage threshold for the study. Example script is provided: `downsampling_bam_example.sh`. The `.Rmd` in this folder assesses overlap between call sets at each coverage level and produces the corresponding visualizations. 
**Requirements:**
- Picard v1.61 (`downsampling_bam_example.sh`)
- Computing resources for a run in the DKFZ HPC (LSF) are specified inside `downsampling_bam_example.sh`
- R 4.3.0, with packages: dplyr 1.2.1, ggplot2 3.4.2, mgcv 1.8-42 (bundled with R 4.3.0), purrr 1.0.1, multcompView 0.1-9 (`benchmarking-analysis.Rmd`)



### `downstream/`
Post-variant-calling analyses applied to colony data. Includes:
- Variant annotation
- Mutational signature analysis
- Plotting scripts for figures

**Requirements:**
- R 4.3.0
- CRAN packages: ggplot2, ggpubr, tidyr, ggbreak, stringr, dplyr, rstatix, vcfR, export, tidyverse, viridis, ggsci, splitstackshape, readxl, patchwork, cowplot, ggrain, gridExtra, wesanderson, colorspace; versions pinned to the CRAN snapshot matching R 4.3.0's release (2023-04-21), via https://packagemanager.posit.co/cran/2023-04-21
- Bioconductor packages: MutationalPatterns, BSgenome, GenomicRanges, ComplexHeatmap; Bioconductor 3.17 (`BiocManager::install(version = "3.17")`)
- VEP 102.0, bcftools 1.9 (loaded as environment modules on an LSF cluster)
- Computing resources for VEP annotation step are specified inside `example_run_VEP.sh` 


### `nanoseq/`
NanoSeq pipeline scripts, developed by the Cagan Lab (https://github.com/AlexTJCagan). This folder contains its own `README` with usage instructions specific to the pipeline. 

### `variant_callers_colony_data/`
Example scripts demonstrating how to run each variant caller evaluated in the study (colony data). Computing resources and module versions are specified inside each script, based on the LSF HPC environment used to run them.

---

## Data Files

| File | Description |
|------|-------------|
| `SNV_trinucl_matrix_per_cell_all_c...` | Trinucleotide substitution matrix, one column per cell (colony data) |
| `SNV_trinucl_matrix_per_mouse_a...` | Trinucleotide substitution matrix, aggregated per mouse (colony data) |
| `Signature_matrix_colony_global_...` | Global matrix including SNV counts, signature contributions, and signature-specific burdens (colony data) |
| `all_variant_annotation_all_colony...` | Full variant annotation table across all colonies |
| `caveman_counts_per_sample.csv` | Per-sample SNV counts from CaVEMan (colony data) |
| `pindel_counts_per_sample.csv` | Per-sample indel counts from Pindel (colony data) |
| `nanoseq_snv_calls.csv` | SNV calls from NanoSeq analysis |
| `ref_SBS_signatures_incl_hspc.txt` | Reference SBS signature file used for signature fitting, provided by Lucca Derks / Ruben van Boxtel lab  |

---

## Dependencies

Scripts are written in R (4.3.0) and Bash. Package versions and, where applicable, HPC module versions and compute resources are specified within each subdirectory's section above or in the relevant script/README.

---

