set terminal postscript eps color enhanced "Helvetica" 38 size 20,5
set style fill solid 1 border -1 
set style boxplot nooutliers
set style boxplot fraction 1.00
set style data boxplot
set boxwidth 0.2
#set xlabel "Number of Ways for I/O" font "Helvetica,16"

set xlabel "Offered Load (Gbps)" font "Helvetica,16"
set ylabel "Throughput (Gbps)" font "Helvetica,16"
set xtics  font "Helvetica, 16" 
set ytic font "Helvetica, 16" 

set yrange [0:*]
set xrange [0:*]

set offsets graph 0, 0, 0.05, 0.05 
set grid
# set parametric
unset key

#Throughput + Latency + TX

do for [f in "COPY PACKETMILL"]{
	set print f.'-TX-throughput-lat99-max-stats.dat'
    print sprintf("#%s %s %s %s %s %s %s %s %s %s %s", "TX", "Throughput-min", "Throughput-q1", "Throughput-median", "Throughput-q3", "Throughput-max", "LAT99-min", "LAT99-q1", "LAT99-median", "LAT99-q3", "LAT99-max")
    do for [i=1:16] {
    stats f.'LAT99.csv' using i prefix "LAT" nooutput
    stats f.'THROUGHPUT.csv' using i prefix "TH" nooutput
    stats f.'TX.csv' using i prefix "TX" nooutput
    print sprintf("%e %e %e %e %e %e %e %e %e %e %e", value(TX_median), value(TH_min), value(TH_lo_quartile), value(TH_median), value(TH_up_quartile), value(TH_max), value(LAT_min), value(LAT_lo_quartile), value(LAT_median), value(LAT_up_quartile), value(LAT_max))
    }
}


do for [f in "COPY PACKETMILL"]{
    set print f.'-TX-throughput-lat50-max-stats.dat'
    print sprintf("#%s %s %s %s %s %s %s %s %s %s %s", "TX", "Throughput-min", "Throughput-q1", "Throughput-median", "Throughput-q3", "Throughput-max", "LAT99-min", "LAT99-q1", "LAT99-median", "LAT99-q3", "LAT99-max")
    do for [i=1:16] {
    stats f.'LAT50.csv' using i prefix "LAT" nooutput
    stats f.'THROUGHPUT.csv' using i prefix "TH" nooutput
    stats f.'TX.csv' using i prefix "TX" nooutput
    print sprintf("%e %e %e %e %e %e %e %e %e %e %e", value(TX_median), value(TH_min), value(TH_lo_quartile), value(TH_median), value(TH_up_quartile), value(TH_max), value(LAT_min), value(LAT_lo_quartile), value(LAT_median), value(LAT_up_quartile), value(LAT_max))
    }
}


# Cache Misses + TX

do for [f in "COPY PACKETMILL"]{
    set print f.'-TX-cachemisses-max-stats.dat'
    print sprintf("#%s %s %s %s %s %s %s %s %s %s %s", "TX", "Load-min", "Load-q1", "Load-median", "Load-q3", "Load-max", "Miss-min", "Miss-q1", "Miss-median", "Miss-q3", "Miss-max")
    do for [i=1:16] {
    stats f.'L1-dcache-loads-avg-C0.csv' using i prefix "LD" nooutput
    stats f.'L1-dcache-load-misses-avg-C0.csv' using i prefix "MS" nooutput
    stats f.'TX.csv' using i prefix "TX" nooutput
    print sprintf("%e %e %e %e %e %e %e %e %e %e %e", value(TX_median), value(LD_min), value(LD_lo_quartile), value(LD_median), value(LD_up_quartile), value(LD_max), value(MS_min), value(MS_lo_quartile), value(MS_median), value(MS_up_quartile), value(MS_max))
    }
}

