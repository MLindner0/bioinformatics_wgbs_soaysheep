### -------------- overview

## Short R script to (1) divide read pairs into batches for bioinformatic processing  (bioinformatics batches), (2) get Read Group (RG) information for respective read pairs in the respective bioinformatics batch from file name & location & (3) export both to .csv files

## samples were sequenced in three batches (sequencing batches) and samples were sequenced in three runs 
## RG .csv is used within the nextflow pipelines to add RG to the three alignments per sample (one alignment per sequencing run)
## afterwards, the three alignmnets are merged for each samples (resulting in one alignment per sample) while retaining information on the three sample runs via read groups


### -------------- notes
## on Stanage, load R module: module load R/4.0.5-foss-2020b
## make sure stringr R package is installed
## otherwiese, install: install.packages("stringr")


### -------------- set-up env and load required packages

library(stringr)
reads <- "/users/bi1ml/public/methylated_soay/soay_wgbs_main_sep2024/data_first_batch"
pipeline_path_main <- "/users/bi1ml/pipelines/first_batch_batches"


### -------------- load & format read pairs & RG information

filenames.R1 <- list.files(path=reads, pattern = "*R1.fastq.gz$") 
filenames.R2 <- list.files(path=reads, pattern = "*R2.fastq.gz$") 


# set up loop to get data from file names:
filenamedata <- NULL
for(f in 1:length(filenames.R1)) {
  elements <- str_split_fixed(filenames.R1[f],"_",4)
  elements.R2 <- str_split_fixed(filenames.R2[f],"_",4)
    # split filename into elements (separated by "_")

  if(elements[,1]==elements.R2[,1] & elements[,3]==elements.R2[,3]) temp <- data.frame(nextflow_id=paste(elements[,1], elements[,2], elements[,3], sep="_"), sample_ref=elements[,1], adapter_seq=elements[,2], lane=elements[,3], file_R1=paste(reads, filenames.R1[f], sep="/"), file_R2=paste(reads, filenames.R2[f], sep="/"))
    # combine elemnts into data frame row

  filenamedata <- rbind(filenamedata, temp)
    # add row to output data frame
}

filenamedata$batch <- "first-batch"
    # add batch info


# divide data into data frame for read pairs (1) & read group information (2)
read_pairs <- filenamedata[,c("nextflow_id", "file_R1", "file_R2")]
read_group_info <- filenamedata[,c("nextflow_id", "sample_ref", "adapter_seq", "lane", "batch")]


### -------------- devide read pairs into batches & export .csv files

# first, make a test batch of 10 samples

batch <- "1"

write.csv(read_pairs[1:3,], paste(pipeline_path_main, paste("read_pairs_b1", batch, "csv", sep="."), sep="/"), row.names=FALSE, quote=FALSE)
write.csv(read_group_info[1:3,], paste(pipeline_path_main, paste("read_group_info_b1", batch, "csv", sep="."), sep="/"), row.names=FALSE, quote=FALSE)


