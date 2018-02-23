% Tested with Matlab 2017b
build_sys = 0; % 0: MacOS

if(build_sys == 0)
    mex -v -largeArrayDims -cxx -c test_omp_build.cpp
    mex -v -largeArrayDims -cxx test_omp_build.o -output test_omp_build
end