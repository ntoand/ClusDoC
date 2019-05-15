function valOut = RipleyKHandler(handles, Fun_OutputFolder_name)
% Handler function for RipleyK calculations

    % parameters
    Start = handles.RipleyK.Start;
    End = handles.RipleyK.End;
    Step = handles.RipleyK.Step;
    MaxSampledPts = handles.RipleyK.MaxSampledPts;
    
    isCombined = handles.ProcessType == handles.CONST.PROCESS_COMBINED;
    if(handles.Nchannels == 1)
        numChannels = 1;
    else
        numChannels = handles.Nchannels + 1; % with combined data channel
    end
    if(isCombined)
        channels = 3;  % [3]
    else
        channels = 1:handles.Nchannels; % e,g, [1, 2]
    end
    

    ArrayHeader = [{'r'},{'L(r)-r'}];

    i = 0;
    
    nSteps = ceil((End - Start)/Step) + 1;
    
	Max_Lr = zeros(sum(cell2mat(cellfun(@length, handles.ROICoordinates, 'uniformoutput', false))), numChannels); % Assuming the first cell has the same number of channels as the rest
	Max_r = zeros(sum(cell2mat(cellfun(@length, handles.ROICoordinates, 'uniformoutput', false))), numChannels);
	Lr_r_Result = zeros(nSteps, sum(cell2mat(cellfun(@length, handles.ROICoordinates, 'uniformoutput', false))), numChannels);

    for cellIter = 1:length(handles.CellData) % cell number

        for roiIter = 1:length(handles.ROICoordinates{cellIter}) % ROI number
            
            if ~isempty(handles.ROICoordinates{cellIter})
            
                q = roiIter;
                p = cellIter;


                CurrentROI = handles.ROICoordinates{handles.CurrentCellData}{handles.CurrentROIData};
                CurrentROI = [CurrentROI(1,1),  CurrentROI(1,2), max(CurrentROI(:,1)) - min(CurrentROI(:,1)), max(CurrentROI(:,2)) - min(CurrentROI(:,2))];


                whichPointsInROI = fliplr(dec2bin(handles.CellData{cellIter}(:,handles.NDataColumns + 1)));
                whichPointsInROI = whichPointsInROI(:,roiIter) == '1';

                dataCropped = handles.CellData{cellIter}(whichPointsInROI, :);

                if ~isempty(dataCropped)
                    
                    i=i+1;

                    size_ROI = CurrentROI(3:4);
                    A = polyarea(handles.ROICoordinates{handles.CurrentCellData}{handles.CurrentROIData}(:,1), ...
                        handles.ROICoordinates{handles.CurrentCellData}{handles.CurrentROIData}(:,2));

                    % Calculate RipleyK for this cell + ROI w/ Channel 1
                    % data

                    selectNums = randsample(1:size(dataCropped, 1), MaxSampledPts);
                    selectVector = false(size(dataCropped, 1), 1);
                    selectVector(selectNums) = true;

                    for chan = channels

                        if chan == 1
                            plotColor = handles.Chan1Color;
                        elseif chan == 2
                            plotColor = handles.Chan2Color;
                        else
                            plotColor = handles.CombinedColor;
                        end

                        if(~isCombined)
                            [r, Lr_r] = RipleyKFun(dataCropped(selectVector & (dataCropped(:,12) == chan),5:6), ...
                                A, Start, End, Step, size_ROI);
                        else
                            [r, Lr_r] = RipleyKFun(dataCropped(selectVector,5:6), ...
                                A, Start, End, Step, size_ROI);
                        end

                        handles.handles.RipleyKCh1Fig = figure('color', [1 1 1]);
                        handles.handles.RipleyKCh1Ax = axes('parent', handles.handles.RipleyKCh1Fig);
                        plot(handles.handles.RipleyKCh1Ax, r, Lr_r, 'color', plotColor, 'linewidth', 2);


                        % Collect results from these calculations
                        [MaxLr_r, Index] = max(Lr_r);
                        Max_Lr(i, chan) = MaxLr_r;
                        Max_r(i, chan) = r(Index);
                        Lr_r_Result(:,i, chan) = Lr_r;

                        annotation('textbox', [0.45,0.8,0.22,0.1],...
                            'String', sprintf('Max L(r) - r: %.3f at Max r : %d', MaxLr_r, Max_r(i)), ...
                            'FitBoxToText','on');
                        xlabel(handles.handles.RipleyKCh1Ax, 'r (nm)', 'fontsize', 12);
                        ylabel(handles.handles.RipleyKCh1Ax, 'L(r) - r', 'fontsize', 12);

                        dirname = sprintf('Ch%d', chan);
                        if(isCombined)
                            dirname = 'Combined';
                        end
                        %print(fullfile(Fun_OutputFolder_name, 'RipleyK Plots', dirname, sprintf('Ripley_%dRegion_%d.tif', p, q)), ...
                        %    handles.handles.RipleyKCh1Fig, '-dtiff');
                        save_plot(fullfile(Fun_OutputFolder_name, 'RipleyK Plots', dirname, sprintf('Ripley_%dRegion_%d.tif', p, q)), ...
                            handles.handles.RipleyKCh1Fig, handles.settings.AlsoSaveFig);
                        close(handles.handles.RipleyKCh1Fig);

                        Matrix_Result = [r, Lr_r];
                        SheetName = sprintf('Cell_%dRegion_%d', p, q);
                        if ispc
                            xlswrite(fullfile(Fun_OutputFolder_name, 'RipleyK Results', dirname, 'RipleyK Results.xls'), ArrayHeader, SheetName, 'A1');
                            xlswrite(fullfile(Fun_OutputFolder_name, 'RipleyK Results', dirname, 'RipleyK Results.xls'), Matrix_Result, SheetName, 'A2');                 
                        end
                    end
                end            
            end
        end
    end

    for chan = channels
        
        Average_Lr_r(:,1) = r;
        Average_Lr_r(:, 2) = squeeze(mean(Lr_r_Result(:,:,chan), 2));
        Std_Lr_r(:,2) = std(Lr_r_Result(:,:,chan), 0, 2);
    
        if chan == 1
            plotColor = handles.Chan1Color;
        elseif chan == 2
            plotColor = handles.Chan2Color;
        else
            plotColor = handles.CombinedColor;
        end
        
        Max_r_Ave=[mean(Max_r(:,chan)), std(Max_r(:,chan))];
        Max_Lr_Ave=[mean(Max_Lr(:,chan)), std(Max_Lr(:,chan))];

        dirname = sprintf('Ch%d', chan);
        filename = sprintf('Ch%dPooled.xls', chan);
        if(isCombined)
            dirname = 'Combined';
            filename = 'CombinedPooled.xls';
        end
        % only write excel file on PC
        if ispc
            % Data average on all the regions and cells
            xlswrite(fullfile(Fun_OutputFolder_name, 'RipleyK Results', dirname, filename), ArrayHeader, 'Pooled data', 'A1');
            xlswrite(fullfile(Fun_OutputFolder_name, 'RipleyK Results', dirname, filename), Average_Lr_r, 'Pooled data', 'A2');

            % average for max Lr-r and r(max Lr-r)
            xlswrite(fullfile(Fun_OutputFolder_name, 'RipleyK Results', dirname, filename), [{'r(max_Lr)'},{'Max_Lr'}], 'Pooled data', 'D3');
            xlswrite(fullfile(Fun_OutputFolder_name, 'RipleyK Results', dirname, filename), [{'Mean'},{'Std'}]', 'Pooled data', 'E2');
            xlswrite(fullfile(Fun_OutputFolder_name, 'RipleyK Results', dirname, filename), [Max_r_Ave' Max_Lr_Ave'], 'Pooled data', 'E3');

            % max Lr-r and r(max Lr-r) for each region
            xlswrite(fullfile(Fun_OutputFolder_name, 'RipleyK Results', dirname, filename), [{'r(max_Lr)'},{'Max_Lr'}], 'Pooled data', 'E6');
            xlswrite(fullfile(Fun_OutputFolder_name, 'RipleyK Results', dirname, filename), [Max_r; Max_Lr]', 'Pooled data', 'E7');
        end
        
        handles.handles.RipleyKMeanFig = figure('color', [1 1 1]);
        clf(handles.handles.RipleyKMeanFig);
        handles.handles.RipleyKMeanAx = axes('parent', handles.handles.RipleyKMeanFig, 'nextplot', 'add');
        plot(handles.handles.RipleyKMeanAx, r, mean(Lr_r_Result(:,:,chan), 2), 'linewidth', 2, 'color', plotColor);
        plot(handles.handles.RipleyKMeanAx, r, mean(Lr_r_Result(:,:,chan), 2) + Std_Lr_r(:,2), ...
            'linewidth', 2, 'linestyle', ':', 'color', rgb(52, 152, 219));
        plot(handles.handles.RipleyKMeanAx, r, mean(Lr_r_Result(:,:,chan), 2) - Std_Lr_r(:,2), ...
            'linewidth', 2, 'linestyle', ':', 'color', rgb(52, 152, 219));
        xlabel(handles.handles.RipleyKMeanAx, 'r (nm)', 'fontsize', 12);
        ylabel(handles.handles.RipleyKMeanAx, 'L(r) - r', 'fontsize', 12);

        annotation('textbox', [0.45,0.8,0.22,0.1],...
            'String', sprintf('Max L(r) - r: %.3f at Max r : %d', MaxLr_r, Max_r(i)), ...
            'FitBoxToText','on');

        %print(fullfile(Fun_OutputFolder_name, 'RipleyK Plots', dirname, 'RipleyK_Average.tif'), ...
        %    handles.handles.RipleyKMeanFig, '-dtiff');
        save_plot(fullfile(Fun_OutputFolder_name, 'RipleyK Plots', dirname, 'RipleyK_Average.tif'), handles.handles.RipleyKMeanFig, handles.settings.AlsoSaveFig); 
        
        close(handles.handles.RipleyKMeanFig);
        
    end

    valOut = 1;

end