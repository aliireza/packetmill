set terminal postscript eps color enhanced "Helvetica" 38 size 20,5
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

do for [f in "Vanilla Devirtualize Constant Graph All"]{
    set print f.'-throughput-stats.dat'
    freq(n) = word("1.2 1.4 1.6 1.8 2.0 2.2 2.4 2.6 2.8 3.0", n)
    print sprintf("#%s %s %s %s", "X", "Throughput-median", "Throughput-min", "Throughput-max")
    do for [i=1:10] {
    stats f.'THROUGHPUT.csv' using i prefix "TH" nooutput
    print sprintf("%s %e %e %e", freq(i), value(TH_median), value(TH_min), value(TH_max))
    }
}

#PPS

do for [f in "Vanilla Devirtualize Constant Graph All"]{
    set print f.'-pps-stats.dat'
    freq(n) = word("1.2 1.4 1.6 1.8 2.0 2.2 2.4 2.6 2.8 3.0", n)
    print sprintf("#%s %s %s %s", "X", "PPS-median", "PPS-min", "PPS-max")
    do for [i=1:10] {
    stats f.'PPS.csv' using i prefix "TH" nooutput
    print sprintf("%s %e %e %e", freq(i), value(TH_median), value(TH_min), value(TH_max))
    }
}


#LLC-load-misses

do for [f in "Vanilla Devirtualize Constant Graph All"]{
    set print f.'-llc-load-misses-stats.dat'
    freq(n) = word("1.2 1.4 1.6 1.8 2.0 2.2 2.4 2.6 2.8 3.0", n)
    print sprintf("#%s %s %s %s", "X", "llc-loads-median", "llc-loads-min", "llc-loads-max")
    do for [i=1:10] {
    stats f.'LLC-load-misses-avg-C0.csv' using i prefix "TH" nooutput
    print sprintf("%s %e %e %e", freq(i), value(TH_median), value(TH_min), value(TH_max))
    }
}


#LLC-loads

do for [f in "Vanilla Devirtualize Constant Graph All"]{
    set print f.'-llc-loads-stats.dat'
    freq(n) = word("1.2 1.4 1.6 1.8 2.0 2.2 2.4 2.6 2.8 3.0", n)
    print sprintf("#%s %s %s %s", "X", "llc-loads-median", "llc-loads-min", "llc-loads-max")
    do for [i=1:10] {
    stats f.'LLC-loads-avg-C0.csv' using i prefix "TH" nooutput
    print sprintf("%s %e %e %e", freq(i), value(TH_median), value(TH_min), value(TH_max))
    }
}


#L1-dcache-loads

do for [f in "Vanilla Devirtualize Constant Graph All"]{
    set print f.'-L1-dcache-loads-stats.dat'
    freq(n) = word("1.2 1.4 1.6 1.8 2.0 2.2 2.4 2.6 2.8 3.0", n)
    print sprintf("#%s %s %s %s", "X", "L1-dcache-loads-median", "L1-dcache-loads-min", "L1-dcache-loads-max")
    do for [i=1:10] {
    stats f.'L1-dcache-loads-avg-C0.csv' using i prefix "TH" nooutput
    print sprintf("%s %e %e %e", freq(i), value(TH_median), value(TH_min), value(TH_max))
    }
}


#L1-dcache-load-misses

do for [f in "Vanilla Devirtualize Constant Graph All"]{
    set print f.'-L1-dcache-load-misses-stats.dat'
    freq(n) = word("1.2 1.4 1.6 1.8 2.0 2.2 2.4 2.6 2.8 3.0", n)
    print sprintf("#%s %s %s %s", "X", "L1-dcache-load-misses-median", "L1-dcache-load-misses-min", "L1-dcache-load-misses-max")
    do for [i=1:10] {
    stats f.'L1-dcache-load-misses-avg-C0.csv' using i prefix "TH" nooutput
    print sprintf("%s %e %e %e", freq(i), value(TH_median), value(TH_min), value(TH_max))
    }
}


#L1-icache-load-misses


