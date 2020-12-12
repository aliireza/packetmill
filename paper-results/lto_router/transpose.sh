#!/bin/bash

csvpath="./csv/"
exp=("NOLTO" "BOTHLTO" "BOTHLTOREORDER")
metric=("THROUGHPUT" "PPS" "LAT50" "LAT99" "LLC-load-misses-avg-C0" "LLC-loads-avg-C0" "L1-dcache-load-misses-avg-C0" "L1-dcache-loads-avg-C0" "L1-icache-load-misses-avg-C0" "cycles-avg-C0" "instructions-avg-C0")
header=1
n_header=2

for e in ${exp[@]}; do
	for m in ${metric[@]}; do
		csvfile="$csvpath$e$m.csv"
		outputname="$e$m.csv"
		echo $outputname
		if [ $header -eq 1 ]; then
			awk '{printf "%-3d %s\n", NR, $0}' $csvfile > 1.csv
			csvtool transpose -t " " -u " " 1.csv > 2.csv
			csvtool head $n_header -t " " -u " " 2.csv > 3.csv
			sed 's/^/#/' 3.csv  > $outputname
			csvtool drop $n_header -t " " -u " " 2.csv >> $outputname
		else
			csvtool transpose -t " " -u " " $csvfile > $outputname
		fi
		rm -f 1.csv 2.csv 3.csv
	done
done