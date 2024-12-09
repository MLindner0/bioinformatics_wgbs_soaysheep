# Nextflow pipeline for bioinformatic processing of wgbs data v1

## pipeline structure

workflow: script.nf
config: nextflow.config
processes: modules/*.nf

## small note on running nextflow on HPC:

to run nextflow on Stanage (HPC), load the module: module load Nextflow/23.10.0

to launch or resume nextflow via slurm batch job, use: sbatch launch_nf.sh /users/bi1ml/pipelines/next_wgbs/script.nf /users/bi1ml/pipelines/next_wgbs/nextflow.config "b1.2" or sbatch resume_nf.sh /users/bi1ml/pipelines/next_wgbs/script.nf /users/bi1ml/pipelines/next_wgbs/nextflow.config "b1.2"
