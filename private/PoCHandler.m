function [CellData, DensityROI] = PoCHandler(ROICoordinates, CellData, FuncType, Lr_rRad, Sigma, Chan1Color, Chan2Color, Outputfolder, NDatacolumns, settings)

    % Handler function for data arrangement and plotting of PoC calculations
    
    Data_PoC = cell(max(cellfun(@length, ROICoordinates)), length(CellData));
    DensityROI = cell(max(cellfun(@length, ROICoordinates)), length(CellData));
    
    for cellIter = 1:length(CellData) % cell number

        for roiIter = 1:numel(ROICoordinates{cellIter}) % ROI number

            roiHere = ROICoordinates{cellIter}{roiIter};

            % Since which ROI a point falls in is encoded in binary, decode here
            whichPointsInROI = fliplr(dec2bin(CellData{cellIter}(:,NDatacolumns + 1)));
            whichPointsInROI = whichPointsInROI(:, roiIter) == '1';
    
            dataCropped = CellData{cellIter}(whichPointsInROI, :);

            if ~isempty(dataCropped)
                
                dataCropped(isnan(dataCropped(:,12)),:)=[];
                whichPointsInROI(isnan(dataCropped(:,12))) = 0;
                
                [ Data_DegColoc1, SizeROI1 ] = PoCCalc( dataCropped, FuncType, Lr_rRad, Sigma, roiHere );
                
                CA1 = Data_DegColoc1.PoC((Data_DegColoc1.Ch == 1) & (Data_DegColoc1.Lr_rAboveThresh == 1)); % Ch1 -> Ch2
                CA2 = Data_DegColoc1.PoC((Data_DegColoc1.Ch == 2) & (Data_DegColoc1.Lr_rAboveThresh == 1)); % Ch2 -> Ch1
                
                handles.handles.PoCFigPerROI = figure('color', [1 1 1], 'inverthardcopy', 'off');

                handles.handles.DoCAxPerROI(1) = subplot(2,1,1);
                histHand = histogram(handles.handles.DoCAxPerROI(1), CA1, 100);
                histHand.FaceColor = Chan1Color;
                histHand.EdgeColor = rgb(52, 73, 94);
                %set(handles.handles.DoCAxPerROI(1), 'XLim', [-1 1]);
                xlabel(handles.handles.DoCAxPerROI(1), 'PoC Score Ch1', 'Fontsize', 20);
                ylabel(handles.handles.DoCAxPerROI(1), 'Frequency','FontSize',20);
                set(handles.handles.DoCAxPerROI(1),'FontSize',20)

                handles.handles.DoCAxPerROI(2) = subplot(2,1,2);
                histHand = histogram(handles.handles.DoCAxPerROI(2), CA2, 100);
                histHand.FaceColor = Chan2Color;
                histHand.EdgeColor = rgb(52, 73, 94);
                %set(handles.handles.DoCAxPerROI(2), 'XLim', [-1 1]);
                xlabel(handles.handles.DoCAxPerROI(2), 'DoC Score Ch2', 'Fontsize', 20);
                ylabel(handles.handles.DoCAxPerROI(2), 'Frequency','FontSize',20);
                set(handles.handles.DoCAxPerROI(2),'FontSize',20)

                drawnow;

                % Save the figure
                Name = sprintf('Table_%d_Region_%d_Hist', cellIter, roiIter);
                %print(fullfile(Outputfolder, 'Clus-PoC Results', 'PoC histograms', Name), ...
                %    handles.handles.PoCFigPerROI, '-dtiff');
                save_plot(fullfile(Outputfolder, 'Clus-PoC Results', 'PoC histograms', Name), ...
                    handles.handles.PoCFigPerROI, settings.AlsoSaveFig);
                close gcf
                
                CellData{cellIter}(whichPointsInROI, NDatacolumns + 10) = Data_DegColoc1.PoC; % col 4: DoC
                CellData{cellIter}(whichPointsInROI, NDatacolumns + 5) = Data_DegColoc1.Lr;
                CellData{cellIter}(whichPointsInROI, NDatacolumns + 6) = Data_DegColoc1.D1_D2;
                CellData{cellIter}(whichPointsInROI, NDatacolumns + 7) = Data_DegColoc1.Lr_rAboveThresh;
                CellData{cellIter}(whichPointsInROI, NDatacolumns + 8) = Data_DegColoc1.Density;
                
                Data_PoC{roiIter, cellIter} = Data_DegColoc1;


                % Average density for each region
                DensityROI{roiIter, cellIter} = [size([CA1;CA2],1)/SizeROI1^2, ...
                    size(CA1,1)/SizeROI1^2, ...
                    size(CA2,1)/SizeROI1^2];
                

            end
            %AvDensityCell(nt,:)=mean (DensityROI,1);
        end
    end

    % PoC1 and PoC2 are PoC scores for chan1->2 and chan2->1 for ALL
    % evaluated points above Lr_r threshold
    PoC1CumHist = zeros(100, 1);
    PoC2CumHist = zeros(100, 1);
    
    assignin('base', 'CellData', CellData);
    
    max1 = -1;
    max2 = -1;
    for k = 1:numel(CellData)
        temp = CellData{k}((CellData{k}(:,NDatacolumns + 1) > 0) & (CellData{k}(:,12) == 1) & (CellData{k}(:, NDatacolumns + 7) == 1), NDatacolumns + 10);
        PoC1CumHist = PoC1CumHist + histc(temp, linspace(0, max(temp(:)), 100));
        max1 = max(max1, max(temp(:)));
        
        temp = CellData{k}((CellData{k}(:,NDatacolumns + 1) > 0) & (CellData{k}(:,12) == 2) & (CellData{k}(:, NDatacolumns + 7) == 1), NDatacolumns + 10);
        PoC2CumHist = PoC2CumHist + histc(temp, linspace(0, max(temp(:)), 100));
        max2 = max(max2, max(temp(:)));
    end
    
    PoC1 = PoC1CumHist/sum(PoC1CumHist(:));
    PoC2 = PoC2CumHist/sum(PoC2CumHist(:));

    % Plot summary data
    handles.handles.PoCFig = figure('color', [1 1 1], 'inverthardcopy', 'off');

    handles.handles.PoCAx(1) = subplot(2,1,1);
