clean:
	rm -f start *.ba *.bo *.cxx *.h *.o *.so
	rm -rf build sim

start:
	# Make the build directories so things don't get messy
	mkdir -p build
	mkdir -p sim
	
	# Build the intermediate files
	bsc -bdir build -sim -g start start.bsv 
	bsc -bdir build -simdir sim -sim -e start -o start