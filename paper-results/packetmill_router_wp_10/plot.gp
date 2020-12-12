set terminal postscript eps color enhanced "Helvetica" 38 size 5,2
set style fill solid 1 border -1 
set style boxplot nooutliers
set style boxplot fraction 1.00
set style data boxplot
set boxwidth 0.15


#Throughput + Latency + TX

set print 'wp-throughput-improve-stats.dat'
wp(n) = word("0 1 2 3 4 5", n) # Real values 1 4 8 12 16 20
print sprintf("#%s %s %s", "S", "W", "Throughput-median")
do for [i=1:6] { # S
    do for [j=1:6] { #W
    	z=(i-1)*6+j
        stats 'VanillaTHROUGHPUT.csv' using z prefix "VA" nooutput
        stats 'PacketMillTHROUGHPUT.csv' using z prefix "PM" nooutput
        print sprintf("%s %s %e", wp(i), wp(j), value( (PM_median - VA_median)*100/VA_median ))
    }
    print sprintf("\n")
}

stats 'wp-throughput-improve-stats.dat' using 3 prefix "IMP" nooutput


set xlabel "Compute-Intensiveness\n{/*0.8 Number of Generated pseudo-random Numbers}" font "Helvetica,15"
# set ylabel "Memory-Intensiveness\n{/*0.8 Size of the Accessed Memory (MB)}" font "Helvetica,15"
set ylabel "Memory Footprint\n{/*0.8 Size of the Accessed Memory (MB)}" font "Helvetica,15"

set yrange [0:*]
set xrange [0:*]
# set xtics 0,4
# set ytics 0,4

set xtics ("0" 0, "4" 1, "8" 2, "12" 3, "16" 4, "20" 5) font "Helvetica, 14"  #offset 0,0.4
set ytics ("0" 0, "4" 1, "8" 2, "12" 3, "16" 4, "20" 5) font "Helvetica, 14"  offset 0.5,0

set offsets graph 0, 0, 0.05, 0.05 
set grid
# set parametric
unset key

unset key
set tic scale 0

# Color runs from white to green
# set palette rgbformula -7,2,-7
set palette defined (-10 "#fddbc7", 0 "#ffffff",10 "#ffffcc",20 "#d9f0a3",30 "#addd8e",\
    40 "#78c679",50 "#31a354",60 "#006837")
set cbrange [-10:IMP_max]
set cblabel "Throughput Improvements (%)" rotate by 90
set cbtics -10,10

set xrange [-0.5:5.5]
set yrange [-0.5:5.5]

set terminal pdf size 5,2.6
set output "heat.pdf"

plot 'wp-throughput-improve-stats.dat'using 2:1:3 with image