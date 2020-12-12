set terminal postscript eps color enhanced "Helvetica" 38 size 20,5
set style fill solid 1 border -1 
set style boxplot nooutliers
set style boxplot fraction 1.00
set style data boxplot
set boxwidth 0.25
#set xlabel "Number of Ways for I/O" font "Helvetica,16"

set xlabel "Processor Frequency" font "Helvetica,14"
set ylabel "Average Cache Misses (k)" font "Helvetica,16"
# set xtics ("1.2 GHz\n{/*0.8(min)}" 1, "2.3 GHz\n{/*0.8(nominal)}" 2, "3.7 GHz\n{/*0.8(max)}" 3) font "Helvetica, 12"  offset 0,0.4
set xtics ("1.2 GHz\n{/*0.8(min)}" 1, "3.7 GHz\n{/*0.8(max)}" 2) font "Helvetica, 16"  #offset 0,0.4
set ytic font "Helvetica, 16" 

set yrange [0:*]
set xrange [0.5:2.5]

set offsets graph 0, 0, 0.05, 0.05 
set grid
# set parametric
unset key

#Throughput

do for [f in "NOLTO BOTHLTO BOTHLTOREORDER"]{
	set print f.'-throughput-min-stats.dat'
    stats f.'THROUGHPUT.csv' using 1 prefix f nooutput
    print sprintf("#%s", "median lo_quartile up_quartile")
    print sprintf("%e %e %e", value(f.'_median'), value(f.'_lo_quartile'), value(f.'_up_quartile'))
}

do for [f in "NOLTO BOTHLTO BOTHLTOREORDER"]{
	set print f.'-throughput-max-stats.dat'
    stats f.'THROUGHPUT.csv' using 3 prefix f nooutput
    print sprintf("#%s", "median lo_quartile up_quartile")
    print sprintf("%e %e %e", value(f.'_median'), value(f.'_lo_quartile'), value(f.'_up_quartile'))
}

#PPS

do for [f in "NOLTO BOTHLTO BOTHLTOREORDER"]{
	set print f.'-pps-min-stats.dat'
    stats f.'PPS.csv' using 1 prefix f nooutput
    print sprintf("#%s", "median lo_quartile up_quartile")
    print sprintf("%e %e %e", value(f.'_median'), value(f.'_lo_quartile'), value(f.'_up_quartile'))
}

do for [f in "NOLTO BOTHLTO BOTHLTOREORDER"]{
	set print f.'-pps-max-stats.dat'
    stats f.'PPS.csv' using 3 prefix f nooutput
    print sprintf("#%s", "median lo_quartile up_quartile")
    print sprintf("%e %e %e", value(f.'_median'), value(f.'_lo_quartile'), value(f.'_up_quartile'))
}

#LLC-load-misses

do for [f in "NOLTO BOTHLTO BOTHLTOREORDER"]{
	set print f.'-llc-load-misses-min-stats.dat'
    stats f.'LLC-load-misses-avg-C0.csv' using 1 prefix f nooutput
    print sprintf("#%s", "median lo_quartile up_quartile")
    print sprintf("%e %e %e", value(f.'_median'), value(f.'_lo_quartile'), value(f.'_up_quartile'))
}

do for [f in "NOLTO BOTHLTO BOTHLTOREORDER"]{
	set print f.'-llc-load-misses-max-stats.dat'
    stats f.'LLC-load-misses-avg-C0.csv' using 3 prefix f nooutput
    print sprintf("#%s", "median lo_quartile up_quartile")
    print sprintf("%e %e %e", value(f.'_median'), value(f.'_lo_quartile'), value(f.'_up_quartile'))
}

#LLC-loads

do for [f in "NOLTO BOTHLTO BOTHLTOREORDER"]{
	set print f.'-llc-loads-min-stats.dat'
    stats f.'LLC-loads-avg-C0.csv' using 1 prefix f nooutput
    print sprintf("#%s", "median lo_quartile up_quartile")
    print sprintf("%e %e %e", value(f.'_median'), value(f.'_lo_quartile'), value(f.'_up_quartile'))
}


