#!/bin/bash

STAGEPATH=$1
NEXTFLOWPATH=$2
PIPBATCH=$3

# before a new batch is processed, files musst be moved from staged to the shared area. This has to be executed on a login node (and thus cannot be part of the pipeline) as the shared are is not accessible from working nodes on STANAGE.

# 1. move staged files to shared area

cd ${STAGEPATH}
#   go to stage directory

# 1.1 move alignment files and reports:
cp align_[0-9]*/*.bam /shared/slate_group_archive/Shared/methylated_soay/soay_wgbs_pilot_mar2023/nextflow_pipeline/alignment/
cp align_[0-9]*/*.txt /shared/slate_group1/Shared/methylated_soay/soay_wgbs_pilot_mar2023/nextflow_pipeline/alignment/

# 1.2 move alignment stats & bs conversion
cp align_stats_[0-9]*/*.txt /shared/slate_group1/Shared/methylated_soay/soay_wgbs_pilot_mar2023/nextflow_pipeline/alignment_stats/
cp  breadth_[0-9]*/*.txt /shared/slate_group1/Shared/methylated_soay/soay_wgbs_pilot_mar2023/nextflow_pipeline/alignment_stats/
cp bs_conversion_[0-9]*/*.txt /shared/slate_group1/Shared/methylated_soay/soay_wgbs_pilot_mar2023/nextflow_pipeline/alignment_stats/
cp depth_[0-9]*/*.txt /shared/slate_group1/Shared/methylated_soay/soay_wgbs_pilot_mar2023/nextflow_pipeline/alignment_stats/

# 1.3 methylation calls & new mbias
cp meth_[0-9]*/*.cov.gz /shared/slate_group1/Shared/methylated_soay/soay_wgbs_pilot_mar2023/nextflow_pipeline/methylation/
cp meth_[0-9]*/*.txt /shared/slate_group1/Shared/methylated_soay/soay_wgbs_pilot_mar2023/nextflow_pipeline/methylation/

# 1.4 multiqc
# report (.html)
cp multiqc_data_b[0-9]*/*.html /shared/slate_group1/Shared/methylated_soay/soay_wgbs_pilot_mar2023/nextflow_pipeline/qc/

# data (.txt)
# data will be added to existing file

# raw:
awk 'NR > 1 { print }' multiqc_data_b[0-9]*/multiqc_report_b[0-9]*/multiqc_fastqc.txt | grep 'fastq.gz' >> /shared/slate_group1/Shared/methylated_soay/soay_wgbs_pilot_mar2023/nextflow_pipeline/qc/multiqc_fastqc_RAW.txt

# trimmed:
awk 'NR > 1 { print }' multiqc_data_b[0-9]*/multiqc_report_b[0-9]*/multiqc_fastqc.txt | grep 'val' >> /shared/slate_group1/Shared/methylated_soay/soay_wgbs_pilot_mar2023/nextflow_pipeline/qc/multiqc_fastqc_TRIMMED.txt

# keep a copy of original file
cp multiqc_data_b[0-9]*/multiqc_report_b[0-9].[0-9]_data/* /shared/slate_group1/Shared/methylated_soay/soay_wgbs_pilot_mar2023/nextflow_pipeline/qc/temp/multiqc_fastqc_${PIPBATCH}.txt

# 1.5 telseq
cp telseq_[0-9]*/*.out /shared/slate_group1/Shared/methylated_soay/soay_wgbs_pilot_mar2023/nextflow_pipeline/telomere/

# 1.6 log files 
cd ${NEXTFLOWPATH}
cp submission_logs/slurm_*${PIPBATCH}.log  /shared/slate_group1/Shared/methylated_soay/soay_wgbs_pilot_mar2023/nextflow_pipeline/logs/

