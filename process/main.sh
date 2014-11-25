#!/bin/bash

for ((i=1;i<=30;i++))
do
stationname=`awk -v a=$i '{x=$1; split(x,aa,".");if(NR==a) print aa[2]}' header_all`
cd $stationname
cp ../velo_start . #the starting velocity
saclst stlo stla f TA.*.z > loc_sta #produce station location data file
awk '{print $1,$3,$4}' master_sta > loc_master  #produce loc_master for make_geometry_new2
awk '{print $5}' master_sta > master_azi #produce azimuth data file for shifting
#first iteration
cal_shift_time.py #calculate shifting time
#shift waveforms
awk '{print "r TA."$1".z";print "chnhdr b",$2; print "w shift."$1".z"}END{print "q"}' shift_time | sac
#differente waveforms to get ground velocity
awk '{print "r shift."$1".z";print "dif";print "w vel."$1".z"}END{print "q"}' shift_time | sac
#update phase velocity 
cal_para.py
#second iteration
cal_shift_time.py
awk '{print "r TA."$1".z";print "chnhdr b",$2; print "w shift."$1".z"}END{print "q"}' shift_time | sac
awk '{print "r shift."$1".z";print "dif";print "w vel."$1".z"}END{print "q"}' shift_time | sac
cal_para.py
#third iteration
cal_shift_time.py
awk '{print "r TA."$1".z";print "chnhdr b",$2; print "w shift."$1".z"}END{print "q"}' shift_time | sac
awk '{print "r shift."$1".z";print "dif";print "w vel."$1".z"}END{print "q"}' shift_time | sac
cal_para.py
#fourth iteration
cal_shift_time.py
awk '{print "r TA."$1".z";print "chnhdr b",$2; print "w shift."$1".z"}END{print "q"}' shift_time | sac
awk '{print "r shift."$1".z";print "dif";print "w vel."$1".z"}END{print "q"}' shift_time | sac
cal_para.py
#store results
mv velo_start ../final_para/velo_$i
mv  azi_var.dat ../final_para/azi_var_$i
mv rad_patt.dat ../final_para/rad_patt_$i
mv geo_spread.dat ../final_para/geo_spread_$i
#cal structural phase velocity

done
