#!/bin/bash
#PBS  -q normal
#PBS  -N yuanliu_gradiometry
#PBS  -l nodes=1:ppn=16
#PBS  -l walltime=5:00:00
#PBS  -m abe
#PBs  -M johnny.lyy@gmail.com

#get notified of status: begin, abort, end of a job
#use this for the last script on the queue
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

#prepare for the following computation
pre_cal.sh

#run the main program, first iteration
for i in `seq 1 15`; do
    numactl -C +$((i-1)) ./main_$i.sh 1 &
done
wait

#second iteration
for i in `seq 1 15`; do
	numactl -C +$((i-1)) ./main_$i.sh 234 &
done
wait

#third iteration
for i in `seq 1 15`; do
	numactl -C +$((i-1)) ./main_$i.sh 234 &
done
wait

#fourth iteration
for i in `seq 1 15`; do
	numactl -C +$((i-1)) ./main_$i.sh 234 &
done
wait

#process all data
cp geometry.dat edge_location.txt final_para/
cd final_para
rm -rf dyna_pxpy AB_all* azi_rad_geo_all
cat pxpy_* > dyna_pxpy
cat AB_* > AB_all
cat azi_rad_geo_* > azi_rad_geo_all

#calculate structural phase velocity
cal_stru_velo.sh

#plot AxAy
#image_A

#plot travel_time peak_amp
#image_time_amp

#plot dyna_velo stru_velo azi_var rad_patt geo_spread
#image_para

#store all the figures
#mv *.ps ../plots
cd ..
### After everything is done, copy all of the results off of the SSD back to 
### where you submitted the job
tar -cf $PBS_O_WORKDIR/ssdout.$PBS_JOBID.tar /dev/shm/yuanliu/final_para 
rm -rf /dev/shm/yuanliu
cd $PBS_O_WORKDIR
tar -xf ssdout.$PBS_JOBID.tar
mv dev/shm/yuanliu/final_para .