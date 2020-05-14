#!/bin/bash

#SBATCH --mem=8GB
#SBATCH --time=04:00:00
#SBATCH --cpus-per-task=1
#SBATCH --output=logs/%a_%A.out
#SBATCH --error=logs/%a_%A.err

module purge
module load matlab/2019a

cd /scratch/$USER/markov-vehicular/Simulation


mkdir -p data
mkdir -p logs

echo "$SLURM_ARRAY_TASK_ID"


matlab -nodisplay -r "CombineData, exit"