do for [f in "Vanilla Devirtualize Constant Graph All"]{
    set print f.'-L1-icache-load-misses-stats.dat'
    freq(n) = word("1.2 1.4 1.6 1.8 2.0 2.2 2.4 2.6 2.8 3.0", n)
    print sprintf("#%s %s %s %s", "X", "L1-icache-load-misses-median", "L1-icache-load-misses-min", "L1-icache-load-misses-max")
    do for [i=1:10] {
    stats f.'L1-icache-load-misses-avg-C0.csv' using i prefix "TH" nooutput
    print sprintf("%s %e %e %e", freq(i), value(TH_median), value(TH_min), value(TH_max))
    }
}


#IPC

do for [f in "Vanilla Devirtualize Constant Graph All"]{
    set print f.'-ipc-stats.dat'
    freq(n) = word("1.2 1.4 1.6 1.8 2.0 2.2 2.4 2.6 2.8 3.0", n)
    print sprintf("#%s %s %s %s", "X", "instruction_median", "cycles_median")
    do for [i=1:10] {
    stats f.'cycles-avg-C0.csv' using i prefix "cycle" nooutput
    stats f.'instructions-avg-C0.csv' using i prefix "inst" nooutput
    print sprintf("%s %e %e %e", freq(i), value(inst_median/cycle_median), value(inst_median), value(cycle_median))
    }
}

# #Lat50

do for [f in "Vanilla Devirtualize Constant Graph All"]{
    set print f.'-lat50-stats.dat'
    freq(n) = word("1.2 1.4 1.6 1.8 2.0 2.2 2.4 2.6 2.8 3.0", n)
    print sprintf("#%s %s %s %s", "X", "lat50-median", "lat50-min", "lat50-max")
    do for [i=1:10] {
    stats f.'LAT50.csv' using i prefix "TH" nooutput
    print sprintf("%s %e %e %e", freq(i), value(TH_median), value(TH_min), value(TH_max))
    }
}

# #Lat99

