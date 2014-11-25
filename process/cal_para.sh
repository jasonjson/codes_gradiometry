#!/bin/bash

for ((i=1;i<=30;i++))
do
stationname=`awk -v a=$i '{x=$1; split(x,aa,".");if(NR==a) print aa[2]}' header_all`
cd $stationname
saclst stlo stla f TA.*.z > loc_sta
cal_shift_peak.py
#shift waveforms
awk '{print "r TA."$1".z";print "chnhdr b",$2; print "w shift."$1".z"}END{print "q"}' shift_time | sac
#differente waveforms to get ground velocity
awk '{print "r shift."$1".z";print "dif";print "w vel."$1".z"}END{print "q"}' shift_time | sac
create_GPS_raw.py
done

