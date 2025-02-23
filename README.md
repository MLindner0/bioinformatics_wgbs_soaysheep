# Nextflow pipeline for bioinformatic processing of wgbs data v1

## pipeline structure

workflow: script.nf\
config: nextflow.config\
processes: modules/*.nf

## small note on running the pipeline on HPC:

To run nextflow on STANAGE (HPC), load the module: `module load Nextflow/23.10.0`

To submit (launch or resume) nextflow to slurm, use: `sbatch launch_nf.sh /users/bi1ml/pipelines/next_wgbs/script.nf /users/bi1ml/pipelines/next_wgbs/nextflow.config "INSERT_SEQUENCING_BATCH" "INSERT_PIPELINE_BATCH"` or `sbatch resume_nf.sh /users/bi1ml/pipelines/next_wgbs/script.nf /users/bi1ml/pipelines/next_wgbs/nextflow.config "INSERT_SEQUENCING_BATCH" "INSERT_PIPELINE_BATCH"`\
For example, to submit the first second (pieline-)batch of samples from the first sequencing batch, run: `sbatch launch_nf.sh /users/bi1ml/pipelines/next_wgbs/script.nf /users/bi1ml/pipelines/next_wgbs/nextflow.config "first_batch" "b1.4"`

The pipeline is run in batches of 40 samples. After each run, files musst be moved from staged to the shared area. This has to be executed on a login node (and thus cannot be part of the pipeline) as the shared are is not accessible from working nodes on STANAGE.

To move files, run `./stage_to_shared.sh INSERT_STAGEDIR INSERT_NEXTFLOWDIR "INSERT_BATCH"` on a login-node (Working nodes cannot access the `/shared` area). Prrovide the path to stage directory, path to local nextflow directory (home) and pipeline batch.\

To clear stage, work and project directories, run: `./clean.sh INSERT_PUBLICDIR INSERT_HOMEDIR`. Prrovide the path to nextflow directory on parscratch and, path to local nextflow directory (home).


