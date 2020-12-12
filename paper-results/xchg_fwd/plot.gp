set terminal postscript eps color enhanced "Helvetica" 38 size 5,2
set style fill solid 1 border -1 
set style boxplot nooutliers
set style boxplot fraction 1.00
set style data boxplot
set boxwidth 0.15
#set xlabel "Number of Ways for I/O" font "Helvetica,16"

set xlabel "Processor Frequency (GHz)" font "Helvetica,14"
set ylabel "Average Cache Misses (k)" font "Helvetica,16"
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

do for [f in "COPY OVERLAY XCHG"]{
    set print f.'-throughput-stats.dat'
    freq(n) = word("1.2 1.4 1.6 1.8 2.0 2.2 2.4 2.6 2.8 3.0", n)
    print sprintf("#%s %s %s %s", "X", "Throughput-median", "Throughput-min", "Throughput-max")
    do for [i=1:10] {
    stats f.'THROUGHPUT.csv' using i prefix "TH" nooutput
    print sprintf("%s %e %e %e", freq(i), value(TH_median), value(TH_min), value(TH_max))
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
plot "COPY-throughput-stats.dat" using ($1):($2/1000000000) with points ls 3 title "Copying",\
"COPY-throughput-stats.dat" using ($1):($2/1000000000) with lines ls 3 dt 2 notitle,\
"OVERLAY-throughput-stats.dat" using ($1):($2/1000000000) with points ls 4 title "Overlaying",\
"OVERLAY-throughput-stats.dat" using ($1):($2/1000000000) with lines ls 4 dt 3 notitle,\
"XCHG-throughput-stats.dat" using ($1):($2/1000000000) with points ls 5 title "X-Change",\
"XCHG-throughput-stats.dat" using ($1):($2/1000000000) with lines ls 5 dt 4 notitle;