do for [f in "COPY PACKETMILL"]{
    set print f.'-TX-LLCmisses-max-stats.dat'
    print sprintf("#%s %s %s %s %s %s %s %s %s %s %s", "TX", "Load-min", "Load-q1", "Load-median", "Load-q3", "Load-max", "Miss-min", "Miss-q1", "Miss-median", "Miss-q3", "Miss-max")
    do for [i=1:16] {
    stats f.'LLC-loads-avg-C0.csv' using i prefix "LD" nooutput
    stats f.'LLC-load-misses-avg-C0.csv' using i prefix "MS" nooutput
    stats f.'TX.csv' using i prefix "TX" nooutput
    print sprintf("%e %e %e %e %e %e %e %e %e %e %e", value(TX_median), value(LD_min), value(LD_lo_quartile), value(LD_median), value(LD_up_quartile), value(LD_max), value(MS_min), value(MS_lo_quartile), value(MS_median), value(MS_up_quartile), value(MS_max))
    }
}

# set style line 1 linecolor rgb '#f0f9e8'   # NOLTO
# set style line 2 linecolor rgb '#a6cee3' ps 1 pt 19 lw 1.5  # Latency
# set style line 3 linecolor rgb '#1f78b4' ps 1 pt 14 lw 1.5  # Latency
set style line 1 linecolor rgb '#78c679' ps 1 pt 3 lw 1.5 # Vanilla
set style line 2 linecolor rgb '#006837' ps 1 pt 6 lw 1.5 # PacketMill

set ylabel "Throughput (Gbps)" font "Helvetica,16"
set key font "Helvetica, 12" vertical Left left top reverse invert
set yrange [0:105]
set xrange [0:105]

# set errorbars fullwidth
# set style fill empty
# set boxwidth 2

# set terminal pdf
# set output 'tx-thourghput-bar.pdf'
# plot '< sort -nk1 COPY-TX-throughput-lat99-max-stats.dat' using ($1/1000000000):($2/1000000000):($3/1000000000):($5/1000000000):($6/1000000000) with candlesticks ls 1 title "COPY" fill pattern 2 whiskerbars 5,\
# '< sort -nk1 PACKETMILL-TX-throughput-lat99-max-stats.dat' using ($1/1000000000):($2/1000000000):($3/1000000000):($5/1000000000):($6/1000000000) with candlesticks ls 2 title "PACKETMILL";

set style fill empty

set terminal pdf size 5,2.5
set output 'tx-thourghput-bar.pdf' 
plot '< sort -gk1 COPY-TX-throughput-lat99-max-stats.dat' using ($1/1000000000):($4/1000000000) with lines ls 1 dt 2 notitle,\
'< sort -gk1 COPY-TX-throughput-lat99-max-stats.dat' using ($1/1000000000):($4/1000000000):($2/1000000000):($6/1000000000) with errorbars ls 1  title "Vanilla",\
'< sort -gk1 PACKETMILL-TX-throughput-lat99-max-stats.dat' using ($1/1000000000):($4/1000000000) with lines ls 2 dt 3 notitle,\
'< sort -gk1 PACKETMILL-TX-throughput-lat99-max-stats.dat' using ($1/1000000000):($4/1000000000):($2/1000000000):($6/1000000000) with errorbars ls 2 title "PacketMill";


set key font "Helvetica, 12" vertical Left left top reverse noinvert

set yrange [0:*]
set ytics 0,100
set ylabel "99^{th} Percentile Latency ({/Symbol m}s)" font "Helvetica,14"
set output 'tx-lat99-bar.pdf'
plot '< sort -gk1 COPY-TX-throughput-lat99-max-stats.dat' using ($1/1000000000):($9) with lines ls 1 dt 2 notitle,\
'< sort -gk1 COPY-TX-throughput-lat99-max-stats.dat' using ($1/1000000000):($9):($7):($11) with errorbars ls 1  title "Vanilla",\
'< sort -gk1 PACKETMILL-TX-throughput-lat99-max-stats.dat' using ($1/1000000000):($9) with lines ls 2 dt 3 notitle,\
'< sort -gk1 PACKETMILL-TX-throughput-lat99-max-stats.dat' using ($1/1000000000):($9):($7):($11) with errorbars ls 2 title "PacketMill";



