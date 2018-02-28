function ExportDBSCANDataToExcelFiles(cellROIPair, Result, outputFolder, chan, isCombined)

    % Formerly Final_Result_DBSCAN_GUIV2
    % Extracts and exports Results table into Excel format
    
    A = Result(:);
    
    cellROIPair(cellfun('isempty', A), :) = []; % filter out empty ones
    A = A(~cellfun('isempty', A));
    
    Percent_in_Cluster_column = cell2mat(cellfun(@(x) x.Percent_in_Cluster, A, 'UniformOutput', false));
    Number_column = cell2mat(cellfun(@(x) x.Number, A, 'UniformOutput', false));
    Area_column = cell2mat(cellfun(@(x) x.Area, A , 'UniformOutput', false));
    Density_column = cell2mat(cellfun(@(x) x.Density, A, 'UniformOutput', false));
    RelativeDensity_column = cell2mat(cellfun(@(x) x.RelativeDensity, A, 'UniformOutput', false));
    TotalNumber = cell2mat(cellfun(@(x) x.TotalNumber, A, 'UniformOutput', false));
    Circularity_column = cell2mat(cellfun(@(x) x.Mean_Circularity, A,'UniformOutput', false));
    Number_Cluster_column = cell2mat(cellfun(@(x) x.Number_Cluster, A, 'UniformOutput', false));

    %export data into Excel

    HeaderArray=[{'Cell'},{'ROI'},{'x bottom corner'},{'y bottom corner'},{'Size of ROI (nm)'},{'Comments'},{'Percentage of molecules in clusters'},...
        {'Average number of molecules per cluster'}, {'Average cluster area (nm^2)'}, {'Abslute density in clusters (molecules / um^2)'}, ...
        {'Relative density in clusters'}, {'Total number of molecules in ROI'}, ...
        {'Circularity'}, {'Number of clusters in ROI'}, {'Density of clusters (clusters / um^2)'}];

    Matrix_Result = [Percent_in_Cluster_column*100 , Number_column(:,1) , Area_column(:,1) , Density_column*1e6 ,...
        RelativeDensity_column, TotalNumber, Circularity_column, Number_Cluster_column, Number_Cluster_column./(1e-6*cellROIPair(:,5))];
    
    try 
        
        disp('Export')
        disp(chan);
        
        if(isCombined)
            dirname = 'Combined';
        else
            dirname = sprintf('Ch%d', chan);
        end

        if ispc
            xlswrite(fullfile(outputFolder, 'DBSCAN Results.xls'), cellROIPair, dirname, 'A2');
            xlswrite(fullfile(outputFolder, 'DBSCAN Results.xls'), HeaderArray, dirname, 'A1');
            xlswrite(fullfile(outputFolder, 'DBSCAN Results.xls'), Matrix_Result, dirname, 'G2');
        end
        
    catch 
        % Catch error for xlswrite that exists on some machines
        % Format as text file and export to tab-delimited text file
     
        fprintf(1, 'Error in xlswrite.  Reverting to tab-delimited text file output.\n');
        
        assignin('base', 'cellROIPair', cellROIPair);
        assignin('base', 'HeaderArray', HeaderArray);
        assignin('base', 'Matrix_Result', Matrix_Result);
        
        matOut = [cellROIPair, nan(size(cellROIPair, 1), 1), Matrix_Result];
        if(isCombined)
            fID = fopen(fullfile(outputFolder, 'DBSCAN Results Combined.txt'), 'w+');
        else
            fID = fopen(fullfile(outputFolder, sprintf('DBSCAN Results Chan%d.txt', chan)), 'w+');
        end
        fprintf(fID, strcat(repmat('%s\t', 1, length(HeaderArray)-1), '%s\r\n'), HeaderArray{:});
        
        fmtString = strcat(repmat('%f\t', 1, length(HeaderArray)-1), '%f\r\n');
        
        for k = 1:size(matOut, 1)
            fprintf(fID, fmtString, matOut(k,:));
        end
        fclose(fID);
        
    end

end