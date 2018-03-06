build_sys = 0; % 0: MacOS

if(build_sys == 0)
	mex -v -largeArrayDims -cxx utils.cpp kdtree2.cpp calpoc.cpp -output calpoc
end