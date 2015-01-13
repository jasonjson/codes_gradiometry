#!/bin/bash

plot_results() {

blockmean sigma_c.dat $R  -I6m -V > sigma_r.dat
grdraster 9 $R -I2m -Gout.grd
grdgradient out.grd -A0 -Nt -Gtopo.grd
surface sigma_r.dat  -Ggm0.grd -I2m  -R -T0.2
psbasemap $R $J -Ba4f2/a4f2WSen  -K -V -X2.0 -Y2.0i -P > $M
makecpt -Chaxby -I $T -Z > vel.cpt
grdimage gm0.grd -Itopo.grd -Cvel.cpt -R -J -O -V -K >> $M
grdcontour gm0.grd  -R -J -Cvel.cpt -B -A- -O -K -S6m -V >> $M
psxy edge_location.txt -R -J -O -K -L -G255 -W1 -V >> $M 
pscoast -J -R -B -N2/0.5p/0/0/0 -S248/248/255 -W4.0 -A5000 -O -V -K >> $M
awk '{print "-126 32 15 0 1 BL Period:",$1}' period > time.dat
pstext time.dat -R -J -O -K -V >> $M 
psscale -Cvel.cpt -D2.4i/-0.5i/3.8i/0.2ih  -O -V -B/:"km/s": -E >> $M

}

#  $R and file name need to be modified

M=`awk '{print "average_dyna_"$1".ps"}' period` 
text="Average dynamical phase velocity(km/s)"
R="-R-129/-105/29/51"
J="-Jm0.5"
T="-T3.5/4.5/0.05"
awk '{print $2,$3,1/$4}' dyna_stru_ave_60 > sigma_c.dat
plot_results

M=`awk '{print "average_stru_"$1".ps"}' period` 
text="Average structural phase velocity(km/s)"
R="-R-129/-105/29/51"
J="-Jm0.5"
T="-T3.5/4.5/0.05"
awk '{print $2,$3,1/$5}' dyna_stru_ave_60 > sigma_c.dat
plot_results

rm sigma_* gm0.* time.dat *.grd .gmt*