do for [f in "NOLTO BOTHLTO BOTHLTOREORDER"]{
	set print f.'-llc-loads-max-stats.dat'
    stats f.'LLC-loads-avg-C0.csv' using 3 prefix f nooutput
    print sprintf("#%s", "median lo_quartile up_quartile")
    print sprintf("%e %e %e", value(f.'_median'), value(f.'_lo_quartile'), value(f.'_up_quartile'))
}

#L1-dcache-loads

do for [f in "NOLTO BOTHLTO BOTHLTOREORDER"]{
	set print f.'-L1-dcache-loads-min-stats.dat'
    stats f.'L1-dcache-loads-avg-C0.csv' using 1 prefix f nooutput
    print sprintf("#%s", "median lo_quartile up_quartile")
    print sprintf("%e %e %e", value(f.'_median'), value(f.'_lo_quartile'), value(f.'_up_quartile'))
}


do for [f in "NOLTO BOTHLTO BOTHLTOREORDER"]{
	set print f.'-lL1-dcache-loads-max-stats.dat'
    stats f.'L1-dcache-loads-avg-C0.csv' using 3 prefix f nooutput
    print sprintf("#%s", "median lo_quartile up_quartile")
    print sprintf("%e %e %e", value(f.'_median'), value(f.'_lo_quartile'), value(f.'_up_quartile'))
}


#L1-dcache-load-misses

do for [f in "NOLTO BOTHLTO BOTHLTOREORDER"]{
	set print f.'-L1-dcache-load-missess-min-stats.dat'
    stats f.'L1-dcache-load-misses-avg-C0.csv' using 1 prefix f nooutput
    print sprintf("#%s", "median lo_quartile up_quartile")
    print sprintf("%e %e %e", value(f.'_median'), value(f.'_lo_quartile'), value(f.'_up_quartile'))
}

do for [f in "NOLTO BOTHLTO BOTHLTOREORDER"]{
	set print f.'-L1-dcache-load-misses-max-stats.dat'
    stats f.'L1-dcache-load-misses-avg-C0.csv' using 3 prefix f nooutput
    print sprintf("#%s", "median lo_quartile up_quartile")
    print sprintf("%e %e %e", value(f.'_median'), value(f.'_lo_quartile'), value(f.'_up_quartile'))
}

#L1-icache-load-misses

do for [f in "NOLTO BOTHLTO BOTHLTOREORDER"]{
    set print f.'-L1-icache-load-misses-min-stats.dat'
    stats f.'L1-icache-load-misses-avg-C0.csv' using 1 prefix f nooutput
    print sprintf("#%s", "median lo_quartile up_quartile")
    print sprintf("%e %e %e", value(f.'_median'), value(f.'_lo_quartile'), value(f.'_up_quartile'))
}

do for [f in "NOLTO BOTHLTO BOTHLTOREORDER"]{
    set print f.'-L1-icache-load-misses-max-stats.dat'
    stats f.'L1-icache-load-misses-avg-C0.csv' using 3 prefix f nooutput
    print sprintf("#%s", "median lo_quartile up_quartile")
    print sprintf("%e %e %e", value(f.'_median'), value(f.'_lo_quartile'), value(f.'_up_quartile'))
}

#IPC

do for [f in "NOLTO BOTHLTO BOTHLTOREORDER"]{
    set print f.'-ipc-min-stats.dat'
    stats f.'cycles-avg-C0.csv' using 1 prefix "cycle" nooutput
    stats f.'instructions-avg-C0.csv' using 1 prefix "inst" nooutput
    print sprintf("#%s %s", "instruction_median", "cycles_median")
    print sprintf("%e %e %e", value(inst_median), value(cycle_median), value(inst_median/cycle_median))
}

do for [f in "NOLTO BOTHLTO BOTHLTOREORDER"]{
    set print f.'-ipc-max-stats.dat'
    stats f.'cycles-avg-C0.csv' using 3 prefix "cycle" nooutput
    stats f.'instructions-avg-C0.csv' using 3 prefix "inst" nooutput
    print sprintf("#%s %s", "instruction_median", "cycles_median")
    print sprintf("%e %e %e", value(inst_median), value(cycle_median), value(inst_median/cycle_median))
}

#Lat50

