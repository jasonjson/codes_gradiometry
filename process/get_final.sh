#!/bin/bash
#PBS  -q normal
#PBS  -N yuanliu_gradiometry
#PBS  -l nodes=1:ppn=16
#PBS  -l walltime=10:00:00


CODEPATH=/home/yuanliu/codes
export PATH=$PATH:$CODEPATH/Shan_lib
export PATH=$PATH:$CODEPATH/Sparse_Lucy
export PATH=$PATH:$CODEPATH/sac/bin
export SACAUX=$CODEPATH/sac/aux
export PATH=/home/yuanliu/codes/gmt/gmt-4.5.11/bin:$PATH

### This changes your directory to the directory from where you used "qsub" to 
### submit this job
cd $PBS_O_WORKDIR
SCRATCH=/scratch/$USER/$PBS_JOBID/
rsync -av $PBS_O_WORKDIR/ $SCRATCH/ 
cd $SCRATCH
mkdir final_para plots #folder for final results and figures
find_subarry.py #create folder for each master station and put supporting stations inside 
cal_peak_time_amp.py #get peak amp and its arrival time for plotting
#produce main_$i.sh file 
N=`wc -l header_all | awk '{print $1}'`
M=`expr $N / 30 `
P=`expr $N / 30 + 1`
for i in `seq 1 $M`
do
	start=`expr $i \* 30 - 29`
	end=`expr $i \* 30`
	cp main.sh  main_$i.sh
	sed -i  "s/startline/$start/g" main_$i.sh
	sed -i  "s/endline/$end/g" main_$i.sh
done
for i in `seq $P $P`
do
	start=`expr $i \* 30 - 29`
	cp main.sh main_$i.sh
	sed -i  "s/startline/$start/g" main_$i.sh
	sed -i  "s/endline/$N/g" main_$i.sh
done

#run the main program
for i in `seq 1 15`; do
    numactl -C +$((i-1)) ./main_$i.sh &
done
wait

#process data
echo ${PWD##*/} > period #create period file for plotting and omega
cp geometry.dat edge_location.txt final_para/
cd final_para
cat velo_* > dyna_velo
cat AB_* > AB_all
cat azi_rad_geo_* > azi_rad_geo_all
#calculate structural phase velocity
omega=`awk -F_ '{printf "%f",2*3.14159/$2}' period`
awk 'function abs(x){return ((x < 0.0) ? -x : x)} {print abs($3)*1000}' AB_all > A_all
percentage=`minmax -C A_all | awk '{print $2*0.005}'`
damping=`minmax -C A_all | awk '{print ($2*0.04/6.371)^2}'`
awk -v a=$percentage 'BEGIN {print "lon lat Ve Vn Se Sn Cen Site Ref"} {print $1,$2,$3*1000,$4*1000,a,a,"0.05 stat(0,0) test1"}' AB_all > GPS_raw.dat
process_AB $damping
awk '{if(NR>=4&&NR<=365)print $2,$3,$4/1000000,$5/1000000}' strain.out > lap_A
# $1-dyna_velo $2-TA*.z $3-dist $4-lon $5-lat $6-azi $7-lon $8-lat $9-Ax $10-Ay $11-Bx $12-By $13-lat $14-lon $15 Exx(lap_Ax) $16-Eyy(lap_Ay)  make sure the lon and lat are the same for each line
paste dyna_velo ../header_all AB_all lap_A | awk -v w=$omega '{print $4,$5,$7,$8,$14,$13, w/sqrt((w*(sin($6*3.14159/180))^2)-$9^2-$15+(w*(cos($6*3.14159/180))^2)-$10^2-$16)}' > stru_velo
#plot AxAy
awk 'function abs(x){return ((x < 0.0) ? -x : x)} {print abs($3)}' sigma_c.dat  > 1
min=`minmax 1 |awk -F/ '{print $2}' | awk -F\> '{printf "-%.0f\n",$1}'`
max=`minmax 1 |awk -F/ '{print $2}' | awk -F\> '{printf "%.0f\n",$1}'`
ave=`minmax 1 |awk -F/ '{print $2}' | awk -F\> '{printf "%.0f\n",($1*10/5)/10}'`
image_A $min $max $ave
#plot travel_time peak_amp
image_time_amp
#plot dyna_velo stru_velo azi_var rad_patt geo_spread
image_para
#store all the figures
mv *.ps ../plots
cd ..
### After everything is done, copy all of the results off of the SSD back to 
### where you submitted the job
rsync -av $SCRATCH/ $PBS_O_WORKDIR/
