set terminal postscript eps color enhanced "Helvetica" 38 size 5,2
# set style fill solid 1 border -1 
# set style boxplot nooutliers
# set style boxplot fraction 1.00
# set style data boxplot
# set boxwidth 0.15


#Throughput + Latency + TX

set print 'wp-throughput-improve-stats.dat'
wp(n) = word("0 1 2 3 4 5", n) # Real values 1 4 8 12 16 20
print sprintf("#%s %s %s %s", "N", "W", "S", "Throughput-median", "Throughput-Vanilla")
do for [k=1:5] { # N
	do for [i=1:6] { # W
	    do for [j=1:21] { #S
	    	z=(k-1)*126+(i-1)*21+j
	        stats 'VanillaTHROUGHPUT.csv' using z prefix "VA" nooutput
	        stats 'PacketMillTHROUGHPUT.csv' using z prefix "PM" nooutput
	        print sprintf("%1.0f %s %1.0f %1.2f %1.2f %1.2f", k, wp(i), j-1, value( (PM_median - VA_median)*100/VA_median ), value(VA_median/1000000000), value(PM_median/1000000000))
	    }
	    print sprintf("")
	}
	# print sprintf("\n")
}


stats 'wp-throughput-improve-stats.dat' using 4 prefix "IMP" nooutput
stats 'wp-throughput-improve-stats.dat' using 5 prefix "VA" nooutput


set xlabel "Compute-Intensiveness\n{/*0.8 Number of Generated pseudo-random Numbers}" font "Helvetica,14" offset 0,-1.5 #rotate by -8.5

set ylabel "Memory Footprint\n{/*0.8 Size of the Accessed Memory (MB)}" font "Helvetica,14" offset -1,-1.5 #rotate by 90

set zlabel "Throughput Improvements (%)" font "Helvetica,15" rotate by 90

set yrange [0:*]
set xrange [0:*]
set zrange [0:60]


set xtics ("0" 0, "4" 1, "8" 2, "12" 3, "16" 4, "20" 5) font "Helvetica, 12"  offset 0,-0.3
# set ytics ("0" 0, "4" 1, "8" 2, "12" 3, "16" 4, "20" 5) font "Helvetica, 14"  offset 0.5,0
# set xtics 0,4,20 font "Helvetica, 14"
set ytics 0,4,16 font "Helvetica, 12" offset 0,-0.3
set ztics 10,10,60 font "Helvetica, 12" 


# set offsets graph 0, 0, 0.05, 0.05 
set grid
set tics scale 0
# set parametric
unset key

# set tic scale 0

# Color runs from white to green
# set palette rgbformula -7,2,-7
set palette defined (0 "#ffffff",VA_max/6 "#ffffcc",VA_max*2/6 "#d9f0a3",VA_max*3/6 "#addd8e",\
    VA_max*4/6 "#78c679",VA_max*5/6 "#31a354",VA_max "#006837")
set cbrange [0:60]
set cblabel "Vanilla Throughput (Gbps)" rotate by 90
set cbtics 0,15

# set xrange [-0.5:5.5]
# set yrange [-0.5:5.5]

set terminal pdf 
set output "heat-3d-1APP.pdf"
# unset hidden3d
# unset surf
set style data pm3d
set border 4095
set isosamples 100
set pm3d
set ticslevel 0.0


# set samples 25, 25
# set isosamples 50, 50
# set hidden3d
# set dgrid3d
# set pm3d map
# set samples 2000

# set view map
 set view 60, 150, 0.8, 1.5
 unset hidden3d
 show hidden3d

splot 'wp-throughput-improve-stats.dat' using ($1==1?$2:NaN):3:4:5 w pm3d,\
'wp-throughput-improve-stats.dat' using ($1==1?$2:NaN):3:4:5 w lines linecolor rgb 'black' lt 1 lw 1
# 'wp-throughput-improve-stats.dat' using ($1==5?$2:NaN):3:4:5 w pm3d

set output "heat-3d-5APP.pdf"

splot 'wp-throughput-improve-stats.dat' using ($1==5?$2:NaN):3:4:5 w pm3d,\
'wp-throughput-improve-stats.dat' using ($1==5?$2:NaN):3:4:5 w lines linecolor rgb 'black' lt 1 lw 1