do for [f in "NOLTO BOTHLTO BOTHLTOREORDER"]{
	set print f.'-lat50-min-stats.dat'
    stats f.'LAT50.csv' using 1 prefix f nooutput
    print sprintf("#%s", "median lo_quartile up_quartile")
    print sprintf("%e %e %e", value(f.'_median'), value(f.'_lo_quartile'), value(f.'_up_quartile'))
}

do for [f in "NOLTO BOTHLTO BOTHLTOREORDER"]{
	set print f.'-lat50-max-stats.dat'
    stats f.'LAT50.csv' using 3 prefix f nooutput
    print sprintf("#%s", "median lo_quartile up_quartile")
    print sprintf("%e %e %e", value(f.'_median'), value(f.'_lo_quartile'), value(f.'_up_quartile'))
}

#Lat99

do for [f in "NOLTO BOTHLTO BOTHLTOREORDER"]{
	set print f.'-lat99-min-stats.dat'
    stats f.'LAT99.csv' using 1 prefix f nooutput
    print sprintf("#%s", "median lo_quartile up_quartile")
    print sprintf("%e %e %e", value(f.'_median'), value(f.'_lo_quartile'), value(f.'_up_quartile'))
}


do for [f in "NOLTO BOTHLTO BOTHLTOREORDER"]{
	set print f.'-lat99-max-stats.dat'
    stats f.'LAT99.csv' using 3 prefix f nooutput
    print sprintf("#%s", "median lo_quartile up_quartile")
    print sprintf("%e %e %e", value(f.'_median'), value(f.'_lo_quartile'), value(f.'_up_quartile'))
}

set style line 1 linecolor rgb '#f0f9e8'  # Vanilla
set style line 2 linecolor rgb '#bae4bc'  # Devitualization
set style line 3 linecolor rgb '#7bccc4'  # Constants
set style line 4 linecolor rgb '#43a2ca'  # Inliner
set style line 5 linecolor rgb '#0868ac'  # Graph

set ylabel "Throughput (Gbps)" font "Helvetica,16"
set key font "Helvetica, 14" vertical Left left top reverse invert
set yrange [0:105]

set terminal pdf
set output 'throughput-bar.pdf'
plot "NOLTO-throughput-min-stats.dat" using (0.75):($1/1000000000) with boxes ls 1 title "Vanilla (w/o LTO)" ,\
"NOLTO-throughput-min-stats.dat" using (0.75):($1/1000000000):($2/1000000000):($3/1000000000) with yerrorb linecolor rgb 'black' lt 1 lw 1 notitle,\
"BOTHLTO-throughput-min-stats.dat" using (1):($1/1000000000) with boxes ls 3 title "Vanilla (LTO)" ,\
"BOTHLTO-throughput-min-stats.dat" using (1):($1/1000000000):($2/1000000000):($3/1000000000) with yerrorb linecolor rgb 'black' lt 1 lw 1 notitle,\
"BOTHLTOREORDER-throughput-min-stats.dat" using (1.25):($1/1000000000) with boxes ls 5 title "Vanilla (LTO) + Reordering" ,\
"BOTHLTOREORDER-throughput-min-stats.dat" using (1.25):($1/1000000000):($2/1000000000):($3/1000000000) with yerrorb linecolor rgb 'black' lt 1 lw 1 notitle,\
"NOLTO-throughput-max-stats.dat" using (1.75):($1/1000000000) with boxes ls 1 notitle ,\
"NOLTO-throughput-max-stats.dat" using (1.75):($1/1000000000):($2/1000000000):($3/1000000000) with yerrorb linecolor rgb 'black' lt 1 lw 1 notitle,\
"BOTHLTO-throughput-max-stats.dat" using (2):($1/1000000000) with boxes ls 3 notitle ,\
"BOTHLTO-throughput-max-stats.dat" using (2):($1/1000000000):($2/1000000000):($3/1000000000) with yerrorb linecolor rgb 'black' lt 1 lw 1 notitle,\
"BOTHLTOREORDER-throughput-max-stats.dat" using (2.25):($1/1000000000) with boxes ls 5 notitle ,\
"BOTHLTOREORDER-throughput-max-stats.dat" using (2):($1/1000000000):($2/1000000000):($3/1000000000) with yerrorb linecolor rgb 'black' lt 1 lw 1 notitle;

