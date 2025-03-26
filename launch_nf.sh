#!/bin/bash

#SBATCH --comment=nextflow_slurm_p.1
#SBATCH --output=submission_logs/slurm_p.1.log
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=5GB
#SBATCH --time=168:00:00
#SBATCH --mail-user=m.lindner@sheffield.ac.uk
#SBATCH --mail-type=all

WORKFLOW=$1
CONFIG=$2
SEQBATCH=$3
PIPBATCH=$4

module use /usr/local/modulefiles/staging/eb/all
module load Nextflow/24.04.2

nextflow -C ${CONFIG} run ${WORKFLOW} -work-dir /fastdata/bi1ml/methylated_soay/soay_wgbs_main_sep2024/nextflow_pipeline/work --project "/fastdata/bi1ml/methylated_soay/soay_wgbs_main_sep2024" --data "/shared/slate_group1/Shared/methylated_soay/soay_wgbs_pilot_mar2023/Trimmed_renamed_2" --userdir "/home/bi1ml/pipelines" --seqbatch ${SEQBATCH} --pipelinebatch ${PIPBATCH}