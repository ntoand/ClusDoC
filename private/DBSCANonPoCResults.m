function [ClusterSmoothTableCh1, ClusterSmoothTableCh2, ClusterSmoothTableCombined, clusterIDOut, clusterTable] = DBSCANonPoCResults(CellData, ROICoordinates, Path_name, ...
    Chan1Color, Chan2Color, dbscanParamsPassed, NDatacolumns, CombinedColor, IsCombined)
% Routine to apply DBSCAN on the Degree of Colocalisation Result for

% Channel 1
% Ch1 hhhhhhh

%load(fullfile(Path_name,'Data_for_Cluster_Analysis.mat'))
%
%         if ~exist(strcat(Path_name, 'DBSCAN'),'dir')
%             mkdir(fullfile(Path_name, 'DBSCAN'));
%             mkdir(fullfile(Path_name, 'DBSCAN', 'Clus-DoC cluster maps', 'Ch1'));
%             mkdir(fullfile(Path_name, 'DBSCAN', 'Clus-DoC cluster maps', 'Ch2'));
%         end
%

    ClusterSmoothTableCh1 = cell(max(cellfun(@length, ROICoordinates)), length(CellData));
    ClusterSmoothTableCh2 = cell(max(cellfun(@length, ROICoordinates)), length(CellData));
    ClusterSmoothTableCombined = cell(max(cellfun(@length, ROICoordinates)), length(CellData));

    ResultCell = cell(max(cellfun(@length, ROICoordinates)), length(CellData));

    clusterIDOut = cell(max(cellfun(@length, ROICoordinates)), length(CellData), 2);

    clusterTable = [];

    channels = [1, 2];
    if(IsCombined)
        channels = 3;
    end

    for Ch = channels

        cellROIPair = [];

        for cellIter = 1:length(CellData) % index for the cell
            for roiIter = 1:length(ROICoordinates{cellIter}) % index for the region

                % Since which ROI a point falls in is encoded in binary, decode here
                whichPointsInROI = fliplr(dec2bin(CellData{cellIter}(:,NDatacolumns + 1)));
                whichPointsInROI = whichPointsInROI(:, roiIter) == '1';

                Data = CellData{cellIter}(whichPointsInROI, :);  

                if ~isempty(Data)

                    if(~IsCombined)
                        thisROIandThisChannel = CellData{cellIter}(whichPointsInROI, 12) == Ch;
                        Data_DoC1 = Data(thisROIandThisChannel, :);
                    else
                        Data_DoC1 = Data;
                    end

                    % FunDBSCAN4ZEN( Data,p,q,2,r,Cutoff,Display1, Display2 )
                    % Input :
                    % -Data = Data Zen table (12 or 13 columns).
                    % -p = index for cell
                    % -q = index for Region
                    % -Cutoff= cutoff for the min number of molecules per cluster
                    % -Display1=1; % Display and save Image from DBSCAN
                    % -Display2=0; % Display and save Image Cluster Density Map

                    %[ClusterSmooth2, fig,fig2,fig3] = FunDBSCAN4ZEN_V3( Data_DoC1,p,q,r,Display1,Display2);

                    dbscanParams = dbscanParamsPassed(Ch);
                    dbscanParams.CurrentChannel = Ch;
                    dbscanParams.IsCombined = IsCombined;
                    dbscanParams.Type = 'PoC';

                    if Ch == 1
                        clusterColor = Chan1Color;
                    elseif Ch == 2
                        clusterColor = Chan2Color;
                    else
                        clusterColor = CombinedColor;
                    end

                    % DBSCAN_Radius=20 - epsilon
                    % DBSCAN_Nb_Neighbor=3; - minPts ;
                    % threads = 2

                    % [datathr, ClusterSmooth, SumofContour, classOut, varargout] = DBSCANHandler(Data, ...
                    % DBSCANParams, cellNum, ROINum, display1, display2, clusterColor, InOutMaskVector, Density, DoCScore)
                    Density = zeros(size(Data_DoC1, 1), 1);
                    [~, ClusterCh, ~, classOut, ~, ~, ~, ResultCell{roiIter, cellIter}] = DBSCANHandler(Data_DoC1(:,5:6), ...
                        dbscanParams, cellIter, roiIter, true, false, clusterColor, Data_DoC1(:, NDatacolumns + 2), Density, ...
                        Data_DoC1(:, NDatacolumns + 10));

                    roi = ROICoordinates{cellIter}{roiIter};
                    cellROIPair = [cellROIPair; cellIter, roiIter, roi(1,1), roi(1,2), polyarea(roi(:,1), roi(:,2))];

                    clusterIDOut{roiIter, cellIter, Ch} = classOut;

                    % Assign cluster IDs to the proper points in CellData
                    % Doing this here to send to AppendToClusterTable, when
                    % also done (permanently) in ClusDoC
                    if(~IsCombined)
                        CellData{cellIter}(whichPointsInROI & (CellData{cellIter}(:,12) == Ch), NDatacolumns + 3) = classOut;
                        CellData{cellIter}(whichPointsInROI, NDatacolumns + 9) = 0;
                    else
                        CellData{cellIter}(whichPointsInROI, NDatacolumns + 9) = classOut;
                    end

                    %                     InClusters = whichPointsInROI;
                    %                     InClusters(thisROIandThisChannel) = classOut > 0;

                    %                     [ClusterCh, fig] = FunDBSCAN4DoC_GUIV2(Data_DoC1, p, q, r, Display1);

                    % Output :
                    % -Datathr : Data after thresholding with lr_Fun +
                    % randommess Criterion
                    % -ClusterSmooth : cell/structure with individual cluster
                    % pareameter (Points, area, Nb of position Contour....)
                    % -SumofContour : cell with big(>Cutoff) and small(<Cutoff)
                    % contours. use to draw quickly all the contours at once
                    % Fig1, fig2 fig3 : handle for figures plot in the
                    % function.

                    if (size(ClusterCh, 1) > 0)

                        clusterTable = AppendToClusterTableInternal(clusterTable, Ch, cellIter, roiIter, ClusterCh, classOut, Data_DoC1(:, 12));

                        % Save the plot and data
                        switch Ch
                            case 1
                                ClusterSmoothTableCh1{roiIter,cellIter} = ClusterCh;
                            case 2
                                ClusterSmoothTableCh2{roiIter,cellIter} = ClusterCh;
                            case 3
                                ClusterSmoothTableCombined{roiIter,cellIter} = ClusterCh;
                        end

                    else
                        fprintf('WARNING: no cluster found, ignore results');
                    end
                    
                    %                         Name1 = sprintf('_Table_%d_Region_%d_', p, q);
                    %                         Name2 = fullfile(Path_name, 'DBSCAN Results', 'Clus-DoC cluster maps', ...
                    %                             sprintf('Ch%d', Ch), sprintf('%sClusters_Ch%d.tif', Name1, Ch));
                    %
                    %                         set(gca, 'box', 'on', 'XTickLabel', [], 'XTick', [], 'YTickLabel', [], 'YTick', [])
                    %                         set(fig, 'Color', [1 1 1])
                    %                         tt = getframe(fig);
                    %                         imwrite(tt.cdata, Name2)
                    %                         close(gcf)

                end % If isempty
            end % ROI counter
        end % Cell counter

        %         disp(ResultCell);

        %         assignin('base', 'ResultCell', ResultCell);
        %         assignin('base', 'cellROIPair', cellROIPair);
        %         assignin('base', 'p', cellIter);
        %         assignin('base', 'q', roiIter);

        dirname = sprintf('Ch%d', Ch);
        if(IsCombined)
            dirname = 'Combined';
        end
        ExportDBSCANDataToExcelFiles(cellROIPair, ResultCell, fullfile(Path_name, 'DBSCAN Results'), Ch, dirname);

    end % channel

    if(~IsCombined)
        save(fullfile(Path_name, 'DBSCAN Clus-DoC Results.mat'),'ClusterSmoothTableCh1','ClusterSmoothTableCh2');
    else
        save(fullfile(Path_name, 'DBSCAN Clus-DoC Results.mat'),'ClusterSmoothTableCombined');
    end

