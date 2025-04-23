# Nextflow pipeline for bioinformatic processing of Soay Sheep whole-genome bisulfite sequencing data

## Nextflow files and pipeline structure

For details on how nextflow works, please reference the [nextflow documentations](https://training.nextflow.io/latest/) as well as Nextflow's [basic concepts in the fundamentals training](https://training.nextflow.io/latest/basic_training/intro/). In short, a Nextflow workflow is made by joining together different processes, executed independently and isolated from each other. The only way they can communicate is via asynchronous first-in, first-out (FIFO) queues, called `channels`. In other words, every input and output of a process is represented as a channel. The interaction between these processes, and ultimately the workflow execution flow itself, is implicitly defined by these `input` and `output` declarations.

### Workflow files

The following files define the workflow execution flow:
- The `workflow file` *script.nf* defines the pipeline input parameters (`params`), loads the relevant processes from the workflow modules, and defines the channels, i.e. the input and output declarations for all processes. 
- The `workflow module files` are located in *modules/* and include the relevant processes for (1) quality control (*qc.nf*), (2) alignment, deduplication, and methylation calling with [Bismark](http://felixkrueger.github.io/Bismark/) (*bismark.nf*), (3) alignment formatting (*alignment_tools.nf*), (4) estimation of bisulfite conversion (*add_ons.nf*), and (5) estimation of telomere length with [telseq](https://github.com/zd1/telseq) (*telseq.nf*).
- The `config file` *nextflow.config* contains the pipeline cnfiguration.

### Pipeline overview

```mermaid
---
config:
  theme: neutral
---

flowchart TD
    subgraph SGA [**run-specific files**]
        direction TB
        A[read files <br> .fastq ] --> |read trimming| B(trimmed read files <br> .fastq)
        B --> |alignment| C[alignment files <br> .bam]
        C --> |deduplication| D[deduplicated <br> alignment files <br> .bam ]
        A --> |quality control| H[fastQC reports <br> .txt]
        B --> |quality control| H[fastQC reports <br> .txt]
    end
    subgraph SG2 [**sample-specific files**]
        direction TB
        E[merged <br> alignment files <br> .bam] --> |methylation calling| F[methylation call files <br> .cov.gz]
        E --> |estimate genome coverage and breadth| I[alignment statistics <br> .txt]
        E --> |run telseq| J[telomere length estimates <br> .out]
    end
    D --> |add read groups and merge run-specific alignments| SG2
    subgraph SG3 [**batch-specific files**]
        direction TB
        G[multiQC reports <br> .txt] 
    end
    H --> |summarize quality conrol| SG3
```

**Sequencing strategy**: <br>
The samples from the main sequencing run (n=872) were sequenced in three batches (sequencing batches). Samples within the first sequencing batch (batch1) were sequenced in 3 runs, while samples within the second and third sequencing batch, were either sequenced in 2, 3 or 4 runs. To facilitate the bioinformatic processing, samples within the second and third sequencing batch were redistributed into new pipeline batches:
- batch2: samples sequenced in 2 runs
- batch3: samples sequenced in 3 runs
- batch4: samples sequenced in 4 runs

The samples from the pilot sequencing run (n=224) were sequenced in one batch in 3 runs.

As the numbers of runs per sample differ between pipeline batches, a small adjustemnt within the process that merges alignments (process `PICARDMERGE` in *modules/alignment_tools.nf*) is required. The number of input alignment must be adjusted when calling `picard MergeSamFiles`: <br>

For samples with three runs (batch1, batch3 and pilot), use
```
picard -Xmx4096m MergeSamFiles I=${alignments[0]} I=${alignments[1]} I=${alignments[2]} O=align_merge_${sample_id}_logs/${sample_id}.merged.bam TMP_DIR=align_merge_${sample_id}_logs/temp SORT_ORDER=queryname
```

and for samples with e.g. four runs (batch 4) use

```
picard -Xmx4096m MergeSamFiles I=${alignments[0]} I=${alignments[1]} I=${alignments[2]} I=${alignments[3]} O=align_merge_${sample_id}_logs/${sample_id}.merged.bam TMP_DIR=align_merge_${sample_id}_logs/temp SORT_ORDER=queryname
```

To facilitate this, I created branches that are specific for the number of runs per sample. WHen running the pipeline, please fetch the correct branch before running the pipeline.
- two runs: `tworuns`
- three runs: `threeruns`
- four runs: `fourruns`




```
process PICARDMERGE {
    tag "PICARDMERGE on $sample_id"

    input:
    tuple val(sample_id), path(alignments)

    output:
    tuple val(sample_id), path("align_merge_${sample_id}_logs/${sample_id}.merged.bam")

    script:
    """
    mkdir align_merge_${sample_id}_logs
    mkdir align_merge_${sample_id}_logs/temp
    picard -Xmx4096m MergeSamFiles I=${alignments[0]} I=${alignments[1]} I=${alignments[2]} O=align_merge_${sample_id}_logs/${sample_id}.merged.bam TMP_DIR=align_merge_${sample_id}_logs/temp SORT_ORDER=queryname
    """
}
```


## Running the pipeline on HPC:

Running nextflow on STANAGE (HPC), requires to load the module using `module load Nextflow/23.10.0` when used in an interactive session. When you e.g. run the test pipelines (see below). When submitting the pipeline as a batch job, loading the module is part of the submission scripts *launch_nf.sh* and *resume_nf.sh* for launching and resuming the pipeline.

### Running the tets pipelines

Before starting a pipeline batch, run the test scripts to see whether the pipeline interpetes the information on read pair files and read group details correctly. 

Create a tmux session, log onto a worker node (e.g. `srun --mem=16G --pty bash -i`) and load the Nextflow module (`module load Nextflow/23.10.0`).

Then, run the first test script *test.nf* using the below code. Note, adjust your user account details and the sequencing and pipeline batch. (Here, the user is "bi1ml", the sequencing batch is "fourth_batch" and the pipeline batch is "b4.5")

```bash
nextflow -C /users/bi1ml/pipelines/next_wgbs/nextflow.config run /users/bi1ml/pipelines/next_wgbs/test.nf -work-dir /mnt/parscratch/users/bi1ml/public/methylated_soay/soay_wgbs_main_sep2024/nextflow_pipeline/work --project "/mnt/parscratch/users/bi1ml/public/methylated_soay/soay_wgbs_main_sep2024" --data "/mnt/parscratch/users/bip23lrb/public/methylated_soay/soay_wgbs_main_sep2024" --userdir "/users/bi1ml/pipelines" --seqbatch "fourth_batch" --pipelinebatch "b4.5" > submission_logs/test.b4.5.log
```

The submission log file should show no errors and the correct paths to the read pair input files grouping R1 and R2 of each run of a sample.

Next, run the second test script *test2.nf* using the below code and again adjust your user account details and the sequencing and pipeline batch.

```bash
nextflow -C /users/bi1ml/pipelines/next_wgbs/nextflow.config run /users/bi1ml/pipelines/next_wgbs/test2.nf -work-dir /mnt/parscratch/users/bi1ml/public/methylated_soay/soay_wgbs_main_sep2024/nextflow_pipeline/work --project "/mnt/parscratch/users/bi1ml/public/methylated_soay/soay_wgbs_main_sep2024" --data "/mnt/parscratch/users/bip23lrb/public/methylated_soay/soay_wgbs_main_sep2024" --userdir "/users/bi1ml/pipelines" --seqbatch "fourth_batch" --pipelinebatch "b4.5" > submission_logs/test2.b4.5.log
```

The submission log file should show no errors and the correct read group details for each run of a sample and group all runs of a sample together.

If successful, go ahead and lauch the Nextflow pipeline for your sequencing batch.

### Launching the pipeline

Before launching the pipeline, adjusting your user account details and the log fime name (pipeline batch) within the lauch script *launch_nf.sh*. This also inlcudes the paths in the nextflow command.

Next, launch the pipeline by executing the lauch script *launch_nf.sh*, while again adjusting your user account details and the sequencing and pipeline batch.

```bash
sbatch launch_nf.sh /users/bi1ml/pipelines/next_wgbs/script.nf /users/bi1ml/pipelines/next_wgbs/nextflow.config "fourth_batch" "b4.5"
```

If you need to resume the pipeline, adjust the resume script *resume_nf.sh* (see above) and resume the pipeline by executing the resume script *resume_nf.sh*, while again adjusting your user account details and the sequencing and pipeline batch.

```bash
sbatch resume_nf.sh /users/bi1ml/pipelines/next_wgbs/script.nf /users/bi1ml/pipelines/next_wgbs/nextflow.config "fourth_batch" "b4.5"
```

