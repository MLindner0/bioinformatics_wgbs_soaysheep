### -------------- overview

## Short R script to get Read Group (RG) information from file name & location
## and export RG information to .csv file

## samples were sequenced in three runs
## RG .csv is used within the nextflow pipelines to add RG to the three alignments per sample (one alignment per sequencing run)
## afterwards, the three alignmnets are merged for each samples (resulting in one alignment per sample)


### -------------- notes
## on Stanage, load R module: module load R/4.0.5-foss-2020b
## make sure stringr R package is installed
## otherwiese, install: install.packages("stringr")


### -------------- set-up env and load required packages

library(stringr)
reads <- "/users/bi1ml/public/methylated_soay/soay_wgbs_full_data_set_sep2024/raw_data_trimmed"
pipeline_data <- "/users/bi1ml/pipelines/next_wgbs/data"


### -------------- load & format RG information

filenames <- list.files(path=reads, pattern = "*R1.fastq.gz$") 
    # only R1

# set up loop to get data from file names:
filenamedata <- NULL
for(f in 1:length(filenames)) {
  elements <- str_split_fixed(filenames[f],"_",4)
    # split filename into elements (separated by "_")


}
