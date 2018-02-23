build_sys = 0; % 0: MacOS

if(build_sys == 0)
	mex -v -largeArrayDims -cxx -c clusters.cpp kdtree2.cpp dbscan.cpp omp_dbscan.cpp pdsdbscan.cpp
    mex -v -largeArrayDims -cxx clusters.cpp kdtree2.cpp dbscan.cpp omp_dbscan.cpp pdsdbscan.cpp -output pdsdbscan
end