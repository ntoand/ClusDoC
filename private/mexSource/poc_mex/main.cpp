#include "kdtree2.hpp"

using std::string;
using std::vector;

#ifndef M_PI
#define M_PI 3.14159265359
#endif

// Calculate Gaussian weight ~ Gaussian curve value at that position point
// Gaussian profile placed at center
float calProp(const vector<float>&center, const vector<float>&point, const float sigma, const float NF) {
    float dx = point[0] - center[0];
    float dy = point[1] - center[1];
    float r;
    
    r = sqrt(dx*dx + dy*dy);
    float val = (exp(-(r*r)/sigma))/(M_PI * sigma);
    return val/NF;
}

int main(int argc, char** argv) {
    
    // Type
    int type = 0; // {0: divide by channel; 1: devide by sum of 2 channels}
    
    // Gaussian
    float sigma1, sigma2;
    sigma1 = sigma2 = 20;
    float sigma = 2.0 * sigma1 * sigma2;
    float NF = (exp(-(0)/sigma))/(M_PI * sigma); // normalized factor
    
    // tree
    float r = std::max(sigma1, sigma2);
    float rr = r*r;

    string inputfile = "/Users/toand/git/mivp/projects/nsw/cluster_analysis/ClusDoC/test_dataset/testdata.txt";
    vector<float> x;
    vector<float> y;
    vector<int> ch;
    
    // load data from txt file
    cout << "Loading data from txt file " << inputfile << "..." << endl;
    string line, str;
    ifstream myfile (inputfile);
    if (myfile.is_open()) {
        while ( getline (myfile, line) ) {
            //cout << line << '\n';
            stringstream iss(line);
            iss >> str;
            x.push_back(std::stof(str));
            
            iss >> str;
            y.push_back(std::stof(str));
            
            iss >> str;
            ch.push_back(std::stoi(str));
          }
    }
    else {
        cout << "Unable to open file" << endl;
        return 1;
    }
    
    cout << "Building trees..." << endl;
    array2dfloat input_data1, input_data2;
    int N = (int)x.size();
    for(int i=0; i<N; i++)
    {
        vector<float> point(2);
        point[0] = (float)x[i];
        point[1] = (float)y[i];
        (ch[i] == 1) ? input_data1.push_back(point) : input_data2.push_back(point);
    }
    
    kdtree2* tree1 = new kdtree2(input_data1, false);
    kdtree2* tree2 = new kdtree2(input_data2, false);
    
    cout << "Calculating PoC..." << endl;
    vector<float> poc(N);
    
    for(int i=0; i < N; i++) {
        vector<float> point(2);
        point[0] = (float)x[i];
        point[1] = (float)y[i];
        float sum1 = 0;
        float sum2 = 0;
        
        kdtree2_result_vector result_vec1; // [(dis, idx), ...]
        tree1->r_nearest( point, rr, result_vec1 );
        for(int j=0; j < result_vec1.size(); j++) {
            int idx = result_vec1[j].idx;
            sum1 += calProp(point, input_data1[idx], sigma, NF);
            //cout << idx << " " << point[0] << " " << point[1] << " " << input_data1[idx][0] << " " << input_data1[idx][1] << " " << val << endl;
        }
        
        kdtree2_result_vector result_vec2;
        tree2->r_nearest( point, rr, result_vec2 );
        for(int j=0; j < result_vec2.size(); j++) {
            int idx = result_vec2[j].idx;
            sum2 += calProp(point, input_data2[idx], sigma, NF);
            //cout << idx << " " << point[0] << " " << point[1] << " " << input_data1[idx][0] << " " << input_data1[idx][1] << " " << val << endl;
        }
        float sum = sum1 + sum2;
        
        if(ch[i] == 1) {
            poc[i] = (type == 0) ? (sum2/sum1) : (sum2/sum);
        }
        else {
            poc[i] = (type == 0) ? (sum1/sum2) : (sum1/sum);
        }
        
        cout << i << " " << sum1 << " " << sum2 << " " << poc[i] << endl;
        
        // DEBUG
        //if(i > 1)
        //    break;
    }
    
    // clean up
    x.clear(); y.clear(); ch.clear();
    input_data1.clear(); input_data2.clear();
    poc.clear();
    if(tree1) delete tree1;
    if(tree2) delete tree2;
    
	cout << "Done!" << endl;
	return 0;
}
