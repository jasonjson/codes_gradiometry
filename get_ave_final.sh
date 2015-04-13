#!/bin/bash
#PBS  -q normal
#PBS  -N jobname 
#PBS  -l nodes=1:ppn=15
#PBS  -l walltime=2:00:00


CODEPATH=/home/yuanliu/codes
export PATH=$PATH:$CODEPATH/Shan_lib
export PATH=$PATH:$CODEPATH/Sparse_Lucy
export PATH=$PATH:$CODEPATH/sac/bin
export SACAUX=$CODEPATH/sac/aux
export PATH=/home/yuanliu/codes/gmt/gmt-4.5.11/bin:$PATH

### This changes your directory to the directory from where you used "qsub" to 
### submit this job
cd $PBS_O_WORKDIR
mkdir /dev/shm/yuanliu
rsync -av $PBS_O_WORKDIR/ /dev/shm/yuanliu 
cd /dev/shm/yuanliu

cal_velo_AB_amp.sh
cal_average_stru_amp.py

mkdir ave_results
mv A.dat B.dat grad_A grad_B stru_velo appa_amp focusing_amp azi_amp_stru_velo ave_amp*.z ave_results

tar -cf $PBS_O_WORKDIR/ssdout.$PBS_JOBID.tar /dev/shm/yuanliu/ave_results 
rm -rf /dev/shm/yuanliu
cd $PBS_O_WORKDIR
tar -xf ssdout.$PBS_JOBID.tar
mv dev/shm/yuanliu/ave_results/* .
