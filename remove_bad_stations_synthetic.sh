#!/bin/bash

#change the name of raw data to TA.
ls *.sac | awk '{x=$1;split(x,aa,".");print "mv "$1,"TA."aa[1]".z"}' | sh

#plot bad stations
saclst stlo stla f *.z > st.info
mkdir selected
awk '{print "grep "$3" st.info"}' ../station.lst  | sh | awk '{print "cp "$1" selected"}' | sh
cd selected
awk '{print "rm TA."$1"*"}' ../../bad | sh
saclst stlo stla f *.z > st.info
awk '{x=$1;split(x,aa,".");print aa[2],$2,$3}' st.info > location
awk '{print $2,$3}' st.info > st.txt 
#make the map boundary larger to find bad stations
R=`minmax -C st.txt | awk '{printf "-R%.f\/%.f\/%.f\/%.f\n",$1-5,$2+5,$3-2,$4+2}'`
pscoast $R -B5/4  -Na -JM15 -K -G255/239/213 -Y2i -W0.10p  -A5000  > station.ps
psxy st.txt -R -J -Sc0.03i -K -G0/0/255 -O  >> station.ps
awk '{ print $2+0.15,$3+0.05,"4 3 0 1",$1}' location  | pstext -R -J -P -O  >> station.ps
#change original time
ls TA.*.z | awk '{if(NR==1) print "saclst nzyear nzjday nzhour nzmin nzsec f "$1}' | sh > header.info
jyear=`awk '{print $2}' header.info`
jday=`awk '{print $3}' header.info`
jhour=`awk '{print $4}' header.info`
jmin=`awk '{print $5}' header.info`
jsec=`awk '{print $6}' header.info`
ls *.z | awk -v a=$jyear -v b=$jday -v c=$jhour -v d=$jmin -v e=$jsec '{x=$1;y=$2;print "r",x; print "rmean"; print "rtrend"; print "taper";print "chnhdr o gmt "a,b,c,d,e; print "evaluate to tt1 &1,o * -1"; print "chnhdr allt %tt1"; print "w over"}END{print "q"}' |sac

saclst dist stlo stla baz f *.z | awk '{print $1,$2,$3,$4,$5-180}' > header_all
create_geometry.py
rm header.info st.info st.txt location .gmt* 
