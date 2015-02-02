#!/bin/bash

#remove bad stations
awk '{print "rm TA."$1"* SAC*TA_"$1"*"}' bad | sh  #stations far away from the main array

#delete useless files
saclst npts f TA.*.z | awk '{if($2<100000) print "rm "$1}' | sh #stations with less data points

#remove instrumental response and modify original time
ls TA.*.z | awk '{if(NR==1) print "saclst nzyear nzjday nzhour nzmin nzsec f "$1}' | sh > header.info
jyear=`awk '{print $2}' header.info`
jday=`awk '{print $3}' header.info`
jhour=`awk '{print $4}' header.info`
jmin=`awk '{print $5}' header.info`
jsec=`awk '{print $6}' header.info`
ls SAC* | awk '{x=$1;split(x,aa,"_");print "mv "$1,aa[1]"_"aa[4]}' | sh
ls *.z | awk '{x=$1;split(x,aa,".");print $1,"SAC_"aa[2]}' | awk -v a=$jyear -v b=$jday -v c=$jhour -v d=$jmin -v e=$jsec '{x=$1;y=$2;print "r",x; print "rmean"; print "rtrend"; print "taper"; print "trans from polezero subtype",y,"to none freq 0.001 0.002 0.1 0.2";print "chnhdr o gmt "a,b,c,d,e; print "evaluate to tt1 &1,o * -1"; print "chnhdr allt %tt1"; print "w over"}END{print "q"}' |sac

saclst dist stlo stla baz f *.z | awk '{print $1,$2,$3,$4,$5-180}' > header_all
create_geometry.py
rm SAC* bad header.info
