function ReviewClusters(varargin)
    close all; % for easier debugging
    clear;
    warning ('off','all');
    
    figObj = findobj('Tag', 'REVIEWCLUSTERS GUI');
    if ~isempty(figObj)
        figure(figObj);
    else
        DoCGUIInitialize();
    end
end


function DoCGUIInitialize(varargin)

    figObj = findobj('Tag', 'REVIEWCLUSTERS GUI');
    settings = LoadSettings();
    
    if ~isempty(figObj) % If figure already exists, clear it out and reset it.
        clf(figObj);
        handles = guidata(figObj);
        fig1 = figObj;
    else
        WIDTH = 1000;
        HEIGHT = 900;
        ss = get(0,'screensize');
        left = (ss(3) - WIDTH) / 2;
        bottom = (ss(4) - HEIGHT) / 2;
        title = sprintf('Review DBSCAN clusters %s', settings.Version);
        fig1 = figure('Name',title, 'Tag', 'REVIEWCLUSTERS GUI', 'Units', 'pixels',...
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
        'Position',[0.2    vpos-0.02    0.65    0.06], 'BackgroundColor', [1 1 1], ...
        'String', '(empty)', 'HorizontalAlignment','left');
    
    handles.handles.hROIPopup = uicontrol('Style', 'popup', 'String', ...
        {'ROI1'}, 'Units', 'normalized', ...
        'Position', [0.87 vpos 0.1 0.04], 'Callback', @onROIChange);
    
    % channels
    vpos = vpos - vdelta;
    handles.handles.hInputChannelText = uicontrol(fig1, 'Style', 'text', 'Units', 'normalized', ...
        'Position',[0.01    vpos    0.9    0.06], 'BackgroundColor', [1 1 1], ...
        'String', 'Set channel and clusters (space separation e.g. 14 24 10) to view', 'HorizontalAlignment','left');
    
    vpos = vpos - vdelta/2;
    handles.handles.hLeftChannelPopup = uicontrol('Style', 'popup', 'String', ...
        {'none', 'Ch1', 'Ch2', 'Ch3'}, 'Units', 'normalized', 'Value', 2, ...
        'Position', [0.01 vpos 0.1 0.04], 'Callback', @onLelfChannelChange);
   
    handles.handles.hLeftChannelEdit = uicontrol('Style', 'edit', 'String', '', ...
        'Units', 'normalized', 'Position', [0.12 vpos 0.35 0.04], ...
        'HorizontalAlignment','left', 'Callback', @onLeftChannelEditChange);
    
    handles.handles.hRightChannelPopup = uicontrol('Style', 'popup', 'String', ...
        {'none', 'Ch1', 'Ch2', 'Ch3'}, 'Units', 'normalized', ...
        'Position', [0.51 vpos 0.1 0.04], 'Callback', @onRightChannelChange);
   
    handles.handles.hRightChannelEdit = uicontrol('Style', 'edit', 'String', '', ...
        'Units', 'normalized', 'Position', [0.62 vpos 0.35 0.04], ...
        'HorizontalAlignment','left', 'Callback', @onRightChannelEditChange);
    
    % plot
    handles.handles.axPlotHandle = axes('Position', [.03 0.05 .94 0.68]);
    set(handles.handles.axPlotHandle, 'xtick', [], 'ytick', []);
    box on
    
    % initial values
    handles.DEBUG = false;
    handles.inputDir = '/Users/toand/git/mivp/projects/nsw-melbourne/cluster_analysis/ClusDoC/test_dataset/3channels/Condition1_3G/Extracted_Region/DBSCAN Results';
    handles.loaded = false;
    handles.numChannels = 0;
    handles.currROI = 1;
    handles.leftChannel = 1;
    handles.rightChannel = 0; 
    handles.leftClusters = [];
    handles.rightClusters = [];
    handles.pointTypes = {'r.', 'b.'};
    handles.lineTypes = {'r', 'b'};
    
    guidata(handles.handles.MainFig, handles);

end % DoCGUIInitialize


function CloseGUIFunction(varargin)
    delete(findobj('Tag', 'REVIEWCLUSTERS GUI'));
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
    handles = guidata(findobj('Tag', 'REVIEWCLUSTERS GUI'));
    
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
    values = cell(handles.numRegions, 1);
    for ii = 1:handles.numRegions
        values{ii, 1} = sprintf('ROI%d', ii);
    end
    set(handles.handles.hROIPopup, 'string', values);
    
    handles.loaded = true;
    handles = plotData(handles);
    statusbar;
    