set yrange [0:*]
set ylabel "Median Latency ({/Symbol m}s)" font "Helvetica,16"
set output 'tx-lat50-bar.pdf'
plot '< sort -gk1 COPY-TX-throughput-lat50-max-stats.dat' using ($1/1000000000):($9) with lines ls 1 dt 2 notitle,\
'< sort -gk1 COPY-TX-throughput-lat50-max-stats.dat' using ($1/1000000000):($9):($7):($11) with errorbars ls 1  title "Vanilla (Copying)",\
'< sort -gk1 PACKETMILL-TX-throughput-lat50-max-stats.dat' using ($1/1000000000):($9) with lines ls 2 dt 3 notitle,\
'< sort -gk1 PACKETMILL-TX-throughput-lat50-max-stats.dat' using ($1/1000000000):($9):($7):($11) with errorbars ls 2 title "PacketMill (X-Change)";

set yrange [0:*]
set ylabel "99^{th} Percentile Latency ({/Symbol m}s)" font "Helvetica,16"
set xlabel "Throughput (Gbps)" font "Helvetica,14"
set output 'throughput-lat99-bar.pdf'
plot '< sort -gk1 COPY-TX-throughput-lat99-max-stats.dat' using ($4/1000000000):($9) with lines ls 1 dt 2 notitle,\
'< sort -gk1 COPY-TX-throughput-lat99-max-stats.dat' using ($4/1000000000):($9):($7):($11) with errorbars ls 1  title "Vanilla",\
'< sort -gk1 PACKETMILL-TX-throughput-lat99-max-stats.dat' using ($4/1000000000):($9) with lines ls 2 dt 3 notitle,\
'< sort -gk1 PACKETMILL-TX-throughput-lat99-max-stats.dat' using ($4/1000000000):($9):($7):($11) with errorbars ls 2 title "PacketMill";

set yrange [0:*]
set ylabel "Median Latency ({/Symbol m}s)" font "Helvetica,16"
set xlabel "Throughput (Gbps)" font "Helvetica,14"
set output 'throughput-lat50-bar.pdf'
plot '< sort -gk1 COPY-TX-throughput-lat50-max-stats.dat' using ($4/1000000000):($9) with lines ls 1 dt 2 notitle,\
'< sort -gk1 COPY-TX-throughput-lat50-max-stats.dat' using ($4/1000000000):($9):($7):($11) with errorbars ls 1  title "Vanilla (Copying)",\
'< sort -gk1 PACKETMILL-TX-throughput-lat50-max-stats.dat' using ($4/1000000000):($9) with lines ls 2 dt 3 notitle,\
'< sort -gk1 PACKETMILL-TX-throughput-lat50-max-stats.dat' using ($4/1000000000):($9):($7):($11) with errorbars ls 2 title "PacketMill (X-Change)";


set ytics auto
set yrange [0:*]
set ylabel "L1-dcache Load Miss Rate (%)" font "Helvetica,16"
set xlabel "Offered Load (Gbps)" font "Helvetica,14"
set output 'tx-L1dcache-load-rate-bar.pdf'
plot '< sort -gk1 COPY-TX-cachemisses-max-stats.dat' using ($1/1000000000):($9*100/$4) with lines ls 1 dt 2 notitle,\
'< sort -gk1 COPY-TX-cachemisses-max-stats.dat' using ($1/1000000000):($9*100/$4) with points ls 1  title "Vanilla (Copying)",\
'< sort -gk1 PACKETMILL-TX-cachemisses-max-stats.dat' using ($1/1000000000):($9*100/$4) with lines ls 2 dt 3 notitle,\
'< sort -gk1 PACKETMILL-TX-cachemisses-max-stats.dat' using ($1/1000000000):($9*100/$4) with points ls 2 title "PacketMill (X-Change)";


set yrange [0:*]
set ylabel "L1-dcache Loads" font "Helvetica,16"
set xlabel "Offered Load (Gbps)" font "Helvetica,14"
set output 'tx-L1dcache-loads-bar.pdf'
plot '< sort -gk1 COPY-TX-cachemisses-max-stats.dat' using ($1/1000000000):($4) with lines ls 1 dt 2 notitle,\
'< sort -gk1 COPY-TX-cachemisses-max-stats.dat' using ($1/1000000000):($4) with points ls 1  title "Vanilla (Copying)",\
'< sort -gk1 PACKETMILL-TX-cachemisses-max-stats.dat' using ($1/1000000000):($4) with lines ls 2 dt 3 notitle,\
'< sort -gk1 PACKETMILL-TX-cachemisses-max-stats.dat' using ($1/1000000000):($4) with points ls 2 title "PacketMill (X-Change)";

