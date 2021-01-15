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

do for [f in "L2fwd L2fwd-xchg FastClick-Copying PacketMill FastClick-Light-Overlaying BESS VPP"]{
    set print f.'-throughput-stats.dat'
    packet(n) = word("64 192 320 448 576 704 832 960 1088 1216 1344 1472 1500", n)
    print sprintf("#%s %s %s %s", "X", "Throughput-median", "Throughput-min", "Throughput-max")
    do for [i=1:13] {
    stats f.'THROUGHPUT.csv' using i prefix "TH" nooutput
    print sprintf("%s %e %e %e", packet(i), value(TH_median), value(TH_min), value(TH_max))
    }
}

# LAT99

do for [f in "L2fwd L2fwd-xchg FastClick-Copying PacketMill FastClick-Light-Overlaying BESS VPP"]{
    set print f.'-lat99-stats.dat'
    packet(n) = word("64 192 320 448 576 704 832 960 1088 1216 1344 1472 1500", n)
    print sprintf("#%s %s %s %s", "X", "lat99-median", "lat99-min", "lat99-max")
    do for [i=1:13] {
    stats f.'LAT99.csv' using i prefix "TH" nooutput
    print sprintf("%s %e %e %e", packet(i), value(TH_median), value(TH_min), value(TH_max))
    }
}

set style line 1 linecolor rgb '#33a02c' ps 0.75 pt 5 lw 1.5  # PacketMill
set style line 2 linecolor rgb '#b2df8a' ps 0.75 pt 4 lw 1.5  # FastClick-Copying
set style line 3 linecolor rgb '#b2df8a' ps 0.75 pt 3 lw 1.5 # FastClick-Light-Overlaying
set style line 4 linecolor rgb '#1f78b4' ps 0.75 pt 6 lw 1.5 # l2fwd 
set style line 5 linecolor rgb '#1f78b4' ps 0.75 pt 7 lw 1.5 # l2f2d-xchg
set style line 6 linecolor rgb '#fb9a99' ps 0.75 pt 11 lw 1.5 # BESS
#set style line 7 linecolor rgb '#a6cee3' ps 0.75 pt 2 lw 1.5 # VPP
set style line 7 linecolor rgb '#1f78b4' ps 0.75 pt 2 lw 1.5 # VPP

set ylabel "Throughput (Gbps)" font "Helvetica,16"
set key font "Helvetica, 14" vertical Left left top reverse invert
set yrange [0:105]

# unset xtics 
# unset xlabel
set grid

set terminal pdf size 5,3
set key right bottom
set output 'throughput-bar-l2fwd.pdf'
plot "FastClick-Copying-throughput-stats.dat" using ($1):($2/1000000000) with points ls 2 title "FastClick (Copying)",\
"FastClick-Copying-throughput-stats.dat" using ($1):($2/1000000000) with lines ls 2 dt 2 notitle,\
"L2fwd-throughput-stats.dat" using ($1):($2/1000000000) with points ls 4 title "l2fwd",\
"L2fwd-throughput-stats.dat" using ($1):($2/1000000000) with lines ls 4 dt 3 notitle,\
"PacketMill-throughput-stats.dat" using ($1):($2/1000000000) with points ls 1 title "PacketMill (X-Change)",\
"PacketMill-throughput-stats.dat" using ($1):($2/1000000000) with lines ls 1 dt 4 notitle,\
"L2fwd-xchg-throughput-stats.dat" using ($1):($2/1000000000) with points ls 5 title "l2fwd-xchg",\
"L2fwd-xchg-throughput-stats.dat" using ($1):($2/1000000000) with lines ls 5 dt 5 notitle;


set terminal pdf size 5,3
set key right bottom
set output 'throughput-bar-apps.pdf'
plot "VPP-throughput-stats.dat" using ($1):($2/1000000000) with points ls 7 title "VPP",\
"VPP-throughput-stats.dat" using ($1):($2/1000000000) with lines ls 7 dt 4 notitle,\
"FastClick-Copying-throughput-stats.dat" using ($1):($2/1000000000) with points ls 2 title "FastClick (Copying)",\
"FastClick-Copying-throughput-stats.dat" using ($1):($2/1000000000) with lines ls 2 dt 2 notitle,\
"FastClick-Light-Overlaying-throughput-stats.dat" using ($1):($2/1000000000) with points ls 3 title "FastClick-Light (Overlaying)",\
"FastClick-Light-Overlaying-throughput-stats.dat" using ($1):($2/1000000000) with lines ls 3 dt 3 notitle,\
"BESS-throughput-stats.dat" using ($1):($2/1000000000) with points ls 6 title "BESS",\
"BESS-throughput-stats.dat" using ($1):($2/1000000000) with lines ls 6 dt 5 notitle,\
"PacketMill-throughput-stats.dat" using ($1):($2/1000000000) with points ls 1 title "PacketMill (X-Change)",\
"PacketMill-throughput-stats.dat" using ($1):($2/1000000000) with lines ls 1 dt 4 notitle;
