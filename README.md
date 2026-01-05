# GATK4 Variant Analysis Workflow

This repository contains scripts to get familiar with the genomic variant analysis workflow using GATK4. It includes two projects:

1. **Tutorial Reproduction**:  
   A reproduction of the GATK4 tutorial from [kpatel427](https://github.com/kpatel427), with slightly adapted shell scripts and the same sample (SRR062634) used in the original tutorial.

2. **Snakemake Adaptation**:  
   A Snakemake pipeline for a different sample (SRR099960), including a step to spike in a known pathogenic variant (PTPN4_Q180Ter_chr2). This creates both an original and a spiked sample for validation.

---

## Goal

To demonstrate proficiency in:
- Reproducing and adapting a GATK4 best practices pipeline
- Building a reproducible Snakemake workflow for variant calling
- Spiking in known variants to validate detection
- Generating QC metrics and annotation (Funcotator)

---
