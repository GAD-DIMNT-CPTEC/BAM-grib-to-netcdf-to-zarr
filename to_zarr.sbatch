#!/bin/bash -x
#SBATCH --exclusive
#SBATCH --job-name=toZarr
#SBATCH --output=/mnt/beegfs/carlos.bastarz/SMNA_v3.0.x_check/anls_compare/pos/convert_to_netcdf/output/to_zarr_%A_%a.out
#SBATCH --error=/mnt/beegfs/carlos.bastarz/SMNA_v3.0.x_check/anls_compare/pos/convert_to_netcdf/output/to_zarr_%A_%a.err
#SBATCH --time=08:00:00
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=32
#SBATCH --mem=120G
#SBATCH --array=1-6
#SBATCH --partition=PESQ1

export EXP_ID=${SLURM_ARRAY_TASK_ID}

echo "Rodando EXP${EXP_ID}"

hostname

source /home/carlos.bastarz/miniconda3/etc/profile.d/conda.sh
conda activate SMNA-Exps

python /mnt/beegfs/carlos.bastarz/SMNA_v3.0.x_check/anls_compare/pos/convert_to_netcdf/output/to_zarr.py
