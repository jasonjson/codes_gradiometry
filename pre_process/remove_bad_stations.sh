#!/bin/bash

rdseed -pdf *.seed
rm `ls | grep -v 'TA'`
ls *.SAC | awk '{x=$1;split(x,aa,".");print "mv "$1,aa[7]"."aa[8]".z"}' | sh
saclst stlo stla f *.z > st.info

#plot bad stations
awk '{x=$1;split(x,aa,".");print aa[2],$2,$3}' st.info > location
awk '{print $2,$3}' st.info > st.txt 
R=`minmax -C st.txt | awk '{printf "-R%.f\/%.f\/%.f\/%.f\n",$1-5,$2+5,$3-2,$4+2}'`
pscoast $R -B5/4  -Na -JM20 -K -G255/239/213 -Y2i -W0.10p  -A5000  > station.ps
psxy st.txt -R -J -Sc0.03i -K -G0/0/255 -O  >> station.ps
awk '{ print $2+0.15,$3+0.05,"4 3 0 1",$1}' location  | pstext -R -J -P -O  >> station.ps
rm st.info st.txt location .gmt*