%     histHand = histogram(handles.handles.PoCAx(1), PoC1, 100);
    histHand = bar(handles.handles.PoCAx(1), linspace(0, max1, 100), PoC1);
    histHand.FaceColor = Chan1Color;
    histHand.EdgeColor = rgb(52, 73, 94);
    %set(handles.handles.PoCAx(1), 'XLim', [-1 1]);
    xlabel(handles.handles.PoCAx(1), 'PoC Score Ch1', 'Fontsize', 20);
    ylabel(handles.handles.PoCAx(1), 'Frequency','FontSize',20);
    set(handles.handles.PoCAx(1),'FontSize',20)

    handles.handles.PoCAx(2) = subplot(2,1,2);
%     histHand = histogram(handles.handles.PoCAx(2), PoC2, 100);
    histHand = bar(handles.handles.PoCAx(2), linspace(0, max2, 100), PoC2);
	histHand.FaceColor = Chan2Color;
    histHand.EdgeColor = rgb(52, 73, 94);
    %set(handles.handles.PoCAx(2), 'XLim', [-1 1]);
    xlabel(handles.handles.PoCAx(2), 'PoC Score Ch2', 'Fontsize', 20);
    ylabel(handles.handles.PoCAx(2), 'Frequency','FontSize',20);
    set(handles.handles.PoCAx(2),'FontSize',20)

    drawnow;

    % Save the figure
    try 
        %print(fullfile(Outputfolder, 'Clus-PoC Results', 'PoC histograms', 'Pooled PoC histogram.tif'), ...
        %    handles.handles.PoCFig, '-dtiff');
        save_plot(fullfile(Outputfolder, 'Clus-PoC Results', 'PoC histograms', 'Pooled PoC histogram.tif'), ...
            handles.handles.PoCFig, settings.AlsoSaveFig);
    catch
        currFig = getframe(handles.handles.PoCFig);
        imwrite(currFig.cdata, fullfile(Outputfolder, 'Clus-PoC Results', 'PoC histograms', 'Pooled PoC histogram.tif'));
    end

    close gcf;
    %save(fullfile(Outputfolder, 'Clus-PoC Results', 'Data_for_Cluster_Analysis.mat'),'Data_PoC','DensityROI'); %ROIData removed!
end
