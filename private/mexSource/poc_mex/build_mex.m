build_sys = 0; % 0: MacOS; 1: Windows

if(build_sys == 0)
	mex -v -largeArrayDims -cxx utils.cpp kdtree2.cpp calpoc.cpp -output calpoc
elseif (build_sys == 1)
    mex -v -largeArrayDims -cxx utils.cpp kdtree2.cpp calpoc.cpp -o calpoc
end