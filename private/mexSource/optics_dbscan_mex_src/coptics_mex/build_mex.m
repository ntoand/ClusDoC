build_sys = 0; % 0: MacOS

if(build_sys == 0)
	mex -v -largeArrayDims -cxx -c utils.cpp kdtree2.cpp coptics.cpp
    mex -v -largeArrayDims -cxx utils.o kdtree2.o coptics.o -output coptics
end