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

### `downstream/`
Post-variant-calling analyses applied to colony data. Includes:
- Variant annotation
- Mutational signature analysis
- Plotting scripts for figures

### `nanoseq/`
NanoSeq pipeline scripts, developed by the Cagan Lab (https://github.com/AlexTJCagan). This folder contains its own `README` with usage instructions specific to the pipeline. 

### `variant_callers_colony_data/`
Example scripts demonstrating how to run each variant caller evaluated in the study (colony data). 

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

Scripts are written in R and Bash. Specific package requirements are noted within each script or subdirectory README where applicable.

---