set terminal pdf 

set style line 1 linecolor rgb '#78c679' ps 0.75 pt 3 lw 1.5 # Vanilla
set style line 2 linecolor rgb '#006837' ps 0.75 pt 5 lw 1.5 # PacketMill


set yrange[0:105]
set xrange[-1:21]

set xlabel "Memory Footprint\n{/*0.8 Size of the Accessed Memory (MB)}" font "Helvetica,14" offset 0,0
set ylabel "Throughput (Gbps)" font "Helvetica,14" offset 0,0

set ytics 0,20,100 font "Helvetica, 12" offset 0,0
set xtics 0,2,20 font "Helvetica, 12" offset 0,0

unset colorbox
set key font "Helvetica, 14" vertical Left left top reverse invert

set title "N=1 (Number of Accesses per Packet) and W=4 (Compute-Intensiveness)"

set output "compute-fixed-N1-W4.pdf"
plot "<awk '{if($1==1 && $2==1){print $3,$5,$6;}}' wp-throughput-improve-stats.dat" using 1:2 with points ls 1 title "Vanilla (Copying)",\
"<awk '{if($1==1 && $2==1){print $3,$5,$6;}}' wp-throughput-improve-stats.dat" using 1:2 with lines ls 1 dt 2 notitle,\
"<awk '{if($1==1 && $2==1){print $3,$5,$6;}}' wp-throughput-improve-stats.dat" using 1:3 with points ls 2 title "PacketMill (X-Change + Source-Code Optimizations)",\
"<awk '{if($1==1 && $2==1){print $3,$5,$6;}}' wp-throughput-improve-stats.dat" using 1:3 with lines ls 2 dt 4 notitle; 

set xlabel "Compute-Intensiveness\n{/*0.8 Number of Generated pseudo-random Numbers}" font "Helvetica,14" offset 0,0

set title "N=2 (Number of Accesses per Packet) and S=2 MB (Memory Footprint)"
set xtics ("0" 0, "4" 1, "8" 2, "12" 3, "16" 4, "20" 5)
set xrange [-0.5:5.5]

set output "memory-fixed-N2-S2.pdf"
plot "<awk '{if($1==2 && $3==2){print $2,$5,$6;}}' wp-throughput-improve-stats.dat" using 1:2 with points ls 1 title "Vanilla (Copying)",\
"<awk '{if($1==2 && $3==2){print $2,$5,$6;}}' wp-throughput-improve-stats.dat" using 1:2 with lines ls 1 dt 2 notitle,\
"<awk '{if($1==2 && $3==2){print $2,$5,$6;}}' wp-throughput-improve-stats.dat" using 1:3 with points ls 2 title "PacketMill (X-Change + Source-Code Optimizations)",\
"<awk '{if($1==2 && $3==2){print $2,$5,$6;}}' wp-throughput-improve-stats.dat" using 1:3 with lines ls 2 dt 4 notitle; 



set xlabel "Number of Memory Accesses per Packet" font "Helvetica,14" offset 0,0

set title "W=4 (Compute-Intensiveness) and S=2 MB (Memory Footprint)"
set xtics 0,1,5
set xrange [0.5:5.5]

set output "memory-compute-fixed-W4-S2.pdf"
plot "<awk '{if($2==1 && $3==2){print $1,$5,$6;}}' wp-throughput-improve-stats.dat" using 1:2 with points ls 1 title "Vanilla (Copying)",\
"<awk '{if($2==1 && $3==2){print $1,$5,$6;}}' wp-throughput-improve-stats.dat" using 1:2 with lines ls 1 dt 2 notitle,\
"<awk '{if($2==1 && $3==2){print $1,$5,$6;}}' wp-throughput-improve-stats.dat" using 1:3 with points ls 2 title "PacketMill (X-Change + Source-Code Optimizations)",\
"<awk '{if($2==1 && $3==2){print $1,$5,$6;}}' wp-throughput-improve-stats.dat" using 1:3 with lines ls 2 dt 4 notitle; 