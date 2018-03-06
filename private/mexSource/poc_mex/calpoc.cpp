// this is actually just a single query
#include "mex.h"
#include "kdtree2.hpp"

#ifndef M_PI
#define M_PI 3.14159265359
#endif

using std::string;
using std::vector;

// Calculate Gaussian weight ~ Gaussian curve value at that position point
// Gaussian profile placed at center
float calProp(const vector<float>&center, const vector<float>&point, const float sigma, const float NF) {
    float dx = point[0] - center[0];
    float dy = point[1] - center[1];
    float r = sqrt(dx*dx + dy*dy);
    float val = (exp(-(r*r)/sigma))/(M_PI * sigma);
    return val/NF;
}

void mexFunction(int nlhs, mxArray * plhs[], int nrhs, const mxArray * prhs[]){
	
	// num_points = calpoc_mex(x_array, y_array, ch_array, sigma1, sigma2)
	if(nrhs != 4 && nrhs != 5) {
		mexPrintf("Error: invalid input arguments. Usage: [sum1, sum2] = calpoc(x_array, y_array, ch_array, sigma1, sigma2)\n");
		return;
	}

	const mwSize *dims;
	int N;  // number of input points
	double *x, *y, *ch;
	double sigma1, sigma2;

	//output
	double* out_sum1;
	double* out_sum2;

	// retrieve input points
	x = mxGetPr(prhs[0]);
	y = mxGetPr(prhs[1]);
	ch = mxGetPr(prhs[2]);
	dims = mxGetDimensions(prhs[0]);
	N = (int)dims[0];
	
	// retrieve the radius
	sigma1 = mxGetScalar(prhs[3]);
	(nrhs == 5) ? sigma2 = mxGetScalar(prhs[4]) : sigma2 = sigma1;

	//associate outputs   
	plhs[0] = mxCreateDoubleMatrix(1, N, mxREAL); // sum1
	out_sum1 = mxGetPr(plhs[0]);

	plhs[1] = mxCreateDoubleMatrix(1, N, mxREAL); // sum2
	out_sum2 = mxGetPr(plhs[1]);

	//actual code from here
	float sigma = 2.0 * sigma1 * sigma2;
    float NF = (exp(-(0)/sigma))/(M_PI * sigma); // normalized factor
    float r = std::max(sigma1, sigma2);
    float rr = r*r;

    //processing
	clock_t begin, end;
	double time_spent;
	begin = clock();

    //build trees
    array2dfloat input_data1, input_data2;
    for(int i=0; i<N; i++) {
        vector<float> point(2);
        point[0] = (float)x[i];
        point[1] = (float)y[i];
        ((int)ch[i] == 1) ? input_data1.push_back(point) : input_data2.push_back(point);
    }
    mexPrintf("Calculate PoC with mex function N: %d,  N1: %d, N2: %d, s1: %0.2f, s2: %0.2f r: %0.2f\n", N, input_data1.size(), input_data2.size(), sigma1, sigma2, r);
    kdtree2* tree1 = new kdtree2(input_data1, false);
    kdtree2* tree2 = new kdtree2(input_data2, false);

    //cal sums of weight
    for(int i=0; i < N; i++) {
        vector<float> point(2);
        point[0] = (float)x[i];
        point[1] = (float)y[i];
        double sum1 = 0;
        double sum2 = 0;
        
        kdtree2_result_vector result_vec1; // [(dis, idx), ...]
        tree1->r_nearest( point, rr, result_vec1 );
        for(int j=0; j < result_vec1.size(); j++) {
            int idx = result_vec1[j].idx;
            sum1 += calProp(point, input_data1[idx], sigma, NF);
        }
        
        kdtree2_result_vector result_vec2;
        tree2->r_nearest( point, rr, result_vec2 );
        for(int j=0; j < result_vec2.size(); j++) {
            int idx = result_vec2[j].idx;
            sum2 += calProp(point, input_data2[idx], sigma, NF);
        }

        out_sum1[i] = sum1;
        out_sum2[i] = sum2;	
	}
    
    // clean up
    input_data1.clear(); input_data2.clear();
    if(tree1) delete tree1;
    if(tree2) delete tree2;

    end = clock();
	time_spent = (double)(end - begin) / CLOCKS_PER_SEC;
	mexPrintf("Time to run calpoc function: %0.3f \n", time_spent);
}