end


function onROIChange(hobj, ~)
    handles = guidata(findobj('Tag', 'REVIEWCLUSTERS GUI'));
    if(get(hobj, 'Value') ~= handles.currROI)
        handles.currROI = get(hobj, 'Value');
        % reset
        set(handles.handles.hLeftChannelPopup, 'Value', 2);
        set(handles.handles.hRightChannelPopup, 'Value', 1);
        set(handles.handles.hLeftChannelEdit, 'String', '');
        set(handles.handles.hRightChannelEdit, 'String', '');
        handles.leftChannel = 1;
        handles.rightChannel = 0;
        handles.leftClusters = [];
        handles.rightClusters = [];
        
        handles = plotData(handles);
        guidata(handles.handles.MainFig, handles);
    end
end

function onLelfChannelChange(hobj, ~)
    handles = guidata(findobj('Tag', 'REVIEWCLUSTERS GUI'));
    handles.leftChannel = get(hobj, 'Value') - 1;
    handles = plotData(handles);
    guidata(handles.handles.MainFig, handles);
end

function onRightChannelChange(hobj, ~)
    handles = guidata(findobj('Tag', 'REVIEWCLUSTERS GUI'));
    handles.rightChannel = get(hobj, 'Value') - 1;
    handles = plotData(handles);
    guidata(handles.handles.MainFig, handles);
end

function onLeftChannelEditChange(hobj, ~)
    handles = guidata(findobj('Tag', 'REVIEWCLUSTERS GUI'));
    handles.leftClusters = str2num(get(hobj, 'string'));
    handles = plotData(handles);
    guidata(handles.handles.MainFig, handles);
end

function onRightChannelEditChange(hobj, ~)
    handles = guidata(findobj('Tag', 'REVIEWCLUSTERS GUI'));
    handles.rightClusters = str2num(get(hobj, 'string'));
    handles = plotData(handles);
    guidata(handles.handles.MainFig, handles);
end

% plot 
function handles = plotData(handles)

    if(handles.loaded == false) 
        return; 
    end
    
    axes(handles.handles.axPlotHandle);
    cla;
    hold on
    if(handles.leftChannel > 0)
        cmt = handles.dbscanResults{handles.currROI, handles.leftChannel}.ClusterSmoothTable;
        points = [];
        for c=1:numel(cmt)
            points = [points; cmt{c}.Points];
        end
        scatter(points(:, 1), points(:, 2), handles.pointTypes{1});
        % draw contours
        if(numel(handles.leftClusters) > 0)
           for cc = 1:numel(handles.leftClusters)
               Contour = cmt{handles.leftClusters(cc)}.Contour;
               plot(Contour(:, 1), Contour(:, 2), handles.lineTypes{1}, 'LineWidth',2);
               p = cmt{handles.leftClusters(cc)}.Points;
               posx = (min(p(:, 1))+max(p(:, 1)))/2;
               posy = 0.996*min(p(:, 2));
               text(posx, posy, sprintf('%d', handles.leftClusters(cc)), 'Color','red','FontSize',12);
           end
        end
    end
    
    if(handles.rightChannel > 0 && handles.rightChannel ~= handles.leftChannel)
        cmt = handles.dbscanResults{handles.currROI, handles.rightChannel}.ClusterSmoothTable;
        points = [];
        for c=1:numel(cmt)
            points = [points; cmt{c}.Points];
        end
        scatter(points(:, 1), points(:, 2), handles.pointTypes{2});
        % draw contours
        if(numel(handles.rightClusters) > 0)
           for cc = 1:numel(handles.rightClusters)
               Contour = cmt{handles.rightClusters(cc)}.Contour;
               plot(Contour(:, 1), Contour(:, 2), handles.lineTypes{2}, 'LineWidth',2);
               p = cmt{handles.rightClusters(cc)}.Points;
               posx = (min(p(:, 1))+max(p(:, 1)))/2;
               posy = 0.996*min(p(:, 2));
               text(posx, posy, sprintf('%d', handles.rightClusters(cc)), 'Color','blue','FontSize',12);
           end
        end
    end
    hold off
        
end