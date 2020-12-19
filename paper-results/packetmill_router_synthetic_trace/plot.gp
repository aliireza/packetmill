set terminal postscript eps color enhanced "Helvetica" 38 size 5,2
set style fill solid 1 border -1 
set style boxplot nooutliers
set style boxplot fraction 1.00
set style data boxplot
set boxwidth 0.15
#set xlabel "Number of Ways for I/O" font "Helvetica,16"

set xlabel "Packet Size (Bytes)" font "Helvetica,14"
set ylabel "Number of Processed Packets per Second" font "Helvetica,16"
# set xtics ("1.2 GHz\n{/*0.8(min)}" 1, "2.3 GHz\n{/*0.8(nominal)}" 2, "3.7 GHz\n{/*0.8(max)}" 3) font "Helvetica, 12"  offset 0,0.4
#set xtics ("64" 1.2, "128" 1.4, "1.6" 1.6, "1.8" 1.8, "2.0" 2, "2.2" 2.2, "2.4" 2.4, "2.6" 2.6, "2.8" 2.8, "3.0" 3) font "Helvetica, 16"  #offset 0,0.4
set ytic font "Helvetica, 16" 

set yrange [0:*]
set xrange [1:*]

set offsets graph 0, 0, 0.05, 0.05 
set grid
# set parametric
unset key

#Throughput

do for [f in "PacketMill Vanilla"]{
    set print f.'-throughput-stats.dat'
    packet(n) = word("64 192 320 448 576 704 832 960 1088 1216 1344 1472 1500", n)
    print sprintf("#%s %s %s %s", "X", "Throughput-median", "Throughput-min", "Throughput-max")
    do for [i=1:13] {
    stats f.'THROUGHPUT.csv' using i prefix "TH" nooutput
    print sprintf("%s %e %e %e", packet(i), value(TH_median), value(TH_min), value(TH_max))
    }
}

# PPS

do for [f in "PacketMill Vanilla"]{
    set print f.'-pps-stats.dat'
    packet(n) = word("64 192 320 448 576 704 832 960 1088 1216 1344 1472 1500", n)
    print sprintf("#%s %s %s %s", "X", "pps-median", "pps-min", "pps-max")
    do for [i=1:13] {
    stats f.'PPS.csv' using i prefix "TH" nooutput
    print sprintf("%s %e %e %e", packet(i), value(TH_median), value(TH_min), value(TH_max))
    }
}

set style line 1 linecolor rgb '#black' ps 0.75 pt 1 lw 1.5  # Vanilla
set style line 2 linecolor rgb '#c2e699' ps 0.75 pt 2 lw 1.5 # Devitualization
set style line 3 linecolor rgb '#78c679' ps 0.75 pt 3 lw 1.5 # Constants
set style line 4 linecolor rgb '#31a354' ps 0.75 pt 4 lw 1.5 # Graph
set style line 5 linecolor rgb '#006837' ps 0.75 pt 5 lw 1.5 # All

set ylabel "Throughput (Gbps)" font "Helvetica,16"
set key font "Helvetica, 14" vertical Left left top reverse invert
set yrange [0:105]

# unset xtics 
# unset xlabel
set grid

set terminal pdf size 5,2.5
set output 'throughput-bar.pdf'
plot "Vanilla-throughput-stats.dat" using ($1):($2/1000000000) with points ls 3 title "Vanilla",\
"Vanilla-throughput-stats.dat" using ($1):($2/1000000000) with lines ls 3 dt 2 notitle,\
"PacketMill-throughput-stats.dat" using ($1):($2/1000000000) with points ls 5 title "PacketMill (X-Change + Source-Code Optimizations)",\
"PacketMill-throughput-stats.dat" using ($1):($2/1000000000) with lines ls 5 dt 4 notitle;




set ylabel "Processed Packets per Second (Million)" font "Helvetica,16"
set key font "Helvetica, 14" vertical Left left bottom reverse invert
set yrange [0:12]
set xtics 64,128,1500
set xrange [0:1600]
# unset xtics 
# unset xlabel
set grid

set terminal pdf size 5,2.5
set output 'pps-bar.pdf'
plot "Vanilla-pps-stats.dat" using ($1):($2/1000000) with points ls 3 title "Vanilla",\
"Vanilla-pps-stats.dat" using ($1):($2/1000000) with lines ls 3 dt 2 notitle,\
"PacketMill-pps-stats.dat" using ($1):($2/1000000) with points ls 5 title "PacketMill (X-Change + Source-Code Optimizations)",\
"PacketMill-pps-stats.dat" using ($1):($2/1000000) with lines ls 5 dt 4 notitle;



set key font "Helvetica, 12" vertical Left right bottom reverse invert 

set output 'throughput-pps-bar.pdf'
set multiplot layout 2, 1
set tmargin 0.6
unset xlabel
# set key left invert
set yrange[0:105]
set ytics 0,20 font "Helvetica, 14"
set ylabel "Throughput (Gbps)" font "Helvetica,14"
plot "Vanilla-throughput-stats.dat" using ($1):($2/1000000000) with points ls 3 title "Vanilla",\
"Vanilla-throughput-stats.dat" using ($1):($2/1000000000) with lines ls 3 dt 2 notitle,\
"PacketMill-throughput-stats.dat" using ($1):($2/1000000000) with points ls 5 title "PacketMill {/*0.8 (X-Change + Source-Code Optimizations)}",\
"PacketMill-throughput-stats.dat" using ($1):($2/1000000000) with lines ls 5 dt 4 notitle;
unset key 
set yrange[0:13]
set ytics 0,3 font "Helvetica, 14"
set xlabel "Packet Size (Bytes)" font "Helvetica,14"
set ylabel "PPS (Million)" font "Helvetica,14"
plot "Vanilla-pps-stats.dat" using ($1):($2/1000000) with points ls 3 title "Vanilla",\
"Vanilla-pps-stats.dat" using ($1):($2/1000000) with lines ls 3 dt 2 notitle,\
"PacketMill-pps-stats.dat" using ($1):($2/1000000) with points ls 5 title "PacketMill (X-Change + Source-Code Optimizations)",\
"PacketMill-pps-stats.dat" using ($1):($2/1000000) with lines ls 5 dt 4 notitle;
unset multiplot