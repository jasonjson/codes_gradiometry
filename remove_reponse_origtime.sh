#!/bin/bash

#remove bad stations
awk '{print "rm TA."$1"* SAC*TA_"$1"*"}' bad | sh  #stations far away from the main array
saclst b f *.z | awk '{if($2>500 || $2<-500) print "rm "$1}' | sh  #stations with abnormal b values
saclst dist stlo stla baz f *.z | awk '{print $1,$2,$3,$4,$5-180}' > header_all
create_geometry.py

#remove instrumental response and modify original time
saclst nzyear nzjday nzhour nzmin nzsec  f TA.Q*.z > header.info
jyear=`awk '{if(NR==1) print $2}' header.info`
jday=`awk '{if(NR==1) print $3}' header.info`
jhour=`awk '{if(NR==1) print $4}' header.info`
jmin=`awk '{if(NR==1) print $5}' header.info`
jsec=`awk '{if(NR==1) print $6}' header.info`
ls SAC* | awk '{x=$1;split(x,aa,"_");print "mv "$1,aa[1]"_"aa[4]}' | sh
ls *.z | awk '{x=$1;split(x,aa,".");print $1,"SAC_"aa[2]}' | awk -v a=$jyear -v b=$jday -v c=$jhour -v d=$jmin -v e=$jsec '{x=$1;y=$2;print "r",x; print "rmean"; print "rtrend"; print "taper"; print "trans from polezero subtype",y,"to none freq 0.001 0.002 0.1 0.2";print "chnhdr o gmt "a,b,c,d,e; print "evaluate to tt1 &1,o * -1"; print "chnhdr allt %tt1"; print "w over"}END{print "q"}' |sac

#delete useless files
rm SAC* bad header.info
