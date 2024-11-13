#!/bin/bash

#SBATCH --comment=nextflow_slurm_trial_resume
#SBATCH --output=submission_logs/slurm_trial_1.log
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=28
#SBATCH --mem=28GB
#SBATCH --time=30:00:00
#SBATCH --mail-user=m.lindner@sheffield.ac.uk
#SBATCH --mail-type=all

WORKFLOW=$1
CONFIG=$2

module load Nextflow/23.10.0

nextflow -C ${CONFIG} run ${WORKFLOW} -resume
