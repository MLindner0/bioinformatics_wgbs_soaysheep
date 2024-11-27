#!/bin/bash

#SBATCH --comment=nextflow_slurm_trial
#SBATCH --output=submission_logs/slurm_trial_2.log
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=5GB
#SBATCH --time=62:00:00
#SBATCH --mail-user=m.lindner@sheffield.ac.uk
#SBATCH --mail-type=all

WORKFLOW=$1
CONFIG=$2

module load Nextflow/23.10.0

nextflow -C ${CONFIG} run ${WORKFLOW} -resume