end

function clusterTableOut = AppendToClusterTableInternal(clusterTable, Ch, cellIter, roiIter, ClusterCh, classOut, channel)

    try
        if isempty(clusterTable)
            oldROIRows = [];
        else
            oldROIRows = (ismember(cellIter, clusterTable(:,1)) & ismember(roiIter, clusterTable(:,2)) & ismember(Ch, clusterTable(:,3)));
        end

        if any(oldROIRows)

            % Clear out the rows that were for this ROI done previously
            clusterTable(oldROIRows, :) = [];

        end
        
        % update number of points in each channel in clusters
        for i = 1:max(classOut)
            c = channel(classOut == i);
            ClusterCh{i, 1}.NChan1Points = sum( c == 1 );
            ClusterCh{i, 1}.NChan2Points = sum( c == 2 );
        end

        % Add new data to the clusterTable
        appendTable = zeros(length(ClusterCh), 15);
        appendTable(:, 1) = cellIter; % CurrentROI
        appendTable(:, 2) = roiIter; % CurrentROI
        appendTable(:, 3) = Ch; % Channel

        appendTable(:, 4) = cellfun(@(x) x.ClusterID, ClusterCh); % ClusterID
        appendTable(:, 5) = cell2mat(cellfun(@(x) size(x.Points, 1), ClusterCh, 'uniformoutput', false)); % NPoints
        appendTable(:, 6) = cellfun(@(x) x.Nb, ClusterCh); % Nb

        if isfield(ClusterCh{1}, 'MeanScore')
            appendTable(:, 7) = cellfun(@(x) x.MeanScore, ClusterCh); % MeanPoCScore
        end

        appendTable(:, 8) = cellfun(@(x) x.Area, ClusterCh); % Area
        appendTable(:, 9) = cellfun(@(x) x.Circularity, ClusterCh); % Circularity
        appendTable(:, 10) = cellfun(@(x) x.TotalAreaDensity, ClusterCh); % TotalAreaDensity
        appendTable(:, 11) = cellfun(@(x) x.AvRelativeDensity, ClusterCh); % AvRelativeDensity
        appendTable(:, 12) = cellfun(@(x) x.Mean_Density, ClusterCh); % MeanDensity
        appendTable(:, 13) = cellfun(@(x) x.Nb_In, ClusterCh); % Nb_In
        appendTable(:, 14) = cellfun(@(x) x.NInsideMask, ClusterCh); % NPointsInsideMask
        appendTable(:, 15) = cellfun(@(x) x.NOutsideMask, ClusterCh); % NPointsInsideMask
        
        appendTable(:, 16) = cellfun(@(x) x.NChan1Points, ClusterCh); % NChan1Points
        appendTable(:, 17) = cellfun(@(x) x.NChan2Points, ClusterCh); % NChan2Points

        clusterTableOut = [clusterTable; appendTable];

    catch mError
        assignin('base', 'ClusterCh', ClusterCh);
        %assignin('base', 'clusterIDList', clusterIDList);
        %assignin('base', 'appendTable', appendTable);
        assignin('base', 'classOut', classOut);

        rethrow(mError);
    end

end


