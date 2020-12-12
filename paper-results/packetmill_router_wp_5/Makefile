all: transpose plot tidy

transpose: transpose.sh
	@echo "Transposing csv files..."
	chmod +x transpose.sh
	./transpose.sh
plot: plot.gp
	@echo "Plotting..."
	gnuplot plot.gp

tidy:
	@echo "Organizing files..."
	rm -fr tmp/
	mkdir -p tmp/
	mv *.csv tmp/
	mv *.dat tmp/

clean:
	@echo  "Cleaning..."
	rm -fr tmp/
	rm -fr *.pdf