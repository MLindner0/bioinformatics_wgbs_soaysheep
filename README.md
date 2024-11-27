# Nextflow pipeline for bioinformatic processing of wgbs data v1

## small notes on running nextflow:

to run nextflow on Stanage, load the module: module load Nextflow/23.10.0

to launch or resume nextflow via slurm batch job, use: sbatch launch_nf.sh /users/bi1ml/pipelines/next_wgbs/script.nf /users/bi1ml/pipelines/next_wgbs/nextflow.config or sbatch resume_nf.sh /users/bi1ml/pipelines/next_wgbs/script.nf /users/bi1ml/pipelines/next_wgbs/nextflow.config --output submission_logs/slurm_trial_3.log
Note: adjust '--output submission_logs/slurm_trial_3.log' when resumed >1 (to keep all slurm.log files)