do for [f in "Vanilla Devirtualize Constant Graph All"]{
    set print f.'-lat99-stats.dat'
    freq(n) = word("1.2 1.4 1.6 1.8 2.0 2.2 2.4 2.6 2.8 3.0", n)
    print sprintf("#%s %s %s %s", "X", "lat99-median", "lat99-min", "lat99-max")
    do for [i=1:10] {
    stats f.'LAT99.csv' using i prefix "TH" nooutput
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
unset xlabel
set grid

set terminal pdf
set output 'throughput-bar.pdf'
plot "Vanilla-throughput-stats.dat" using ($1):($2/1000000000) with points ls 1 title "Vanilla",\
"Vanilla-throughput-stats.dat" using ($1):($2/1000000000) with lines ls 1 dt 2 notitle,\
"Devirtualize-throughput-stats.dat" using ($1):($2/1000000000) with points ls 2 title "Devirtualize",\
"Devirtualize-throughput-stats.dat" using ($1):($2/1000000000) with lines ls 2 dt 3 notitle,\
"Constant-throughput-stats.dat" using ($1):($2/1000000000) with points ls 3 title "Constant Embedding",\
"Constant-throughput-stats.dat" using ($1):($2/1000000000) with lines ls 3 dt 4 notitle,\
"Graph-throughput-stats.dat" using ($1):($2/1000000000) with points ls 4 title "Static Graph {/*1(elements + connections)}",\
"Graph-throughput-stats.dat" using ($1):($2/1000000000) with lines ls 4 dt 5 notitle,\
"All-throughput-stats.dat" using ($1):($2/1000000000) with points ls 5 title "All",\
"All-throughput-stats.dat" using ($1):($2/1000000000) with lines ls 5 dt 2 notitle;

v(x)=6.854e+09+ 2.250e+10* x #vanilla 0.998
d(x)=7.486e+09 + 2.338e+10 * x #devirtualize 0.998
c(x)= 7.631e+09+ 2.355e+10 * x #constants 0.9981
g(x)= 2.594e+09+ 2.806e+10 * x #graph 0.9996
a(x)=2.903e+09 + 2.865e+10 *x # All 0.9996

set style data lines

# set label 1 at 1.75,33 left "All(f) = 2.903e+09 + 2.865e+10f (R^{2}=0.9996)" tc 'black' font "Helvetica-Bold, 12" front
# set label 2 at 1.75,26 left "Graph(f) = 2.594e+09+ 2.806e+10f (R^{2}=0.9996)" tc 'black' font "Helvetica-Bold, 12" front
# set label 3 at 1.75,19 left "Constant(f) = 7.631e+09+ 2.355e+10f (R^{2}=0.9981)" tc 'black' font "Helvetica-Bold, 12" front
# set label 4 at 1.75,12 left "Devirt(f) = 7.486e+09 + 2.338e+10f (R^{2}=0.998)" tc 'black' font "Helvetica-Bold, 12" front
# set label 5 at 1.75,5 left "Vanilla(f) =  6.854e+09 + 2.250e+10f (R^{2}=0.998)" tc 'black' font "Helvetica-Bold, 12" front

set label 1 at 1.75,33 left "All(f) = 2.903 + 28.65f (R^{2}=0.9996)" tc 'black' font "Helvetica-Bold, 12" front
set label 2 at 1.75,26 left "Graph(f) = 2.594 + 28.06f (R^{2}=0.9996)" tc 'black' font "Helvetica-Bold, 12" front
set label 3 at 1.75,19 left "Constant(f) = 7.631 + 23.55f (R^{2}=0.9981)" tc 'black' font "Helvetica-Bold, 12" front
set label 4 at 1.75,12 left "Devirt(f) = 7.486 + 23.38f (R^{2}=0.998)" tc 'black' font "Helvetica-Bold, 12" front
set label 5 at 1.75,5 left "Vanilla(f) =  6.854 + 22.50f (R^{2}=0.998)" tc 'black' font "Helvetica-Bold, 12" front


set terminal pdf
set output 'throughput-bar-equation.pdf'
plot "Vanilla-throughput-stats.dat" using ($1):($2/1000000000) with points ls 1 title "Vanilla",\
[t=1.2:3] v(t)/1000000000 with lines ls 1 dt 2 notitle,\
"Devirtualize-throughput-stats.dat" using ($1):($2/1000000000) with points ls 2 title "Devirtualize",\
[t=1.2:3] d(t)/1000000000  with lines ls 2 dt 3 notitle,\
"Constant-throughput-stats.dat" using ($1):($2/1000000000) with points ls 3 title "Constant Embedding",\
[t=1.2:3] c(t)/1000000000  with lines ls 3 dt 4 notitle,\
"Graph-throughput-stats.dat" using ($1):($2/1000000000) with points ls 4 title "Static Graph {/*1(elements + connections)}",\
[t=1.2:3] g(t)/1000000000  with lines ls 4 dt 5 notitle,\
"All-throughput-stats.dat" using ($1):($2/1000000000) with points ls 5 title "All",\
[t=1.2:3] a(t)/1000000000  with lines ls 5 dt 2 notitle;

set ylabel "Median Latency ({/Symbol m}s)" font "Helvetica,16"
unset key
# set key font "Helvetica, 12" vertical Left right top reverse noinvert
set yrange [0:600]

unset label 1
unset label 2
unset label 3
unset label 4
unset label 5

set xtics ("1.2" 1.2, "1.4" 1.4, "1.6" 1.6, "1.8" 1.8, "2.0" 2, "2.2" 2.2, "2.4" 2.4, "2.6" 2.6, "2.8" 2.8, "3.0" 3) font "Helvetica, 16"  #offset 0,0.4
set ytic font "Helvetica, 16" 
set xlabel "Processor Frequency (GHz)" font "Helvetica,14"

set terminal pdf
set output 'lat50-bar.pdf'
plot "Vanilla-lat50-stats.dat" using ($1):($2) with points ls 1 title "Vanilla",\
"Vanilla-lat50-stats.dat" using ($1):($2) with lines ls 1 dt 2 notitle,\
"Devirtualize-lat50-stats.dat" using ($1):($2) with points ls 2 title "Devirtualize",\
"Devirtualize-lat50-stats.dat" using ($1):($2) with lines ls 2 dt 2 notitle,\
"Constant-lat50-stats.dat" using ($1):($2) with points ls 3 title "Constant Embedding",\
"Constant-lat50-stats.dat" using ($1):($2) with lines ls 3 dt 2 notitle,\
"Graph-lat50-stats.dat" using ($1):($2) with points ls 4 title "Static Graph {/*1(elements + connections)}",\
"Graph-lat50-stats.dat" using ($1):($2) with lines ls 4 dt 2 notitle,\
"All-lat50-stats.dat" using ($1):($2) with points ls 5 title "All",\
"All-lat50-stats.dat" using ($1):($2) with lines ls 5 dt 2 notitle;


set xtics ("1.2" 1.2, "1.4" 1.4, "1.6" 1.6, "1.8" 1.8, "2.0" 2, "2.2" 2.2, "2.4" 2.4, "2.6" 2.6, "2.8" 2.8, "3.0" 3) font "Helvetica, 16"  #offset 0,0.4
set ytic font "Helvetica, 16" 
set xlabel "Processor Frequency (GHz)" font "Helvetica,14"

set label 6 at 1.2,200 left "All(f) = 521.353 - 212.234f + 39.560f^{2} (R^{2}=0.9655)" tc 'black' font "Helvetica-Bold, 12" front
set label 7 at 1.2,160 left "Graph(f) = 539.193 - 224.627f + 41.809f^{2} (R^{2}=0.9651)" tc 'black' font "Helvetica-Bold, 12" front
set label 8 at 1.2,120 left "Constant(f) = 821.29 - 334.06f + 57.53f^{2} (R^{2}=0.9925)" tc 'black' font "Helvetica-Bold, 12" front
set label 9 at 1.2,80 left "Devirt(f) = 831.212 - 341.139f + 58.973f^{2} (R^{2}=0.993)" tc 'black' font "Helvetica-Bold, 12" front
set label 10 at 1.2,40 left "Vanilla(f) =  874.522 - 367.700f + 63.707f^{2} (R^{2}=0.9655)" tc 'black' font "Helvetica-Bold, 12" front


v(x)= 874.522 -367.700*x + 63.707*x**2 #vanilla 0.9954
d(x)= 831.212 -341.139*x + 58.973*x**2 #devirtualize 0.993
c(x)= 821.29 -334.06*x + 57.53*x**2 #constants 0.9925
g(x)= 539.193 -224.627*x + 41.809*x**2 #graph 0.9651
a(x)=521.353 -212.234*x + 39.560*x**2  # All 0.9655

set terminal pdf
set output 'lat50-bar-equation.pdf'
plot "Vanilla-lat50-stats.dat" using ($1):($2) with points ls 1 title "Vanilla",\
[t=1.2:3] v(t) with lines ls 1 dt 2 notitle,\
"Devirtualize-lat50-stats.dat" using ($1):($2) with points ls 2 title "Devirtualize",\
[t=1.2:3] d(t) with lines ls 2 dt 2 notitle,\
"Constant-lat50-stats.dat" using ($1):($2) with points ls 3 title "Constant Embedding",\
[t=1.2:3] c(t) with lines ls 3 dt 2 notitle,\
"Graph-lat50-stats.dat" using ($1):($2) with points ls 4 title "Static Graph {/*1(elements + connections)}",\
[t=1.2:3] g(t) with lines ls 4 dt 2 notitle,\
"All-lat50-stats.dat" using ($1):($2) with points ls 5 title "All",\
[t=1.2:3] a(t)  with lines ls 5 dt 2 notitle;

# plot "Vanilla-throughput-min-stats.dat" using (0.7):($1/1000000000) with boxes ls 1 title "Vanilla" ,\
# "Vanilla-throughput-min-stats.dat" using (0.7):($1/1000000000):($2/1000000000):($3/1000000000) with yerrorb linecolor rgb 'black' lt 1 lw 1 notitle,\
# "Devirtualize-throughput-min-stats.dat" using (0.85):($1/1000000000) with boxes ls 2 title "Devirtualization" ,\
# "Devirtualize-throughput-min-stats.dat" using (0.85):($1/1000000000):($2/1000000000):($3/1000000000) with yerrorb linecolor rgb 'black' lt 1 lw 1 notitle,\
# "Constant-throughput-min-stats.dat" using (1):($1/1000000000) with boxes ls 3 title "Constant Embedding" ,\
# "Constant-throughput-min-stats.dat" using (1):($1/1000000000):($2/1000000000):($3/1000000000) with yerrorb linecolor rgb 'black' lt 1 lw 1 notitle,\
# "Graph-throughput-min-stats.dat" using (1.15):($1/1000000000) with boxes ls 4 title "Static Graph {/*1(elements + connections)}" ,\
# "Graph-throughput-min-stats.dat" using (1.15):($1/1000000000):($2/1000000000):($3/1000000000) with yerrorb linecolor rgb 'black' lt 1 lw 1 notitle ,\
# "All-throughput-min-stats.dat" using (1.3):($1/1000000000) with boxes ls 5 title "All" ,\
# "All-throughput-min-stats.dat" using (1.3):($1/1000000000):($2/1000000000):($3/1000000000) with yerrorb linecolor rgb 'black' lt 1 lw 1 notitle ,\
# "Vanilla-throughput-max-stats.dat" using (1.7):($1/1000000000) with boxes ls 1 notitle ,\
# "Vanilla-throughput-max-stats.dat" using (1.7):($1/1000000000):($2/1000000000):($3/1000000000) with yerrorb linecolor rgb 'black' lt 1 lw 1 notitle,\
# "Devirtualize-throughput-max-stats.dat" using (1.85):($1/1000000000) with boxes ls 2 notitle ,\
# "Devirtualize-throughput-max-stats.dat" using (1.85):($1/1000000000):($2/1000000000):($3/1000000000) with yerrorb linecolor rgb 'black' lt 1 lw 1 notitle,\
# "Constant-throughput-max-stats.dat" using (2):($1/1000000000) with boxes ls 3 notitle ,\
# "Constant-throughput-max-stats.dat" using (2):($1/1000000000):($2/1000000000):($3/1000000000) with yerrorb linecolor rgb 'black' lt 1 lw 1 notitle,\
# "Graph-throughput-max-stats.dat" using (2.15):($1/1000000000) with boxes ls 4 notitle ,\
# "Graph-throughput-max-stats.dat" using (2.15):($1/1000000000):($2/1000000000):($3/1000000000) with yerrorb linecolor rgb 'black' lt 1 lw 1 notitle,\
# "All-throughput-max-stats.dat" using (2.3):($1/1000000000) with boxes ls 5 notitle ,\
# "All-throughput-max-stats.dat" using (2.3):($1/1000000000):($2/1000000000):($3/1000000000) with yerrorb linecolor rgb 'black' lt 1 lw 1 notitle;

# set ylabel "Median Latency ({/Symbol m}s)" font "Helvetica,16"
# unset key
# # set key font "Helvetica, 12" vertical Left right top reverse noinvert
# set yrange [0:1000]

# set terminal pdf
# set output 'lat50-bar.pdf'
# plot "Vanilla-lat50-min-stats.dat" using (0.7):($1) with boxes ls 1 title "Vanilla" ,\
# "Vanilla-lat50-min-stats.dat" using (0.7):($1):($2):($3) with yerrorb linecolor rgb 'black' lt 1 lw 1 notitle,\
# "Devirtualize-lat50-min-stats.dat" using (0.85):($1) with boxes ls 2 title "Devirtualization" ,\
# "Devirtualize-lat50-min-stats.dat" using (0.85):($1):($2):($3) with yerrorb linecolor rgb 'black' lt 1 lw 1 notitle,\
# "Constant-lat50-min-stats.dat" using (1):($1) with boxes ls 3 title "Constant Embedding" ,\
# "Constant-lat50-min-stats.dat" using (1):($1):($2):($3) with yerrorb linecolor rgb 'black' lt 1 lw 1 notitle,\
# "Graph-lat50-min-stats.dat" using (1.15):($1) with boxes ls 4 title "Static Graph {/*1(elements + connections)}" ,\
# "Graph-lat50-min-stats.dat" using (1.15):($1):($2):($3) with yerrorb linecolor rgb 'black' lt 1 lw 1 notitle ,\
# "All-lat50-min-stats.dat" using (1.3):($1) with boxes ls 5 title "All" ,\
# "All-lat50-min-stats.dat" using (1.3):($1):($2):($3) with yerrorb linecolor rgb 'black' lt 1 lw 1 notitle ,\
# "Vanilla-lat50-max-stats.dat" using (1.7):($1) with boxes ls 1 notitle ,\
# "Vanilla-lat50-max-stats.dat" using (1.7):($1):($2):($3) with yerrorb linecolor rgb 'black' lt 1 lw 1 notitle,\
# "Devirtualize-lat50-max-stats.dat" using (1.85):($1) with boxes ls 2 notitle ,\
# "Devirtualize-lat50-max-stats.dat" using (1.85):($1):($2):($3) with yerrorb linecolor rgb 'black' lt 1 lw 1 notitle,\
# "Constant-lat50-max-stats.dat" using (2):($1) with boxes ls 3 notitle ,\
# "Constant-lat50-max-stats.dat" using (2):($1):($2):($3) with yerrorb linecolor rgb 'black' lt 1 lw 1 notitle,\
# "Graph-lat50-max-stats.dat" using (2.15):($1) with boxes ls 4 notitle ,\
# "Graph-lat50-max-stats.dat" using (2.15):($1):($2):($3) with yerrorb linecolor rgb 'black' lt 1 lw 1 notitle,\
# "All-lat50-max-stats.dat" using (2.3):($1) with boxes ls 5 notitle ,\
# "All-lat50-max-stats.dat" using (2.3):($1):($2):($3) with yerrorb linecolor rgb 'black' lt 1 lw 1 notitle;


# set ylabel "99^{th} Percentile Latency ({/Symbol m}s)" font "Helvetica,16"
# unset key
# # set key font "Helvetica, 12" vertical Left right top reverse noinvert
# set yrange [0:1050]

# set terminal pdf
# set output 'lat99-bar.pdf'
# plot "Vanilla-lat99-min-stats.dat" using (0.7):($1) with boxes ls 1 title "Vanilla" ,\
# "Vanilla-lat99-min-stats.dat" using (0.7):($1):($2):($3) with yerrorb linecolor rgb 'black' lt 1 lw 1 notitle,\
# "Devirtualize-lat99-min-stats.dat" using (0.85):($1) with boxes ls 2 title "Devirtualization" ,\
# "Devirtualize-lat99-min-stats.dat" using (0.85):($1):($2):($3) with yerrorb linecolor rgb 'black' lt 1 lw 1 notitle,\
# "Constant-lat99-min-stats.dat" using (1):($1) with boxes ls 3 title "Constant Embedding" ,\
# "Constant-lat99-min-stats.dat" using (1):($1):($2):($3) with yerrorb linecolor rgb 'black' lt 1 lw 1 notitle,\
# "Graph-lat99-min-stats.dat" using (1.15):($1) with boxes ls 4 title "Static Graph {/*1(elements + connections)}" ,\
# "Graph-lat99-min-stats.dat" using (1.15):($1):($2):($3) with yerrorb linecolor rgb 'black' lt 1 lw 1 notitle ,\
# "All-lat99-min-stats.dat" using (1.3):($1) with boxes ls 5 title "All" ,\
# "All-lat99-min-stats.dat" using (1.3):($1):($2):($3) with yerrorb linecolor rgb 'black' lt 1 lw 1 notitle ,\
# "Vanilla-lat99-max-stats.dat" using (1.7):($1) with boxes ls 1 notitle ,\
# "Vanilla-lat99-max-stats.dat" using (1.7):($1):($2):($3) with yerrorb linecolor rgb 'black' lt 1 lw 1 notitle,\
# "Devirtualize-lat99-max-stats.dat" using (1.85):($1) with boxes ls 2 notitle ,\
# "Devirtualize-lat99-max-stats.dat" using (1.85):($1):($2):($3) with yerrorb linecolor rgb 'black' lt 1 lw 1 notitle,\
# "Constant-lat99-max-stats.dat" using (2):($1) with boxes ls 3 notitle ,\
# "Constant-lat99-max-stats.dat" using (2):($1):($2):($3) with yerrorb linecolor rgb 'black' lt 1 lw 1 notitle,\
# "Graph-lat99-max-stats.dat" using (2.15):($1) with boxes ls 4 notitle ,\
# "Graph-lat99-max-stats.dat" using (2.15):($1):($2):($3) with yerrorb linecolor rgb 'black' lt 1 lw 1 notitle,\
# "All-lat99-max-stats.dat" using (2.3):($1) with boxes ls 5 notitle ,\
# "All-lat99-max-stats.dat" using (2.3):($1):($2):($3) with yerrorb linecolor rgb 'black' lt 1 lw 1 notitle;
