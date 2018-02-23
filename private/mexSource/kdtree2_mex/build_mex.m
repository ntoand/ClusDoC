build_sys = 0; % 0: MacOS

if(build_sys == 0)
	mex -v -largeArrayDims -cxx -c kdtree2.cpp utils.cpp kdtree2rnearest.cpp
    mex -v -largeArrayDims -cxx kdtree2.o utils.o kdtree2rnearest.o -output kdtree2rnearest
end