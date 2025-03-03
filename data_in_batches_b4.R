
###--- R script 
###--- PROJECT: 1,000 Soay sheep methylomes (main data) 
###---
###--- AIM: Create .csv files for nextflow pipeline (sample location & readgroup information) 
###--- Pipeline Github rep: https://github.com/MLindner0/bioinformatics_wgbs_soaysheep
###---
###--- Author: M Lindner (m.lindner@sheffield.ac.uk) 
###---


###--- OVERVIEW
###---
#
# short R script to
# (1) divide samples (.fatsq.gz files) into "pipeline-batches" for bioinformatic processing (40 samples per pipeline-batch as well as an intial test batch of 10 samples)
# (2) export .csv files with file refs (used in pipeline) and respective file locations on STANAGE
# (3) export .csv files with Read Group (RG) information 
#   these .csv files will be used as input in the nextflow pipeline


###--- NOTES
###---
#
# samples were sequenced in three batches (sequencing batches)
# samples within the first sequencing batch (batch1), were sequenced in 3 runs
# samples within the second and third sequencing batch, were either sequenced in 2, 3 or 4 runs
# hence samples within the second and third sequencing batch were redistributed into new batches
#   - batch2: samples sequenced in 2 runs
#   - batch3: samples sequenced in 3 runs
#   - batch4: samples sequenced in 4 runs

# to run R on STANAGE;
# load R module: module load R/4.0.5-foss-2020b
# make sure R package stringr is installed
#   otherwiese, install R package stringr: install.packages("stringr")


###--- Prepare environment 
###---

## load libraries
library(stringr)
pipeline_path_main <- "/users/bi1ml/pipelines/fourth_batch_batches"

### -------------- load & format read pairs & RG information

filepaths <- read.table("/users/bi1ml/check/wgbs_main/read_files_as_processed.txt")$V9
# filepaths_original <- read.table("/users/bi1ml/check/wgbs_main/read_files_as_processed.txt")$V11

new_path <- "/mnt/parscratch/users/bip23lrb/public/methylated_soay/soay_wgbs_main_sep2024/data_fourth_batch"
  # note, as it is not possible to access the /shared are from a working node, we need to get the file names and paths from a file

Seq.Batch <- filepaths[grepl("batch4/", filepaths)]
# Seq.Batch_original <- filepaths_original[grepl("batch4/", filepaths)]

R1 <- Seq.Batch[grepl("*R1.fastq.gz$", Seq.Batch)]
R2 <- Seq.Batch[grepl("*R2.fastq.gz$", Seq.Batch)]

# R1_original <- Seq.Batch_original[grepl("*R1.fastq.gz$", Seq.Batch)]
  # get R1 and R2 file paths

filenames.R1 <- str_split_fixed(R1,"/",9)[,9]
filenames.R2 <- str_split_fixed(R2,"/",9)[,9]
  # get R1 and R2 file names

index <- 1:length(filenames.R1)

# set up loop to get data from file names:
filenamedata <- NULL
rename <- NULL
rename_test <- NULL

for(f in 1:length(filenames.R1)) {
  elements <- str_split_fixed(filenames.R1[f],"_",6)
  elements.R2 <- str_split_fixed(filenames.R2[f],"_",6)
  # split filename into elements (separated by "_")
  
  nextflow_id <- paste(elements[,1], elements[,3], elements[,5], index[f], sep="_")
  new_filenames.R1 <- paste(nextflow_id, elements[,6], sep="_")
  new_filenames.R2 <- paste(nextflow_id, elements.R2[,6], sep="_")
  # get nextflow id and new filename
  
  if(elements[,1]==elements.R2[,1] & elements[,5]==elements.R2[,5]) temp <- data.frame(nextflow_id=nextflow_id, sample_ref=elements[,1], adapter_seq=elements[,3], lane=elements[,5], file_R1=paste(new_path, new_filenames.R1, sep="/"), file_R2=paste(new_path, new_filenames.R2, sep="/"), batch=elements[,4])
  # combine elements into data frame row
  # note, batch info included in filename and added here rather than after loop
  
  filenamedata <- rbind(filenamedata, temp)
  # add row to output data frame
  
  # get files to rename data (including test data)
  temp_rename <- data.frame(old=c(paste(new_path, filenames.R1[f], sep="/"), paste(new_path, filenames.R2[f], sep="/")), new=c(paste(new_path, new_filenames.R1, sep="/"), paste(new_path, new_filenames.R2, sep="/")))
  rename <- rbind(rename, temp_rename)
  
  temp_rename_test <- data.frame(old=c(paste("/users/bi1ml/test/rename/files", filenames.R1[f], sep="/"), paste("/users/bi1ml/test/rename/files", filenames.R2[f], sep="/")), new=c(paste("/users/bi1ml/test/rename/files", new_filenames.R1, sep="/"), paste("/users/bi1ml/test/rename/files", new_filenames.R2, sep="/")))
  rename_test <- rbind(rename_test, temp_rename_test)
}

# divide data into data frame for read pairs (1) & read group information (2)
read_pairs <- filenamedata[,c("nextflow_id", "file_R1", "file_R2")]
read_group_info <- filenamedata[,c("nextflow_id", "sample_ref", "adapter_seq", "lane", "batch")]


### -------------- divide read pairs into batches & export .csv files

# create & export batch of 40 samples

batch <- 1:8
start <- seq(1,1121,160)
end <- c(start[1:7]+159,nrow(read_pairs))

for(i in 1:length(batch)) {
  write.csv(read_pairs[start[i]:end[i],], paste(pipeline_path_main, paste("read_pairs_b3", batch[i], "csv", sep="."), sep="/"), row.names=FALSE, quote=FALSE)
  write.csv(read_group_info[start[i]:end[i],], paste(pipeline_path_main, paste("read_group_info_b3", batch[i], "csv", sep="."), sep="/"), row.names=FALSE, quote=FALSE)
  
}

# export rename file
write.table(rename, paste(pipeline_path_main, "rename_b4.txt", sep="/"), row.names=FALSE, col.names=FALSE, quote=FALSE, sep="\t")
write.table(rename_test, "/users/bi1ml/test/rename/rename_b4.txt", row.names=FALSE, col.names=FALSE, quote=FALSE, sep="\t")

