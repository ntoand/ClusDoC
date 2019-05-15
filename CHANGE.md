# Change log

**for v1.3.0**

- Option to save plots as .fig

| Plots                                | Done |
| -------------------------------------|:----:|
| **RimpleyK**                         |      |
| Ripley_XRegion_Y                     | Y    |
| RipleyK_Average                      | Y    |
| **DBSCAN**                           |      |
| CellX_RegionYRegion_with_Cluster     | Y    |
| CellX_RegionY_Density_map            | Y    |
| CellX_RegionY_Norm_Density_map       | Y    |
| **Clus-DoC**                         |      |
| CellX_RegionYRegion_with_Cluster     | Y    |
| Pooled DoC histogram                 | Y*   |
| Table_X_Region_Y_Hist                | Y    |
| Table_X_Region_YDensity_ChZ          | Y    |
| Table_X_Region_YDoC_ChZ              | Y    |
| Table_X_Region_YRaw_data             | Y    |
| Table_X_Region_YOutliers             | Y    |
| **Clus-PoC**                         |      |
| CellX_RegionYRegion_with_Cluster     | Y    |
| Pooled PoC histogram                 | Y*   |
| Table_X_Region_Y_Hist                | Y    |
| Table_X_Region_YDensity_ChZ          | Y    |
| Table_X_Region_YPoC_ChZ              | Y    |
| Table_X_Region_YPoC_ChZ_log          | Y    |
| Table_X_Region_YRaw_data             | Y    |
| Table_X_Region_YOutliers             | Y    |

(*): not handle fig save in catch (DoCHandler.m, PoCHandler.m)

**for v1.2.0**

- Add converter to convert Picasso hdf5 file to Zen format
- Support load and process Zen format converted from Picasso

**for v1.1.0**

- Fix bug in loadMaskFiles when there is no mask tif file
- Rearrange GUI controls
- Fix bugs in DBSCAN when running with Lr_r=off and Stat=on
- Add new process data mode: combined data 
- Add scalebar to plot
- Add alphaShape for contour extraction for DBSCAN
- Move inputParameters dialogs to a separate file
- Add click to select ROI with pre-defined ROI size

**v1.0.0**

- Clone repo from https://github.com/PRNicovich/ClusDoC commit 2778b67931ab49edbc9f89f992ccc85fd033e018 (Feb 2018)
- Add mex build guide and scripts for MacOS
- Clean up