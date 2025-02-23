#!/bin/bash

#SBATCH --comment=nextflow_slurm_b3.1
#SBATCH --output=submission_logs/slurm_resume_b3.1.log
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=5GB
#SBATCH --time=96:00:00
#SBATCH --mail-user=m.lindner@sheffield.ac.uk
#SBATCH --mail-type=all

WORKFLOW=$1
CONFIG=$2
SEQBATCH=$3
PIPBATCH=$4

module load Nextflow/23.10.0

nextflow -C ${CONFIG} run ${WORKFLOW} -work-dir /mnt/parscratch/users/bi1ml/public/methylated_soay/soay_wgbs_main_sep2024/nextflow_pipeline/work --project "/mnt/parscratch/users/bi1ml/public/methylated_soay/soay_wgbs_main_sep2024" --data "/mnt/parscratch/users/bo1jxs/public/methylated_soay/soay_wgbs_main_sep2024" --userdir "/users/bi1ml/pipelines" --seqbatch ${SEQBATCH} --pipelinebatch ${PIPBATCH} -resume
