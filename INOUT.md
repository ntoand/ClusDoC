# A note on input / output format

Input files (txt) may have 12 or 13 columns.

ColumeIndex		13-columnInput		12-columnInput		
1				Index				
2				First Frame	
3				Number Frames	
4				Frames Missing	
5				Position X [nm]	
6				Position Y [nm]	
7				Precision [nm]	
8				Number Photons	
9				Background variance	
10				Chi square	
11				PSF width [nm]	
12				Channel	
13				Z Slice				x (missing)
Total			N = 13				N = 12

Added columns in output files (version 1.0.0, without combined data processing)
N+1				ROINum
N+2				InOutMask
N+3				ClusterID
N+4				DoCScore
N+5				LrValue
N+6				CrossChanDensity
N+6				LrAboveThreshold
N+8				AllChanDensity

Some columns are added to store results for combined data (avoiding conflicting with results of channel 1 or 2)
N+9				Combined_ClusterID