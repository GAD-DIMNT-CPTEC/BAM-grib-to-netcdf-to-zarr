#! /bin/bash -x

Exps=(EXP1 EXP2 EXP3 EXP4 EXP5 EXP6)

for expn in ${Exps[@]}
do        

if [ "${expn}" == "EXP1" ]
then         
  export expd=/mnt/beegfs/carlos.bastarz/SMNA_v3.0.1_bdtc
  export dataei=2025090100
  export dataef=2025110806
  export ncycles=274
elif [ "${expn}" == "EXP2" ]
then        
  export expd=/mnt/beegfs/liviany.viana/SMNA_v3.0.x
  export dataei=2025090100
  export dataef=2025110806
  export ncycles=274
elif [ "${expn}" == "EXP3" ]
then        
  export expd=/mnt/beegfs/helena.azevedo/SMNA_v3.0.x
  export dataei=2025090100
  export dataef=2025111700
  export ncycles=309
elif [ "${expn}" == "EXP4" ]
then        
  export expd=/mnt/beegfs/liviany.viana/SMNA_v3.0.1
  export dataei=2025090100
  export dataef=2025110700
  export ncycles=269
elif [ "${expn}" == "EXP5" ]
then        
  export expd=/mnt/beegfs/carlos.bastarz/SMNA_v3.0.1_bcpt
  export dataei=2025090100
  export dataef=2025110806
  export ncycles=274
elif [ "${expn}" == "EXP6" ]
then        
  export expd=/mnt/beegfs/helena.azevedo/SMNA_v3.0.x_noamsua
  export dataei=2025090100
  export dataef=2025110512
  export ncycles=263
fi

cat << EOF > /mnt/beegfs/carlos.bastarz/SMNA_v3.0.1_bdtc/SMG/cptec/bam/run/qsub_pos_cycle_${expn}.qsb
#!/bin/bash
#SBATCH -o /mnt/beegfs/carlos.bastarz/SMNA_v3.0.1_bdtc/SMG/cptec/bam/run/Out.pos.CPT.MPI72_${expn}.out
#SBATCH --time=00:45:00
##SBATCH --nodes=
#SBATCH --ntasks=72
#SBATCH --ntasks-per-node=24  # @egeon: must be <=6 (6, 4), 8 or more creates some corrupted grib files
#SBATCH --job-name=Pos${expn}
#SBATCH --partition=PESQ2
#SBATCH --mem=480G
#SBATCH --cpus-per-task=1  # @egeon: this do not seems to speed the processing time  
#SBATCH --array=1-${ncycles}

module purge
module load intel/2021.4.0
module load mpi/2021.4.0 impi/2021.4.0
module load netcdf/4.7.4 pnetcdf/1.12.2 netcdf-fortran/4.5.3
module list

export inctime=/home/carlos.bastarz/bin/inctime

DATAI=${dataei}

export inc=\$((\${SLURM_ARRAY_TASK_ID}*6))
export DATA=\$(\${inctime} \${DATAI} +\${inc}hr %y4%m2%d2%h2)
export DATAFCT=\$(\${inctime} \${DATA} +9hr %y4%m2%d2%h2)

mkdir -p /mnt/beegfs/carlos.bastarz/SMNA_v3.0.1_bdtc/SMG/datainout/bam/pos/${expn}/exec_CPT\${DATA}/setout
mkdir -p /mnt/beegfs/carlos.bastarz/SMNA_v3.0.1_bdtc/SMG/datainout/bam/pos/${expn}/dataout/TQ0299L064/\${DATA}/

cp /mnt/beegfs/carlos.bastarz/SMNA_v3.0.1_bdtc/SMG/datainout/bam/pos/exec/PostGrib /mnt/beegfs/carlos.bastarz/SMNA_v3.0.1_bdtc/SMG/datainout/bam/pos/${expn}/exec_CPT\${DATA}


cd /mnt/beegfs/carlos.bastarz/SMNA_v3.0.1_bdtc/SMG/datainout/bam/pos/${expn}/exec_CPT\${DATA}

ulimit -s unlimited
ulimit -c unlimited
export I_MPI_DEBUG=15

# export OMP_WAIT_POLICY=PASSIVE
export OMP_NUM_THREADS=\$SLURM_CPUS_PER_TASK
# export MPICH_ENV_DISPLAY=1
# export MPICH_NO_BUFFER_ALIAS_CHECK=1

export KMP_STACKSIZE=128m

mq=linux
if [ \${mq} = "linux" ]; then
   export F_UFMTENDIAN=10,11
fi

cat << EOT > /mnt/beegfs/carlos.bastarz/SMNA_v3.0.1_bdtc/SMG/datainout/bam/pos/${expn}/exec_CPT\${DATA}/POSTIN-GRIB
 &PosInput
  nffrs=-1,            
  nfbeg=-1,            
  nfend=2000,          
  nmand=32,            
  RegIntIn=.FALSE.,    
  Linear=.FALSE.,      
  trunc ='TQ0299',     
  lev   ='L064',       
  labeli='\${DATA}', 
  labelf='\${DATAFCT}', 
  kpds13=11,           
  prefx ='CPT',        
  req   ='p',          
  datain='${expd}/SMG/datainout/bam/model/dataout/TQ0299L064/DAS/\${DATA}',
  datalib='/mnt/beegfs/carlos.bastarz/SMNA_v3.0.1_bdtc/SMG/cptec/bam/pos/datain',
  dataout='/mnt/beegfs/carlos.bastarz/SMNA_v3.0.1_bdtc/SMG/datainout/bam/pos/${expn}/dataout/TQ0299L064/\${DATA}', 
  Binary=.FALSE.,      
  postclim=.FALSE.,    
  res=-0.5,            
  ENS=.TRUE.,          
  ExtrapoAdiabatica=.TRUE.,
  RunRecort=.FALSE.,     
  prefy ='POS',          
  RecLat= -60.0,  20.0   
  RecLon= -90.0,  30.0   
  givenfouriergroups=.FALSE., 
  nproc_vert= 1,       
  ibdim_size= 12,        
  tamBlock=512,          
 /
 &PressureLevel
  plevs( 1:10) =1000.00,  975.00,  950.00,  925.00,  900.00,  875.00,  850.00,  825.00,  800.00,  775.00,
  plevs(11:20) = 750.00,  725.00,  700.00,  675.00,  650.00,  600.00,  550.00,  500.00,  450.00,  400.00,
  plevs(21:30) = 350.00,  300.00,  250.00,  200.00,  150.00,  100.00,   70.00,   50.00,   30.00,   20.00,
  plevs(31:32) =  10.00,    3.0,     0.00
 /

EOT

mpirun -np \$SLURM_NTASKS  ./PostGrib < POSTIN-GRIB > setout/Print.post.\${DATA}.\${DATAFCT}.1771439943.MPI72.out 
DATAOUT=/mnt/beegfs/carlos.bastarz/SMNA_v3.0.1_bdtc/SMG/datainout/bam/pos/${expn}/dataout/TQ0299L064/\${DATA}
    
    module load grads/2.2.1
    for arqctl in \$(find \${DATAOUT} -name "*.ctl")
    do
    
      gribmap -i \${arqctl} 
    
    done

EOF

done
