
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
# for the pilot data set, all samples were sequenced in three batches (sequencing batches)

# to run R on BESSEMER;
# load R module: module load R/4.0.0-foss-2020a
# make sure R package stringr is installed
#   otherwiese, install R package stringr: install.packages("stringr")


###--- Prepare environment 
###---

## load libraries
library(stringr)
pipeline_path_main <- "/home/bi1ml/pipelines/pilot_batches"

### -------------- load & format read pairs & RG information

filepaths <- read.table("/home/bi1ml/check/wgbs_pilot/read_files_as_processed.txt")$V9
filepaths_original <- read.table("/home/bi1ml/check/wgbs_pilot/read_files_as_processed.txt")$V11

# new_path <- "/mnt/parscratch/users/bo1jxs/public/methylated_soay/soay_wgbs_main_sep2024/data_third_batch"
  # note, as it is not possible to access the /shared are from a working node, we need to get the file names and paths from a file

R1 <- filepaths[grepl("*R1.fastq.gz$", filepaths)]
R2 <- filepaths[grepl("*R2.fastq.gz$", filepaths)]

R1_original <- filepaths_original[grepl("*R1.fastq.gz$", filepaths_original)]
R2_original <- filepaths_original[grepl("*R2.fastq.gz$", filepaths_original)]
  # get R1 and R2 file paths

filenames.R1 <- str_split_fixed(R1,"/",8)[,8]
filenames.R2 <- str_split_fixed(R2,"/",8)[,8]
filenames_original.R1 <- str_split_fixed(R1_original,"/",8)[,8]
filenames_original.R2 <- str_split_fixed(R2_original,"/",8)[,8]
  # get R1 and R2 file names

#index <- 1:length(filenames.R1)

# set up loop to get data from file names:
filenamedata <- NULL

for(f in 1:length(filenames.R1)) {
  elements <- str_split_fixed(filenames.R1[f],"_",3)
  elements.R2 <- str_split_fixed(filenames.R2[f],"_",3)
  elements_O <- str_split_fixed(filenames_original.R1[f],"_",5)
  elements_O.R2 <- str_split_fixed(filenames_original.R2[f],"_",5)
  # split filename into elements (separated by "_")
  
  nextflow_id <- paste(elements[,1], elements[,2], sep="_")
  #new_filenames.R1 <- paste(nextflow_id, elements[,5], sep="_")
  #new_filenames.R2 <- paste(nextflow_id, elements.R2[,5], sep="_")
  # get nextflow id
  
  if(elements_O[,1]==elements_O.R2[,1] & elements_O[,4]==elements_O.R2[,4]) temp <- data.frame(nextflow_id=nextflow_id, sample_ref=elements_O[,1], adapter_seq=NA, lane=paste(elements_O[,3], elements_O[,4], sep="_"), batch="pilot", file_R1=R1[f], file_R2=R2[f])
  # combine elements into data frame row
  
  filenamedata <- rbind(filenamedata, temp)
  # add row to output data frame
}

# divide data into data frame for read pairs (1) & read group information (2)
read_pairs <- filenamedata[,c("nextflow_id", "file_R1", "file_R2")]
read_group_info <- filenamedata[,c("nextflow_id", "sample_ref", "adapter_seq", "lane", "batch")]


### -------------- divide read pairs into batches & export .csv files

# create & export batch of 40 samples

batch <- 1:6
start <- seq(1,672,120)
end <- c(start[1:5]+119,nrow(read_pairs))

for(i in 1:length(batch)) {
  write.csv(read_pairs[start[i]:end[i],], paste(pipeline_path_main, paste("read_pairs_pilot", batch[i], "csv", sep="."), sep="/"), row.names=FALSE, quote=FALSE)
  write.csv(read_group_info[start[i]:end[i],], paste(pipeline_path_main, paste("read_group_info_pilot", batch[i], "csv", sep="."), sep="/"), row.names=FALSE, quote=FALSE)
  
}




