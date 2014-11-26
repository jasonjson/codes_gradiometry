#!/bin/bash

for ((i=startline;i<=endline;i++))
do
stationname=`awk -v a=$i '{x=$1; split(x,aa,".");if(NR==a) print aa[2]}' header_all`
cd $stationname
cp ../velo_start . #the starting velocity
saclst stlo stla f TA.*.z > loc_sta #produce station location data file
awk '{print $1,$3,$4}' master_sta > loc_master  #produce loc_master for make_geometry_new2
for ((j=1;j<=4;j++)) #do 4 iterations
do
cal_shift_time.py #calculate shifting time
awk '{print "r TA."$1".z";print "chnhdr b",$2; print "w shift."$1".z"}END{print "q"}' shift_time | sac 
awk '{print "r shift."$1".z";print "dif";print "w vel."$1".z"}END{print "q"}' shift_time | sac 
cal_para.py #update phase velocity
done
#store final results
mv velo_start ../final_para/velo_$stationname
mv AB.dat ../final_para/AB_$stationname
mv azi_rad_geo.dat ../final_para/azi_rad_geo_$stationname
cd ..
done