set yrange [0:*]
set ylabel "L1-dcache Load Misses" font "Helvetica,16"
set xlabel "Offered Load (Gbps)" font "Helvetica,14"
set output 'tx-L1dcache-load-misses-bar.pdf'
plot '< sort -gk1 COPY-TX-cachemisses-max-stats.dat' using ($1/1000000000):($9) with lines ls 1 dt 2 notitle,\
'< sort -gk1 COPY-TX-cachemisses-max-stats.dat' using ($1/1000000000):($9) with points ls 1  title "Vanilla (Copying)",\
'< sort -gk1 PACKETMILL-TX-cachemisses-max-stats.dat' using ($1/1000000000):($9) with lines ls 2 dt 3 notitle,\
'< sort -gk1 PACKETMILL-TX-cachemisses-max-stats.dat' using ($1/1000000000):($9) with points ls 2 title "PacketMill (X-Change)";



set yrange [0:*]
set ylabel "LLC Loads (k)" font "Helvetica,16"
set xlabel "Offered Load (Gbps)" font "Helvetica,14"
set output 'tx-LLC-loads-bar.pdf'
plot '< sort -gk1 COPY-TX-LLCmisses-max-stats.dat' using ($1/1000000000):($4/1000) with lines ls 1 dt 2 notitle,\
'< sort -gk1 COPY-TX-LLCmisses-max-stats.dat' using ($1/1000000000):($4/1000) with points ls 1  title "Vanilla (Copying)",\
'< sort -gk1 PACKETMILL-TX-LLCmisses-max-stats.dat' using ($1/1000000000):($4/1000) with lines ls 2 dt 3 notitle,\
'< sort -gk1 PACKETMILL-TX-LLCmisses-max-stats.dat' using ($1/1000000000):($4/1000) with points ls 2 title "PacketMill (X-Change)";


set yrange [0:*]
set ylabel "LLC Load Misses" font "Helvetica,16"
set xlabel "Offered Load (Gbps)" font "Helvetica,14"
set output 'tx-LLC-load-misses-bar.pdf'
plot '< sort -gk1 COPY-TX-LLCmisses-max-stats.dat' using ($1/1000000000):($9) with lines ls 1 dt 2 notitle,\
'< sort -gk1 COPY-TX-LLCmisses-max-stats.dat' using ($1/1000000000):($9) with points ls 1  title "Vanilla (Copying)",\
'< sort -gk1 PACKETMILL-TX-LLCmisses-max-stats.dat' using ($1/1000000000):($9) with lines ls 2 dt 3 notitle,\
'< sort -gk1 PACKETMILL-TX-LLCmisses-max-stats.dat' using ($1/1000000000):($9) with points ls 2 title "PacketMill (X-Change)";

