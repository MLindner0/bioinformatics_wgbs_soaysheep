### -------------- overview

## Short R script to get Read Group (RG) Information from file name & location
## and export RG Information to .csv file

## samples were sequenced in three runs
## RG .csv is used within the nextflow pipelines to add RG to the three alignments per sample (one alignment per sequencing run)
## afterwards, the three alignmnets are merged for each samples (resulting in one alignment per sample)



### -------------- set-up env and load required packages

library(stringr)
reads <- "/users/bi1ml/public/methylated_soay/soay_wgbs_full_data_set_sep2024/raw_data_trimmed"
