% Post process: analyse coclustering (Approach2ab) from DBSCAN results
% You need to run DBSCAN on separate clusters first. The DBSCAN results will
% be stored in "DBSCAN Results" folder

function Coclustering(varargin)
    close all; % for easier debugging
    clear;
    warning ('off','all');
    
    figObj = findobj('Tag', 'COCLUSTERING GUI');
    if ~isempty(figObj)
        figure(figObj);
    else
        GUIInitialize();
    end
end


function GUIInitialize(varargin)

    figObj = findobj('Tag', 'COCLUSTERING GUI');
    settings = LoadSettings();
    
    if ~isempty(figObj) % If figure already exists, clear it out and reset it.
        clf(figObj);
        handles = guidata(figObj);
        fig1 = figObj;
    else
        WIDTH = 1000;
        HEIGHT = 600;
        ss = get(0,'screensize');
        left = (ss(3) - WIDTH) / 2;
        bottom = (ss(4) - HEIGHT) / 2;
        title = sprintf('Perform coclusters %s', settings.Version);
        fig1 = figure('Name',title, 'Tag', 'COCLUSTERING GUI', 'Units', 'pixels',...
            'Position',[left bottom WIDTH HEIGHT], 'color', [1 1 1]);%'Position',[0.05 0.3 760/scrsz(3) 650/scrsz(4)] );
        
        set(fig1, 'CloseRequestFcn', @CloseGUIFunction);

        handles.handles.MainFig = fig1;
    end
    handles.settings = settings;
    fprintf('GUI version %s\n', settings.Version);
    
    % controls
    vpos = 0.9;
    vdelta = 0.08;
    
    
    % DBSCAN result path
    handles.handles.hInputDir =  uicontrol(fig1, 'Units', 'normalized', 'Style', 'pushbutton', 'String', 'DBSCAN input dir',...
        'Position', [0.01    vpos    0.1500    0.05], 'Callback', @SetInputDir, 'Enable', 'on');

    handles.handles.hInputDirText = uicontrol(fig1, 'Style', 'text', 'Units', 'normalized', ...
        'Position',[0.2    vpos-0.02    0.78    0.06], 'BackgroundColor', [1 1 1], ...
        'String', '(empty)', 'HorizontalAlignment','left');
    
    % Approach2a - Mask Overlap Cocluster
    vpos = vpos - 1.5*vdelta;
    handles.handles.hMaskOverlapCheckbox =  uicontrol(fig1, 'Units', 'normalized', 'Style', 'checkbox', 'String', 'Mask overlap cocluster',...
        'Position', [0.01    vpos    0.1500    0.05], 'Callback', @onMaskOverlapChange, 'Value', true, 'BackgroundColor', [1 1 1]);
    
    vpos = vpos - vdelta;
    handles.handles.hChannelText = uicontrol(fig1, 'Style', 'text', 'Units', 'normalized', ...
        'Position',[0.01    vpos-0.02    0.1    0.06], 'BackgroundColor', [1 1 1], ...
        'String', 'Mask channel', 'HorizontalAlignment','left');
    
    handles.handles.hChannelPopup = uicontrol('Style', 'popup', 'String', ...
        {'Ch1'}, 'Units', 'normalized', ...
        'Position', [0.1 vpos 0.1 0.04], 'Callback', @onChannelChange);
    
    handles.handles.hOverlapDistanceText = uicontrol(fig1, 'Style', 'text', 'Units', 'normalized', ...
        'Position',[0.31    vpos-0.02    0.1    0.06], 'BackgroundColor', [1 1 1], ...
        'String', 'Overlap distance', 'HorizontalAlignment','left');
    
    handles.handles.hOverlapDistanceEdit = uicontrol('Style', 'edit', 'String', '50', 'Units', 'normalized', ...
        'Position', [0.41 vpos+0.005 0.1 0.04], 'Callback', @onOverlapDistanceChange);
    
    % Approach2b - Nearest Neighbour Cocluster
    vpos = vpos - 1.5*vdelta;
    handles.handles.hNearestNeighbourCheckbox =  uicontrol(fig1, 'Units', 'normalized', 'Style', 'checkbox', 'String', 'Nerest neighbour cocluster',...
        'Position', [0.01    vpos    0.1500    0.05], 'Callback', @onNereastNeighbourChange, 'Value', true, 'BackgroundColor', [1 1 1]);
    
    vpos = vpos - vdelta;
    handles.handles.hNumNeighbourText = uicontrol(fig1, 'Style', 'text', 'Units', 'normalized', ...
        'Position',[0.01    vpos-0.02    0.2    0.06], 'BackgroundColor', [1 1 1], ...
        'String', 'Number of neighbours', 'HorizontalAlignment','left');
    
    handles.handles.hNumNeighboursEdit = uicontrol('Style', 'edit', 'String', '10', 'Units', 'normalized', ...
        'Position', [0.15 vpos+0.005 0.1 0.04], 'Callback', @onNumNeighboursChange);
    
    
    % RUN button
    vpos = vpos - 2.5*vdelta;
    handles.handles.hRun =  uicontrol(fig1, 'Units', 'normalized', 'Style', 'pushbutton', 'String', 'Run Coclustering',...
        'Position', [0.01    vpos    0.2    0.1], 'Enable', 'off', 'Callback', @RunCoclustering);
    
    % initial values
    handles.DEBUG = false;
    handles.inputDir = '/Users/toand/git/mivp/projects/nsw-melbourne/cluster_analysis/ClusDoC/test_dataset/3channels/Condition1_3G/Extracted_Region/DBSCAN Results';
    handles.showFigures = false;
    % Approach2a - Mask Overlap Cocluster
    handles.MaskOverlap = {};
    handles.MaskOverlap.Enabled = true; % only run if enabled
    handles.MaskOverlap.Dir = fullfile(handles.inputDir, 'MaskOverlapCocluster');
    handles.MaskOverlap.OverlapDistance = 50; % maximum distance between 2 cluster to mark as coclustered
    handles.MaskOverlap.MaskChannel = 1; % a mask channel to compare to e.g. TCR
    % Approach2b - Nearest Neighbour Cocluster
    handles.NearestNeighbour = {};
    handles.NearestNeighbour.Enabled = true; % only run if enabled
    handles.NearestNeighbour.Dir = fullfile(handles.inputDir, 'NearestNeighbourCocluster');
    handles.NearestNeighbour.NumNeighbours = 10; % Number of nearesh neighbours
    % Others
    handles.loaded = false;
    handles.numRegions = 0;
    handles.numChannels = 0;
    handles.pointTypes = {'r.', 'g.', 'b.'};    
    handles.lineTypes = {'r', 'g', 'b'};
    
    guidata(handles.handles.MainFig, handles);