set ytics 0,100
set key font "Helvetica, 12" vertical Left left top reverse noinvert
set ylabel "Throughput (Gbps)" font "Helvetica,16"
set y2label "99^{th} Percentile Latency ({/Symbol m}s)" font "Helvetica,16"
set y2tics font "Helvetica, 16" 
set terminal pdf
set output 'tx-thourghput-lat99-bar.pdf'
plot '< sort -gk1 PACKETMILL-TX-throughput-lat99-max-stats.dat  | tail -n +3' using ($1/1000000000):($4/1000000000):($2/1000000000):($6/1000000000) with errorbars ls 2 title "PacketMill (X-Change) - Throughput" axes x1y1,\
'< sort -gk1 COPY-TX-throughput-lat99-max-stats.dat  | tail -n +3' using ($1/1000000000):($9) with lines ls 2 dt 2 notitle axes x1y2,\
'< sort -gk1 COPY-TX-throughput-lat99-max-stats.dat  | tail -n +3' using ($1/1000000000):($4/1000000000) with lines ls 1 dt 2 notitle axes x1y1,\
'< sort -gk1 COPY-TX-throughput-lat99-max-stats.dat  | tail -n +3' using ($1/1000000000):($4/1000000000):($2/1000000000):($6/1000000000) with errorbars ls 1  title "Vanilla (Copying) - Throughput" axes x1y1,\
'< sort -gk1 COPY-TX-throughput-lat99-max-stats.dat  | tail -n +3' using ($1/1000000000):($9):($7):($11) with errorbars ls 2 title "Vanilla (Copying) - Latency" axes x1y2,\
'< sort -gk1 PACKETMILL-TX-throughput-lat99-max-stats.dat  | tail -n +3' using ($1/1000000000):($9) with lines ls 3 dt 3 notitle axes x1y2,\
'< sort -gk1 PACKETMILL-TX-throughput-lat99-max-stats.dat  | tail -n +3' using ($1/1000000000):($4/1000000000) with lines ls 2 dt 3 notitle axes x1y1,\
'< sort -gk1 PACKETMILL-TX-throughput-lat99-max-stats.dat  | tail -n +3' using ($1/1000000000):($9):($7):($11) with errorbars ls 3 title "PacketMill (X-Change) - Latency" axes x1y2;


# set ylabel "99^{th} Percentile Latency ({/Symbol m}s)" font "Helvetica,16"
# unset key
# set key font "Helvetica, 12" vertical Left right top reverse noinvert
# set yrange [0:700]

# set terminal pdf
# set output 'lat99-bar.pdf'
# plot "NOLTO-lat99-min-stats.dat" using (0.75):($1) with boxes ls 1 title "COPY (w/o LTO)" ,\
# "NOLTO-lat99-min-stats.dat" using (0.75):($1):($2):($3) with yerrorb linecolor rgb 'black' lt 1 lw 1 notitle,\
# "LTO-lat99-min-stats.dat" using (1):($1) with boxes ls 3 title "COPY (LTO)" ,\
# "LTO-lat99-min-stats.dat" using (1):($1):($2):($3) with yerrorb linecolor rgb 'black' lt 1 lw 1 notitle,\
# "LTOREORDER-lat99-min-stats.dat" using (1.25):($1) with boxes ls 1 title "COPY (LTO) + Reordering" ,\
# "LTOREORDER-lat99-min-stats.dat" using (1.25):($1):($2):($3) with yerrorb linecolor rgb 'black' lt 1 lw 1 notitle,\
# "NOLTO-lat99-nominal-stats.dat" using (1.75):($1) with boxes ls 1 notitle ,\
# "NOLTO-lat99-nominal-stats.dat" using (1.75):($1):($2):($3) with yerrorb linecolor rgb 'black' lt 1 lw 1 notitle,\
# "LTO-lat99-nominal-stats.dat" using (2):($1) with boxes ls 3 notitle ,\
# "LTO-lat99-nominal-stats.dat" using (2):($1):($2):($3) with yerrorb linecolor rgb 'black' lt 1 lw 1 notitle,\
# "LTOREORDER-lat99-nominal-stats.dat" using (2.25):($1) with boxes ls 1 notitle ,\
# "LTOREORDER-lat99-nominal-stats.dat" using (2.25):($1):($2):($3) with yerrorb linecolor rgb 'black' lt 1 lw 1 notitle,\
# "NOLTO-lat99-max-stats.dat" using (2.75):($1) with boxes ls 1 notitle ,\
# "NOLTO-lat99-max-stats.dat" using (2.75):($1):($2):($3) with yerrorb linecolor rgb 'black' lt 1 lw 1 notitle,\
# "LTO-lat99-max-stats.dat" using (3):($1) with boxes ls 3 notitle ,\
# "LTO-lat99-max-stats.dat" using (3):($1):($2):($3) with yerrorb linecolor rgb 'black' lt 1 lw 1 notitle,\
# "LTOREORDER-lat99-max-stats.dat" using (3.25):($1) with boxes ls 1 notitle ,\
# "LTOREORDER-lat99-max-stats.dat" using (3.25):($1):($2):($3) with yerrorb linecolor rgb 'black' lt 1 lw 1 notitle;