set ylabel "Median Latency ({/Symbol m}s)" font "Helvetica,16"
unset key
# set key font "Helvetica, 12" vertical Left right top reverse noinvert
set yrange [0:600]

set terminal pdf
set output 'lat50-bar.pdf'
plot "NOLTO-lat50-min-stats.dat" using (0.75):($1) with boxes ls 1 title "Vanilla" ,\
"NOLTO-lat50-min-stats.dat" using (0.75):($1):($2):($3) with yerrorb linecolor rgb 'black' lt 1 lw 1 notitle,\
"BOTHLTO-lat50-min-stats.dat" using (1):($1) with boxes ls 3 title "Devirtualization" ,\
"BOTHLTO-lat50-min-stats.dat" using (1):($1):($2):($3) with yerrorb linecolor rgb 'black' lt 1 lw 1 notitle,\
"BOTHLTOREORDER-lat50-min-stats.dat" using (1.25):($1) with boxes ls 5 title "Constant Embedding" ,\
"BOTHLTOREORDER-lat50-min-stats.dat" using (1.25):($1):($2):($3) with yerrorb linecolor rgb 'black' lt 1 lw 1 notitle,\
"NOLTO-lat50-max-stats.dat" using (1.75):($1) with boxes ls 1 notitle ,\
"NOLTO-lat50-max-stats.dat" using (1.75):($1):($2):($3) with yerrorb linecolor rgb 'black' lt 1 lw 1 notitle,\
"BOTHLTO-lat50-max-stats.dat" using (2):($1) with boxes ls 3 notitle ,\
"BOTHLTO-lat50-max-stats.dat" using (2):($1):($2):($3) with yerrorb linecolor rgb 'black' lt 1 lw 1 notitle,\
"BOTHLTOREORDER-lat50-max-stats.dat" using (2.25):($1) with boxes ls 5 notitle ,\
"BOTHLTOREORDER-lat50-max-stats.dat" using (2.25):($1):($2):($3) with yerrorb linecolor rgb 'black' lt 1 lw 1 notitle;


set ylabel "99^{th} Percentile Latency ({/Symbol m}s)" font "Helvetica,16"
unset key
# set key font "Helvetica, 12" vertical Left right top reverse noinvert
set yrange [0:650]

set terminal pdf
set output 'lat99-bar.pdf'
plot "NOLTO-lat99-min-stats.dat" using (0.75):($1) with boxes ls 1 title "Vanilla" ,\
"NOLTO-lat99-min-stats.dat" using (0.75):($1):($2):($3) with yerrorb linecolor rgb 'black' lt 1 lw 1 notitle,\
"BOTHLTO-lat99-min-stats.dat" using (1):($1) with boxes ls 3 title "Devirtualization" ,\
"BOTHLTO-lat99-min-stats.dat" using (1):($1):($2):($3) with yerrorb linecolor rgb 'black' lt 1 lw 1 notitle,\
"BOTHLTOREORDER-lat99-min-stats.dat" using (1.25):($1) with boxes ls 5 title "Constant Embedding" ,\
"BOTHLTOREORDER-lat99-min-stats.dat" using (1.25):($1):($2):($3) with yerrorb linecolor rgb 'black' lt 1 lw 1 notitle,\
"NOLTO-lat99-max-stats.dat" using (1.75):($1) with boxes ls 1 notitle ,\
"NOLTO-lat99-max-stats.dat" using (1.75):($1):($2):($3) with yerrorb linecolor rgb 'black' lt 1 lw 1 notitle,\
"BOTHLTO-lat99-max-stats.dat" using (2):($1) with boxes ls 3 notitle ,\
"BOTHLTO-lat99-max-stats.dat" using (2):($1):($2):($3) with yerrorb linecolor rgb 'black' lt 1 lw 1 notitle,\
"BOTHLTOREORDER-lat99-max-stats.dat" using (2.25):($1) with boxes ls 5 notitle ,\
"BOTHLTOREORDER-lat99-max-stats.dat" using (2.25):($1):($2):($3) with yerrorb linecolor rgb 'black' lt 1 lw 1 notitle;
