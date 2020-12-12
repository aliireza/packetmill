set terminal postscript eps color enhanced "Helvetica" 38 size 5,2
set style fill solid 1 border -1 
set style boxplot nooutliers
set style boxplot fraction 1.00
set style data boxplot
set boxwidth 0.15
#set xlabel "Number of Ways for I/O" font "Helvetica,16"

set xlabel "Processor Frequency (GHz)" font "Helvetica,14"
# set xtics ("1.2 GHz\n{/*0.8(min)}" 1, "2.3 GHz\n{/*0.8(nominal)}" 2, "3.7 GHz\n{/*0.8(max)}" 3) font "Helvetica, 12"  offset 0,0.4
set xtics ("1.2" 1.2, "1.4" 1.4, "1.6" 1.6, "1.8" 1.8, "2.0" 2, "2.2" 2.2, "2.4" 2.4, "2.6" 2.6, "2.8" 2.8, "3.0" 3) font "Helvetica, 16"  #offset 0,0.4
set ytic font "Helvetica, 16" 

set yrange [0:*]
set xrange [1:3.2]

set offsets graph 0, 0, 0.05, 0.05 
set grid
# set parametric
unset key

#Throughput

do for [f in "Vanilla PacketMill"]{
    set print f.'-throughput-stats.dat'
    freq(n) = word("1.2 1.4 1.6 1.8 2.0 2.2 2.4 2.6 2.8 3.0", n)
    print sprintf("#%s %s %s %s", "X", "Throughput-median", "Throughput-min", "Throughput-max")
    do for [i=1:10] {
    stats f.'THROUGHPUT.csv' using i prefix "TH" nooutput
    print sprintf("%s %e %e %e", freq(i), value(TH_median), value(TH_min), value(TH_max))
    }
}

#LAT50
do for [f in "Vanilla PacketMill"]{
    set print f.'-lat50-stats.dat'
    freq(n) = word("1.2 1.4 1.6 1.8 2.0 2.2 2.4 2.6 2.8 3.0", n)
    print sprintf("#%s %s %s %s", "X", "lat50-median", "lat50-min", "lat50-max")
    do for [i=1:10] {
    stats f.'LAT50.csv' using i prefix "TH" nooutput
    print sprintf("%s %e %e %e", freq(i), value(TH_median), value(TH_min), value(TH_max))
    }
}

#LAT99
do for [f in "Vanilla PacketMill"]{
    set print f.'-lat99-stats.dat'
    freq(n) = word("1.2 1.4 1.6 1.8 2.0 2.2 2.4 2.6 2.8 3.0", n)
    print sprintf("#%s %s %s %s", "X", "lat99-median", "lat99-min", "lat99-max")
    do for [i=1:10] {
    stats f.'LAT99.csv' using i prefix "TH" nooutput
    print sprintf("%s %e %e %e", freq(i), value(TH_median), value(TH_min), value(TH_max))
    }
}


set style line 1 linecolor rgb '#78c679' ps 1 pt 3 lw 1.5 # Vanilla
set style line 2 linecolor rgb '#006837' ps 1 pt 6 lw 1.5 # PacketMill

set ylabel "Throughput (Gbps)" font "Helvetica,16"
set key font "Helvetica, 14" vertical Left left top reverse invert
set yrange [0:105]

# unset xtics 
# unset xlabel
set grid

set terminal pdf
set output 'throughput-bar.pdf'
plot "Vanilla-throughput-stats.dat" using ($1):($2/1000000000) with lines ls 1 dt 2 notitle,\
"Vanilla-throughput-stats.dat" using ($1):($2/1000000000):($3/1000000000):($4/1000000000) with errorbars ls 1 title "Vanilla (Copying)",\
"PacketMill-throughput-stats.dat" using ($1):($2/1000000000) with lines ls 2 dt 2 notitle,\
"PacketMill-throughput-stats.dat" using ($1):($2/1000000000):($3/1000000000):($4/1000000000) with errorbars ls 2 title "PacketMill (X-Change)";

set yrange [0:850]
set ylabel "Median Latency ({/Symbol m}s)" font "Helvetica,16"
set key noinvert right top
set terminal pdf
set output 'lat50-bar.pdf'
plot "Vanilla-lat50-stats.dat" using ($1):($2) with lines ls 1 dt 2 notitle,\
"Vanilla-lat50-stats.dat" using ($1):($2):($3):($4) with errorbars ls 1 title "Vanilla (Copying)",\
"PacketMill-lat50-stats.dat" using ($1):($2) with lines ls 2 dt 2 notitle,\
"PacketMill-lat50-stats.dat" using ($1):($2):($3):($4) with errorbars ls 2 title "PacketMill (X-Change + Source-Code Optimizations)";

set yrange [0:1000]
set ylabel "99^{th} Percentile Latency ({/Symbol m}s)" font "Helvetica,16"
set key noinvert right top
set terminal pdf
set output 'lat99-bar.pdf'
plot "Vanilla-lat99-stats.dat" using ($1):($2) with lines ls 1 dt 2 notitle,\
"Vanilla-lat99-stats.dat" using ($1):($2):($3):($4) with errorbars ls 1 title "Vanilla (Copying)",\
"PacketMill-lat99-stats.dat" using ($1):($2) with lines ls 2 dt 2 notitle,\
"PacketMill-lat99-stats.dat" using ($1):($2):($3):($4) with errorbars ls 2 title "PacketMill (X-Change + Source-Code Optimizations)";


set output 'throughput-lat50-bar.pdf'
set multiplot layout 2, 1
set tmargin 2
unset xlabel
set key left invert
set yrange[0:105]
set ylabel "Throughput (Gbps)" font "Helvetica,16"
plot "Vanilla-throughput-stats.dat" using ($1):($2/1000000000) with lines ls 1 dt 2 notitle,\
"Vanilla-throughput-stats.dat" using ($1):($2/1000000000):($3/1000000000):($4/1000000000) with errorbars ls 1 title "Vanilla (Copying)",\
"PacketMill-throughput-stats.dat" using ($1):($2/1000000000) with lines ls 2 dt 2 notitle,\
"PacketMill-throughput-stats.dat" using ($1):($2/1000000000):($3/1000000000):($4/1000000000) with errorbars ls 2 title "PacketMill (X-Change + Source-Code Optimizations)";
unset key 
set xlabel
set yrange[0:850]
set ytics 0,200
set xlabel "Processor Frequency (GHz)" font "Helvetica,14"
set ylabel "Median Latency ({/Symbol m}s)" font "Helvetica,16"
plot "Vanilla-lat50-stats.dat" using ($1):($2) with lines ls 1 dt 2 notitle,\
"Vanilla-lat50-stats.dat" using ($1):($2):($3):($4) with errorbars ls 1 title "Vanilla (Copying)",\
"PacketMill-lat50-stats.dat" using ($1):($2) with lines ls 2 dt 2 notitle,\
"PacketMill-lat50-stats.dat" using ($1):($2):($3):($4) with errorbars ls 2 title "PacketMill (X-Change + Source-Code Optimizations)";
unset multiplot