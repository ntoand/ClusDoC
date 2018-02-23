## Setup mex to build and run on MacOS with OpenMP

Tested with Matlab 2017b

Ref: https://stackoverflow.com/questions/37362414/openmp-with-mex-in-matlab-on-mac

- Run prefdir to find where Matlab stores configuration files
/Users/username/Library/Application Support/MathWorks/MATLAB/R2017b

- Install LLVM with brew

- Modify mex_C_maci64.xml and mex_C++_maci64.xml to use LLVM clang. Check sample files attached