end % DoCGUIInitialize


function CloseGUIFunction(varargin)
    delete(findobj('Tag', 'COCLUSTERING GUI'));
end

function onMaskOverlapChange(~, ~)
    handles = guidata(findobj('Tag', 'COCLUSTERING GUI'));
    handles.MaskOverlap.Enabled = get(handles.handles.hMaskOverlapCheckbox', 'Value') > 0;
    %disp(handles.MaskOverlap.Enabled);
    guidata(handles.handles.MainFig, handles);
end

function onChannelChange(~, ~)
    handles = guidata(findobj('Tag', 'COCLUSTERING GUI'));
    handles.MaskOverlap.MaskChannel = get(handles.handles.hChannelPopup, 'Value');
    %disp(handles.MaskOverlap.MaskChannel);
    guidata(handles.handles.MainFig, handles);
end

function onOverlapDistanceChange(~, ~)
    handles = guidata(findobj('Tag', 'COCLUSTERING GUI'));
    handles.MaskOverlap.OverlapDistance = str2double(get(handles.handles.hOverlapDistanceEdit, 'String'));
    %disp(handles.MaskOverlap.OverlapDistance);
    guidata(handles.handles.MainFig, handles);
end

function onNumNeighboursChange(~, ~)
    handles = guidata(findobj('Tag', 'COCLUSTERING GUI'));
    handles.NearestNeighbour.NumNeighbours = str2double(get(handles.handles.hNumNeighboursEdit, 'String'));
    %disp(handles.NearestNeighbour.NumNeighbours);
    guidata(handles.handles.MainFig, handles);
end


function settings = LoadSettings()
    settings.Version = 'v1.0.0';
    settings.ShowScalebar = 1;
    settings.RoiSize = 5000;
    settings.DrawPointOnAlphaShape = 0;

    f = fopen('settings.ini', 'rt');
    while(~feof(f))
        line = fgets(f);
        if isempty(line)
            continue;
        end
        line = strtrim(line);
        C = strsplit(line, ':');
        if (numel(C) ~= 2)
            continue;
        end
        C{1} = strtrim(C{1});
        C{2} = strtrim(C{2});
        if strcmp(C{1}, 'version')
            settings.Version = C{2};
        elseif strcmp(C{1}, 'show_scalebar')
            settings.ShowScalebar = floor(str2double(C{2}));
        elseif strcmp(C{1}, 'roi_size_when_create_roi_by_click')
            settings.RoiSize = floor(str2double(C{2}));
        elseif strcmp(C{1}, 'draw_cluster_points_on_alpha_shape')
            settings.DrawPointOnAlphaShape = floor(str2double(C{2}));
        end
    end
    fclose(f);
end


% set DBSCAN resuls as input dir
function SetInputDir(~, ~, ~)
    handles = guidata(findobj('Tag', 'COCLUSTERING GUI'));
    
    if handles.DEBUG == false
        currentdirectory = pwd;
        selpath = uigetdir(currentdirectory, 'Select DBSCAN Results folder');
        if(selpath == 0)
            disp('Cancelled!');
            return;
        end
        set(handles.handles.hInputDirText, 'String', selpath);
        handles.inputDir = selpath;
    end
    
    set(handles.handles.MainFig, 'pointer', 'watch'); drawnow;
    handles = LoadInputData(handles);
    set(handles.handles.MainFig, 'pointer', 'arrow');
    
    guidata(handles.handles.MainFig, handles);
end


% init parameters from input data
function handles = LoadInputData(handles)

    handles.numChannels = 0;
    for ii=1:10
        fname = fullfile(handles.inputDir, sprintf('Ch%d', ii));
        if exist(fname,'dir') == 7
            handles.numChannels = ii;
        else
            break;
        end 
    end
    fprintf('Number of channels: %d\n', handles.numChannels);
    
    if(handles.numChannels == 0)
        statusbar(handles.handles.MainFig, 'ERROR: cannot find any channel!');
        return;
    end

    % load channel 1 to find number of regions
    fprintf('Load DBSCAN results...\n');
    statusbar(handles.handles.MainFig, 'Load DBSCAN results');
    
    load(fullfile(handles.inputDir, sprintf('Ch%d', 1), 'DBSCAN_Cluster_Result.mat'), 'ClusterSmoothTable');
    handles.numRegions = size(ClusterSmoothTable, 1);

    handles.dbscanResults = cell(handles.numRegions, handles.numChannels);
    for rr=1:handles.numRegions
        for ii=1:handles.numChannels
            fprintf('Loading DBSCAN result region %d channel %d...\n', rr, ii);
            statusbar(handles.handles.MainFig, sprintf('Loading DBSCAN result region %d channel %d...\n', rr, ii));
            load(fullfile(handles.inputDir, sprintf('Ch%d', ii), 'DBSCAN_Cluster_Result.mat'), 'ClusterSmoothTable', 'Result');
            result = {};
            result.ClusterSmoothTable = ClusterSmoothTable{rr,1};
            result.Result = Result{rr,1};
            handles.dbscanResults{rr,ii} = result;
        end
    end
    clearvars ClusterSmoothTable Result
    
    % update roi popup
    values = cell(handles.numChannels, 1);
    for ii = 1:handles.numChannels
        values{ii, 1} = sprintf('Ch%d', ii);
    end
    set(handles.handles.hChannelPopup, 'string', values);
        
    set(handles.handles.hRun, 'Enable', 'on');
    handles.loaded = true;
    statusbar(handles.handles.MainFig, 'Data loaded! Now you can run Colustering');
    
end


function RunCoclustering(~, ~, ~)
    handles = guidata(findobj('Tag', 'COCLUSTERING GUI'));
    if handles.loaded == false
        return;
    end
    
    set(handles.handles.MainFig, 'pointer', 'watch'); drawnow;
    statusbar(handles.handles.MainFig, 'Run colustering...');
    
    for rr=1:handles.numRegions
    
        fprintf('Processing region %d ...\n', rr);

        % display points
        if handles.showFigures
            figure;
            title(sprintf('Region %d', rr));
            hold on
        end

        for ii=1:handles.numChannels
            cmt = handles.dbscanResults{rr, ii}.ClusterSmoothTable;
            points = [];
            for c=1:numel(cmt)
                points = [points; cmt{c}.Points];
                Contour = cmt{c}.Contour;
                if handles.showFigures
                    plot(Contour(:, 1), Contour(:, 2), handles.lineTypes{ii}, 'LineWidth',1);
                end
            end
            if handles.showFigures
                scatter(points(:, 1), points(:, 2), handles.pointTypes{ii});
            end
        end
        if handles.showFigures
            hold off
        end

        % Approach2a - MaskOverlap
        if handles.MaskOverlap.Enabled

            fprintf('Region %d MaskOverlapCocluster ...\n', rr);
            statusbar(handles.handles.MainFig, sprintf('Region %d MaskOverlapCocluster ...\n', rr));
            mkdir(handles.MaskOverlap.Dir);
            maskClusters = handles.dbscanResults{rr, handles.MaskOverlap.MaskChannel}.ClusterSmoothTable;
            result2A = cell(numel(maskClusters), handles.numChannels-1);
            curChan = 0;
            for ii=1:handles.numChannels
                if ii == handles.MaskOverlap.MaskChannel
                    continue;
                end
                curChan = curChan + 1;
                curClusters = handles.dbscanResults{rr, ii}.ClusterSmoothTable;
                fprintf('MaskOverlapCocluster Comparing mask channel %d with channel %d ...\n', handles.MaskOverlap.MaskChannel, ii);
                statusbar(handles.handles.MainFig, sprintf('MaskOverlapCocluster Comparing mask channel %d with channel %d ...', handles.MaskOverlap.MaskChannel, ii));

                for c1 = 1:numel(maskClusters)
                    result2A{c1, 2*(curChan-1)+1} = []; % channels
                    result2A{c1, 2*(curChan-1)+2} = []; % min distances
                    for c2 = 1:numel(curClusters)
                        D = pdist2(maskClusters{c1}.Points, curClusters{c2}.Points);
                        minD = min(D(:)); 
                        if(minD <= handles.MaskOverlap.OverlapDistance)
                            if minD < 10
                                minD = 0;
                            end
                            result2A{c1, 2*(curChan-1)+1} = [result2A{c1, 2*(curChan-1)+1} c2];
                            result2A{c1, 2*(curChan-1)+2} = [result2A{c1, 2*(curChan-1)+2} minD];
                        end
                    end
                end

                %write to file
                statusbar(handles.handles.MainFig, sprintf('Region %d MaskOverlapCocluster saving to files ...\n', rr));
                f1 = fopen(fullfile(handles.MaskOverlap.Dir, sprintf('MaskOverlap_ROI%d_MaskChan%d_Ch%d_cocluster.csv', rr, handles.MaskOverlap.MaskChannel, ii)), 'wt');
                f2 = fopen(fullfile(handles.MaskOverlap.Dir, sprintf('MaskOverlap_ROI%d_MaskChan%d_Ch%d_no_cocluster.csv', rr, handles.MaskOverlap.MaskChannel, ii)), 'wt');
                header1 = ['Index,Nb,Area,TotalAreaDensity,Circularity,Mean_Density,AvRelativeDensity,' ...
                         'NumOverlap,OverlapClusters,OverlapMinDistances\n'];
                fprintf(f1, header1); 
                header2 = 'Index,Nb,Area,TotalAreaDensity,Circularity,Mean_Density,AvRelativeDensity\n';
                fprintf(f2, header2);
                for cInd=1:size(result2A, 1)
                    numoverlap = numel(result2A{cInd, 2*(curChan-1)+1});
                    c = maskClusters{cInd};
                    if(numoverlap > 0)
                        fprintf(f1, '%d,%d,%0.4f,%0.4f,%0.4f,%0.4f,%0.4f,%d,%s,%s\n', ...
                                    cInd,c.Nb,c.Area,c.TotalAreaDensity,c.Circularity,c.Mean_Density,c.AvRelativeDensity,...
                                    numoverlap,array2str(result2A{cInd, 2*(curChan-1)+1}, '%d'),array2str(result2A{cInd, 2*(curChan-1)+2}, '%0.2f'));
                    else
                        fprintf(f2, '%d,%d,%0.4f,%0.4f,%0.4f,%0.4f,%0.4f\n', ...
                                    cInd,c.Nb,c.Area,c.TotalAreaDensity,c.Circularity,c.Mean_Density,c.AvRelativeDensity);
                    end
                end
                fclose(f1); fclose(f2);

            end

            % write results to files
            fprintf('Region %d MaskOverlap: saving results to files ...\n', rr);
            MaskOverlapCocluster = result2A;
            save(fullfile(handles.MaskOverlap.Dir, sprintf('MaskOverlap_ROI%d_MaskChan%d.mat', rr, handles.MaskOverlap.MaskChannel)), 'MaskOverlapCocluster');

        end % approach 2a


        % Approach2b - NearestNeighbour
        if handles.NearestNeighbour.Enabled

            fprintf('Region %d NearestNeighbour ...\n', rr);
            statusbar(handles.handles.MainFig, sprintf('Region %d NearestNeighbour ...\n', rr));
            mkdir(handles.NearestNeighbour.Dir);
            for ii=1:handles.numChannels

                Clusters1 = handles.dbscanResults{rr, ii}.ClusterSmoothTable;

                for jj=1:handles.numChannels
                    if jj == ii
                        continue;
                    end
                    fprintf('Region %d NearestNeighbour between Ch%d and Ch%d ...\n', rr, ii, jj);
                    statusbar(handles.handles.MainFig, sprintf('Region %d NearestNeighbour between Ch%d and Ch%d ...', rr, ii, jj));
                    result2B = zeros(numel(Clusters1), handles.NearestNeighbour.NumNeighbours);
                    Clusters2 = handles.dbscanResults{rr, jj}.ClusterSmoothTable;

                    for c1 = 1:numel(Clusters1)
                        dists = zeros(numel(Clusters2), 1);
                        for c2=1:numel(Clusters2)
                            D = pdist2(Clusters1{c1}.Points, Clusters2{c2}.Points);
                            dists(c2) = min(D(:));
                            if (dists(c2) < 10)
                                dists(c2) = 0;
                            end
                        end
                        dists = sort(dists);
                        result2B(c1, :) = dists(1:handles.NearestNeighbour.NumNeighbours, 1);
                    end

                    % save result Ch{ii} Ch{jj}
                    NearestNeighbourCocluster = result2B;
                    dlmwrite(fullfile(handles.NearestNeighbour.Dir, sprintf('NearestNeighbour_ROI%d_Ch%d_Ch%d.csv', rr, ii, jj)), NearestNeighbourCocluster);
                    save(fullfile(handles.NearestNeighbour.Dir, sprintf('NearestNeighbour_ROI%d_Ch%d_Ch%d.mat', rr, ii, jj)), 'NearestNeighbourCocluster');
                end
            end

        end % approach2b

    end  %regions
    
    set(handles.handles.MainFig, 'pointer', 'arrow'); drawnow;
    statusbar(handles.handles.MainFig, 'Finished! Results are stored in the input folder');
end


% Helpers
function res = array2str(arr, format)
    if nargin == 1
        format = '%d';
    end
    res = '';
    if numel(arr) > 0
        res = sprintf(format, arr(1));
    end
    for ii=2:numel(arr)
        res = [res, ' ', sprintf(format, arr(ii))];
    end
end