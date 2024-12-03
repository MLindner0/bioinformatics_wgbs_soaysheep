
### -------------- overview

## Short R script to evaluate methylation bias at the start and end of reads (R1 & R2) based on bismark methylation calling
## This will be used to update the methylation calling prpocess and mask the first x and last x bases of the respective read from methylation calling
## only CpG site methylation is assessed as methylation in other contexts is not considered


### -------------- notes
## on Stanage, load R module: module load R/4.0.5-foss-2020b
## make sure stringr R package is installed
## otherwiese, install: install.packages("stringr")

# on Stanage: format m-bias txt files (bismark methylation calling output) 
# cd /mnt/parscratch/users/bi1ml/public/methylated_soay/soay_wgbs_main_sep2024/nextflow_pipeline/temp/mbias_test
# for f in *M-bias.txt; do cat $f | grep -A 153 "CpG context (R1)" > R1/$f; done
# for f in *M-bias.txt; do cat $f | grep -A 152 "CpG context (R2)" > R2/$f; done


### -------------- set-up env and load required packages
setwd("/mnt/parscratch/users/bi1ml/public/methylated_soay/soay_wgbs_main_sep2024/nextflow_pipeline/temp")
library(stringr)

### -------------- load & format read pairs & RG information
## R1:
FileLocation <- "mbias_test/R1"
FileNames <- list.files(path = FileLocation, pattern = "*.txt")
dat.R1 <- lapply(paste(FileLocation, FileNames, sep="/"), function(x) read.table(x, sep="\t", header=TRUE, skip=2))

sample.names <- str_split_fixed(FileNames, "\\.", 2)[,1]
names(dat.R1) <- sample.names

## R2:
FileLocation <- "mbias_test/R2"
FileNames <- list.files(path = FileLocation, pattern = "*.txt")
dat.R2 <- lapply(paste(FileLocation, FileNames, sep="/"), function(x) read.table(x, sep="\t", header=TRUE, skip=2))

sample.names <- str_split_fixed(FileNames, "\\.", 2)[,1]
names(dat.R2) <- sample.names


### -------------- make m-bias plots

# max coverage?
lapply(dat.R1, function(x) max(x$coverage))[which.max(lapply(dat.R1, function(x) max(x$coverage)))]
lapply(dat.R2, function(x) max(x$coverage))[which.max(lapply(dat.R2, function(x) max(x$coverage)))]
max <- 2069972

## R1
pdf(file = "mbias_test/plots/M-bias.R1.pdf", width = 10, height = 4)

for(i in 1:length(dat.R1)) {
  dat <- dat.R1[[i]]
  
  # build base plot
  par(mfrow=c(1,1), mar = c(4,4,2,4), mgp=c(2, 0.5, 0))
  plot(NULL, xaxt="n", yaxt="n", xlim=c(0,152), ylim=c(0,100),
       xlab="read position", ylab="percent methylation", cex.lab=1)
  mtext("million counts",side=4,line=2, cex=1) 
  mtext(names(dat.R1)[i],side=3,line=0.5, cex=1.1) 
  
  axis(1, at=seq(5,146,20), labels=seq(5,146,20), lwd = 0, lwd.ticks = 1)
  axis(2, at=seq(0,100,20), labels=seq(0,100,20), lwd = 0, lwd.ticks = 1)
  lab.y2 <- seq(0,100,20)*(max/100)
  axis(4, at=seq(0,100,20), labels=round(lab.y2/1000000, 2), lwd = 0, lwd.ticks = 1)
  
  # add data
  lines(dat$position, dat$X..methylation, lwd=2, col="black")
  
  lines(dat$position, dat$coverage*(100/max), lwd=2, col="gold")
  lines(dat$position, dat$count.methylated*(100/max), lwd=2, col="cornflowerblue")
  lines(dat$position, dat$count.unmethylated*(100/max), lwd=2, col="gray50")
  
  # add selected cut off
  abline(v=3.5, col="black", lty=2) # cut off 3 bases
  abline(v=147.5, col="black", lty=2) # cut of 4 bases (from 151)
  
  # add legend
  legend("top",legend=c("percent methylation","coverage", "count methylated", "count unmethylated"), pch=19, col=c("black","gold", "cornflowerblue", "gray50"), 
         bty="n", cex=1, horiz=TRUE)
}
dev.off()

# merged // R2
pdf(file = "mbias_test/plots/M-bias.R2.pdf", width = 10, height = 4)

for(i in 1:length(dat.R2)) {
  dat <- dat.R2[[i]]
  
  # build base plot
  par(mfrow=c(1,1), mar = c(4,4,2,4), mgp=c(2, 0.5, 0))
  plot(NULL, xaxt="n", yaxt="n", xlim=c(0,152), ylim=c(0,100),
       xlab="read position", ylab="percent methylation", cex.lab=1)
  mtext("million counts",side=4,line=2, cex=1) 
  mtext(names(dat.R2)[i],side=3,line=0.5, cex=1.1) 
  
  axis(1, at=seq(5,146,20), labels=seq(5,146,20), lwd = 0, lwd.ticks = 1)
  axis(2, at=seq(0,100,20), labels=seq(0,100,20), lwd = 0, lwd.ticks = 1)
  lab.y2 <- seq(0,100,20)*(max/100)
  axis(4, at=seq(0,100,20), labels=round(lab.y2/1000000, 2), lwd = 0, lwd.ticks = 1)
  
  # add data
  lines(dat$position, dat$X..methylation, lwd=2, col="black")
  
  lines(dat$position, dat$coverage*(100/max), lwd=2, col="gold")
  lines(dat$position, dat$count.methylated*(100/max), lwd=2, col="cornflowerblue")
  lines(dat$position, dat$count.unmethylated*(100/max), lwd=2, col="gray50")
  
  # add selected cut off
  abline(v=4.5, col="black", lty=2) # cut off 4 bases
  abline(v=147.5, col="black", lty=2) # cut of 3 bases (from 150)
  
  # add legend
  legend("top",legend=c("percent methylation","coverage", "count methylated", "count unmethylated"), pch=19, col=c("black","gold", "cornflowerblue", "gray50"), 
         bty="n", cex=1, horiz=TRUE)
}
dev.off()


