# A note on input / output format

When you run "Export Result Tables", there are 2 files will be exported

- 1_ExportByPoint.txt: similar to input file with additional columns for output data
- 1_ClusterExport.txt: cluster output table


## Input files (txt) may have 12 or 13 columns.

ColumeIndex		13-columnInput		12-columnInput	

- 1				Index				
- 2				First Frame	
- 3				Number Frames	
- 4				Frames Missing	
- 5				Position X [nm]	
- 6				Position Y [nm]	
- 7				Precision [nm]	
- 8				Number Photons	
- 9				Background variance	
- 10				Chi square	
- 11				PSF width [nm]	
- 12				Channel	
- 13				Z Slice				x (missing)
- Total			N = 13				N = 12

Added columns in output files (version 1.0.0, without combined data processing)

- N+1				ROINum
- N+2				InOutMask
- N+3				ClusterID
- N+4				DoCScore
- N+5				LrValue
- N+6				CrossChanDensity
- N+6				LrAboveThreshold
- N+8				AllChanDensity

Some columns are added to store results for combined data (avoiding conflicting with results of channel 1 or 2)

- N+9				CombinedClusterID


## Cluster output table (DBSCAN)

ColumeIndex
- 1				CellNum	
- 2				ROINum	
- 3				Channel			(Channel = 3 for combined data)
- 4				ClusterID	
- 5				NPoints	
- 6				Nb	
- 7				MeanDoCScore	
- 8				Area	
- 9				Circularity	
- 10				TotalAreaDensity	
- 11				AvRelativeDensity	
- 12				MeanDensity	
- 13				Nb_In	
- 14				NInMask	
- 15				NOutMask

With combined total data, there are some more added columns

- 16				NChan1Points	(number of points of channel1)
- 17				NChan2Points	(number of points of channel2)

From (5)NPoints, (16)NChan1Points and (17)NChan2Points, we can calculate "the ratio of red versus green points in the cluster, the percentage of red (and green) points in total clusters, the number of red (and green) points in clusters"
