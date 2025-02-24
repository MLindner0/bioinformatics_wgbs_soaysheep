
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
pipeline_path_main <- "/users/bi1ml/pipelines/third_batch_batches"

### -------------- load & format read pairs & RG information

filepaths <- read.table("/users/bi1ml/check/wgbs_main/read_files_as_processed.txt")$V9
filepaths_original <- read.table("/users/bi1ml/check/wgbs_main/read_files_as_processed.txt")$V11

new_path <- "/mnt/parscratch/users/bo1jxs/public/methylated_soay/soay_wgbs_main_sep2024/data_third_batch"
  # note, as it is not possible to access the /shared are from a working node, we need to get the file names and paths from a file

Seq.Batch <- filepaths[grepl("batch3/", filepaths)]
Seq.Batch_original <- filepaths_original[grepl("batch3/", filepaths)]

R1 <- Seq.Batch[grepl("*R1.fastq.gz$", Seq.Batch)]
R2 <- Seq.Batch[grepl("*R2.fastq.gz$", Seq.Batch)]

R1_original <- Seq.Batch_original[grepl("*R1.fastq.gz$", Seq.Batch)]
  # get R1 and R2 file paths

filenames.R1 <- str_split_fixed(R1,"/",9)[,9]
filenames.R2 <- str_split_fixed(R2,"/",9)[,9]
  # get R1 and R2 file names

index <- 1:length(filenames.R1)

# set up loop to get data from file names:
filenamedata <- NULL
for(f in 1:length(filenames.R1)) {
  elements <- str_split_fixed(filenames.R1[f],"_",5)
  elements.R2 <- str_split_fixed(filenames.R2[f],"_",5)
  # split filename into elements (separated by "_")
  
  if(elements[,1]==elements.R2[,1] & elements[,4]==elements.R2[,4]) temp <- data.frame(nextflow_id=paste(elements[,1], elements[,3], elements[,4], index[f], sep="_"), sample_ref=elements[,1], adapter_seq=elements[,3], lane=elements[,4], file_R1=paste(new_path, filenames.R1[f], sep="/"), file_R2=paste(new_path, filenames.R2[f], sep="/"))
  # combine elements into data frame row
  
  filenamedata <- rbind(filenamedata, temp)
  # add row to output data frame
}

# add batch info
# first get data on batch from original file location
batch.temp <- str_split_fixed(R1_original, "/", 10) 
batch.batch <- batch.temp[,7]
table(batch.batch)
  # only batch 2 and 3
batch.batch_long <- ifelse(batch.batch=="batch2", "second-batch", "third-batch")

batch.filename <- batch.batch <- batch.temp[,10]
batch.sample <- str_split_fixed(batch.filename, "_", 5)[,1] 
batch.lane <- str_split_fixed(batch.filename, "_", 5)[,4] 

batch.help <- data.frame(sample_ref=batch.sample, lane=batch.lane, batch=batch.batch_long)

# now check whether order is ok and add batch info to data
  # note, all samples were sequenced on one batch (either 2 or 3) 
if(unique(filenamedata$sample_ref==batch.help$sample_ref) & unique(filenamedata$lane==batch.help$lane)) filenamedata$batch <- batch.help$batch

# divide data into data frame for read pairs (1) & read group information (2)
read_pairs <- filenamedata[,c("nextflow_id", "file_R1", "file_R2")]
read_group_info <- filenamedata[,c("nextflow_id", "sample_ref", "adapter_seq", "lane", "batch")]


### -------------- divide read pairs into batches & export .csv files

# first, make a test batch of 10 samples

batch <- 1:10
start <- seq(1,1081,120)
end <- c(start[1:9]+119,nrow(read_pairs))

for(i in 1:length(batch)) {
  write.csv(read_pairs[start[i]:end[i],], paste(pipeline_path_main, paste("read_pairs_b3", batch[i], "csv", sep="."), sep="/"), row.names=FALSE, quote=FALSE)
  write.csv(read_group_info[start[i]:end[i],], paste(pipeline_path_main, paste("read_group_info_b3", batch[i], "csv", sep="."), sep="/"), row.names=FALSE, quote=FALSE)
  
}
