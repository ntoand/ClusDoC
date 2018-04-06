function ClusDoC(varargin)
    version = '1.0.0';
    fprintf('Clus-DoC version %s\n', version);
    close all; % for easier debugging
    DEBUG = false;
    if(DEBUG)
        addpath('dev'); % "ln -s private dev" to debug line by line in private funcs
    end
    
    figObj = findobj('Tag', 'PALM GUI');
    if ~isempty(figObj)
        figure(figObj);
    else
        DoCGUIInitialize(DEBUG);
    end
end

function UpdateStatusBar(handles, str)
    statusbar(handles.handles.MainFig, str);
end

function CreateDir(path)
    if ~(exist(path, 'dir') == 7)
        mkdir(path);
    end
end

function DoCGUIInitialize(varargin)

    figObj = findobj('Tag', 'PALM GUI');
    if ~isempty(figObj) % If figure already exists, clear it out and reset it.
        clf(figObj);
        handles = guidata(figObj);
        fig1 = figObj;
    else
        %fig1 = figure('Name','Clus-DoC', 'Tag', 'PALM GUI', 'Units', 'pixels',...
        %    'Position',[700 150 924 780], 'color', [1 1 1]);%'Position',[0.05 0.3 760/scrsz(3) 650/scrsz(4)] );
        ss = get(0,'screensize');
        left = (ss(3) - 924) / 2;
        bottom = (ss(4) - 810) / 2;
        fig1 = figure('Name','Clus-DoC', 'Tag', 'PALM GUI', 'Units', 'pixels',...
            'Position',[left bottom 924 780], 'color', [1 1 1]);%'Position',[0.05 0.3 760/scrsz(3) 650/scrsz(4)] );
        
        set(fig1, 'CloseRequestFcn', @CloseGUIFunction);

        handles.handles.MainFig = fig1;
    end
    handles.DEBUG = varargin{1};

    panel_border = 680/925-0.01;
    
    % Load in icons used here, convert to appropriate format
    currFileName = mfilename('fullpath');
    currPath = fileparts(currFileName);   

	[SquareSelectIcon, ~] = imread(fullfile(currPath, 'private', 'SquareROIIcon.jpg'));
	[PolySelectIcon, ~] = imread(fullfile(currPath, 'private', 'PolyROIIcon.jpg'));

    handles.handles.b_panel = uipanel(fig1, 'Units', 'normalized', 'Position', [0 0.05, 1-panel_border, 0.90], ...
        'BackgroundColor', [1 1 1], 'BorderType', 'none', 'Tag', 'b_panel');

    % b_panel1 = uipanel(fig1, 'Units', 'normalized', 'Position',[0 0, 1-panel_border, 0.5] , ...
    %     'BackgroundColor', [0.5 0.5 0.5], 'BorderType', 'none', 'Tag', 'b_panel');


    handles.handles.ax_panel = uipanel(fig1, 'Units', 'normalized', 'Position', [1-panel_border 0.015 panel_border .90], ...
        'BackgroundColor', [1 1 1], 'BorderType', 'none', 'Tag', 'ax_panel');
    set(0,'DefaultFigureColormap',jet)
    
    handles.handles.loadPanel = uipanel(fig1, 'Units', 'normalized', 'Position', [0 .88 1 .12], ...
        'BackgroundColor', [1 1 1], 'BorderType', 'none', 'Tag', 'loadPanel');
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Load panel objects
    % Button
    handles.handles.Load_out =     uicontrol(handles.handles.loadPanel, 'Units', 'normalized', 'Style', 'pushbutton', 'String', 'Select Input File(s)',...
        'Position', [0.01    0.6710    0.1500    0.2890],...
        'Callback', @Load_Data, 'Tag', 'Add Data File(s)');

    handles.handles.Load_text = uicontrol(handles.handles.loadPanel, 'Style', 'edit', 'Units', 'normalized', ...
        'Position',[0.200    0.6967    0.6000    0.2264], 'BackgroundColor', [1 1 1], ...
        'String', 'Input File(s)', 'Callback', @Load_edit, 'Tag', 'Load_textbox');

    handles.handles.CoordinatesSet =     uicontrol(handles.handles.loadPanel, 'Units', 'normalized', 'Style', 'pushbutton', 'String', 'Select Coordinates File',...
        'Position', [0.01    0.3610    0.1500    0.2890],...
        'Callback', @CoordinatesPush, 'Tag', 'Set Coordinates Path');

    handles.handles.CoordinatesText = uicontrol(handles.handles.loadPanel, 'Style', 'edit', 'Units', 'normalized', ...
        'Position',[0.200    0.3817    0.6000    0.2764], 'BackgroundColor', [1 1 1], ...
        'String', 'Coordinates File Path', 'Callback', @CoordinatesEdit, 'Tag', 'Load_textbox');

    handles.handles.OutputSet =     uicontrol(handles.handles.loadPanel, 'Units', 'normalized', 'Style', 'pushbutton', 'String', 'Set Output Path',...
        'Position', [0.01    0.0410    0.1500    0.2890],...
        'Callback', @OutputEdit, 'Tag', 'Set Output Path');

    handles.handles.OutputText = uicontrol(handles.handles.loadPanel, 'Style', 'edit', 'Units', 'normalized', ...
        'Position',[0.200    0.0667    0.6000    0.2764], 'BackgroundColor', [1 1 1], ...
        'String', 'Output Folder Path', 'Callback', @OutputTextEdit, 'Tag', 'Load_textbox');
        
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Button
    % Define buttons and position.  Can continute this down to add more buttons
    % in the future.  Can modify button appearance here.  Addition of multiple
    % additional buttons may require an increase in figure size or decrease in
    % button size to keep all visible.

    % Button Dimensions - now in relative units.
    butt_width = .96;
    butt_height = .08;
    butt_offset_y = butt_height / 5;
    butt_offset_y2 = butt_height / 8;

    space1 = 0.01;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Button Panel 2
    space2 = 2 * space1;
    col2_x = 0.28; % end of text colume ~ start of 2nd control column
    col3_x = 0.85;

    % Load Zen Data
    xbutton=space2;
    ybutton=0.92;

    % Button Load individual cell (1st row)
    h1=butt_height/2;
    w1=col2_x;
    xbutton=space2;
    ybutton=ybutton-(space1+h1)-h1/4;
    handles.handles.hLoad_cell =     uicontrol(handles.handles.b_panel, 'Units', 'normalized', 'Style', 'text', 'String', 'Active Cell',...
        'Position', [xbutton ybutton w1 h1], 'Tag', 'Load_Cell', 'horizontalalignment', 'left', 'backgroundcolor', [1 1 1], 'fontsize', 10);

    % Popupmenu for selected Cell
    h2=butt_height/3;
    w2=col3_x - col2_x - space1;
    xbutton2=col2_x;
    ybutton2=ybutton + butt_offset_y;
    handles.handles.popupCell2 =     uicontrol(handles.handles.b_panel, 'Units', 'normalized', 'Style', 'popup', 'String', {'Cell'},...
        'Position', [xbutton2 ybutton2 w2 h2],'Callback', @popupCell_Callback2, 'Tag', 'SelectCell');

    h3=1.3*h2;
    w3=1 - col3_x - space1;
    xbutton3=col3_x;
    ybutton3=ybutton + butt_offset_y2;
	handles.handles.DeleteCell =     uicontrol(handles.handles.b_panel, 'Units', 'normalized', 'Style', 'pushbutton', 'String', {'X'},...
        'Position', [xbutton3 ybutton3 w3 h3],'Callback', @DeleteCell, 'Tag', 'DeleteCell', 'enable', 'off');
    

    % PushButton to Create ROI (2nd row)
    h1=butt_height/2;
    w1=col2_x;
    xbutton=space2;
    ybutton=ybutton-(space1+h1)-h1/4;
    handles.handles.hSelectROI = uicontrol(handles.handles.b_panel, 'Units', 'normalized','Style','text','String','Active ROI',...
        'Position',[xbutton ybutton w1 h1], 'Tag', 'SelectROI', 'horizontalAlignment', 'left', 'backgroundcolor', [1 1 1], 'fontsize', 10);
    
    % Popupmenu for selected ROI
    h2=butt_height/3;
    w2=col3_x - col2_x - space1;
    xbutton2=col2_x;
    ybutton2=ybutton + butt_offset_y;
    handles.handles.popupROI2 = uicontrol(handles.handles.b_panel, 'Units', 'normalized', 'Style', 'popup', 'String', {'ROI'},...
        'Position', [xbutton2 ybutton2 w2 h2], 'Callback', @popupROI_Callback2, 'Tag', 'SelectROI');
    
    h3=1.3*h2;
    w3=1 - col3_x - space1;
    xbutton3=col3_x;
    ybutton3=ybutton + butt_offset_y2;
	handles.handles.DeleteROI =     uicontrol(handles.handles.b_panel, 'Units', 'normalized', 'Style', 'pushbutton', 'String', {'X'},...
        'Position', [xbutton3 ybutton3 w3 h3],'Callback', @DeleteROI, 'Tag', 'DeleteROI', 'enable', 'off');

    % Select ROI (3rd row)
    h1=butt_height/2;
    w1=col2_x;
    xbutton=space2;
    ybutton=ybutton-(space1+h1)-h1/4;
	handles.handles.hSelectROI = uicontrol(handles.handles.b_panel, 'Units', 'normalized','Style','text','String','Add ROI',...
        'Position',[xbutton ybutton w1 h1], 'Tag', 'SelectROI', 'horizontalAlignment', 'left', 'backgroundcolor', [1 1 1], 'fontsize', 10);

    w2=0.1;
    h2 = h1;
    xbutton2 = col2_x;
    ybutton2 = ybutton + butt_offset_y2;
	handles.handles.hCreateSquareROI = uicontrol(handles.handles.b_panel, 'Units', 'normalized', 'Style', 'pushbutton', 'CData', SquareSelectIcon,...
        'Position',[xbutton2 ybutton2 w2 h2],'Callback', @CreateSquareROI, 'Tag', 'CreateSquareROI','enable','off');
    
    xbutton3 = xbutton2+w2+space2;
	handles.handles.hCreatePolyROI = uicontrol(handles.handles.b_panel, 'Units', 'normalized', 'Style', 'pushbutton', 'CData', PolySelectIcon,...
        'Position',[xbutton3 ybutton2 w2 h2],'Callback', @CreatePolyROI, 'Tag', 'CreatePolyROI','enable','off');

    % Save Cells and ROIs set
    xbutton4 = xbutton3 + w2 + 2*space2;
    w4 = 1 - xbutton4;
    handles.handles.hSaveCellROI = uicontrol(handles.handles.b_panel, 'Units', 'normalized','Style','pushbutton','String','Export ROIs',...
        'Position',[xbutton4 ybutton2 w4 h2],'Callback', @SaveCellROI, 'Tag', 'SaveROI','enable','off');
    
    
    % Popupmenu for selected Mask (4th row)
    h1=butt_height/2;
    w1=col2_x;
    xbutton=space2;
    ybutton=ybutton-(space1+h1)-h1/4;
	handles.handles.maskText = uicontrol(handles.handles.b_panel, 'Units', 'normalized','Style','text','String','Mask File',...
        'Position',[xbutton ybutton w1 h1], 'Tag', 'SelectMask', 'horizontalAlignment', 'left', 'backgroundcolor', [1 1 1], 'fontsize', 10);

    h2=butt_height/3;
    w2=1 - col2_x;
    xbutton2=col2_x;
    ybutton2=ybutton + butt_offset_y;
    handles.handles.popupMask = uicontrol(handles.handles.b_panel, 'Units', 'normalized', 'Style', 'popup', 'String', {''},...
        'Position', [xbutton2 ybutton2 w2 h2], 'Callback', @popupMask_Callback, 'Tag', 'SelectMask');
    
    % Align mask to cell data button (5th row)
    w1 = 1 - xbutton4; 
    h1 = butt_height/2;
    xbutton = xbutton4; % same as Export ROIs button
    ybutton = ybutton-(space1+h1)-h1/4 + butt_offset_y;
    handles.handles.alignMaskButton = uicontrol(handles.handles.b_panel, 'Units', 'normalized','Style','pushbutton','String','Align Mask',...
        'Position',[xbutton ybutton w1 h1],'Callback', @alignMask, 'Tag', 'AlignMask','enable','off');
    
    
    % Select data to process (new row)
    h1=butt_height/2;
    w1=col2_x;
    xbutton=space2;
    ybutton=ybutton-(space1+h1)-h1/4-h1; % -h1 to add some space between rows
    handles.handles.selectedDataText = uicontrol(handles.handles.b_panel, 'Units', 'normalized','Style','text','String','Process',...
        'Position',[xbutton ybutton w1 h1], 'Tag', 'SelectMask', 'horizontalAlignment', 'left', 'backgroundcolor', [1 1 1], 'fontsize', 10);

    h2=butt_height/3;
    w2=1 - col2_x;
    xbutton2=col2_x;
    ybutton2=ybutton + butt_offset_y;
    handles.handles.popupProcessType = uicontrol(handles.handles.b_panel, 'Units', 'normalized', 'Style', 'popup', 'String', ...
        {'Channels 1 and 2 separately', 'Combined data'},...
        'Position', [xbutton2 ybutton2 w2 h2], 'Callback', @popupProcessType_Callback, 'Tag', 'SelectMask');

    
    % Button RipleyK test for Active ROI (new row)
    h1=butt_height/2;
    w1=(1-2*space2)/2;
    xbutton=space2;
    ybutton=ybutton-(space1+h1)-h1/4; % -h1 to add some space between rows
    handles.handles.hRipleyActiveROI = uicontrol(handles.handles.b_panel, 'Units', 'normalized', 'Style', 'pushbutton', 'String', 'RipleyK Test',...
        'Position', [xbutton ybutton w1 h1], 'Callback', @RipleyKtest, 'Tag', 'RipleyK_test','enable','off');

    % Button DBSCAN test for Active ROI
    handles.handles.hDBSCANActiveROI = uicontrol(handles.handles.b_panel, 'Units', 'normalized', 'Style', 'pushbutton', 'String', 'DBSCAN Test',...
        'Position', [xbutton+w1+space1 ybutton w1 h1],'Callback', @DBSCAN_Test, 'Tag', 'DBSCAN_test','enable','off');

    % Button RipleyK for Selected ROIs (new row
    h1=butt_height/2;
    w1=1-2*space2;
    xbutton=space2;
    ybutton=ybutton-(space1+h1)-h1/4; % -h1 if want to add some space between rows
    handles.handles.hRipleyK_All = uicontrol(handles.handles.b_panel, 'Units', 'normalized', 'Style', 'pushbutton', 'String', 'Run RipleyK',...
        'Position', [xbutton ybutton w1 h1], 'Callback', @RunRipleyK, 'Tag', 'RipleyK_ROI','enable','off');

    % Button DBSCAN for Selected ROIs
    h1=butt_height/2;
    w1=1-2*space2;
    xbutton=space2;
    ybutton=ybutton-h1-space1;
    handles.handles.hDBSCAN_All = uicontrol(handles.handles.b_panel, 'Units', 'normalized', 'Style', 'pushbutton', 'String', 'Run DBSCAN',...
        'Position', [xbutton ybutton w1 h1], 'Callback', @RunDBSCAN, 'Tag', 'DBSCAN_All','enable','off');

    % Button Degree of colocalisation
    h1=butt_height/2;
    w1=1-2*space2;
    xbutton=space2;
    ybutton=ybutton-h1-space1;
    handles.handles.hDoC_All1 = uicontrol(handles.handles.b_panel, 'Units', 'normalized', 'Style', 'pushbutton', 'String', 'Run Clus-DoC',...
        'Position', [xbutton ybutton w1 h1], 'Callback', @RunDoC, 'Tag', 'DoC_All','enable','off');
    
    % Button probability of co-localisation (PoC)
    h1=butt_height/2;
    w1=1-2*space2;
    xbutton=space2;
    ybutton=ybutton-h1-space1;
    handles.handles.hPoC_All1 = uicontrol(handles.handles.b_panel, 'Units', 'normalized', 'Style', 'pushbutton', 'String', 'Run Clus-PoC',...
        'Position', [xbutton ybutton w1 h1], 'Callback', @RunPoC, 'Tag', 'DoC_All','enable','off');
    
    % Button Results Explorer
    h1=butt_height/2;
    w1=1-2*space2;
    xbutton=space2;
    ybutton=ybutton-h1-space1 -h1; % -h1 to add some space between rows
    handles.handles.ResultsExplorerButton = uicontrol(handles.handles.b_panel, 'Units', 'normalized', 'Style', 'pushbutton', 'String', 'Results Explorer',...
        'Position', [xbutton ybutton w1 h1], 'Callback', @ResultsExplorerPush, 'Tag', 'ResultsExplorer', 'enable', 'off', 'visible', 'off');
    
    % Export checkbox
    h1=butt_height/2;
    w1=1-2*space2;
    xbutton=space2;
    ybutton=ybutton-h1-space1;
    handles.handles.ExportResultsCheckbox = uicontrol(handles.handles.b_panel, 'Units', 'normalized', 'Style', 'checkbox', 'String', 'Export only points in active ROI',...
        'Value', 1, 'Position', [xbutton ybutton w1 h1], 'Callback', @ExportToTextCheckBox, 'Tag', 'ExportToTextCheckBox', ...
        'backgroundcolor', [1 1 1], 'fontsize', 10);
    
    % Button ExporttoText
    h1=butt_height/2;
    w1=1-2*space2;
    xbutton=space2;
    ybutton=ybutton-h1-space1;
    handles.handles.ExportResultsButton = uicontrol(handles.handles.b_panel, 'Units', 'normalized', 'Style', 'pushbutton', 'String', 'Export Result Tables',...
        'Position', [xbutton ybutton w1 h1], 'Callback', @ExportToTextPush, 'Tag', 'ExportToText', 'enable', 'off');

    % Button Reset
    h1=butt_height/2;
    w1=1-2*space2;
    xbutton=space2;
    ybutton=ybutton-space2 -h1; % -h1 to add some space between rows
    handles.handles.hreset = uicontrol(handles.handles.b_panel, 'Units', 'normalized', 'Style', 'pushbutton', 'String', 'Reset',...
        'Position', [xbutton ybutton w1 h1], 'Callback', @Reset, 'Tag', 'Reset','enable','on');

    % End of buttons
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Axes initialization

    handles.handles.ax_h = axes('Parent', handles.handles.ax_panel, 'Position', [0.005 .01 .99 .98]);
    set(handles.handles.ax_h, 'Tag', 'PALM GUI axis');
    % initialize data to put into the axes on startup
    z=peaks(1000);
    z = z./max(abs(z(:)));
    fill_image = imshow(z, 'Parent', handles.handles.ax_h, 'ColorMap', jet, 'DisplayRange', [min(z(:)) max(z(:))]);
    set(fill_image, 'Tag', 'fill_image', 'HitTest', 'on');

    % Get rid of tick labels
    set(handles.handles.ax_h, 'xtick', [], 'ytick', [])
    axis(handles.handles.ax_h, 'image'); % Freezes axis aspect ratio to that of the initial image - disallows skewing due to figure reshaping.

    guidata(fig1, handles);
    initializeParameters();
    
    UpdateStatusBar(handles, 'GUI initialized'); 
    
end
    
function initializeParameters(varargin)

    % Set initial parameters for calculation + display parameters

    handles = guidata(findobj('Tag', 'PALM GUI'));
    
    % Some constants
    handles.CONST.DEFAULT_ROI_SIZE = 4000;
    handles.CONST.PROCESS_SEPARATE = 1;
    handles.CONST.PROCESS_COMBINED = 2;
    handles.CONST.POC_TYPE1 = 1;    % poc = sumA / sumB
    handles.CONST.POC_TYPE2 = 2;    % poc = sumA / (sumA + sumB)
    
    % Initialize structure to pass values between GUI components
    handles.CellData = {};
    handles.ROIData = {};
    handles.ROIPos = [];
    handles.CurrentCellData = 1;
    handles.CurrentROIData = [];
    handles.ProcessType = handles.CONST.PROCESS_SEPARATE; % Channels 1 and 2 separately
    
    handles.Path_name = pwd;

    % Default ROI settings
    handles.ROISize = handles.CONST.DEFAULT_ROI_SIZE; % Length of ROI, in nm

    % Initialize some global settings
    handles.Chan1Color = [46, 204, 113]/255; % Flat UI Emerald
    handles.Chan2Color = [231, 76, 60]/255; % Flat UI Alizarin
    handles.CombinedColor = [0, 0, 255]/255;
    handles.UnselectedROIColor = [142, 68, 173]/255; % Flat UI Peter River
    handles.ROIColor = [40, 142, 230]/255; % Flat UI Amethyst
    
    % Default RipleyK settings
    handles.RipleyK.Start = 0;
    handles.RipleyK.End = 1000;
    handles.RipleyK.Step = 10;
    handles.RipleyK.MaxSampledPts = 1e4;
    
    % Default DBSCAN parameters
    % for channel1, channel2, combined data
    for k = 1:3
        handles.DBSCAN(k).epsilon = 20;
        handles.DBSCAN(k).minPts = 3;
        handles.DBSCAN(k).UseLr_rThresh = true;
        handles.DBSCAN(k).Lr_rThreshRad = 20;
        handles.DBSCAN(k).SmoothingRad = 15;
        handles.DBSCAN(k).Cutoff = 10;
        handles.DBSCAN(k).threads = 2;
        handles.DBSCAN(k).DoStats = true;
    end
    
    % Default DoC parameters
    handles.DoC.Lr_rRad = 20;
    handles.DoC.Rmax = 500;
    handles.DoC.Step = 10;
    handles.DoC.ColoThres = 0.4;
    handles.DoC.NbThresh = 10;
    
    % Default PoC parameters
    handles.PoC.FuncType = handles.CONST.POC_TYPE1;
    handles.PoC.Lr_rRad = 20;
    handles.PoC.Sigma = 100;
    handles.PoC.ColoThres = 0.4;
    handles.PoC.NbThresh = 10;
    
    % output
    handles.ClusterTable = [];
    
    % Send back to main figure
    guidata(handles.handles.MainFig, handles);
    
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Callback functions

function Load_edit(varargin)

end

function OutputTextEdit(varargin)

end

function CoordinatesEdit(varargin)

end

function ExportToTextCheckBox(varargin)

end

function CoordinatesPush(varargin)

    handles = guidata(findobj('Tag', 'PALM GUI'));

    [fileName, pathName] = uigetfile('coordinates.txt', 'Select Coordinates File');
    handles.CoordFile = fullfile(pathName, fileName);
    
    if exist(fullfile(pathName, fileName), 'file') == 2

        [handles.ROICoordinates, loadOK] = loadCoordinatesFile(fullfile(pathName, fileName), handles.ROIMultiplier, handles);
        
        if loadOK
            handles.ROIPopupList = cell(length(handles.ImportFiles), 1);
            for c = 1:length(handles.CellData)
                % Reset pull-down menu to new entries and set to desired value
                handles.ROIPopupList{c} = strsplit(num2str(1:length(handles.ROICoordinates{c})), ' ');
            end
            set(handles.handles.popupROI2, 'String', handles.ROIPopupList{handles.CurrentCellData});
        end


        handles.CurrentROIData = 1;
        set(handles.handles.popupROI2, 'Value', handles.CurrentROIData);


        handles.CellData = assignROIsToCellData(handles.CellData, handles.ROICoordinates, handles.NDataColumns);
        
        % Set output folder to match

        set(handles.handles.CoordinatesText, 'String', fullfile(pathName, fileName));

        guidata(handles.handles.MainFig, handles)
        plotAllROIs(handles.CurrentCellData);

    end
end


% Plot SMLM data
function FunPlot(whichCell)

    handles = guidata(findobj('Tag', 'PALM GUI'));

    if numel(unique(handles.CellData{whichCell}(:,12))) == 1
        handles.handles.dSTORM_plot = plot(handles.handles.ax_h, handles.CellData{whichCell}(:,5), handles.CellData{whichCell}(:,6), ...
            'Marker','.','MarkerSize',3,'LineStyle','none',...
            'color','red', 'Tag', 'dSTORM_plot');
    else
        handles.handles.dSTORM_plot = plot(handles.handles.ax_h, handles.CellData{whichCell}(handles.CellData{whichCell}(:, 12) == 1, 5), ...
            handles.CellData{whichCell}(handles.CellData{whichCell}(:, 12) == 1, 6),...
            'Marker','.','MarkerSize',3,'LineStyle', 'none', 'color', handles.Chan1Color, 'Tag', 'dSTORM_plot');
        set(handles.handles.ax_h, 'NextPlot', 'add');
        handles.handles.dSTORM_plot = plot(handles.handles.ax_h, handles.CellData{whichCell}(handles.CellData{whichCell}(:, 12) == 2, 5), ...
            handles.CellData{whichCell}(handles.CellData{whichCell}(:, 12) == 2, 6), ...
            'Marker','.','MarkerSize',3,'LineStyle','none','color', handles.Chan2Color, 'Tag', 'dSTORM_plot');
        set(handles.handles.ax_h, 'NextPlot', 'replace');
    end
    
    % Reset list of ROIs to match current cell
    if isfield(handles.handles, 'popupROI2')
        set(handles.handles.popupROI2, 'String', handles.ROIPopupList{whichCell});
    end
    set(handles.handles.ax_h, 'xtick', [], 'ytick', [], 'Position', [0.005 .01 .99 .955])
    set(handles.handles.ax_h, 'xlim', [0 handles.MaxSize], 'ylim', [0 handles.MaxSize]);
    axis image % Freezes axis aspect ratio to that of the initial image -
    
    % Mask files
    handles.SelectedMask = handles.MaskCellPair(whichCell, 2);
    set(handles.handles.popupMask, 'Value', handles.SelectedMask + 1);
    
    guidata(handles.handles.MainFig, handles);
    
    plotAllROIs(whichCell);
    displayMaskImg(handles);

end


function plotAllROIs(whichCell)
    % Plot all ROIs in current window

    handles = guidata(findobj('Tag', 'PALM GUI'));
    
    
    delete(findobj('parent', handles.handles.ax_h, 'color', handles.UnselectedROIColor));
    delete(findobj('parent', handles.handles.ax_h, 'color', handles.ROIColor));
    
    set(handles.handles.ax_h, 'NextPlot', 'add');
    handles.handles.ROIOutlines = zeros(length(handles.ROICoordinates{whichCell}), 1);
    for k = 1:length(handles.ROICoordinates{whichCell})
       handles.handles.ROIOutlines(k) = plot(handles.handles.ax_h, ...
           handles.ROICoordinates{whichCell}{k}(:,1), ...
            handles.ROICoordinates{whichCell}{k}(:,2), 'linewidth', 2, ...
            'Color', handles.UnselectedROIColor);
    end
        
    set(handles.handles.ax_h, 'NextPlot', 'replace');
    
    
    if (handles.CurrentROIData > length(handles.ROIPopupList{whichCell})) & (~isempty(handles.ROIPopupList{whichCell}))
        handles.CurrentROIData = length(handles.ROIPopupList{whichCell});
        set(handles.handles.popupROI2, 'Value', handles.CurrentROIData);
    elseif isempty(handles.ROIPopupList{whichCell})
        handles.CurrentROIData = []; 
%         disp('emptyROI');
        set(handles.handles.popupROI2, 'String', 'ROI');
    else
        % Nothing to do
    end
    
    if ~isempty(handles.handles.ROIOutlines)
        set(handles.handles.ROIOutlines(handles.CurrentROIData), 'color', handles.ROIColor);
    end
    
    set(handles.handles.ax_h, 'xlim', [0 handles.MaxSize], 'ylim', [0 handles.MaxSize]);
    
    guidata(handles.handles.MainFig, handles); 
    
end


function DeleteCell(varargin)

    handles = guidata(findobj('Tag', 'PALM GUI'));
       
    handles.ImportFiles(handles.CurrentCellData) = [];
    handles.CellData(handles.CurrentCellData) = [];
    handles.ROICoordinates(handles.CurrentCellData) = [];
    
    handles.MaskCellPair(handles.CurrentCellData, :) = [];
    
    popupList = cell(length(handles.ImportFiles), 1);
    for pL = 1:length(popupList)
        [~, popupList{pL}, ext] = fileparts(handles.ImportFiles{pL});
        popupList{pL} = strcat(popupList{pL}, ext);
    end

    if (handles.CurrentCellData == 1) && (~isempty(handles.CellData))
        
        % Delete first entry
        set(handles.handles.popupCell2, 'string', popupList);
        
        if ~isempty(length(handles.CellData{handles.CurrentCellData}))
            handles.CurrentCellData = 1;
            set(handles.handles.popupCell2, 'Value', handles.CurrentCellData);
        else
            handles.CurrentCellData = [];
        end
        
        set(handles.handles.Load_text, 'String', sprintf('%s[%d files]', handles.Path_name, length(handles.CellData)));
        
    elseif isempty(handles.CellData)
        % Delete remaining item from list
        handles.CurrentROIData = [];
        handles.CurrentCellData = [];
        set(handles.handles.popupROI2, 'string', 'ROI');
        set(handles.handles.DeleteROI, 'enable', 'off');
        set(handles.handles.popupCell2, 'string', 'Cell');
        set(handles.handles.DeleteCell, 'enable', 'off');
        set(handles.handles.Load_text, 'string', 'Input File(s)');
        set(handles.handles.popupMask, 'Value', 1);
        % Plot empty axes filler
        
        % initialize data to put into the axes on startup
        z=peaks(1000);
        z = z./max(abs(z(:)));
        fill_image = imshow(z, 'Parent', handles.handles.ax_h, 'ColorMap', jet, 'DisplayRange', [min(z(:)) max(z(:))]);
        set(fill_image, 'Tag', 'fill_image', 'HitTest', 'on');

        % Get rid of tick labels
        set(handles.handles.ax_h, 'xtick', [], 'ytick', [])
        axis(handles.handles.ax_h, 'image'); % Freezes axis aspect ratio to that of the initial image - disallows skewing due to figure reshaping.
        
    elseif (handles.CurrentCellData > length(handles.CellData)) && (handles.CurrentCellData > 1) && (~isempty(handles.CellData))
         % Delete first entry
        handles.CurrentCellData = length(handles.CellData);
        set(handles.handles.popupCell2, 'Value', handles.CurrentCellData);
        set(handles.handles.popupCell2, 'string', popupList);
        set(handles.handles.Load_text, 'String', sprintf('%s[%d files]', handles.Path_name, length(handles.CellData)));
    else
        % Delete middle entry
        set(handles.handles.popupCell2, 'string', popupList);
        set(handles.handles.Load_text, 'String', sprintf('%s[%d files]', handles.Path_name, length(handles.CellData)));
    end
    
    
    guidata(handles.handles.MainFig, handles);
    
    if ~isempty(handles.CellData)
        FunPlot(handles.CurrentCellData);
        plotAllROIs(handles.CurrentCellData);
    end
    
end


function DeleteROI(varargin)

    handles = guidata(findobj('Tag', 'PALM GUI'));

    % Remove current ROI from list of everything
    handles.ROICoordinates{handles.CurrentCellData}(handles.CurrentROIData) = [];
    handles.handles.ROIOutlines(handles.CurrentROIData) = [];
    
    
    if (handles.CurrentROIData == 1) & (~isempty(handles.ROICoordinates{handles.CurrentCellData}))
        % Delete first entry
        handles.ROIPopupList{handles.CurrentCellData}(handles.CurrentROIData) = [];
        set(handles.handles.popupROI2, 'string', handles.ROIPopupList{handles.CurrentCellData});
        handles.CurrentROIData = 1;
        
    elseif isempty(handles.ROICoordinates{handles.CurrentCellData})
        % Delete remaining item from list
        handles.CurrentROIData = [];
        set(handles.handles.popupROI2, 'string', 'ROI');
        set(handles.handles.DeleteROI, 'enable', 'off');
    elseif (handles.CurrentROIData > length(handles.ROICoordinates{handles.CurrentCellData})) && (handles.CurrentROIData > 1) && (~isempty(handles.ROICoordinates{handles.CurrentCellData}))
        % Delete last entry
        
        handles.ROIPopupList{handles.CurrentCellData}(handles.CurrentROIData) = [];
        handles.CurrentROIData = length(handles.ROICoordinates{handles.CurrentCellData});
        set(handles.handles.popupROI2, 'Value', handles.CurrentROIData);
        set(handles.handles.popupROI2, 'string', handles.ROIPopupList{handles.CurrentCellData});
        
    else
        % Delete middle entry
        handles.ROIPopupList{handles.CurrentCellData}(handles.CurrentROIData) = [];
        set(handles.handles.popupROI2, 'string', handles.ROIPopupList{handles.CurrentCellData});
    end

    
    guidata(handles.handles.MainFig, handles);
    plotAllROIs(handles.CurrentCellData);
    
    handles = guidata(handles.handles.MainFig);
    handles.CellData = assignROIsToCellData(handles.CellData, handles.ROICoordinates, handles.NDataColumns);
    guidata(handles.handles.MainFig, handles);
end


function Load_Data(~,~,~)
    % Master load function
    % Load a selected set of 1.txt files from disk.
    % Add each to memory now
    

    handles = guidata(findobj('Tag', 'PALM GUI'));

    set(get(handles.handles.b_panel, 'children'), 'enable', 'off');

    if (handles.DEBUG)
        fileName = '1.txt';
        pathName = sprintf('%s/test_dataset/', pwd);
        filterIndex = 1;
    else
        [fileName, pathName, filterIndex] = uigetfile({'*.txt', 'ZEN export table'; '*.csv', 'ThunderSTORM Export table'},'Select ZEN export files', 'MultiSelect', 'on');
    end
    
    if ischar(fileName)
        fileName = {fileName};
    end

    if ismember(filterIndex, [1, 2])
        
        w = waitbar(0, 'Loading files...');
    
        % Check that each is an acceptable ZEN file
        % If OK, add to handles.CellData

        handles.CellData = cell(length(fileName), 1);
        handles.ImportFiles = cell(length(fileName), 1);
        handles.Path_name = pathName;
        
        skipList = false(length(fileName), 1);
        
        for k = 1:length(fileName)

            waitbar(k/(length(fileName) + 1), w);
            
            goodZENFile = checkZenFile(fullfile(pathName, fileName{k}));

            if goodZENFile

                importData = Import1File(fullfile(pathName, fileName{k}));
                handles.CellData{k} = [importData.Data zeros(size(importData.Data, 1), 8)];
%                 handles.CellData{k}(:,5:6) = handles.CellData{k}(:,5:6)*importData.Footer{2}(3)/importData.Footer{2}(1);
                handles.CellData{k}(any(isnan(handles.CellData{k}), 2), :) = []; % protection against incomplete line writing in ZEN export
                   
                handles.NDataColumns = size(importData.Data, 2);
                handles.CellData{k}(:,handles.NDataColumns + 2) = 1; % All data is in mask until set otherwise
                handles.ROIMultiplier = importData.Footer{2}(1); % Conversion from coordinates.txt positions to nm
                
                % Max size calc has some issues around certain imported ZEN
                % files
                handles.MaxSize = importData.Footer{2}(5)*10*importData.Footer{2}(1)/importData.Footer{2}(3); % FOV size, in nm
                
                if handles.MaxSize == 256;
                    handles.MaxSize = handles.MaxSize*100;
                end
                
                handles.ImportFiles{k} = fullfile(pathName, fileName{k});
                
                % Clear out any points outside of bounds [0 MaxSize];
                handles.CellData{k}(any(handles.CellData{k}(:, 5:6) > handles.MaxSize), : )= [];
                handles.CellData{k}(any(handles.CellData{k}(:, 5:6) < 0), : )= [];
                
                handles.Nchannels = numel(unique(handles.CellData{k}(:,12)));
          
            else
                
                fprintf(1, 'File not in accepted coordinate table format.\nSkipping %s\n', fullfile(pathName, fileName{k}));
                skipList(k) = 1;

            end
        end
               
        % Remove empty cells
        handles.CellData(skipList) = [];
        handles.ImportFiles(skipList) = [];
        
        if handles.CurrentCellData > length(handles.CellData)
            handles.CurrentCellData = 1;
        end
        
        popupList = cell(length(handles.ImportFiles), 1);
        for pL = 1:length(popupList)
            [~, popupList{pL}, ext] = fileparts(handles.ImportFiles{pL});
            popupList{pL} = strcat(popupList{pL}, ext);
        end
        set(handles.handles.popupCell2, 'String', popupList);
        set(handles.handles.popupCell2, 'Value', handles.CurrentCellData);
        
        waitbar(1, w);
        close(w);
        
        % Check for corresponding coordinates.txt file
        % If it's there, use it and append ROI IDs to all points in all
        % cells
        
        if exist(fullfile(pathName, 'coordinates.txt'), 'file')
        
            handles.CoordFile = fullfile(pathName, 'coordinates.txt');
            [handles.ROICoordinates, loadOK] = loadCoordinatesFile(fullfile(pathName, 'coordinates.txt'), handles.ROIMultiplier, handles);

            if loadOK
                handles.ROIPopupList = cell(length(handles.ImportFiles), 1);
                for c = 1:length(handles.CellData)
                    % Reset pull-down menu to new entries and set to desired value
                    handles.ROIPopupList{c} = strsplit(num2str(1:length(handles.ROICoordinates{c})), ' ');
                end
                set(handles.handles.popupROI2, 'String', handles.ROIPopupList{handles.CurrentCellData}); 
                
            end
            
            
            handles.CurrentROIData = 1;
            set(handles.handles.popupROI2, 'Value', handles.CurrentROIData);
            
            
            handles.CellData = assignROIsToCellData(handles.CellData, handles.ROICoordinates, handles.NDataColumns);
            set(handles.handles.CoordinatesText, 'String', fullfile(pathName, 'coordinates.txt'));
            
        else
            
%             handles.ROIPopupList = {'ROI'};
            for c = 1:length(handles.CellData)
                handles.ROICoordinates{c} = {};
                handles.ROIPopupList{c} = {'ROI'};
                handles.CoordFile = '';
            end
  
        end
           
        % Set output folder to match
        if length(fileName) == 1
            set(handles.handles.Load_text, 'String', fullfile(handles.Path_name, fileName{1}));
        else
            set(handles.handles.Load_text, 'String', sprintf('%s[%d files]', handles.Path_name, length(fileName)));
        end

        if exist(fullfile(handles.Path_name, 'Extracted_Region'), 'dir') == 7
            set(handles.handles.OutputText, 'String', fullfile(handles.Path_name, 'Extracted_Region'));
            handles.Outputfolder = fullfile(handles.Path_name, 'Extracted_Region');
            set(get(handles.handles.b_panel, 'children'), 'enable', 'on');
            set(handles.handles.alignMaskButton, 'enable', 'off');
            if handles.Nchannels == 1
                set(handles.handles.hDoC_All1, 'enable', 'off');
            end
        else
            set(handles.handles.OutputText, 'String', 'Set Output Folder Before Proceeding');
        end

        % Load mask files
        handles.MaskCellPair = zeros(size(handles.CellData, 1), 2);
        %TODO: Disabled for testing. Need to reenable and fix this bug!
        handles = loadMaskFiles(handles);
        handles.ClusterTable = [];
        
        guidata(handles.handles.MainFig, handles);
        FunPlot(1);
    
        UpdateStatusBar(handles, 'Data loaded successfully!');
    end
    
    %%%%%%%%%%%%%%%%%%%
    % Local functions
    
    % Checking function for selected files
    function isGood = checkZenFile(fName)
    
        fID = fopen(fName, 'r');
        firstLine = fgetl(fID);
        nTabs = length(strfind(firstLine, sprintf('\t')));
        firstEntry = firstLine(1:5);
        fclose(fID);

        if ismember(nTabs, [11, 12, 13, 14]) && strcmp(firstEntry, 'Index')
            isGood = true;
        elseif ismember(nTabs, 23) && strcmp(firstEntry, 'Chann')
            isGood = true;
            % Is good Nikon file, which will get interpreted into Zeiss
            % format in Import1File
        elseif ismember(nTabs, 0) 

                fID = fopen(fName, 'r');
                firstLine = fgetl(fID);
                nTabs = length(strfind(firstLine, sprintf(',')));
                firstEntry = firstLine(1:5);
                fclose(fID);
                
                if ismember(nTabs, [9, 10]) && strcmp(firstEntry, '"id",')
                    isGood = true;
                    % Is good ThunderSTORM file
                else
                    isGood = false;
                end
        else
            isGood = false;
        end
    
    end


end


% Load ROI coordinates from coordinates.txt file (if existing)
function [roiCoordinates, loadOK] = loadCoordinatesFile(fName, scaleFactor, handles)

    % Optional comment block at top, which may contain line specifying
    % the ROI size.
    % Comments have first character #
    % ROI size specified by # ROISize:\t%f in nanometers
    % If not specified, assume is default value
    % Assuming that all ROIs specified in coordinates.txt file are
    % squares

    fID = fopen(fName, 'r');
    lineNow = 0;
    isEnd = false;
    isData = false;
    while ~isEnd | ~isData
        lineString = fgetl(fID);
        if lineString(1) ~= '#'
            testLine = lineString;
%             disp('end of header');
            isData = true;
            break;
        elseif isempty(lineString)
            isEnd = true;
%             disp('end of file');
        else
            lineNow = lineNow + 1;
            % Check if ROI size specified
            if ~isempty(strfind(lower(lineString), 'roisize'))
                handles.ROISize = str2double(lineString(regexp(lineString, '\d+'):end));
            end
        end
    end

    % See if file is ZEN export format of identical rectangles, or is
    % polygons w/ xy coordinates
    % If only 4 columns, then ZEN rectangles
    % Any more than 4 columns and format has to be polygons in
    % x1\ty1\tx2\ty2\tx3\ty3... format

    nTabs = numel(strfind(testLine, sprintf('\t')));
    fseek(fID, 0, -1);
    for skipLines = 1:lineNow
        fgetl(fID);
        % Skip enough lines to get back to start of data
    end

    if nTabs == 3
        % is ZEN output file

        coordRead = textscan(fID, '%s\t%s\t%f\t%f');
        fclose(fID);

        roiCoordinates = cell(length(handles.CellData), 1);

        for m = 1:length(handles.CellData)

            [~, IDstring, ~] = fileparts(handles.ImportFiles{m});
            % coordinates here are in "reslution units", which is ~10
            % nm in most cases for ZEN output
            thisCellsROIs = [coordRead{3}(strcmp(IDstring, cellstr(coordRead{2})))/scaleFactor, ...
                handles.MaxSize - coordRead{4}(strcmp(IDstring, cellstr(coordRead{2})))/scaleFactor];

            for p = 1:size(thisCellsROIs, 1)
                roiCoordinates{m}{p} = zeros(5, 2);
                % Assign ROI coordinates in proper format for inpolygon()
                roiCoordinates{m}{p} = [thisCellsROIs(p,:) + [-handles.ROISize/2 -handles.ROISize/2];
                    thisCellsROIs(p,:) + [handles.ROISize/2 -handles.ROISize/2];
                    thisCellsROIs(p,:) + [handles.ROISize/2 handles.ROISize/2];
                    thisCellsROIs(p,:) + [-handles.ROISize/2 handles.ROISize/2];
                    thisCellsROIs(p,:) + [-handles.ROISize/2 -handles.ROISize/2]];
            end

        end

        loadOK = true;

    elseif nTabs > 3
        % Is polygonal format file
        % Each line may have a different number of coordinates, but
        % should always be paired
        % Everything is still in "resolution units", so be sure to
        % incorporate scaleFactor into the import

        roiCount = 1;
        fileEnd = false;
        cellList = cell(1,1);
        coordList = cell(1,1);
        while ~fileEnd
            thisLine = fgetl(fID);
            if ischar(thisLine)
                thisLine = strsplit(thisLine, sprintf('\t'));
                cellList{roiCount} = thisLine{2};
                coordList{roiCount} = reshape(str2double(thisLine(3:end)), 2, [])';
                roiCount = roiCount + 1;
            else
                fileEnd = true;
            end
        end

        fclose(fID);
        
        roiCoordinates = cell(length(handles.CellData), 1);

        for m = 1:length(handles.CellData)

            [~, IDstring, ~] = fileparts(handles.ImportFiles{m});

            
            thisCellsROIs = coordList(strcmp(IDstring, cellList));

%             disp(length(thisCellsROIs));
            
            for p = 1:length(thisCellsROIs)

                % Assign ROI coordinates in proper format for inpolygon()
                roiCoordinates{m}{p} = thisCellsROIs{p}([1:end 1], :)/scaleFactor;
                roiCoordinates{m}{p}(:,2) = handles.MaxSize - roiCoordinates{m}{p}(:,2);
            end

        end

        loadOK = true;

    else
        error('Import file format not supported');
    end

end


function cellData = assignROIsToCellData(cellData, roiArray, nDataColumns)    

    % Given a table of cell data and a cell array of arrays of ROI coordinates for
    % those cells, assign an ROI number for all points in the loaded data
    % sets

    for k = 1:length(cellData)
        % Iterate over array of cell data
        
        cellData{k}(:, nDataColumns + 1) = 0;
        
        for m = 1:length(roiArray{k})
            % Iterate over each ROI in that cell
            cellData{k}(inpolygon(cellData{k}(:,5), cellData{k}(:,6), roiArray{k}{m}(:,1), roiArray{k}{m}(:,2)), nDataColumns + 1) = ...
                cellData{k}(inpolygon(cellData{k}(:,5), cellData{k}(:,6), roiArray{k}{m}(:,1), roiArray{k}{m}(:,2)), nDataColumns + 1) + 2^(m-1);
        end
    end           
    
end


function handles = loadMaskFiles(handles)

    possibleFiles = dir(fullfile(handles.Path_name, '*.tif'));
    if( isempty(possibleFiles) || size(possibleFiles, 1) < 1)
        return;
    end
    
    handles.MaskFiles = cell(size(possibleFiles, 1), 1);
    handles.MaskImg = cell(size(possibleFiles, 1), 1);

    % Check that each possible file is at least square before loading
    % and binarizing
    % Mask is applied upon selection in pull-down menu
    for k = 1:size(possibleFiles, 1)
    
        %maskInfo = imfinfo(fullfile(handles.Path_name, possibleFiles(k,:)));
        filename = possibleFiles(k).name;
        maskInfo = imfinfo(fullfile(handles.Path_name, filename));
        
        if maskInfo.Height == maskInfo.Width
            
            % Is square, so load it
            maskImg = double(imread(fullfile(handles.Path_name, filename), 'Info', maskInfo));
            
            % binarize it
            maskImg = sum(maskImg, 3);
            handles.MaskImg{k} = flipud(maskImg == max(maskImg(:)));
            handles.MaskFiles{k, 1} = strtrim(filename);
            
        end
    
    end
    
    if ~isempty(possibleFiles)
        handles.MaskFiles(isempty(handles.MaskFiles)) = [];
        handles.MaskImg(isempty(handles.MaskImg)) = [];
    end
    
	handles.MaskCellPair = zeros(size(handles.CellData, 1), 2);
    handles.MaskCellPair(:,1) = 1:size(handles.CellData, 1);
    
    handles.MaskFiles = [{' -- '}; handles.MaskFiles];
    
    handles.SelectedMask = 0;
    set(handles.handles.popupMask, 'String', handles.MaskFiles);
    set(handles.handles.popupMask, 'value', handles.SelectedMask + 1);
    set(handles.handles.alignMaskButton, 'enable', 'on');
    

end


function popupMask_Callback(varargin)

    handles = guidata(findobj('Tag', 'PALM GUI'));
    
    handles.SelectedMask = get(handles.handles.popupMask, 'Value') - 1;
    oldValue = handles.MaskCellPair(handles.CurrentCellData, 2);
    
    handles.MaskCellPair(handles.CurrentCellData, 2) = handles.SelectedMask;
    
    guidata(handles.handles.MainFig, handles);        
    if handles.SelectedMask ~= oldValue
        displayMaskImg(handles);
        applyMaskImgToDataTable(handles);
    end

end


function alignMask(varargin)

    handles = guidata(findobj('tag', 'PALM GUI'));
    
    pointMask = double(hist2(handles.CellData{handles.CurrentCellData}(:,5)/handles.MaskPixelSize, handles.CellData{handles.CurrentCellData}(:,6)/handles.MaskPixelSize, ...
        0:1:round(handles.MaxSize/handles.MaskPixelSize - 1), 0:1:round(handles.MaxSize/handles.MaskPixelSize - 1)) > 0)';

    maskImg = double(handles.MaskImg{handles.MaskCellPair(handles.CurrentCellData, 2)});
    [optimizer, metric] = imregconfig('monomodal');
    tform = imregister(maskImg, pointMask, 'translation', optimizer, metric);
    handles.MaskImg{handles.MaskCellPair(handles.CurrentCellData, 2)} = tform > 0.5;

    guidata(handles.handles.MainFig, handles);
    displayMaskImg(handles);
    applyMaskImgToDataTable(handles);
end


function displayMaskImg(handles)

    % Given a selected mask image, scale and apply it to the current image
    % axes
    
    if handles.SelectedMask ~= 0

        if isfield(handles.handles, 'MaskHandle');
            if ishandle(handles.handles.MaskHandle)
             delete(handles.handles.MaskHandle);
            end
        end
        
            imgDom = linspace(0, handles.MaxSize, size(handles.MaskImg{handles.SelectedMask}, 1) + 1);
            handles.MaskPixelSize = diff(imgDom(1:2));
            imgDom = imgDom + handles.MaskPixelSize/2;
            imgDom(end) = [];

            set(handles.handles.ax_h, 'NextPlot', 'add');
            image(imgDom, imgDom, Vector2Colormap(handles.MaskImg{handles.SelectedMask}, 'gray'), ...
                'parent', handles.handles.ax_h, 'alphaData', 0.3);
            handles.handles.MaskHandle = findobj('type', 'image', 'parent', handles.handles.ax_h);

            handles.MaskPixelSize = diff(imgDom(1:2));

            guidata(handles.handles.MainFig, handles);
            set(handles.handles.ax_h, 'NextPlot', 'replace');
        
    else
        
        if isfield(handles.handles, 'MaskHandle');
            if ishandle(handles.handles.MaskHandle)
             delete(handles.handles.MaskHandle);
             handles.MaskCellPair(handles.CurrentCellData, 2) = 0;
             handles.CellData{handles.CurrentCellData}(:,handles.NDataColumns + 2) = 1; % All data is in mask until set otherwise
             guidata(handles.handles.MainFig, handles);
            end
        end
        
    end
    
end


function applyMaskImgToDataTable(varargin)

    handles = guidata(findobj('tag', 'PALM GUI'));
    
    if handles.MaskCellPair(handles.CurrentCellData, 2) ~= 0
        % Round data off to the nearest handles.MaskPixelSize
        roundData = round(handles.CellData{handles.CurrentCellData}(:,5:6)/handles.MaskPixelSize);

        handles.CellData{handles.CurrentCellData}(:, handles.NDataColumns + 2) = ...
            handles.MaskImg{handles.MaskCellPair(handles.CurrentCellData, 2)}(sub2ind(size(handles.MaskImg{handles.SelectedMask}), roundData(:,2), roundData(:,1)));
        
    end

    guidata(handles.handles.MainFig, handles);

end


function OutputEdit(varargin)

    handles = guidata(findobj('Tag', 'PALM GUI'));
    set(get(handles.handles.b_panel, 'children'), 'enable', 'off');

    handles.Outputfolder = uigetdir(handles.Path_name, 'Choose or Create an output folder');
    
    if handles.Outputfolder ~= 0
    
        set(handles.handles.OutputText, 'String', handles.Outputfolder);

        set(get(handles.handles.b_panel, 'children'), 'enable', 'on');
        set(handles.handles.alignMaskButton, 'enable', 'off');
        set(handles.handles.ExportResultsButton, 'enable', 'off');
        if handles.Nchannels == 1
            set(handles.handles.hDoC_All1, 'enable', 'off');
        end

        guidata(handles.handles.MainFig, handles);

    end
end


function popupCell_Callback2(hobj, ~)
    % Called to update popup for which cell is currently displayed.

    handles = guidata(findobj('Tag', 'PALM GUI'));

    % Display cell data
    handles.CurrentCellData = get(hobj, 'Value');
    guidata(handles.handles.MainFig, handles);
    
    FunPlot(get(hobj, 'Value'));
end


function CreateSquareROI(~, ~, ~)

    handles = guidata(findobj('Tag', 'PALM GUI'));

    rectHand = imrect('PositionConstraintFcn', @(x) [x(1) x(2) min(x(3),x(4))*[1 1]]);
    rectHand.addNewPositionCallback(@SquareROICallback);
    
    position = wait(rectHand);
    setFinalPosition(position);
    set(handles.handles.DeleteROI, 'enable', 'on');
%     disp('positionSet');
    
    function SquareROICallback(varargin)
%         disp('callback')
        
    end

    function setFinalPosition(varargin)
        newROInum = length(handles.ROICoordinates{handles.CurrentCellData}) + 1;
        post = rectHand.getPosition();
        
        handles.ROICoordinates{handles.CurrentCellData}{newROInum} = round([post(1), post(2);
                                                                            post(1) + post(3), post(2);
                                                                            post(1) + post(3), post(2) + post(4);
                                                                            post(1), post(2) + post(4);
                                                                            post(1), post(2)]);
        
        if newROInum == 1
            lastNumEntry = 0;
        else
            lastNumEntry = str2double(handles.ROIPopupList{handles.CurrentCellData}(end));
        end
        
        handles.ROIPopupList{handles.CurrentCellData}{newROInum} = num2str(lastNumEntry + 1);
        
        handles.CurrentROIData = newROInum;
        set(handles.handles.popupROI2, 'String', handles.ROIPopupList{handles.CurrentCellData});
        set(handles.handles.popupROI2, 'Value', handles.CurrentROIData);
        
        delete(rectHand);
        
        guidata(handles.handles.MainFig, handles);
        plotAllROIs(handles.CurrentCellData);
        
        handles = guidata(handles.handles.MainFig);
        handles.CellData = assignROIsToCellData(handles.CellData, handles.ROICoordinates, handles.NDataColumns);
        guidata(handles.handles.MainFig, handles);
        
    end
 
end


function CreatePolyROI(~, ~, ~)

    handles = guidata(findobj('Tag', 'PALM GUI'));

    polyHand = impoly(handles.handles.ax_h);
    api = iptgetapi(polyHand);
    fcn = makeConstrainToRectFcn('impoly',get(handles.handles.ax_h,'XLim'), ...
        get(handles.handles.ax_h,'YLim'));
    api.setPositionConstraintFcn(fcn);
    
    position = wait(polyHand);
    setFinalPosition(position);

    function setFinalPosition(varargin)
        newROInum = length(handles.ROICoordinates{handles.CurrentCellData}) + 1;
        post = polyHand.getPosition();
        
        handles.ROICoordinates{handles.CurrentCellData}{newROInum} = round(post([1:end 1], :));
        
        if newROInum == 1
            lastNumEntry = 0;
        else
            lastNumEntry = str2double(handles.ROIPopupList{handles.CurrentCellData}(end));
        end
        
%         lastNumEntry = str2double(handles.ROIPopupList{handles.CurrentCellData}(end));
        handles.ROIPopupList{handles.CurrentCellData}{newROInum} = num2str(lastNumEntry + 1);
        
        handles.CurrentROIData = newROInum;
        set(handles.handles.popupROI2, 'String', handles.ROIPopupList{handles.CurrentCellData});
        set(handles.handles.popupROI2, 'Value', handles.CurrentROIData);
        
        delete(polyHand);
        
        guidata(handles.handles.MainFig, handles);
        plotAllROIs(handles.CurrentCellData);
        
        set(handles.handles.DeleteROI, 'enable', 'on');
        
        handles = guidata(handles.handles.MainFig);
        handles.CellData = assignROIsToCellData(handles.CellData, handles.ROICoordinates, handles.NDataColumns);
        guidata(handles.handles.MainFig, handles);
    end

end


function popupROI_Callback2(~,~,~)

    % Set current ROI to active and mark

    handles = guidata(findobj('Tag', 'PALM GUI'));

    handles.CurrentROIData = get(handles.handles.popupROI2, 'Value');
    set(handles.handles.ROIOutlines, 'color', handles.UnselectedROIColor);
    set(handles.handles.ROIOutlines(handles.CurrentROIData), 'color', handles.ROIColor);
    
    guidata(handles.handles.MainFig, handles);

end


% Save the cell and ROI in matlab folder
function SaveCellROI(~,~,~)

    handles = guidata(findobj('Tag', 'PALM GUI'));

    % Export ROIs to text file
    % Do everything as a polygonal coordinates file, even if there are
    % square ROIs
    [fileName, pathName, filterIndex] = uiputfile('coordinates.txt', 'Save ROI file');
    if filterIndex > 0
        fID = fopen(fullfile(pathName, fileName), 'w+');
        fprintf(fID, '# Export ROI coordinates %s\r\n', date);
        fprintf(fID, '# ROI Multiplier %.2f\r\n', handles.ROIMultiplier);
        for k = 1:length(handles.CellData)
            [~, importString, ~] = fileparts(handles.ImportFiles{k});
            for m = 1:length(handles.ROICoordinates{k})
                fmtApnd = repmat('\t%.0f\t%.0f', 1, size(handles.ROICoordinates{k}{m}, 1)-1);
                
                coordToWrite = handles.ROICoordinates{k}{m}(1:(end-1), :)*handles.ROIMultiplier;
                coordToWrite(:,2) = (handles.MaxSize*handles.ROIMultiplier) - coordToWrite(:,2);
                
                fprintf(fID, strcat('roi%d\t%s', fmtApnd, '\r\n'), m, importString, (reshape(coordToWrite', 1, [])));
                
            end
        end
        fclose(fID);
    end
    

    guidata(handles.handles.MainFig, handles);

end


function popupProcessType_Callback(varargin)
    handles = guidata(findobj('Tag', 'PALM GUI'));
    handles.ProcessType = get(handles.handles.popupProcessType, 'Value');
    guidata(handles.handles.MainFig, handles);
end


% Pop-up window to set RipleyK parameters
function returnValue = setRipleyKParameters(handles)

    handles.handles.RipleyKSettingsFig = figure();
    set(handles.handles.RipleyKSettingsFig, 'Tag', 'ClusDoC');
    resizeFig(handles.handles.RipleyKSettingsFig, [220 180]);
    set(handles.handles.RipleyKSettingsFig, 'toolbar', 'none', 'menubar', 'none', ...
        'name', 'Ripley K Parameters');
  
% 	handles.handles.RipleyKSettingsTitleText(2) = uicontrol('Style', 'text', ...
%         'String', '_____________________', 'parent', handles.handles.RipleyKSettingsFig,...
%         'Position', [0 153 220 20], 'horizontalalignment', 'center', 'Fontsize', 10);

	handles.handles.RipleyKSettingsTitleText(1) = uicontrol('Style', 'text', ...
        'String', 'Ripley K Parameters', 'parent', handles.handles.RipleyKSettingsFig,...
        'Position', [0 158 220 20], 'horizontalalignment', 'center', 'Fontsize', 10);
    
    handles.handles.RipleyKSettingsText(1) = uicontrol('Style', 'text', ...
        'String', 'Start (nm):', 'parent', handles.handles.RipleyKSettingsFig,...
        'Position', [20 127 65 20]);
    
    handles.handles.RipleyKSettingsText(2) = uicontrol('Style', 'text', ...
        'String', 'End (nm):', 'parent', handles.handles.RipleyKSettingsFig,...
        'Position', [20 97 65 20]);
    
    handles.handles.RipleyKSettingsText(3) = uicontrol('Style', 'text', ...
        'String', 'Step (nm):', 'parent', handles.handles.RipleyKSettingsFig,...
        'Position', [20 67 65 20]);
    
    handles.handles.RipleyKSettingsText(4) = uicontrol('Style', 'text', ...
        'String', 'Max Points:', 'parent', handles.handles.RipleyKSettingsFig,...
        'Position', [20 37 65 20]);
    
    handles.handles.RipleyKSettingsEdit(1) = uicontrol('Style', 'edit', ...
        'String', num2str(handles.RipleyK.Start), 'parent', handles.handles.RipleyKSettingsFig,...
        'Position', [110 127 80 20]);
    
    handles.handles.RipleyKSettingsEdit(2) = uicontrol('Style', 'edit', ...
        'String', num2str(handles.RipleyK.End), 'parent', handles.handles.RipleyKSettingsFig,...
        'Position', [110 97 80 20]);
    
    handles.handles.RipleyKSettingsEdit(3) = uicontrol('Style', 'edit', ...
        'String', num2str(handles.RipleyK.Step), 'parent', handles.handles.RipleyKSettingsFig,...
        'Position', [110 67 80 20]);
    
    handles.handles.RipleyKSettingsEdit(4) = uicontrol('Style', 'edit', ...
        'String', num2str(handles.RipleyK.MaxSampledPts), 'parent', handles.handles.RipleyKSettingsFig,...
        'Position', [110 37 80 20]);
    
    set(handles.handles.RipleyKSettingsEdit, 'Callback', @RipleyKCheckEditBox);
    
    handles.handles.RipleyKSettingsButton = uicontrol('Style', 'pushbutton', ...
        'String', 'Continue', 'parent', handles.handles.RipleyKSettingsFig, ...
        'Position', [133 2 85 30], 'Callback', @RipleyKSetAndContinue);

    set(handles.handles.RipleyKSettingsFig, 'CloseRequestFcn', @RipleyKCloseOutWindow);
    
    uiwait;
    
    function RipleyKCloseOutWindow(varargin)
        % Cancel, don't execute further
        returnValue = 0;
        uiresume;
        delete(handles.handles.RipleyKSettingsFig);
    end

    function RipleyKCheckEditBox(hObj, varargin)
        
        input = str2double(get(hObj,'string'));
        if isnan(input) 
            
            errordlg('You must enter a numeric value','Invalid Input','modal');
%             return;
        elseif input < 0
            
            errordlg('Value must be positive','Invalid Input','modal');
%             return;
        else
            % continue
        end

    end

    function RipleyKSetAndContinue(varargin)
        
        % Collect inputs and set parameters in guidata
     	handles.RipleyK.Start = str2double(get(handles.handles.RipleyKSettingsEdit(1),'string'));
        handles.RipleyK.End = str2double(get(handles.handles.RipleyKSettingsEdit(2),'string'));
        handles.RipleyK.Step = str2double(get(handles.handles.RipleyKSettingsEdit(3),'string'));
        handles.RipleyK.MaxSampledPts = str2double(get(handles.handles.RipleyKSettingsEdit(4),'string'));
                
        returnValue = 1;
        guidata(handles.handles.MainFig, handles);
        uiresume;
        delete(handles.handles.RipleyKSettingsFig);
        
    end
    
end


% Pop-up window to set DBSCAN parameters
function returnValue = setDBSCANParameters(handles, withstats)

    isCombined = handles.ProcessType == handles.CONST.PROCESS_COMBINED;

    handles.handles.DBSCANSettingsFig = figure();
    set(handles.handles.DBSCANSettingsFig, 'Tag', 'ClusDoC');
    resizeFig(handles.handles.DBSCANSettingsFig, [250 240]);
    set(handles.handles.DBSCANSettingsFig, 'toolbar', 'none', 'menubar', 'none', ...
        'name', 'DBSCAN Parameters');
        
% 	handles.handles.DBSCANSettingsTitleText(2) = uicontrol('Style', 'text', ...
%         'String', '_____________________', 'parent', handles.handles.DBSCANSettingsFig,...
%         'Position', [0 215 250 20], 'horizontalalignment', 'center', 'Fontsize', 10);

    str = 'DBSCAN Parameters for channels';
    if(isCombined)
        str = 'DBSCAN Parameters for combined data';
    end
	handles.handles.DBSCANSettingsTitleText(1) = uicontrol('Style', 'text', ...
        'String', str, 'parent', handles.handles.DBSCANSettingsFig,...
        'Position', [0 220 250 20], 'horizontalalignment', 'center', 'Fontsize', 10);
    
    %%%%%%
    if verLessThan('matlab', '8.4')
        handles.handles.DBSCANChannelToggle = uibuttongroup('Visible', 'on', 'Position',[.2 195/250 .6 .11],...
            'SelectionChangeFcn', @changeDBSCANChannel);
    else
        handles.handles.DBSCANChannelToggle = uibuttongroup('Visible', 'on', 'Position',[.2 195/250 .6 .11],...
            'SelectionChangedFcn', @changeDBSCANChannel);
    end
    
    handles.handles.DBSCANChannelSelect(1) = uicontrol(handles.handles.DBSCANChannelToggle, ...
        'Style', 'radiobutton', 'String', 'Ch 1', 'position', [15 4 50 20]);
    
    handles.handles.DBSCANChannelSelect(2) = uicontrol(handles.handles.DBSCANChannelToggle, ...
        'Style', 'radiobutton', 'String', 'Ch 2', 'position', [90 4 50 20]);
    
    if verLessThan('matlab', '8.4')     
        if handles.Nchannels > 1
            set(handles.handles.DBSCANChannelToggle, 'Visible', 'on');     
        else  
            set(handles.handles.DBSCANChannelToggle, 'Visible', 'on');
            set(handles.handles.DBSCANChannelSelect(2), 'Enable', 'off');
        end
    else
        if handles.Nchannels > 1
            handles.handles.DBSCANChannelToggle.Visible = 'on';
        else
            handles.handles.DBSCANChannelToggle.Visible = 'on';
            handles.handles.DBSCANChannelSelect(2).Enable = 'off';
        end  
    end
    
    ch = 1;
    if(isCombined)
        ch = 3;
        if verLessThan('matlab', '8.4')
            set(handles.handles.DBSCANChannelToggle, 'Visible', 'off'); 
        else
            handles.handles.DBSCANChannelToggle.Visible = 'off';
        end 
    end
    
    
    %%%%%%
    handles.handles.DBSCANSettingsText(1) = uicontrol('Style', 'text', ...
        'String', 'Epsilon (nm):', 'parent', handles.handles.DBSCANSettingsFig,...
        'Position', [0 162 110 20], 'horizontalalignment', 'right');
    
    handles.handles.DBSCANSettingsText(2) = uicontrol('Style', 'text', ...
        'String', 'minPts:', 'parent', handles.handles.DBSCANSettingsFig,...
        'Position', [0 137 110 20], 'horizontalalignment', 'right');
    
    handles.handles.DBSCANSettingsText(3) = uicontrol('Style', 'text', ...
        'String', 'Plot Cutoff:', 'parent', handles.handles.DBSCANSettingsFig,...
        'Position', [0 112 110 20], 'horizontalalignment', 'right');
    
    handles.handles.DBSCANSettingsText(4) = uicontrol('Style', 'text', ...
        'String', 'Processing Threads:', 'parent', handles.handles.DBSCANSettingsFig,...
        'Position', [0 87 110 20], 'horizontalalignment', 'right');
    
    handles.handles.DBSCANSettingsText(5) = uicontrol('Style', 'text', ...
        'String', 'L(r) - r Radius (nm):', 'parent', handles.handles.DBSCANSettingsFig,...
        'Position', [0 62 110 20], 'horizontalalignment', 'right');
    
    handles.handles.DBSCANSettingsText(6) = uicontrol('Style', 'text', ...
        'String', 'Use', 'parent', handles.handles.DBSCANSettingsFig,...
        'Position', [190 62 30 20], 'horizontalalignment', 'right');
    
    handles.handles.DBSCANSettingsText(7) = uicontrol('Style', 'text', ...
        'String', 'Smooth Radius (nm):', 'parent', handles.handles.DBSCANSettingsFig,...
        'Position', [0 37 110 20], 'horizontalalignment', 'right');
    
	handles.handles.DBSCANSettingsText(8) = uicontrol('Style', 'text', ...
        'String', 'Calc Stats:', 'parent', handles.handles.DBSCANSettingsFig,...
        'Position', [0 11 110 20], 'horizontalalignment', 'right');
    
	%%%%%%%%%%
    
    handles.handles.DBSCANSettingsEdit(1) = uicontrol('Style', 'edit', ...
        'String', num2str(handles.DBSCAN(ch).epsilon), 'parent', handles.handles.DBSCANSettingsFig,...
        'Position', [115 166 60 20]);
    
    handles.handles.DBSCANSettingsEdit(2) = uicontrol('Style', 'edit', ...
        'String', num2str(handles.DBSCAN(ch).minPts), 'parent', handles.handles.DBSCANSettingsFig,...
        'Position', [115 141 60 20]);
    
    handles.handles.DBSCANSettingsEdit(3) = uicontrol('Style', 'edit', ...
        'String', num2str(handles.DBSCAN(ch).Cutoff), 'parent', handles.handles.DBSCANSettingsFig,...
        'Position', [115 116 60 20]);
    
    handles.handles.DBSCANSettingsEdit(4) = uicontrol('Style', 'edit', ...
        'String', num2str(handles.DBSCAN(ch).threads), 'parent', handles.handles.DBSCANSettingsFig,...
        'Position', [115 92 60 20]);
    
    handles.handles.DBSCANSettingsEdit(5) = uicontrol('Style', 'edit', ...
        'String', num2str(handles.DBSCAN(ch).Lr_rThreshRad), 'parent', handles.handles.DBSCANSettingsFig,...
        'Position', [115 66 60 20]);
    
    handles.handles.DBSCANSettingsEdit(6) = uicontrol('Style', 'edit', ...
        'String', num2str(handles.DBSCAN(ch).SmoothingRad), 'parent', handles.handles.DBSCANSettingsFig,...
        'Position', [115 41 60 20]);
    
    set(handles.handles.DBSCANSettingsEdit, 'Callback', @DBSCANCheckEditBox);
    
    %%%%%%
    
    handles.handles.DBSCANSetToggle = uicontrol('Style', 'checkbox', ...
        'Value', handles.DBSCAN(ch).UseLr_rThresh, 'position', [225 65 20 20], ...
        'callback', @DBSCANUseThreshold);
    
	handles.handles.DBSCANDoStatsToggle = uicontrol('Style', 'checkbox', ...
        'Value', handles.DBSCAN(ch).DoStats, 'position', [115 15 20 20]);
    
    if(withstats) % avoid changing the settings by users
        set(handles.handles.DBSCANSetToggle, 'Enable', 'off');
        set(handles.handles.DBSCANDoStatsToggle, 'Enable', 'off');
    end
    
    
    handles.handles.DBSCANSettingsButton = uicontrol('Style', 'pushbutton', ...
        'String', 'Continue', 'parent', handles.handles.DBSCANSettingsFig, ...
        'Position', [165 2 85 30], 'Callback', @DBSCANSetAndContinue);

    set(handles.handles.DBSCANSettingsFig, 'CloseRequestFcn', @DBSCANCloseOutWindow);
    
    DBSCANUseThreshold();
    
    uiwait;
    
    function DBSCANCloseOutWindow(varargin)
        % Cancel, don't execute further
        returnValue = 0;
        uiresume;
        delete(handles.handles.DBSCANSettingsFig);
    end

    function DBSCANCheckEditBox(hObj, varargin)
        
        input = str2double(get(hObj,'string'));
        if isnan(input) 
            errordlg('You must enter a numeric value','Invalid Input','modal');
%             return;
        elseif input < 0
            
            errordlg('Value must be positive','Invalid Input','modal');
%             return;
        else
            % continue
        end
    end

    function changeDBSCANChannel(varargin)
        
        changeToValue = (varargin{2}.NewValue);

        if strcmp(changeToValue.String, 'Ch 1');
            ch = 1;
            oldCh = 2;
        elseif strcmp(changeToValue.String, 'Ch 2');
            ch = 2;
            oldCh = 1;
        end
        
     	handles.DBSCAN(oldCh).epsilon = str2double(get(handles.handles.DBSCANSettingsEdit(1),'string'));
        handles.DBSCAN(oldCh).minPts = str2double(get(handles.handles.DBSCANSettingsEdit(2),'string'));
        handles.DBSCAN(oldCh).Cutoff = str2double(get(handles.handles.DBSCANSettingsEdit(3),'string'));
        handles.DBSCAN(oldCh).threads = str2double(get(handles.handles.DBSCANSettingsEdit(4),'string'));
        handles.DBSCAN(oldCh).Lr_rThreshRad = str2double(get(handles.handles.DBSCANSettingsEdit(5),'string'));
        handles.DBSCAN(oldCh).SmoothingRad = str2double(get(handles.handles.DBSCANSettingsEdit(6),'string'));
        handles.DBSCAN(oldCh).UseLr_rThresh = (get(handles.handles.DBSCANSetToggle, 'value')) == get(handles.handles.DBSCANSetToggle, 'Max');
        handles.DBSCAN(oldCh).DoStats = (get(handles.handles.DBSCANDoStatsToggle, 'value')) == get(handles.handles.DBSCANDoStatsToggle, 'Max');
        
%         disp(handles.DBSCAN(oldCh));
        
        set(handles.handles.DBSCANSettingsEdit(1), 'String', num2str(handles.DBSCAN(ch).epsilon));
        set(handles.handles.DBSCANSettingsEdit(2), 'String', num2str(handles.DBSCAN(ch).minPts));
        set(handles.handles.DBSCANSettingsEdit(3), 'String', num2str(handles.DBSCAN(ch).Cutoff));
        set(handles.handles.DBSCANSettingsEdit(4), 'String', num2str(handles.DBSCAN(ch).threads));
        set(handles.handles.DBSCANSettingsEdit(5), 'String', num2str(handles.DBSCAN(ch).Lr_rThreshRad));
        set(handles.handles.DBSCANSettingsEdit(6), 'String', num2str(handles.DBSCAN(ch).SmoothingRad));       
        set(handles.handles.DBSCANSetToggle, 'Value', handles.DBSCAN(ch).UseLr_rThresh);
        set(handles.handles.DBSCANDoStatsToggle, 'Value', handles.DBSCAN(ch).DoStats);
        
    end

    function DBSCANUseThreshold(varargin)
        
        if get(handles.handles.DBSCANSetToggle, 'value') == 1
            set(handles.handles.DBSCANSettingsEdit(5), 'enable', 'on');
        elseif get(handles.handles.DBSCANSetToggle, 'value') == 0
            set(handles.handles.DBSCANSettingsEdit(5), 'enable', 'off');
        end
        
    end

    function DBSCANSetAndContinue(varargin)
        
        % Collect inputs and set parameters in guidata
     	handles.DBSCAN(ch).epsilon = str2double(get(handles.handles.DBSCANSettingsEdit(1),'string'));
        handles.DBSCAN(ch).minPts = str2double(get(handles.handles.DBSCANSettingsEdit(2),'string'));
        handles.DBSCAN(ch).Cutoff = str2double(get(handles.handles.DBSCANSettingsEdit(3),'string'));
        handles.DBSCAN(ch).threads = str2double(get(handles.handles.DBSCANSettingsEdit(4),'string'));
        handles.DBSCAN(ch).Lr_rThreshRad = str2double(get(handles.handles.DBSCANSettingsEdit(5),'string'));
        handles.DBSCAN(ch).SmoothingRad = str2double(get(handles.handles.DBSCANSettingsEdit(6),'string'));
        handles.DBSCAN(ch).UseLr_rThresh = (get(handles.handles.DBSCANSetToggle, 'value')) == get(handles.handles.DBSCANSetToggle, 'Max');
        handles.DBSCAN(ch).DoStats = (get(handles.handles.DBSCANDoStatsToggle, 'value')) == get(handles.handles.DBSCANDoStatsToggle, 'Max');
                
        returnValue = 1;
        guidata(handles.handles.MainFig, handles);
        uiresume;
        delete(handles.handles.DBSCANSettingsFig);
    end    
end


% Pop-up window to set DoC parameters
function returnValue = setDoCParameters(handles)

    isCombined = handles.ProcessType == handles.CONST.PROCESS_COMBINED;

    handles.handles.DoCSettingsFig = figure();
    set(handles.handles.DoCSettingsFig, 'Tag', 'ClusDoC');
    resizeFig(handles.handles.DoCSettingsFig, [510 306]);
    set(handles.handles.DoCSettingsFig, 'toolbar', 'figure', 'menubar', 'none', ...
        'name', 'DoC Parameters');
    
    ch = 1;
    if(isCombined)
        ch = 3;
    end
    
    SUP = 40; %shift control up compared to v1.0.0
    SUP2 = 30;
   
    handles.handles.DoCSettingsTitleText(2) = uicontrol('Style', 'text', ...
        'String', '_____________________', 'parent', handles.handles.DoCSettingsFig,...
        'Position', [0 197+SUP 200 20], 'horizontalalignment', 'center', 'Fontsize', 10);

	handles.handles.DoCSettingsTitleText(1) = uicontrol('Style', 'text', ...
        'String', 'Degree of Colocalization Parameters', 'parent', handles.handles.DoCSettingsFig,...
        'Position', [0 207+SUP 200 35], 'horizontalalignment', 'center', 'Fontsize', 10);
    
    %%%%%%
    
    handles.handles.DoCSettingsText(1) = uicontrol('Style', 'text', ...
        'String', 'L(r) - r radius (nm):', 'parent', handles.handles.DoCSettingsFig,...
        'Position', [0 160+SUP2 100 20], 'horizontalalignment', 'right');
    
    handles.handles.DoCSettingsText(2) = uicontrol('Style', 'text', ...
        'String', 'Rmax (nm):', 'parent', handles.handles.DoCSettingsFig,...
        'Position', [0 130+SUP2 100 20], 'horizontalalignment', 'right');
    
    handles.handles.DoCSettingsText(3) = uicontrol('Style', 'text', ...
        'String', 'Step (nm):', 'parent', handles.handles.DoCSettingsFig,...
        'Position', [0 100+SUP2 100 20], 'horizontalalignment', 'right');
    
    handles.handles.DoCSettingsText(4) = uicontrol('Style', 'text', ...
        'String', 'Colocalization Threshold:', 'parent', handles.handles.DoCSettingsFig,...
        'Position', [0 60+SUP2 100 30], 'horizontalalignment', 'right');
    
	handles.handles.DoCSettingsText(5) = uicontrol('Style', 'text', ...
        'String', 'Min Coloc''d Points/Cluster:', 'parent', handles.handles.DoCSettingsFig,...
        'Position', [0 20+SUP2 100 30], 'horizontalalignment', 'right');
    
	%%%%%%%%%%
    
    handles.handles.DoCSettingsEdit(1) = uicontrol('Style', 'edit', ...
        'String', num2str(handles.DoC.Lr_rRad), 'parent', handles.handles.DoCSettingsFig,...
        'Position', [120 162+SUP2 60 20]);
    
    handles.handles.DoCSettingsEdit(2) = uicontrol('Style', 'edit', ...
        'String', num2str(handles.DoC.Rmax), 'parent', handles.handles.DoCSettingsFig,...
        'Position', [120 132+SUP2 60 20]);
    
    handles.handles.DoCSettingsEdit(3) = uicontrol('Style', 'edit', ...
        'String', num2str(handles.DoC.Step), 'parent', handles.handles.DoCSettingsFig,...
        'Position', [120 102+SUP2 60 20]);
    
    handles.handles.DoCSettingsEdit(4) = uicontrol('Style', 'edit', ...
        'String', num2str(handles.DoC.ColoThres), 'parent', handles.handles.DoCSettingsFig,...
        'Position', [120 67+SUP2 60 20]);
    
	handles.handles.DoCSettingsEdit(5) = uicontrol('Style', 'edit', ...
        'String', num2str(handles.DoC.NbThresh), 'parent', handles.handles.DoCSettingsFig,...
        'Position', [120 32+SUP2 60 20]);
    
    
    %%%%%%%%%%%%%%%
    % DoC - DBSCAN settings
    
    str = 'DBSCAN Parameters';
    if(isCombined)
        str = 'DBSCAN Parameters for combined data';
    end
	handles.handles.DBSCANSettingsTitleText(1) = uicontrol('Style', 'text', ...
        'String', str, 'parent', handles.handles.DoCSettingsFig,...
        'Position', [260 220+SUP 250 20], 'horizontalalignment', 'center', 'Fontsize', 10);
    
    %%%%%%%%
    if verLessThan('matlab', '8.4');
        handles.handles.DBSCANChannelToggle = uibuttongroup('Visible', 'on', 'Position',[.55 220/306 .4 .11],...
            'SelectionChangeFcn', @changeDBSCANChannel);
    else
        handles.handles.DBSCANChannelToggle = uibuttongroup('Visible', 'on', 'Position',[.55 220/306 .4 .11],...
            'SelectionChangedFcn', @changeDBSCANChannel);
    end
                  
    handles.handles.DBSCANChannelSelect(1) = uicontrol(handles.handles.DBSCANChannelToggle, ...
        'Style', 'radiobutton', 'String', 'Ch 1', 'position', [39 7 50 20]);
    
    handles.handles.DBSCANChannelSelect(2) = uicontrol(handles.handles.DBSCANChannelToggle, ...
        'Style', 'radiobutton', 'String', 'Ch 2', 'position', [130 7 50 20]);
    
    if verLessThan('matlab', '8.4')
        
        if handles.Nchannels > 1
            set(handles.handles.DBSCANChannelToggle, 'Visible', 'on');
        else
            set(handles.handles.DBSCANChannelToggle, 'Visible', 'on');
            set(handles.handles.DBSCANChannelSelect(2), 'Enable', 'off');
        end
        
    else
        if handles.Nchannels > 1
            handles.handles.DBSCANChannelToggle.Visible = 'on';
        else
            handles.handles.DBSCANChannelToggle.Visible = 'on';
            handles.handles.DBSCANChannelSelect(2).Enable = 'off';
        end
    end
    
    if(isCombined)
        if verLessThan('matlab', '8.4')
            set(handles.handles.DBSCANChannelToggle, 'Visible', 'off'); 
        else
            handles.handles.DBSCANChannelToggle.Visible = 'off';
        end 
        handles.handles.DBSCANSettingsTitleText(2) = uicontrol('Style', 'text', ...
            'String', '_____________________', 'parent', handles.handles.DoCSettingsFig,...
            'Position', [260 197+SUP 250 20], 'horizontalalignment', 'center', 'Fontsize', 10);
    end
        
    %%%%%%%%
    
    
    %%%%%%
    
    handles.handles.DBSCANSettingsText(1) = uicontrol('Style', 'text', ...
        'String', 'Epsilon (nm):', 'parent', handles.handles.DoCSettingsFig,...
        'Position', [260 157+SUP2 110 20], 'horizontalalignment', 'right');
    
    handles.handles.DBSCANSettingsText(2) = uicontrol('Style', 'text', ...
        'String', 'minPts:', 'parent', handles.handles.DoCSettingsFig,...
        'Position', [260 132+SUP2 110 20], 'horizontalalignment', 'right');
    
    handles.handles.DBSCANSettingsText(3) = uicontrol('Style', 'text', ...
        'String', 'Plot Cutoff:', 'parent', handles.handles.DoCSettingsFig,...
        'Position', [260 107+SUP2 110 20], 'horizontalalignment', 'right');
    
    handles.handles.DBSCANSettingsText(4) = uicontrol('Style', 'text', ...
        'String', 'Processing Threads:', 'parent', handles.handles.DoCSettingsFig,...
        'Position', [260 82+SUP2 110 20], 'horizontalalignment', 'right');
    
    handles.handles.DBSCANSettingsText(5) = uicontrol('Style', 'text', ...
        'String', 'L(r) - r Radius (nm):', 'parent', handles.handles.DoCSettingsFig,...
        'Position', [260 57+SUP2 110 20], 'horizontalalignment', 'right');
    
    handles.handles.DBSCANSettingsText(6) = uicontrol('Style', 'text', ...
        'String', 'Use', 'parent', handles.handles.DoCSettingsFig,...
        'Position', [450 57+SUP2 30 20], 'horizontalalignment', 'right');
    
    handles.handles.DBSCANSettingsText(7) = uicontrol('Style', 'text', ...
        'String', 'Smooth Radius (nm):', 'parent', handles.handles.DoCSettingsFig,...
        'Position', [260 32+SUP2 110 20], 'horizontalalignment', 'right');
    
	handles.handles.DBSCANSettingsText(8) = uicontrol('Style', 'text', ...
        'String', 'Calc Stats:', 'parent', handles.handles.DoCSettingsFig,...
        'Position', [260 6+SUP2 110 20], 'horizontalalignment', 'right');
    
	%%%%%%%%%%
    
    handles.handles.DBSCANSettingsEdit(1) = uicontrol('Style', 'edit', ...
        'String', num2str(handles.DBSCAN(ch).epsilon), 'parent', handles.handles.DoCSettingsFig,...
        'Position', [375 161+SUP2 60 20]);
    
    handles.handles.DBSCANSettingsEdit(2) = uicontrol('Style', 'edit', ...
        'String', num2str(handles.DBSCAN(ch).minPts), 'parent', handles.handles.DoCSettingsFig,...
        'Position', [375 136+SUP2 60 20]);
    
    handles.handles.DBSCANSettingsEdit(3) = uicontrol('Style', 'edit', ...
        'String', num2str(handles.DBSCAN(ch).Cutoff), 'parent', handles.handles.DoCSettingsFig,...
        'Position', [375 111+SUP2 60 20]);
    
    handles.handles.DBSCANSettingsEdit(4) = uicontrol('Style', 'edit', ...
        'String', num2str(handles.DBSCAN(ch).threads), 'parent', handles.handles.DoCSettingsFig,...
        'Position', [375 86+SUP2 60 20]);
    
    handles.handles.DBSCANSettingsEdit(5) = uicontrol('Style', 'edit', ...
        'String', num2str(handles.DBSCAN(ch).Lr_rThreshRad), 'parent', handles.handles.DoCSettingsFig,...
        'Position', [375 61+SUP2 60 20]);
    
    handles.handles.DBSCANSettingsEdit(6) = uicontrol('Style', 'edit', ...
        'String', num2str(handles.DBSCAN(ch).SmoothingRad), 'parent', handles.handles.DoCSettingsFig,...
        'Position', [375 36+SUP2 60 20]);
    
    set(handles.handles.DBSCANSettingsEdit, 'Callback', @DoCCheckEditBox);
    
    %%%%%%
    
    handles.handles.DBSCANSetToggle = uicontrol('Style', 'checkbox', ...
        'Value', handles.DBSCAN(ch).UseLr_rThresh, 'position', [485 60+SUP2 20 20], ...
        'callback', @DBSCANUseThreshold);
    
	handles.handles.DBSCANDoStatsToggle = uicontrol('Style', 'checkbox', ...
        'Value', handles.DBSCAN(ch).DoStats, 'position', [375 10+SUP2 20 20]);

    set(handles.handles.DBSCANSetToggle, 'Enable', 'off');
    set(handles.handles.DBSCANDoStatsToggle, 'Enable', 'off');

    %%%%%%
    
    
    handles.handles.DoCSettingsButton = uicontrol('Style', 'pushbutton', ...
        'String', 'Continue', 'parent', handles.handles.DoCSettingsFig, ...
        'Position', [425 4 85 30], 'Callback', @DoCSetAndContinue);

    set(handles.handles.DoCSettingsFig, 'CloseRequestFcn', @DoCCloseOutWindow);
    
    DoCUseThreshold();
    
    uiwait;
    
    function DoCCloseOutWindow(varargin)
        % Cancel, don't execute further
        returnValue = 0;
        uiresume;
        delete(handles.handles.DoCSettingsFig);
    end

    function DoCCheckEditBox(hObj, varargin)
        
        input = str2double(get(hObj,'string'));
        if isnan(input) 
            
            errordlg('You must enter a numeric value','Invalid Input','modal');
%             return;
        elseif input < 0
            
            errordlg('Value must be positive','Invalid Input','modal');
%             return;
        else
            % continue
        end

    end

    function changeDBSCANChannel(varargin)
        
        changeToValue = (varargin{2}.NewValue);
        
        if strcmp(changeToValue.String, 'Ch 1');
            ch = 1;
            oldCh = 2;
        elseif strcmp(changeToValue.String, 'Ch 2');
            ch = 2;
            oldCh = 1;
        end
        
     	handles.DBSCAN(oldCh).epsilon = str2double(get(handles.handles.DBSCANSettingsEdit(1),'string'));
        handles.DBSCAN(oldCh).minPts = str2double(get(handles.handles.DBSCANSettingsEdit(2),'string'));
        handles.DBSCAN(oldCh).Cutoff = str2double(get(handles.handles.DBSCANSettingsEdit(3),'string'));
        handles.DBSCAN(oldCh).threads = str2double(get(handles.handles.DBSCANSettingsEdit(4),'string'));
        handles.DBSCAN(oldCh).Lr_rThreshRad = str2double(get(handles.handles.DBSCANSettingsEdit(5),'string'));
        handles.DBSCAN(oldCh).SmoothingRad = str2double(get(handles.handles.DBSCANSettingsEdit(6),'string'));
        handles.DBSCAN(oldCh).UseLr_rThresh = (get(handles.handles.DBSCANSetToggle, 'value')) == get(handles.handles.DBSCANSetToggle, 'Max');
        handles.DBSCAN(oldCh).DoStats = (get(handles.handles.DBSCANDoStatsToggle, 'value')) == get(handles.handles.DBSCANDoStatsToggle, 'Max');
        
%         disp(handles.DBSCAN(oldCh));
        
        set(handles.handles.DBSCANSettingsEdit(1), 'String', num2str(handles.DBSCAN(ch).epsilon));
        set(handles.handles.DBSCANSettingsEdit(2), 'String', num2str(handles.DBSCAN(ch).minPts));
        set(handles.handles.DBSCANSettingsEdit(3), 'String', num2str(handles.DBSCAN(ch).Cutoff));
        set(handles.handles.DBSCANSettingsEdit(4), 'String', num2str(handles.DBSCAN(ch).threads));
        set(handles.handles.DBSCANSettingsEdit(5), 'String', num2str(handles.DBSCAN(ch).Lr_rThreshRad));
        set(handles.handles.DBSCANSettingsEdit(6), 'String', num2str(handles.DBSCAN(ch).SmoothingRad));       
        set(handles.handles.DBSCANSetToggle, 'Value', handles.DBSCAN(ch).UseLr_rThresh);
        set(handles.handles.DBSCANDoStatsToggle, 'Value', handles.DBSCAN(ch).DoStats);
        
    end


    function DoCUseThreshold(varargin)
        
        if get(handles.handles.DBSCANSetToggle, 'value') == 1
            set(handles.handles.DBSCANSettingsEdit(5), 'enable', 'on');
        elseif get(handles.handles.DBSCANSetToggle, 'value') == 0
            set(handles.handles.DBSCANSettingsEdit(5), 'enable', 'off');
        end
        
    end

    function DoCSetAndContinue(varargin)
        
        % Collect inputs and set parameters in guidata
     	handles.DoC.Lr_rRad = str2double(get(handles.handles.DoCSettingsEdit(1),'string'));
        handles.DoC.Rmax = str2double(get(handles.handles.DoCSettingsEdit(2),'string'));
        handles.DoC.Step = str2double(get(handles.handles.DoCSettingsEdit(3),'string'));
        handles.DoC.ColoThres = str2double(get(handles.handles.DoCSettingsEdit(4), 'string'));
        handles.DoC.NbThresh = str2double(get(handles.handles.DoCSettingsEdit(5), 'string'));
             
        % Collect inputs and set parameters in guidata
     	handles.DBSCAN(ch).epsilon = str2double(get(handles.handles.DBSCANSettingsEdit(1),'string'));
        handles.DBSCAN(ch).minPts = str2double(get(handles.handles.DBSCANSettingsEdit(2),'string'));
        handles.DBSCAN(ch).Cutoff = str2double(get(handles.handles.DBSCANSettingsEdit(3),'string'));
        handles.DBSCAN(ch).threads = str2double(get(handles.handles.DBSCANSettingsEdit(4),'string'));
        handles.DBSCAN(ch).Lr_rThreshRad = str2double(get(handles.handles.DBSCANSettingsEdit(5),'string'));
        handles.DBSCAN(ch).SmoothingRad = str2double(get(handles.handles.DBSCANSettingsEdit(6),'string'));
        handles.DBSCAN(ch).UseLr_rThresh = (get(handles.handles.DBSCANSetToggle, 'value')) == get(handles.handles.DBSCANSetToggle, 'Max');
        handles.DBSCAN(ch).DoStats = (get(handles.handles.DBSCANDoStatsToggle, 'value')) == get(handles.handles.DBSCANDoStatsToggle, 'Max');
        
        returnValue = 1;
        guidata(handles.handles.MainFig, handles);
        uiresume;
        delete(handles.handles.DoCSettingsFig);
        
    end  

end


% Pop-up window to set PoC parameters
function returnValue = setPoCParameters(handles)

    isCombined = handles.ProcessType == handles.CONST.PROCESS_COMBINED;

    handles.handles.PoCSettingsFig = figure();
    set(handles.handles.PoCSettingsFig, 'Tag', 'ClusPoC');
    resizeFig(handles.handles.PoCSettingsFig, [510 306]);
    set(handles.handles.PoCSettingsFig, 'toolbar', 'figure', 'menubar', 'none', ...
        'name', 'PoC Parameters');
    
    ch = 1;
    if(isCombined)
        ch = 3;
    end
    
    SUP = 40; %shift control up compared to v1.0.0
    SUP2 = 30;
   
    handles.handles.PoCSettingsTitleText(2) = uicontrol('Style', 'text', ...
        'String', '_____________________', 'parent', handles.handles.PoCSettingsFig,...
        'Position', [0 197+SUP 200 20], 'horizontalalignment', 'center', 'Fontsize', 10);

	handles.handles.PoCSettingsTitleText(1) = uicontrol('Style', 'text', ...
        'String', 'Probability of Colocalization Parameters', 'parent', handles.handles.PoCSettingsFig,...
        'Position', [0 207+SUP 200 35], 'horizontalalignment', 'center', 'Fontsize', 10);
    
    %%%%%%
    
    handles.handles.PoCSettingsText(1) = uicontrol('Style', 'text', ...
        'String', 'PoC_a=:', 'parent', handles.handles.PoCSettingsFig,...
        'Position', [0 160+SUP2 100 20], 'horizontalalignment', 'right');
    
    handles.handles.DoCSettingsText(2) = uicontrol('Style', 'text', ...
        'String', 'L(r) - r radius (nm):', 'parent', handles.handles.PoCSettingsFig,...
        'Position', [0 130+SUP2 100 20], 'horizontalalignment', 'right');
    
    handles.handles.PoCSettingsText(3) = uicontrol('Style', 'text', ...
        'String', 'Gaussian width (sigma):', 'parent', handles.handles.PoCSettingsFig,...
        'Position', [0 100+SUP2 100 30], 'horizontalalignment', 'right');
    
    handles.handles.PoCSettingsText(4) = uicontrol('Style', 'text', ...
        'String', 'Colocalization Threshold:', 'parent', handles.handles.PoCSettingsFig,...
        'Position', [0 60+SUP2 100 30], 'horizontalalignment', 'right');
    
    handles.handles.PoCSettingsText(5) = uicontrol('Style', 'text', ...
        'String', 'Min Coloc''d Points/Cluster:', 'parent', handles.handles.PoCSettingsFig,...
        'Position', [0 20+SUP2 100 30], 'horizontalalignment', 'right');
    
	%%%%%%%%%%
    
    handles.handles.PoCSettingsEdit(1) = uicontrol(handles.handles.b_panel, 'Style', 'popup', 'String', ...
        {'sum_b/sum_a', 'sum_b/(sum_a+sum_b)'}, 'parent', handles.handles.PoCSettingsFig, ...
        'Position', [118 162+SUP2 120 20]);
    
    handles.handles.PoCSettingsEdit(2) = uicontrol('Style', 'edit', ...
        'String', num2str(handles.PoC.Lr_rRad), 'parent', handles.handles.PoCSettingsFig,...
        'Position', [120 132+SUP2 60 20]);
    
    handles.handles.PoCSettingsEdit(3) = uicontrol('Style', 'edit', ...
        'String', num2str(handles.PoC.Sigma), 'parent', handles.handles.PoCSettingsFig,...
        'Position', [120 102+SUP2 60 20]);
    
    handles.handles.PoCSettingsEdit(4) = uicontrol('Style', 'edit', ...
        'String', num2str(handles.PoC.ColoThres), 'parent', handles.handles.PoCSettingsFig,...
        'Position', [120 67+SUP2 60 20]);
    
    handles.handles.PoCSettingsEdit(5) = uicontrol('Style', 'edit', ...
        'String', num2str(handles.PoC.NbThresh), 'parent', handles.handles.PoCSettingsFig,...
        'Position', [120 32+SUP2 60 20]);
    
    
    %%%%%%%%%%%%%%%
    % PoC - DBSCAN settings
    
    str = 'DBSCAN Parameters';
    if(isCombined)
        str = 'DBSCAN Parameters for combined data';
    end
	handles.handles.DBSCANSettingsTitleText(1) = uicontrol('Style', 'text', ...
        'String', str, 'parent', handles.handles.PoCSettingsFig,...
        'Position', [260 220+SUP 250 20], 'horizontalalignment', 'center', 'Fontsize', 10);
    
    %%%%%%%%
    if verLessThan('matlab', '8.4')
        handles.handles.DBSCANChannelToggle = uibuttongroup('Visible', 'on', 'Position',[.55 220/306 .4 .11],...
            'SelectionChangeFcn', @changeDBSCANChannel);
    else
        handles.handles.DBSCANChannelToggle = uibuttongroup('Visible', 'on', 'Position',[.55 220/306 .4 .11],...
            'SelectionChangedFcn', @changeDBSCANChannel);
    end
                  
    handles.handles.DBSCANChannelSelect(1) = uicontrol(handles.handles.DBSCANChannelToggle, ...
        'Style', 'radiobutton', 'String', 'Ch 1', 'position', [39 7 50 20]);
    
    handles.handles.DBSCANChannelSelect(2) = uicontrol(handles.handles.DBSCANChannelToggle, ...
        'Style', 'radiobutton', 'String', 'Ch 2', 'position', [130 7 50 20]);
    
    if verLessThan('matlab', '8.4')
        
        if handles.Nchannels > 1
            set(handles.handles.DBSCANChannelToggle, 'Visible', 'on');
        else
            set(handles.handles.DBSCANChannelToggle, 'Visible', 'on');
            set(handles.handles.DBSCANChannelSelect(2), 'Enable', 'off');
        end
        
    else
        if handles.Nchannels > 1
            handles.handles.DBSCANChannelToggle.Visible = 'on';
        else
            handles.handles.DBSCANChannelToggle.Visible = 'on';
            handles.handles.DBSCANChannelSelect(2).Enable = 'off';
        end
    end
    
    if(isCombined)
        if verLessThan('matlab', '8.4')
            set(handles.handles.DBSCANChannelToggle, 'Visible', 'off'); 
        else
            handles.handles.DBSCANChannelToggle.Visible = 'off';
        end 
        handles.handles.DBSCANSettingsTitleText(2) = uicontrol('Style', 'text', ...
            'String', '_____________________', 'parent', handles.handles.PoCSettingsFig,...
            'Position', [260 197+SUP 250 20], 'horizontalalignment', 'center', 'Fontsize', 10);
    end
        
    %%%%%%%%
    
    
    %%%%%%
    
    handles.handles.DBSCANSettingsText(1) = uicontrol('Style', 'text', ...
        'String', 'Epsilon (nm):', 'parent', handles.handles.PoCSettingsFig,...
        'Position', [260 157+SUP2 110 20], 'horizontalalignment', 'right');
    
    handles.handles.DBSCANSettingsText(2) = uicontrol('Style', 'text', ...
        'String', 'minPts:', 'parent', handles.handles.PoCSettingsFig,...
        'Position', [260 132+SUP2 110 20], 'horizontalalignment', 'right');
    
    handles.handles.DBSCANSettingsText(3) = uicontrol('Style', 'text', ...
        'String', 'Plot Cutoff:', 'parent', handles.handles.PoCSettingsFig,...
        'Position', [260 107+SUP2 110 20], 'horizontalalignment', 'right');
    
    handles.handles.DBSCANSettingsText(4) = uicontrol('Style', 'text', ...
        'String', 'Processing Threads:', 'parent', handles.handles.PoCSettingsFig,...
        'Position', [260 82+SUP2 110 20], 'horizontalalignment', 'right');
    
    handles.handles.DBSCANSettingsText(5) = uicontrol('Style', 'text', ...
        'String', 'L(r) - r Radius (nm):', 'parent', handles.handles.PoCSettingsFig,...
        'Position', [260 57+SUP2 110 20], 'horizontalalignment', 'right');
    
    handles.handles.DBSCANSettingsText(6) = uicontrol('Style', 'text', ...
        'String', 'Use', 'parent', handles.handles.PoCSettingsFig,...
        'Position', [450 57+SUP2 30 20], 'horizontalalignment', 'right');
    
    handles.handles.DBSCANSettingsText(7) = uicontrol('Style', 'text', ...
        'String', 'Smooth Radius (nm):', 'parent', handles.handles.PoCSettingsFig,...
        'Position', [260 32+SUP2 110 20], 'horizontalalignment', 'right');
    
	handles.handles.DBSCANSettingsText(8) = uicontrol('Style', 'text', ...
        'String', 'Calc Stats:', 'parent', handles.handles.PoCSettingsFig,...
        'Position', [260 6+SUP2 110 20], 'horizontalalignment', 'right');
    
	%%%%%%%%%%
    
    handles.handles.DBSCANSettingsEdit(1) = uicontrol('Style', 'edit', ...
        'String', num2str(handles.DBSCAN(ch).epsilon), 'parent', handles.handles.PoCSettingsFig,...
        'Position', [375 161+SUP2 60 20]);
    
    handles.handles.DBSCANSettingsEdit(2) = uicontrol('Style', 'edit', ...
        'String', num2str(handles.DBSCAN(ch).minPts), 'parent', handles.handles.PoCSettingsFig,...
        'Position', [375 136+SUP2 60 20]);
    
    handles.handles.DBSCANSettingsEdit(3) = uicontrol('Style', 'edit', ...
        'String', num2str(handles.DBSCAN(ch).Cutoff), 'parent', handles.handles.PoCSettingsFig,...
        'Position', [375 111+SUP2 60 20]);
    
    handles.handles.DBSCANSettingsEdit(4) = uicontrol('Style', 'edit', ...
        'String', num2str(handles.DBSCAN(ch).threads), 'parent', handles.handles.PoCSettingsFig,...
        'Position', [375 86+SUP2 60 20]);
    
    handles.handles.DBSCANSettingsEdit(5) = uicontrol('Style', 'edit', ...
        'String', num2str(handles.DBSCAN(ch).Lr_rThreshRad), 'parent', handles.handles.PoCSettingsFig,...
        'Position', [375 61+SUP2 60 20]);
    
    handles.handles.DBSCANSettingsEdit(6) = uicontrol('Style', 'edit', ...
        'String', num2str(handles.DBSCAN(ch).SmoothingRad), 'parent', handles.handles.PoCSettingsFig,...
        'Position', [375 36+SUP2 60 20]);
    
    set(handles.handles.DBSCANSettingsEdit, 'Callback', @PoCCheckEditBox);
    
    %%%%%%
    
    handles.handles.DBSCANSetToggle = uicontrol('Style', 'checkbox', ...
        'Value', handles.DBSCAN(ch).UseLr_rThresh, 'position', [485 60+SUP2 20 20], ...
        'callback', @DBSCANUseThreshold);
    
	handles.handles.DBSCANDoStatsToggle = uicontrol('Style', 'checkbox', ...
        'Value', handles.DBSCAN(ch).DoStats, 'position', [375 10+SUP2 20 20]);

    set(handles.handles.DBSCANSetToggle, 'Enable', 'off');
    set(handles.handles.DBSCANDoStatsToggle, 'Enable', 'off');

    %%%%%%
    
    
    handles.handles.PoCSettingsButton = uicontrol('Style', 'pushbutton', ...
        'String', 'Continue', 'parent', handles.handles.PoCSettingsFig, ...
        'Position', [425 4 85 30], 'Callback', @PoCSetAndContinue);

    set(handles.handles.PoCSettingsFig, 'CloseRequestFcn', @PoCCloseOutWindow);
    
    PoCUseThreshold();
    
    uiwait;
    
    function PoCCloseOutWindow(varargin)
        % Cancel, don't execute further
        returnValue = 0;
        uiresume;
        delete(handles.handles.PoCSettingsFig);
    end

    function PoCCheckEditBox(hObj, varargin)
        
        input = str2double(get(hObj,'string'));
        if isnan(input) 
            
            errordlg('You must enter a numeric value','Invalid Input','modal');
%             return;
        elseif input < 0
            
            errordlg('Value must be positive','Invalid Input','modal');
%             return;
        else
            % continue
        end

    end

    function changeDBSCANChannel(varargin)
        
        changeToValue = (varargin{2}.NewValue);
        
        if strcmp(changeToValue.String, 'Ch 1');
            ch = 1;
            oldCh = 2;
        elseif strcmp(changeToValue.String, 'Ch 2');
            ch = 2;
            oldCh = 1;
        end
        
     	handles.DBSCAN(oldCh).epsilon = str2double(get(handles.handles.DBSCANSettingsEdit(1),'string'));
        handles.DBSCAN(oldCh).minPts = str2double(get(handles.handles.DBSCANSettingsEdit(2),'string'));
        handles.DBSCAN(oldCh).Cutoff = str2double(get(handles.handles.DBSCANSettingsEdit(3),'string'));
        handles.DBSCAN(oldCh).threads = str2double(get(handles.handles.DBSCANSettingsEdit(4),'string'));
        handles.DBSCAN(oldCh).Lr_rThreshRad = str2double(get(handles.handles.DBSCANSettingsEdit(5),'string'));
        handles.DBSCAN(oldCh).SmoothingRad = str2double(get(handles.handles.DBSCANSettingsEdit(6),'string'));
        handles.DBSCAN(oldCh).UseLr_rThresh = (get(handles.handles.DBSCANSetToggle, 'value')) == get(handles.handles.DBSCANSetToggle, 'Max');
        handles.DBSCAN(oldCh).DoStats = (get(handles.handles.DBSCANDoStatsToggle, 'value')) == get(handles.handles.DBSCANDoStatsToggle, 'Max');
        
%         disp(handles.DBSCAN(oldCh));
        
        set(handles.handles.DBSCANSettingsEdit(1), 'String', num2str(handles.DBSCAN(ch).epsilon));
        set(handles.handles.DBSCANSettingsEdit(2), 'String', num2str(handles.DBSCAN(ch).minPts));
        set(handles.handles.DBSCANSettingsEdit(3), 'String', num2str(handles.DBSCAN(ch).Cutoff));
        set(handles.handles.DBSCANSettingsEdit(4), 'String', num2str(handles.DBSCAN(ch).threads));
        set(handles.handles.DBSCANSettingsEdit(5), 'String', num2str(handles.DBSCAN(ch).Lr_rThreshRad));
        set(handles.handles.DBSCANSettingsEdit(6), 'String', num2str(handles.DBSCAN(ch).SmoothingRad));       
        set(handles.handles.DBSCANSetToggle, 'Value', handles.DBSCAN(ch).UseLr_rThresh);
        set(handles.handles.DBSCANDoStatsToggle, 'Value', handles.DBSCAN(ch).DoStats);
        
    end


    function PoCUseThreshold(varargin)
        
        if get(handles.handles.DBSCANSetToggle, 'value') == 1
            set(handles.handles.DBSCANSettingsEdit(5), 'enable', 'on');
        elseif get(handles.handles.DBSCANSetToggle, 'value') == 0
            set(handles.handles.DBSCANSettingsEdit(5), 'enable', 'off');
        end
        
    end

    function PoCSetAndContinue(varargin)
        
        % Collect inputs and set parameters in guidata
     	handles.PoC.FuncType = get(handles.handles.PoCSettingsEdit(1),'value');
        handles.PoC.Lr_rRad = str2double(get(handles.handles.PoCSettingsEdit(2),'string'));
        handles.PoC.Sigma = str2double(get(handles.handles.PoCSettingsEdit(3),'string'));
        handles.PoC.ColoThres = str2double(get(handles.handles.PoCSettingsEdit(4), 'string'));
        handles.PoC.NbThresh = str2double(get(handles.handles.PoCSettingsEdit(5), 'string'));
             
        % Collect inputs and set parameters in guidata
     	handles.DBSCAN(ch).epsilon = str2double(get(handles.handles.DBSCANSettingsEdit(1),'string'));
        handles.DBSCAN(ch).minPts = str2double(get(handles.handles.DBSCANSettingsEdit(2),'string'));
        handles.DBSCAN(ch).Cutoff = str2double(get(handles.handles.DBSCANSettingsEdit(3),'string'));
        handles.DBSCAN(ch).threads = str2double(get(handles.handles.DBSCANSettingsEdit(4),'string'));
        handles.DBSCAN(ch).Lr_rThreshRad = str2double(get(handles.handles.DBSCANSettingsEdit(5),'string'));
        handles.DBSCAN(ch).SmoothingRad = str2double(get(handles.handles.DBSCANSettingsEdit(6),'string'));
        handles.DBSCAN(ch).UseLr_rThresh = (get(handles.handles.DBSCANSetToggle, 'value')) == get(handles.handles.DBSCANSetToggle, 'Max');
        handles.DBSCAN(ch).DoStats = (get(handles.handles.DBSCANDoStatsToggle, 'value')) == get(handles.handles.DBSCANDoStatsToggle, 'Max');
        
        returnValue = 1;
        guidata(handles.handles.MainFig, handles);
        uiresume;
        delete(handles.handles.PoCSettingsFig);
        
    end  

end


% Function Ripley K Test for active ROI
function RipleyKtest(~, ~, ~)

    handles = guidata(findobj('Tag', 'PALM GUI'));
    
    UpdateStatusBar(handles, 'Ripley K test on Selected ROI');
    fprintf(1, 'Ripley K test on Selected ROI\n');
    set(handles.handles.MainFig, 'pointer', 'watch');
    set(findobj('parent', handles.handles.b_panel), 'enable', 'off');
    drawnow;
    
    CurrentROI = handles.ROICoordinates{handles.CurrentCellData}{handles.CurrentROIData};
    CurrentROI = [CurrentROI(1,1),  CurrentROI(1,2), max(CurrentROI(:,1)) - min(CurrentROI(:,1)), max(CurrentROI(:,2)) - min(CurrentROI(:,2))];
    
    % RipleyK parameter
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Launch GUI window to change the set parameters, if desired
    returnVal = setRipleyKParameters(handles);

    if returnVal == 0
        set(handles.handles.MainFig, 'pointer', 'arrow');
        set(findobj('parent', handles.handles.b_panel), 'enable', 'on');
        fprintf(1, 'Ripley K test cancelled.\n');
        UpdateStatusBar(handles, 'Ripley K test cancelled');
        drawnow;
        return;
        
    elseif returnVal == 1
        
        try 
            % Since which ROI a point falls in is encoded in binary, decode here
            whichPointsInROI = fliplr(dec2bin(handles.CellData{handles.CurrentCellData}(:,handles.NDataColumns + 1)));
            whichPointsInROI = whichPointsInROI(:,handles.CurrentROIData) == '1';
            
            handles.RipleyK.size_ROI = CurrentROI(3:4);
            handles.RipleyK.Area = polyarea(handles.ROICoordinates{handles.CurrentCellData}{handles.CurrentROIData}(:,1), ...
                handles.ROICoordinates{handles.CurrentCellData}{handles.CurrentROIData}(:,2));
            
            handles.RipleyK.r = zeros(((handles.RipleyK.End - handles.RipleyK.Start)/handles.RipleyK.Step + 1), ...
                handles.Nchannels);
            handles.RipleyK.Lr_r = zeros(((handles.RipleyK.End - handles.RipleyK.Start)/handles.RipleyK.Step + 1), ...
                handles.Nchannels);
            
            if(handles.ProcessType == handles.CONST.PROCESS_SEPARATE)
                xCh1 = handles.CellData{handles.CurrentCellData}(whichPointsInROI & ...
                    (handles.CellData{handles.CurrentCellData}(:, handles.NDataColumns - 1) == 1), 5:6);

                xCh2 = handles.CellData{handles.CurrentCellData}(whichPointsInROI & ...
                    (handles.CellData{handles.CurrentCellData}(:, handles.NDataColumns - 1) == 2), 5:6);
                
                % Sub-sample each Ch1 and Ch2 points to improve RipleyK calculation
                % speed, provide even density between samples
                if size(xCh1, 1) > handles.RipleyK.MaxSampledPts
                    rKsubsample = randsample(1:size(xCh1, 1), handles.RipleyK.MaxSampledPts);
                    xCh1 = xCh1(rKsubsample, :);
                end

                if size(xCh2, 1) > handles.RipleyK.MaxSampledPts
                    rKsubsample = randsample(1:size(xCh2, 1), handles.RipleyK.MaxSampledPts);
                    xCh2 = xCh2(rKsubsample, :);
                end
                
                % Channel 1
                [handles.RipleyK.r(:,1), handles.RipleyK.Lr_r(:,1)] = RipleyKFun( xCh1, handles.RipleyK.Area, ...
                    handles.RipleyK.Start, handles.RipleyK.End, handles.RipleyK.Step, ...
                    handles.RipleyK.size_ROI);
                % Plot
                handles.handles.RipleyKCh1Fig = figure('Name','Active ROI Ch1', 'color', [1 1 1]); 
                handles.handles.RipleyKCh1Ax = axes('parent', handles.handles.RipleyKCh1Fig);
                plot(handles.handles.RipleyKCh1Ax, handles.RipleyK.r(:,1), handles.RipleyK.Lr_r(:,1), ...
                    'linewidth', 2, 'color', handles.Chan1Color);
                set(handles.handles.RipleyKCh1Ax, 'NextPlot', 'add', 'fontsize', 12);
                title_name = sprintf('%.0d points in %.0f x %.0f nm Area', size(xCh1, 1), CurrentROI(3), CurrentROI(4));
                title(title_name);
                xlabel(handles.handles.RipleyKCh1Ax, 'r (nm)', 'fontsize', 12);
                ylabel(handles.handles.RipleyKCh1Ax, 'L(r)-r', 'fontsize', 12);
                set(handles.handles.RipleyKCh1Ax, 'NextPlot', 'replace');
                
                % Channel 2
                if handles.Nchannels == 2
                    %Ch2
                    % RipleyK function
                    [handles.RipleyK.r(:,2), handles.RipleyK.Lr_r(:,2)] = RipleyKFun( xCh2, handles.RipleyK.Area, ...
                    handles.RipleyK.Start, handles.RipleyK.End, handles.RipleyK.Step, ...
                    handles.RipleyK.size_ROI);
                    % Plot
                    handles.handles.RipleyKCh2Fig = figure('Name','Active ROI Ch2', 'color', [1 1 1]); 
                    handles.handles.RipleyKCh2Ax = axes('parent', handles.handles.RipleyKCh2Fig, 'fontsize', 12);
                    plot(handles.handles.RipleyKCh2Ax, handles.RipleyK.r(:,2), handles.RipleyK.Lr_r(:,2), ...
                         'linewidth', 2, 'color', handles.Chan2Color);
                    set(handles.handles.RipleyKCh2Ax, 'NextPlot', 'add', 'fontsize', 12);
                    title_name = sprintf('%.0d points in %.0f x %.0f nm Area', size(xCh2, 1), CurrentROI(3), CurrentROI(4));
                    title(title_name);
                    xlabel(handles.handles.RipleyKCh2Ax, 'r (nm)', 'fontsize', 12);
                    ylabel(handles.handles.RipleyKCh2Ax, 'L(r)-r', 'fontsize', 12);
                    set(handles.handles.RipleyKCh2Ax, 'NextPlot', 'replace');
                end 
                
            else % combined data
                xCombined = handles.CellData{handles.CurrentCellData}(whichPointsInROI, 5:6);
                if size(xCombined, 1) > handles.RipleyK.MaxSampledPts
                    rKsubsample = randsample(1:size(xCombined, 1), handles.RipleyK.MaxSampledPts);
                    xCombined = xCombined(rKsubsample, :);
                end
                
                [handles.RipleyK.r(:,1), handles.RipleyK.Lr_r(:,1)] = RipleyKFun( xCombined, handles.RipleyK.Area, ...
                    handles.RipleyK.Start, handles.RipleyK.End, handles.RipleyK.Step, ...
                    handles.RipleyK.size_ROI);
                % Plot
                handles.handles.RipleyKCh1Fig = figure('Name','Active ROI combined data', 'color', [1 1 1]); 
                handles.handles.RipleyKCh1Ax = axes('parent', handles.handles.RipleyKCh1Fig);
                plot(handles.handles.RipleyKCh1Ax, handles.RipleyK.r(:,1), handles.RipleyK.Lr_r(:,1), ...
                    'linewidth', 2, 'color', handles.CombinedColor);
                set(handles.handles.RipleyKCh1Ax, 'NextPlot', 'add', 'fontsize', 12);
                title_name = sprintf('%.0d points in %.0f x %.0f nm Area', size(xCombined, 1), CurrentROI(3), CurrentROI(4));
                title(title_name);
                xlabel(handles.handles.RipleyKCh1Ax, 'r (nm)', 'fontsize', 12);
                ylabel(handles.handles.RipleyKCh1Ax, 'L(r)-r', 'fontsize', 12);
                set(handles.handles.RipleyKCh1Ax, 'NextPlot', 'replace');
            end
           
            % update GUI
            set(handles.handles.MainFig, 'pointer', 'arrow');
            set(findobj('parent', handles.handles.b_panel), 'enable', 'on');
            drawnow;
            fprintf(1, 'Ripley K test completed.\n');
            UpdateStatusBar(handles, 'Ripley K test completed.');
            
        catch mError
            
            set(handles.handles.MainFig, 'pointer', 'arrow');
            set(findobj('parent', handles.handles.b_panel), 'enable', 'on');
            drawnow;
            
            disp('Ripley K test exited with errors');
            UpdateStatusBar(handles, 'Ripley K test exited with errors');
            rethrow(mError);
        end
    end

    guidata(handles.handles.MainFig, handles);
    
end

% Function DBSCAN Test for active ROI
function DBSCAN_Test(~, ~, ~)

    handles = guidata(findobj('Tag', 'PALM GUI'));
    
    set(handles.handles.MainFig, 'pointer', 'watch');
    set(findobj('parent', handles.handles.b_panel), 'enable', 'off');
    UpdateStatusBar(handles, 'DBSCAN test on ROI...');
    drawnow;

    for ch = 1:3
        handles.DBSCAN(ch).UseLr_rThresh = false;
        handles.DBSCAN(ch).DoStats = false;
    end
    returnVal = setDBSCANParameters(handles, false);
    handles = guidata(findobj('Tag', 'PALM GUI'));
    
    if returnVal == 0
        set(handles.handles.MainFig, 'pointer', 'arrow');
        set(findobj('parent', handles.handles.b_panel), 'enable', 'on');
        fprintf(1, 'DBSCAN test cancelled.\n');
        UpdateStatusBar(handles, 'DBSCAN test cancelled');
        drawnow;
        return;
        
    elseif returnVal == 1
        
        try
            % Since which ROI a point falls in is encoded in binary, decode here
            whichPointsInROI = fliplr(dec2bin(handles.CellData{handles.CurrentCellData}(:,handles.NDataColumns + 1)));
            whichPointsInROI = whichPointsInROI(:,handles.CurrentROIData) == '1';
            dataCropped = handles.CellData{handles.CurrentCellData}(whichPointsInROI, :);
            
            if(handles.ProcessType == handles.CONST.PROCESS_SEPARATE)
                dbscanParams = handles.DBSCAN(1);
                dbscanParams.Outputfolder = handles.Outputfolder;
                dbscanParams.CurrentChannel = 1;
                dbscanParams.IsCombined = false;
                
                % Channel 1
                [~, ClusterCh, ~, classOut, figOut] = DBSCANHandler(dataCropped(dataCropped(:,12) == 1, 5:6), dbscanParams, ...
                    dataCropped(dataCropped(:,12) == 1, handles.NDataColumns + 2)); 
              
                handles.CellData{handles.CurrentCellData}(whichPointsInROI & (handles.CellData{handles.CurrentCellData}(:,12) == 1),...
                    handles.NDataColumns + 3) = classOut;

                handles.ClusterTable = AppendToClusterTable(handles.ClusterTable, 1, handles.CurrentCellData, handles.CurrentROIData, ClusterCh, classOut, dataCropped(:,12));
                set(handles.handles.ExportResultsButton, 'enable', 'on');
                
                set(figOut, 'Name', 'DBSCAN Active ROI Ch1')
                
                % Channel 2
                if handles.Nchannels == 2

                    dbscanParams = handles.DBSCAN(2);
                    dbscanParams.Outputfolder = handles.Outputfolder;
                    dbscanParams.CurrentChannel = 2;
                    dbscanParams.IsCombined = false;

                    [~, ClusterCh, ~, classOut, figOut] = DBSCANHandler(dataCropped(dataCropped(:,12) == 2, 5:6), dbscanParams, ...
                        dataCropped(dataCropped(:,12) == 2, handles.NDataColumns + 2));
          
                    handles.CellData{handles.CurrentCellData}(whichPointsInROI & (handles.CellData{handles.CurrentCellData}(:,12) == 2),...
                        handles.NDataColumns + 3) = classOut;
                    set(figOut, 'Name', 'DBSCAN Active ROI Ch2')

                    handles.ClusterTable = AppendToClusterTable(handles.ClusterTable, 2, handles.CurrentCellData, handles.CurrentROIData, ClusterCh, classOut, dataCropped(:,12));
                end
                
                handles.CellData{handles.CurrentCellData}(whichPointsInROI, handles.NDataColumns + 9) = 0;
                
                
            else % combined data
                dbscanParams = handles.DBSCAN(3);
                dbscanParams.Outputfolder = handles.Outputfolder;
                dbscanParams.CurrentChannel = 3;
                dbscanParams.IsCombined = true;
                
                [~, ClusterCh, ~, classOut, figOut] = DBSCANHandler(dataCropped(:, 5:6), dbscanParams, ...
                    dataCropped(:, handles.NDataColumns + 2)); 
           
                handles.CellData{handles.CurrentCellData}(whichPointsInROI, handles.NDataColumns + 9) = classOut;

                handles.ClusterTable = AppendToClusterTable(handles.ClusterTable, 3, handles.CurrentCellData, handles.CurrentROIData, ClusterCh, classOut, dataCropped(:,12));
                set(handles.handles.ExportResultsButton, 'enable', 'on');
                
                set(figOut, 'Name', 'DBSCAN Active ROI Combined data')
            end

            set(handles.handles.MainFig, 'pointer', 'arrow');
            set(findobj('parent', handles.handles.b_panel), 'enable', 'on');
            if handles.Nchannels == 1
                set(handles.handles.hDoC_All1, 'enable', 'off');
            end
            drawnow;
            fprintf(1, 'DBSCAN test completed.\n');
            UpdateStatusBar(handles, 'DBSCAN test completed');
            
        catch mError
           
            set(handles.handles.MainFig, 'pointer', 'arrow');
            set(findobj('parent', handles.handles.b_panel), 'enable', 'on');
            if handles.Nchannels == 1
                set(handles.handles.hDoC_All1, 'enable', 'off');
            end
            drawnow;
            
            disp('DBSCAN text exited with errors');
            UpdateStatusBar(handles, 'DBSCAN text exited with errors');
            rethrow(mError);
        end
    end
    
    set(handles.handles.MainFig, 'pointer', 'arrow');
    set(findobj('parent', handles.handles.b_panel), 'enable', 'on');
    drawnow;
    
    guidata(handles.handles.MainFig, handles);
end


% Load the existing Ripley data or calculate the Ripley
function RunRipleyK(~, ~, ~)

    handles = guidata(findobj('Tag', 'PALM GUI'));

    set(handles.handles.MainFig, 'pointer', 'watch');
    set(get(handles.handles.b_panel, 'children'), 'enable', 'off');
    UpdateStatusBar(handles, 'Running RippleK on ROI...');
    drawnow;

    returnVal = setRipleyKParameters(handles); % re-set RipleyK parameters if desired
    handles = guidata(findobj('Tag', 'PALM GUI'));
    
    if returnVal == 0
        
        set(handles.handles.MainFig, 'pointer', 'arrow');
        set(get(handles.handles.b_panel, 'children'), 'enable', 'on');
        if handles.Nchannels == 1
            set(handles.handles.hDoC_All1, 'enable', 'off');
        end
        UpdateStatusBar(handles, 'RippleK on ROI cancelled');
        drawnow;
        return
        
    elseif returnVal == 1
        
        try
    
            % Ripley K calculation
            % Iterate through cells + ROIs

            % Code inside loop is from RipleyKmultiData_GUIFunV2.m 
            % Moving here to create more reasonable workflow
            % create the output folder 'RipleyKGUI_Result
            Fun_OutputFolder_name = fullfile(handles.Outputfolder, 'RipleyKGUI_Result');
            CreateDir(Fun_OutputFolder_name);
            CreateDir(fullfile(Fun_OutputFolder_name, 'RipleyK Plots'));
            CreateDir(fullfile(Fun_OutputFolder_name, 'RipleyK Results'));
            if(handles.ProcessType == handles.CONST.PROCESS_SEPARATE)
                mkdir(fullfile(Fun_OutputFolder_name, 'RipleyK Plots', 'Ch1'));
                mkdir(fullfile(Fun_OutputFolder_name, 'RipleyK Plots', 'Ch2'));
                mkdir(fullfile(Fun_OutputFolder_name, 'RipleyK Results', 'Ch1'));
                mkdir(fullfile(Fun_OutputFolder_name, 'RipleyK Results', 'Ch2'));
            else
                mkdir(fullfile(Fun_OutputFolder_name, 'RipleyK Plots', 'Combined'));
                mkdir(fullfile(Fun_OutputFolder_name, 'RipleyK Results', 'Combined'));
            end

            [~] = RipleyKHandler(handles, Fun_OutputFolder_name);
            
        catch mError
           
            set(handles.handles.MainFig, 'pointer', 'arrow');
            set(get(handles.handles.b_panel, 'children'), 'enable', 'on');
            if handles.Nchannels == 1
                set(handles.handles.hDoC_All1, 'enable', 'off');
            end
            drawnow;
            
            disp('Ripley K processing exited with errors');
            UpdateStatusBar(handles, 'Ripley K processing exited with errors');
            rethrow(mError);
            
        end
    end

    set(handles.handles.MainFig, 'pointer', 'arrow');
    set(get(handles.handles.b_panel, 'children'), 'enable', 'on');
    if handles.Nchannels == 1
        set(handles.handles.hDoC_All1, 'enable', 'off');
    end
    UpdateStatusBar(handles, 'RippleK on ROI completed!');
    drawnow;
    
    guidata(handles.handles.MainFig, handles);
    
end


% Calculate DBSCAN for selected data or loaded data
function RunDBSCAN(~, ~, ~)

    handles = guidata(findobj('Tag', 'PALM GUI'));

    set(handles.handles.MainFig, 'pointer', 'watch');
    set(get(handles.handles.b_panel, 'children'), 'enable', 'off');
    UpdateStatusBar(handles, 'Running DBSCAN on ROI...');
    drawnow;

    CreateDir(fullfile(handles.Outputfolder, 'DBSCAN Results'));

    for ch = 1:3
        handles.DBSCAN(ch).UseLr_rThresh = true;
        handles.DBSCAN(ch).DoStats = true;
    end
    
    returnVal = setDBSCANParameters(handles, true);
    handles = guidata(findobj('Tag', 'PALM GUI'));

    if returnVal == 0
        % Cancel.  Reset GUI
        set(handles.handles.MainFig, 'pointer', 'arrow');
        set(get(handles.handles.b_panel, 'children'), 'enable', 'on');
        if handles.Nchannels == 1
            set(handles.handles.hDoC_All1, 'enable', 'off');
        end
        UpdateStatusBar(handles, 'DBSCAN on ROI cancelled!');
        drawnow;
        return;

    elseif returnVal == 1
        
        % Do DBSCAN on each cell, ROI, and channel
        % Can parfor this?
        try   
            
            isCombined = handles.ProcessType == handles.CONST.PROCESS_COMBINED;
            if(isCombined)
                channels = 3;  % [3]
            else
                channels = 1:handles.Nchannels; % e,g, [1, 2]
            end
            
            for chan = channels
                
                if(isCombined)
                    dirname = 'Combined';
                else
                    dirname = sprintf('Ch%d', chan);
                end
                
                dbscanParams = handles.DBSCAN(chan);
                dbscanParams.Outputfolder = handles.Outputfolder;
                dbscanParams.IsCombined = isCombined;
                
                CreateDir(fullfile(handles.Outputfolder, 'DBSCAN Results', dirname));
                CreateDir(fullfile(handles.Outputfolder, 'DBSCAN Results', dirname, 'Cluster maps'));
                CreateDir(fullfile(handles.Outputfolder, 'DBSCAN Results', dirname, 'Cluster density maps'));
                
                dbscanParams.CurrentChannel = chan;
                
                if chan == 1
                    clusterColor = handles.Chan1Color;
                elseif chan == 2
                    clusterColor = handles.Chan2Color;
                else
                    clusterColor = handles.CombinedColor;
                end
                
                cellROIPair = [];    
                
                Result = cell(max(cell2mat(cellfun(@length, handles.ROICoordinates, 'uniformoutput', false))), ...
                    size(handles.CellData, 1));
                ClusterSmoothTable = cell(max(cell2mat(cellfun(@length, handles.ROICoordinates, 'uniformoutput', false))), ...
                    size(handles.CellData, 1));
            
                for c = 1:size(handles.CellData, 1)

                    for roiInc = 1:length(handles.ROICoordinates{c})

                        roi = handles.ROICoordinates{c}{roiInc};

                        % Since which ROI a point falls in is encoded in binary, decode here
                        whichPointsInROI = fliplr(dec2bin(handles.CellData{c}(:,handles.NDataColumns + 1)));
                        whichPointsInROI = whichPointsInROI(:,roiInc) == '1';

                        dataCropped = handles.CellData{c}(whichPointsInROI, :);

                        if ~isempty(dataCropped)
                            
                            % DBSCANHandler(Data, DBSCANParams, varargin)
                            %         p = varargin{1}; % Labeling only
                            %         q = varargin{2}; % Labeling only
                            %         display1 = varargin{3};
                            %         display2 = varargin{4};
                            %         clusterColor = varargin{5}
                            
                            if(~isCombined)
                                [~, ClusterSmoothTable{roiInc, c}, ~, classOut, ~, ~, ~, Result{roiInc, c}] = ...
                                    DBSCANHandler(dataCropped(dataCropped(:,12) == chan, 5:6), dbscanParams, c, roiInc, ...
                                    true, true, clusterColor, dataCropped(dataCropped(:,12) == chan, handles.NDataColumns + 2));
                                
                                handles.CellData{c}(whichPointsInROI & (handles.CellData{c}(:,12) == chan), handles.NDataColumns + 3) = classOut;
                                
                                handles.CellData{handles.CurrentCellData}(whichPointsInROI, handles.NDataColumns + 9) = 0;
                            
                            else
                                [~, ClusterSmoothTable{roiInc, c}, ~, classOut, ~, ~, ~, Result{roiInc, c}] = ...
                                    DBSCANHandler(dataCropped(:, 5:6), dbscanParams, c, roiInc, ...
                                    true, true, clusterColor, dataCropped(:, handles.NDataColumns + 2));
                                
                                %Check INOUT.md for details
                                handles.CellData{c}(whichPointsInROI, handles.NDataColumns + 9) = classOut;
                            end
                            
                            % Result is stats per ROI
                            % ClusterSmoothTable is stats per cluster
                            cellROIPair = [cellROIPair; c, roiInc, roi(1,1), roi(1,2), polyarea(roi(:,1), roi(:,2))];
                            
                            handles.ClusterTable = AppendToClusterTable(handles.ClusterTable, chan, c, roiInc, ClusterSmoothTable{roiInc, c}, classOut, dataCropped(:,12));

                        else
                            % Have chosen an empty region as ROI
                            
                            fprintf(1, 'Cell %d - ROI %d is empty.  Skipping.\n', c, roiInc);                
                            ClusterSmoothTable{roiInc, c} = [];
                            classOut = [];
                            Result{roiInc, c} = [];
                        end

                    drawnow;
                        
                    end % ROI
                end % Cell

                if ~all(cellfun(@isempty, Result))
                    ExportDBSCANDataToExcelFiles(cellROIPair, Result, strcat(handles.Outputfolder, sprintf('%sDBSCAN Results', filesep)), chan, isCombined);
                else
                    fprintf(1, 'All cells and ROIs empty.  Skipping export.\n');
                end
                
                save(fullfile(handles.Outputfolder, 'DBSCAN Results', dirname, ...
                                    'DBSCAN_Cluster_Result.mat'),'ClusterSmoothTable','Result','-v7.3');
                            
            end % Channel
            
            set(handles.handles.ExportResultsButton, 'enable', 'on');
            guidata(handles.handles.MainFig, handles);
                            
        catch mError
            
            set(handles.handles.MainFig, 'pointer', 'arrow');
            set(get(handles.handles.b_panel, 'children'), 'enable', 'on');
            if handles.Nchannels == 1
                set(handles.handles.hDoC_All1, 'enable', 'off');
            end
            drawnow;
            
            %Disabled because these parameters are not avai here!
            %assignin('base', 'cellROIPair', cellROIPair);
            %assignin('base', 'Result', Result);
            %assignin('base', 'outputFolder', strcat(handles.Outputfolder, sprintf('%sDBSCAN Results', filesep)));
            %assignin('base', 'chan', chan);
            disp('DBSCAN processing exited with errors.');
            UpdateStatusBar(handles, 'DBSCAN processing exited with errors');
            rethrow(mError);
        end
        
    end % returnVal

    set(handles.handles.MainFig, 'pointer', 'arrow');
    set(get(handles.handles.b_panel, 'children'), 'enable', 'on');
	if (handles.Nchannels == 1)
        set(handles.handles.hDoC_All1, 'enable', 'off');
    end
    UpdateStatusBar(handles, 'DBSCAN on ROI completed!');
    drawnow;
    
    guidata(handles.handles.MainFig, handles);

end


function handles = AppendToROITable(handles, ROIData)

    f = ROIData;
    handles = handles;
    
end

% Calculate DoC  for selected data or loaded data
function RunDoC(~, ~, ~)

    handles = guidata(findobj('Tag', 'PALM GUI'));
    set(handles.handles.MainFig, 'pointer', 'watch');
    set(get(handles.handles.b_panel, 'children'), 'enable', 'off');
    UpdateStatusBar(handles, 'Running DoC on ROI...');
    drawnow;
    
    isCombined = handles.ProcessType == handles.CONST.PROCESS_COMBINED;
    
    
    CreateDir(fullfile(handles.Outputfolder, 'Clus-DoC Results'));
    CreateDir(fullfile(handles.Outputfolder, 'Clus-DoC Results', 'DoC histograms'));
    CreateDir(fullfile(handles.Outputfolder, 'Clus-DoC Results', 'DBSCAN Results'));
    if(~isCombined)
        CreateDir(fullfile(handles.Outputfolder, 'Clus-DoC Results', 'DBSCAN Results', 'Ch1'));
        CreateDir(fullfile(handles.Outputfolder, 'Clus-DoC Results', 'DBSCAN Results', 'Ch1', 'Cluster maps'));
        CreateDir(fullfile(handles.Outputfolder, 'Clus-DoC Results', 'DBSCAN Results', 'Ch2'));
        CreateDir(fullfile(handles.Outputfolder, 'Clus-DoC Results', 'DBSCAN Results', 'Ch2', 'Cluster maps'));
    else
        CreateDir(fullfile(handles.Outputfolder, 'Clus-DoC Results', 'DBSCAN Results', 'Combined'));
        CreateDir(fullfile(handles.Outputfolder, 'Clus-DoC Results', 'DBSCAN Results', 'Combined', 'Cluster maps'));
    end
    CreateDir(fullfile(handles.Outputfolder, 'Clus-DoC Results', 'DoC Statistics and Plots'));
    
    % Input parameters for calculating DoC scores for all points
	returnVal = setDoCParameters(handles);
        
    if returnVal == 0
        
        set(handles.handles.MainFig, 'pointer', 'arrow');
        set(get(handles.handles.b_panel, 'children'), 'enable', 'on');
        if handles.Nchannels == 1
            set(handles.handles.hDoC_All1, 'enable', 'off');
        end
        drawnow;
        return;
        
    elseif returnVal == 1
        
        try
            
            handles = guidata(handles.handles.MainFig);
            % Should be only place that DBSCANparams are passed both
            % channels together
            dbscanParams = handles.DBSCAN;
            for i = 1:3
                dbscanParams(i).Outputfolder = handles.Outputfolder;
                dbscanParams(i).ScoreThreshold = handles.DoC.ColoThres;
            end
            
            % cd to DoC_Result
            
            % Input parameters:
            % Lr_rad - radius for Lr thresholding check - 20 default
            % Rmax - max distance for DoC Calc (nm) - 500 default
            % Step - step size for DoC Calc (nm) - 10 default
            % ColoThres - threshold for DoC/notDoC - 0.4 default
            % Nb - Num particles with DoC score above threshold to be a 'colocalised' cluster
            % DBSCAN_Radius=20 - epsilon
            % DBSCAN_Nb_Neighbor=3; - minPts ;
            % threads = 2
            
            UpdateStatusBar(handles, 'Calculating DoC...');
            [handles.CellData, DensityROI] = DoCHandler(handles.ROICoordinates, handles.CellData, ...
                handles.DoC.Lr_rRad, handles.DoC.Rmax, handles.DoC.Step, ...
                handles.Chan1Color, handles.Chan2Color, handles.Outputfolder, handles.NDataColumns);
            
            %%%%%%%%%%%%%%%
            % Plotting, segmentation, and statistics start here
            
            UpdateStatusBar(handles, 'Processing DoC results...');
            ResultTable = ProcessDoCResults(handles.CellData, handles.NDataColumns, handles.ROICoordinates, ...
                DensityROI, fullfile(handles.Outputfolder, 'Clus-DoC Results'), handles.DoC.ColoThres);
            
            
            % Run DBSCAN on data used for DoC analysis
            UpdateStatusBar(handles, 'DBSCAN on DoC results...');
            [ClusterTableCh1, ClusterTableCh2, ClusterTableCombined, clusterIDOut, handles.ClusterTable] = DBSCANonDoCResults(handles.CellData, handles.ROICoordinates, ...
                fullfile(handles.Outputfolder, 'Clus-DoC Results'), handles.Chan1Color, handles.Chan2Color, dbscanParams, handles.NDataColumns, ...
                handles.CombinedColor, isCombined);
            
            UpdateStatusBar(handles, 'Assigning DoC data to points...');
            handles = AssignDoCDataToPoints(handles, clusterIDOut, isCombined);
            
            %
            %                 assignin('base', 'ClusterTableCh1', ClusterTableCh1);
            %                 assignin('base', 'ClusterTableCh2', ClusterTableCh2);
            %                 assignin('base', 'ResultTable', ResultTable);
            
            % ^ Doesn't quite capture all of the stats that
            % EvalStatisticsOnDBSCANandDoCResults.m does in ClusterTable.  Let's see
            % if/when it falls apart
            
            UpdateStatusBar(handles, 'Evaluating statistics on DBSCAN and DoC results...');
            if(~isCombined)
                EvalStatisticsOnDBSCANandDoCResults(ClusterTableCh1, 1, fullfile(handles.Outputfolder, 'Clus-DoC Results'));
                EvalStatisticsOnDBSCANandDoCResults(ClusterTableCh2, 2, fullfile(handles.Outputfolder, 'Clus-DoC Results'));
            else
                EvalStatisticsOnDBSCANandDoCResults(ClusterTableCombined, 3, fullfile(handles.Outputfolder, 'Clus-DoC Results'));
            end
            
            guidata(handles.handles.MainFig, handles);
            
            handles = AppendToROITable(handles, ResultTable);
            set(handles.handles.ExportResultsButton, 'enable', 'on');
            
            
            %
            %%%%%%%%%%%%%%
            
        catch mError
            
            set(handles.handles.MainFig, 'pointer', 'arrow');
            set(get(handles.handles.b_panel, 'children'), 'enable', 'on');
            if handles.Nchannels == 1
                set(handles.handles.hDoC_All1, 'enable', 'off');
            end
            drawnow;
            
            %             assignin('base', 'ClusterTableCh1', ClusterTableCh1);
            %             assignin('base', 'ClusterTableCh2', ClusterTableCh2);
            %             assignin('base', 'clusterIDOut', clusterIDOut);
            
            disp('DoC exited with errors');
            UpdateStatusBar(handles, 'DoC exited with errors');
            rethrow(mError);
            
        end
    end
    
    set(handles.handles.MainFig, 'pointer', 'arrow');
    set(get(handles.handles.b_panel, 'children'), 'enable', 'on');
    if handles.Nchannels == 1
        set(handles.handles.hDoC_All1, 'enable', 'off');
    end
    UpdateStatusBar(handles, 'DoC completed!');
    drawnow;
    
    guidata(handles.handles.MainFig, handles);

end


% Calculate PoC  for selected data or loaded data
function RunPoC(~, ~, ~)
    handles = guidata(findobj('Tag', 'PALM GUI'));
    set(handles.handles.MainFig, 'pointer', 'watch');
    set(get(handles.handles.b_panel, 'children'), 'enable', 'off');
    UpdateStatusBar(handles, 'Running PoC on ROI...');
    drawnow;
    
    isCombined = handles.ProcessType == handles.CONST.PROCESS_COMBINED;
    
    
    CreateDir(fullfile(handles.Outputfolder, 'Clus-PoC Results'));
    CreateDir(fullfile(handles.Outputfolder, 'Clus-PoC Results', 'PoC histograms'));
    CreateDir(fullfile(handles.Outputfolder, 'Clus-PoC Results', 'DBSCAN Results'));
    if(~isCombined)
        CreateDir(fullfile(handles.Outputfolder, 'Clus-PoC Results', 'DBSCAN Results', 'Ch1'));
        CreateDir(fullfile(handles.Outputfolder, 'Clus-PoC Results', 'DBSCAN Results', 'Ch1', 'Cluster maps'));
        CreateDir(fullfile(handles.Outputfolder, 'Clus-PoC Results', 'DBSCAN Results', 'Ch2'));
        CreateDir(fullfile(handles.Outputfolder, 'Clus-PoC Results', 'DBSCAN Results', 'Ch2', 'Cluster maps'));
    else
        CreateDir(fullfile(handles.Outputfolder, 'Clus-PoC Results', 'DBSCAN Results', 'Combined'));
        CreateDir(fullfile(handles.Outputfolder, 'Clus-PoC Results', 'DBSCAN Results', 'Combined', 'Cluster maps'));
    end
    CreateDir(fullfile(handles.Outputfolder, 'Clus-PoC Results', 'PoC Statistics and Plots'));
    
    % Input parameters for calculating DoC scores for all points
	returnVal = setPoCParameters(handles);
        
    if returnVal == 0
        
        set(handles.handles.MainFig, 'pointer', 'arrow');
        set(get(handles.handles.b_panel, 'children'), 'enable', 'on');
        if handles.Nchannels == 1
            set(handles.handles.hDoC_All1, 'enable', 'off');
        end
        drawnow;
        return;
        
    elseif returnVal == 1
        
        try
            
            handles = guidata(handles.handles.MainFig);
            % Should be only place that DBSCANparams are passed both
            % channels together
            dbscanParams = handles.DBSCAN;
            for i = 1:3
                dbscanParams(i).Outputfolder = handles.Outputfolder;
                dbscanParams(i).ScoreThreshold = handles.PoC.ColoThres;
            end
            
            % cd to DoC_Result
            
            % Input parameters:
            % Sigma - std of Gausssian
            % ColoThres - threshold for DoC/notDoC - 0.4 default
            % Nb - Num particles with DoC score above threshold to be a 'colocalised' cluster
            % DBSCAN_Radius=20 - epsilon
            % DBSCAN_Nb_Neighbor=3; - minPts ;
            % threads = 2
            
            UpdateStatusBar(handles, 'Calculating PoC...');
            [handles.CellData, DensityROI] = PoCHandler(handles.ROICoordinates, handles.CellData, ...
                handles.PoC.FuncType, handles.PoC.Lr_rRad, handles.PoC.Sigma, handles.Chan1Color, handles.Chan2Color, handles.Outputfolder, handles.NDataColumns);
            
            %%%%%%%%%%%%%%%
            % Plotting, segmentation, and statistics start here
            UpdateStatusBar(handles, 'Processing PoC results...');
            ResultTable = ProcessPoCResults(handles.CellData, handles.NDataColumns, handles.ROICoordinates, ...
                DensityROI, fullfile(handles.Outputfolder, 'Clus-PoC Results'), handles.PoC.ColoThres);
            
            % Run DBSCAN on data used for DoC analysis
            UpdateStatusBar(handles, 'DBSCAN on PoC results...');
            [ClusterTableCh1, ClusterTableCh2, ClusterTableCombined, clusterIDOut, handles.ClusterTable] = DBSCANonPoCResults(handles.CellData, handles.ROICoordinates, ...
                fullfile(handles.Outputfolder, 'Clus-PoC Results'), handles.Chan1Color, handles.Chan2Color, dbscanParams, handles.NDataColumns, ...
                handles.CombinedColor, isCombined);
            
            UpdateStatusBar(handles, 'Assigning PoC data to points...');
            handles = AssignPoCDataToPoints(handles, clusterIDOut, isCombined);
            
            UpdateStatusBar(handles, 'Evaluating statistics on DBSCAN and PoC results...');
            if(~isCombined)
                EvalStatisticsOnDBSCANandPoCResults(ClusterTableCh1, 1, fullfile(handles.Outputfolder, 'Clus-PoC Results'));
                EvalStatisticsOnDBSCANandPoCResults(ClusterTableCh2, 2, fullfile(handles.Outputfolder, 'Clus-PoC Results'));
            else
                EvalStatisticsOnDBSCANandDoCResults(ClusterTableCombined, 3, fullfile(handles.Outputfolder, 'Clus-PoC Results'));
            end
            
            guidata(handles.handles.MainFig, handles);
            
            handles = AppendToROITable(handles, ResultTable);
            set(handles.handles.ExportResultsButton, 'enable', 'on');
            
            %}
            %
            %%%%%%%%%%%%%%
            
        catch mError
            
            set(handles.handles.MainFig, 'pointer', 'arrow');
            set(get(handles.handles.b_panel, 'children'), 'enable', 'on');
            if handles.Nchannels == 1
                set(handles.handles.hDoC_All1, 'enable', 'off');
            end
            drawnow;
            
            %             assignin('base', 'ClusterTableCh1', ClusterTableCh1);
            %             assignin('base', 'ClusterTableCh2', ClusterTableCh2);
            %             assignin('base', 'clusterIDOut', clusterIDOut);
            
            disp('PoC exited with errors');
            UpdateStatusBar(handles, 'PoC exited with errors');
            rethrow(mError);
            
        end
    end
    
    set(handles.handles.MainFig, 'pointer', 'arrow');
    set(get(handles.handles.b_panel, 'children'), 'enable', 'on');
    if handles.Nchannels == 1
        set(handles.handles.hDoC_All1, 'enable', 'off');
    end
    UpdateStatusBar(handles, 'PoC completed!');
    drawnow;
    
    guidata(handles.handles.MainFig, handles);
end


function handles = AssignDoCDataToPoints(handles, clusterIDOut, isCombined)

% disp('clusterIDAssign');

    % Assignments handled in DoC Handler
    % dataOut(:,1) = X - X position
    % dataOut(:,2) = Y - Y position
    % dataOut(:,3) = Lr - Lr value at radius r
    % dataOut(:,4) = Ch - Channel
    % dataOut(:,5) = Density - relative density, number of points inside RipleyK filter radius, ALL CHANNELS
    % dataOut(:,6) = DoC - Cross-channel Degree of colocalization
    % dataOut(:,7) = D1_D2 - num points inside RipleyK filter radius, SAME CHANNEL
    % dataOut(:,8) = Lr_r above threshold and carried forward in calculations

    for k = 1:length(handles.CellData)
        for m = 1:length(handles.ROICoordinates{k})
            
            % Since which ROI a point falls in is encoded in binary, decode here
            whichPointsInROI = fliplr(dec2bin(handles.CellData{k}(:, handles.NDataColumns + 1)));
            whichPointsInROI = whichPointsInROI(:, m) == '1';
            
            % Assign cluster IDs to the proper points in CellData
            if(~isCombined)
                handles.CellData{k}(whichPointsInROI & (handles.CellData{k}(:,12) == 1), handles.NDataColumns + 3) = clusterIDOut{m, k, 1};
                handles.CellData{k}(whichPointsInROI & (handles.CellData{k}(:,12) == 2), handles.NDataColumns + 3) = clusterIDOut{m, k, 2};
                handles.CellData{k}(whichPointsInROI, handles.NDataColumns + 9) = 0;
            else
                handles.CellData{k}(whichPointsInROI, handles.NDataColumns + 9) = clusterIDOut{m, k, 3};
            end

        end
    end

end

function handles = AssignPoCDataToPoints(handles, clusterIDOut, isCombined)

    handles = AssignDoCDataToPoints(handles, clusterIDOut, isCombined);

end


function ExportToTextPush(varargin)

    handles = guidata(findobj('tag', 'PALM GUI'));
    
    try
        set(get(handles.handles.b_panel, 'children'), 'enable', 'off')
        set(handles.handles.MainFig, 'pointer', 'watch');

        w = waitbar(0, 'Export Data to txt files');

        for fN = 1:length(handles.CellData)

            waitbar(fN/(length(handles.CellData) + 1), w);

            fileName = strcat(handles.ImportFiles{fN}(1:(end-4)), '_ExportByPoint.txt');
            UpdateStatusBar(handles, 'Exporting _ExportByPoint.txt file...');
            fprintf(1, 'Writing to file %s\n', fileName);

            fID = fopen(fileName, 'w+');

            if handles.NDataColumns == 13
                headerString = sprintf('Index\tFirstFrame\tNumFrames\tNFramesMissing\tPostX[nm]\tPostY[nm]\tPrecision[nm]\tNPhotons\tBkgdVar\tChi^2\tPSFWidth[nm]\tChannel\tZSlice\tROINum\tInOutMask\tClusterID\tDoCScore\tLrValue\tCrossChanDensity\tLrAboveThreshold\tAllChanDensity\tCombinedClusterID\tPoCScore\r\n');
                fmtStr = strcat(repmat('%d\t', 1, 4), repmat('%.1f\t', 1, 3), '%d\t%.4f\t%.4f\t%.1f\t%d\t%d\t%s\t%d\t%d\t%.4f\t%.4f\t%.4f\t%d\t%.4f\t%d\t%.4f\r\n');
            elseif handles.NDataColumns == 12
                headerString = sprintf('Index\tFirstFrame\tNumFrames\tNFramesMissing\tPostX[nm]\tPostY[nm]\tPrecision[nm]\tNPhotons\tBkgdVar\tChi^2\tPSFWidth[nm]\tChannel\tROINum\tInOutMask\tClusterID\tDoCScore\tLrValue\tCrossChanDensity\tLrAboveThreshold\tAllChanDensity\tCombinedClusterID\tPoCScore\r\n');
                fmtStr = strcat(repmat('%d\t', 1, 4), repmat('%.1f\t', 1, 3), '%d\t%.4f\t%.4f\t%.1f\t%d\t%s\t%d\t%d\t%.4f\t%.4f\t%.4f\t%d\t%.4f\t%d\t%.4f\r\n');
            else
                error('Number of data columns not supported');
            end
            
            fprintf(fID, '%s', headerString);

            
            ROIIDStr = dec2bin(handles.CellData{fN}(:,14));
            exportInRoi = get(handles.handles.ExportResultsCheckbox, 'Value');
            if(exportInRoi == 0)
                for k = 1:size(handles.CellData{fN}, 1)
                    fprintf(fID, fmtStr, handles.CellData{fN}(k,1:handles.NDataColumns), ROIIDStr(k, :), ...
                        handles.CellData{fN}(k, (handles.NDataColumns + 2):end));

                end
            else
                % Since which ROI a point falls in is encoded in binary, decode here
                whichPointsInROI = fliplr(dec2bin(handles.CellData{handles.CurrentCellData}(:,handles.NDataColumns + 1)));
                whichPointsInROI = whichPointsInROI(:,handles.CurrentROIData) == '1';
                dataCropped = handles.CellData{handles.CurrentCellData}(whichPointsInROI, :);
                for k = 1:size(dataCropped, 1)
                    fprintf(fID, fmtStr, dataCropped(k,1:handles.NDataColumns), ROIIDStr(k, :), ...
                        dataCropped(k, (handles.NDataColumns + 2):end));
                end 
            end

            fprintf(fID, '\r\n');
            fprintf(fID, '\r\n');
            % 
            % Footer contains info on data processing parameters
            fprintf(fID, '# SourceFile: %s\r\n', handles.ImportFiles{fN});
            fprintf(fID, '# CoordinatesFile: %s\r\n', handles.CoordFile);
            fprintf(fID, '# NROIs: %d\r\n', length(handles.ROICoordinates{fN}));

            if  handles.MaskCellPair(fN, 2) > 0
                fprintf(fID, '# MaskFile: %d\r\n', fullfile(handles.Path_name, handles.MaskFiles{handles.MaskCellPair(fN, 2)}));
            else
                fprintf(fID, '# MaskFile: %s\r\n', 'NoMask');
            end

            fprintf(fID, '# DBSCANEpsilon: %.3f\r\n', handles.DBSCAN.epsilon);
            fprintf(fID, '# DBSCANminPts: %d\r\n', handles.DBSCAN.minPts);
            fprintf(fID, '# DBSCANUseLr_Thresh: %d\r\n', handles.DBSCAN.UseLr_rThresh);
            fprintf(fID, '# DBSCANLr_rThreshRad: %.2f\r\n', handles.DBSCAN.Lr_rThreshRad);
            fprintf(fID, '# DBSCANSmoothingRad: %.2f\r\n', handles.DBSCAN.SmoothingRad);
            fprintf(fID, '# DBSCANCutoff: %.2f\r\n', handles.DBSCAN.Cutoff);
            fprintf(fID, '# DBSCANthreads: %d\r\n', handles.DBSCAN.threads);
            fprintf(fID, '# DoCLr_rRad: %.2f\r\n', handles.DoC.Lr_rRad);
            fprintf(fID, '# DoCRmax: %d\r\n', handles.DoC.Rmax);
            fprintf(fID, '# DoCStep: %d\r\n', handles.DoC.Step);
            fprintf(fID, '# DoCColocalizationThreshold: %.4f\r\n', handles.DoC.ColoThres);
            fprintf(fID, '# DoCMinColocPoints: %.4f\r\n', handles.DoC.NbThresh);
            fprintf(fID, '\r\n');

            fclose(fID);
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % ClusterwiseData
        % Print to txt file
        
        fileName = strcat(handles.ImportFiles{fN}(1:(end-4)), '_ClusterExport.txt');
        UpdateStatusBar(handles, 'Exporting _ClusterExport.txt file...');
        fprintf(1, 'Writing to file %s\n', fileName);
        fID = fopen(fileName, 'w+');
        fprintf(fID, 'CellNum\tROINum\tChannel\tClusterID\tNPoints\tNb\tMeanScore\tArea\tCircularity\tTotalAreaDensity\tAvRelativeDensity\tMeanDensity\tNb_In\tNInMask\tNOutMask\tNChan1Points\tNChan2Points\r\n');

        fmtStr = strcat(repmat('%d\t', 1, 6), repmat('%.4f\t', 1, 6), '%d\t%d\t%d\t%d\t%d\r\n');
        for k = 1:size(handles.ClusterTable, 1)

            fprintf(fID, fmtStr, handles.ClusterTable(k,:));

        end

        fprintf(fID, '\r\n');
        fprintf(fID, '\r\n');
        %
        % Footer contains info on data processing parameters
        for k = 1:length(handles.ImportFiles)
            fprintf(fID, '# SourceFiles: %d. %s\r\n', k, handles.ImportFiles{fN});
        end
        fprintf(fID, '# CoordinatesFile: %s\r\n', handles.CoordFile);
        fprintf(fID, '# NROIs: %d\r\n', length(handles.ROICoordinates{fN}));

        if  handles.MaskCellPair(fN, 2) > 0
            fprintf(fID, '# MaskFile: %s\r\n', fullfile(handles.Path_name, handles.MaskFiles{handles.MaskCellPair(fN, 2) + 1}));
        else
            fprintf(fID, '# MaskFile: %s\r\n', 'NoMask');
        end

        fprintf(fID, '# DBSCANEpsilon: %.3f\r\n', handles.DBSCAN.epsilon);
        fprintf(fID, '# DBSCANminPts: %d\r\n', handles.DBSCAN.minPts);
        fprintf(fID, '# DBSCANUseLr_Thresh: %d\r\n', handles.DBSCAN.UseLr_rThresh);
        fprintf(fID, '# DBSCANLr_rThreshRad: %.2f\r\n', handles.DBSCAN.Lr_rThreshRad);
        fprintf(fID, '# DBSCANSmoothingRad: %.2f\r\n', handles.DBSCAN.SmoothingRad);
        fprintf(fID, '# DBSCANCutoff: %.2f\r\n', handles.DBSCAN.Cutoff);
        fprintf(fID, '# DBSCANthreads: %d\r\n', handles.DBSCAN.threads);
        fprintf(fID, '# DoCLr_rRad: %.2f\r\n', handles.DoC.Lr_rRad);
        fprintf(fID, '# DoCRmax: %d\r\n', handles.DoC.Rmax);
        fprintf(fID, '# DoCStep: %d\r\n', handles.DoC.Step);
        fprintf(fID, '# DoCColocalizationThreshold: %.4f\r\n', handles.DoC.ColoThres);
        fprintf(fID, '# DoCMinColocPoints: %.4f\r\n', handles.DoC.NbThresh);
        fprintf(fID, '\r\n');

        fclose(fID);


        waitbar(1, w);
        close(w);
        
        set(get(handles.handles.b_panel, 'children'), 'enable', 'on')
        set(handles.handles.MainFig, 'pointer', 'arrow');
        
        UpdateStatusBar(handles, 'Exporting to txt files completed!');
        
    catch mError
        set(get(handles.handles.b_panel, 'children'), 'enable', 'on');
        if handles.Nchannels == 1
            set(handles.handles.hDoC_All1, 'enable', 'off');
        end
        set(handles.handles.MainFig, 'pointer', 'arrow');
        rethrow(mError)
        UpdateStatusBar(handles, 'Exporting to txt failed with errors');
    end

end

function clusterTableOut = AppendToClusterTable(clusterTable, Ch, cellIter, roiIter, ClusterCh, classOut, channel)

    try 
        if isempty(clusterTable)
            oldROIRows = [];
        else
            oldROIRows = (cellIter == clusterTable(:,1)) & (roiIter == clusterTable(:,2)) & (Ch == clusterTable(:,3));
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
        appendTable = nan(length(ClusterCh), 15);
        appendTable(:, 1) = cellIter; % CurrentROI
        appendTable(:, 2) = roiIter; % CurrentROI
        appendTable(:, 3) = Ch; % Channel

        appendTable(:, 4) = cellfun(@(x) x.ClusterID, ClusterCh); % ClusterID
        appendTable(:, 5) = cell2mat(cellfun(@(x) size(x.Points, 1), ClusterCh, 'uniformoutput', false)); % NPoints
        appendTable(:, 6) = cellfun(@(x) x.Nb, ClusterCh); % Nb

        if ~isempty(ClusterCh)
            
            if isfield(ClusterCh{1}, 'MeanDoC')
                appendTable(:, 7) = cellfun(@(x) x.MeanDoC, ClusterCh); % MeanDoCScore
            end
            
            if isfield(ClusterCh{1}, 'AvRelativeDensity')
                appendTable(:, 11) = cellfun(@(x) x.AvRelativeDensity, ClusterCh); % AvRelativeDensity
                appendTable(:, 12) = cellfun(@(x) x.Mean_Density, ClusterCh); % MeanDensity
            end
            
            if isfield(ClusterCh{1}, 'Nb_In')
                appendTable(:, 13) = cellfun(@(x) x.Nb_In, ClusterCh); % Nb_In
            end
            
        end

        appendTable(:, 8) = cellfun(@(x) x.Area, ClusterCh); % Area
        appendTable(:, 9) = cellfun(@(x) x.Circularity, ClusterCh); % Circularity
        appendTable(:, 10) = cellfun(@(x) x.TotalAreaDensity, ClusterCh); % TotalAreaDensity
        
        appendTable(:, 14) = cellfun(@(x) x.NInsideMask, ClusterCh); % NPointsInsideMask
        appendTable(:, 15) = cellfun(@(x) x.NOutsideMask, ClusterCh); % NPointsInsideMask
        
        appendTable(:, 16) = cellfun(@(x) x.NChan1Points, ClusterCh); % NChan1Points
        appendTable(:, 17) = cellfun(@(x) x.NChan2Points, ClusterCh); % NChan2Points

        clusterTableOut = [clusterTable; appendTable];
    
    catch mError
        assignin('base', 'ClusterCh', ClusterCh);
%         assignin('base', 'clusterIDList', clusterIDList);
        assignin('base', 'appendTable', appendTable);
        assignin('base', 'classOut', classOut);

        rethrow(mError);

    end
    
end


function ResultsExplorerPush(varargin)

    handles = guidata(findobj('Tag', 'PALM GUI'));
    
    LaunchResultsExplorer(handles);
    
    guidata(handles.handles.MainFig, handles);

end


% Reset the handles and the graph the starting point... Ready to go!
function Reset(~,~,~)

    handles = guidata(findobj('Tag', 'PALM GUI'));

    set(handles.handles.popupROI2,'String', {'ROI'},'Value',1);
    set(handles.handles.popupCell2,'String',{'Cell'},'Value',1);

    guidata(findobj('Tag', 'PALM GUI'), handles);

    DoCGUIInitialize();

end

function CloseGUIFunction(varargin)

    delete(findobj('Tag', 'ClusDoC'));
    delete(findobj('Tag', 'PALM GUI'));
    
end


