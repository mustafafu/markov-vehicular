#!/bin/bash

#SBATCH --mem=16GB
#SBATCH --time=01:00:00
#SBATCH --cpus-per-task=1
#SBATCH --output=logs/%a_%A.out
#SBATCH --error=logs/%a_%A.err

module purge
module load matlab/2019a

cd /scratch/$USER/markov-vehicular/theory

mkdir -p data
mkdir -p logs

echo "$SLURM_ARRAY_TASK_ID"


matlab -nodisplay -r "theory_main, exit"

