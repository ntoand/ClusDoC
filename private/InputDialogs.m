function [handles, returnVal] = InputDialogs(handles, name, varargin)

    % for quick debug
    %{
    close all
    clear
    
    handles.CONST.DEFAULT_ROI_SIZE = 4000;
    handles.CONST.PROCESS_SEPARATE = 1;
    handles.CONST.PROCESS_COMBINED = 2;
    handles.CONST.PROCESS_BOTH = 3;
    handles.CONST.POC_TYPE1 = 1;    % poc = sumA / sumB
    handles.CONST.POC_TYPE2 = 2;    % poc = sumA / (sumA + sumB)

    handles.Nchannels = 2;

    handles.ProcessType = handles.CONST.PROCESS_SEPARATE;
    for k = 1:10
        handles.DBSCAN(k).Epsilon = 20;
        handles.DBSCAN(k).MinPts = 3;
        handles.DBSCAN(k).UseLr_rThresh = true;
        handles.DBSCAN(k).Lr_rThreshRad = 20;
        handles.DBSCAN(k).Cutoff = 10;
        handles.DBSCAN(k).Threads = 2;
        handles.DBSCAN(k).DoStats = true;
        % plot
        handles.DBSCAN(k).ColorForClusters = false;
        handles.DBSCAN(k).ContourMethod = 1; % 1: smoothing, 2: alphaShape
        handles.DBSCAN(k).SmoothingRad = 15;
    end
    
    % Default RipleyK settings
    handles.RipleyK.Start = 0;
    handles.RipleyK.End = 1000;
    handles.RipleyK.Step = 10;
    handles.RipleyK.MaxSampledPts = 1e4;
    
    % Default DoC parameters
    handles.DoC.TCR = 1;
    handles.DoC.Signal = 2;
    handles.DoC.Lr_rRad = 20;
    handles.DoC.Rmax = 500;
    handles.DoC.Step = 10;
    handles.DoC.ColoThres = 0.4;
    handles.DoC.NbThresh = 10;
    
    % Default PoC parameters
    handles.PoC.TCR = 1;
    handles.PoC.Signal = 2;
    handles.PoC.FuncType = handles.CONST.POC_TYPE1;
    handles.PoC.Lr_rRad = 20;
    handles.PoC.Sigma = 100;
    handles.PoC.ColoThres = 0.4;
    handles.PoC.NbThresh = 10;
    
    handles.DBSCAN_channels = {'Ch1', 'Ch2', 'Ch3'};
    
    [handles, ~] = setPoCParameters(handles);
    %}
    % end for quick debug
    
    
    if strcmp(name, 'ripley')
        [handles, returnVal] = setRipleyParameters(handles);
    elseif strcmp(name, 'dbscan')
        [handles, returnVal] = setDBSCANParameters(handles, varargin{1});
    elseif strcmp(name, 'doc')
        [handles, returnVal] = setDoCParameters(handles);
    elseif strcmp(name, 'poc')
        [handles, returnVal] = setPoCParameters(handles);
    elseif strcmp(name, 'settings')
        [handles, returnVal] = setSettings(handles);
    end
 
    
    
    % RIPLEY parameters
    function [handles, returnVal] = setRipleyParameters(handles)
        handles.handles.RipleyKSettingsFig = figure();
        set(handles.handles.RipleyKSettingsFig, 'Tag', 'RipleyKSettingsFig');
        resizeFig(handles.handles.RipleyKSettingsFig, [220 180]);
        set(handles.handles.RipleyKSettingsFig, 'toolbar', 'none', 'menubar', 'none', ...
            'name', 'Ripley K Parameters');

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
            returnVal = 0;
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

            returnVal = 1;
            uiresume;
            delete(handles.handles.RipleyKSettingsFig);

        end
        
    end % RIPLEY
        


    % Pop-up window to set DBSCAN parameters
    function [handles, returnVal] = setDBSCANParameters(handles, withstats)

        handles.handles.DBSCANSettingsFig = figure();
        set(handles.handles.DBSCANSettingsFig, 'Tag', 'DBSCANSettingsFig');
        WIDTH = 260;
        HEIGHT = 340;
        HSPACE = 25;
        currChan = 1;
        
        resizeFig(handles.handles.DBSCANSettingsFig, [WIDTH HEIGHT]);
        set(handles.handles.DBSCANSettingsFig, 'toolbar', 'none', 'menubar', 'none', ...
            'name', 'DBSCAN Parameters');

        
        str = 'DBSCAN Parameters for channels';
        if (handles.ProcessType == handles.CONST.PROCESS_COMBINED)
            str = 'DBSCAN Parameters for combined pairs';
        elseif (handles.ProcessType == handles.CONST.PROCESS_BOTH)
            str = 'DBSCAN Parameters for both (channels + pairs)';
        end
        
        ypos = HEIGHT - HSPACE;
        handles.handles.DBSCANSettingsTitleText(1) = uicontrol('Style', 'text', ...
            'String', str, 'parent', handles.handles.DBSCANSettingsFig,...
            'Position', [0 ypos 250 20], 'horizontalalignment', 'center', 'Fontsize', 10);

        %%%%%%
        ypos = ypos - 40;
        handles.handles.DBSCANChannelsPopup = uicontrol('Style', 'popup', 'String', handles.DBSCAN_channels,...
            'Position', [20 ypos WIDTH-40 20],'Callback', @changeDBSCANChannel);

        %%%%%%
        ypos = ypos - 35;
        handles.handles.DBSCANSettingsText(1) = uicontrol('Style', 'text', ...
            'String', 'Epsilon (nm):', 'parent', handles.handles.DBSCANSettingsFig,...
            'Position', [0 ypos 120 20], 'horizontalalignment', 'right');
        
        handles.handles.DBSCANSettingsEdit(1) = uicontrol('Style', 'edit', ...
            'String', num2str(handles.DBSCAN(currChan).Epsilon), 'parent', handles.handles.DBSCANSettingsFig,...
            'Position', [125 ypos 60 20]);

        ypos = ypos - HSPACE;
        handles.handles.DBSCANSettingsText(2) = uicontrol('Style', 'text', ...
            'String', 'minPts:', 'parent', handles.handles.DBSCANSettingsFig,...
            'Position', [0 ypos 120 20], 'horizontalalignment', 'right');
        
        handles.handles.DBSCANSettingsEdit(2) = uicontrol('Style', 'edit', ...
            'String', num2str(handles.DBSCAN(currChan).MinPts), 'parent', handles.handles.DBSCANSettingsFig,...
            'Position', [125 ypos 60 20]);

        ypos = ypos - HSPACE;
        handles.handles.DBSCANSettingsText(3) = uicontrol('Style', 'text', ...
            'String', 'Plot Cutoff:', 'parent', handles.handles.DBSCANSettingsFig,...
            'Position', [0 ypos 120 20], 'horizontalalignment', 'right');
        
        handles.handles.DBSCANSettingsEdit(3) = uicontrol('Style', 'edit', ...
            'String', num2str(handles.DBSCAN(currChan).Cutoff), 'parent', handles.handles.DBSCANSettingsFig,...
            'Position', [125 ypos 60 20]);

        ypos = ypos - HSPACE;
        handles.handles.DBSCANSettingsText(4) = uicontrol('Style', 'text', ...
            'String', 'Processing Threads:', 'parent', handles.handles.DBSCANSettingsFig,...
            'Position', [0 ypos 120 20], 'horizontalalignment', 'right');
        
        handles.handles.DBSCANSettingsEdit(4) = uicontrol('Style', 'edit', ...
            'String', num2str(handles.DBSCAN(currChan).Threads), 'parent', handles.handles.DBSCANSettingsFig,...
            'Position', [125 ypos 60 20]);

        ypos = ypos - HSPACE;
        handles.handles.DBSCANSettingsText(5) = uicontrol('Style', 'text', ...
            'String', 'L(r) - r Radius (nm):', 'parent', handles.handles.DBSCANSettingsFig,...
            'Position', [0 ypos 120 20], 'horizontalalignment', 'right');
        
        handles.handles.DBSCANSettingsEdit(5) = uicontrol('Style', 'edit', ...
            'String', num2str(handles.DBSCAN(currChan).Lr_rThreshRad), 'parent', handles.handles.DBSCANSettingsFig,...
            'Position', [125 ypos 60 20]);

        handles.handles.DBSCANSettingsText(6) = uicontrol('Style', 'text', ...
            'String', 'Use', 'parent', handles.handles.DBSCANSettingsFig,...
            'Position', [190 ypos 30 20], 'horizontalalignment', 'right');
        
        handles.handles.DBSCANSetToggle = uicontrol('Style', 'checkbox', ...
            'Value', handles.DBSCAN(currChan).UseLr_rThresh, 'position', [225 ypos 20 20], ...
            'callback', @DBSCANUseThreshold);

        ypos = ypos - HSPACE;
        handles.handles.DBSCANSettingsText(8) = uicontrol('Style', 'text', ...
            'String', 'Calc Stats:', 'parent', handles.handles.DBSCANSettingsFig,...
            'Position', [0 ypos 120 20], 'horizontalalignment', 'right');
        
        handles.handles.DBSCANDoStatsToggle = uicontrol('Style', 'checkbox', ...
            'Value', handles.DBSCAN(currChan).DoStats, 'position', [125 ypos 20 20]);
        
        % plot options
        ypos = ypos - HSPACE;
        handles.handles.DBSCANSettingsText(7) = uicontrol('Style', 'text', ...
            'String', 'Color clusters', 'parent', handles.handles.DBSCANSettingsFig,...
            'Position', [0 ypos 120 20], 'horizontalalignment', 'right');
        
        handles.handles.DBSCANColorClustersToggle = uicontrol('Style', 'checkbox', ...
            'Value', handles.DBSCAN(currChan).ColorForClusters, 'position', [125 ypos 20 20]);
        
        ypos = ypos - HSPACE;
        handles.handles.DBSCANSettingsText(8) = uicontrol('Style', 'text', ...
            'String', 'Contour method', 'parent', handles.handles.DBSCANSettingsFig,...
            'Position', [0 ypos 120 20], 'horizontalalignment', 'right');
        
        handles.handles.DBSCANContourPopup = uicontrol('Style', 'popup', 'String', {'Smoothing', 'Alpha shape'},...
            'Position', [120 ypos WIDTH-130 20],'Callback', @popupContourCallback);
        
        ypos = ypos - HSPACE;
        handles.handles.DBSCANSettingsText(9) = uicontrol('Style', 'text', ...
            'String', 'Smooth Radius (nm):', 'parent', handles.handles.DBSCANSettingsFig,...
            'Position', [0 ypos 120 20], 'horizontalalignment', 'right');
        
        handles.handles.DBSCANSettingsEdit(6) = uicontrol('Style', 'edit', ...
            'String', num2str(handles.DBSCAN(currChan).SmoothingRad), 'parent', handles.handles.DBSCANSettingsFig,...
            'Position', [125 ypos 60 20]);
           
        % event
        set(handles.handles.DBSCANSettingsEdit, 'Callback', @DBSCANCheckEditBox);

        if(withstats) % avoid changing the settings by users
            set(handles.handles.DBSCANSetToggle, 'Enable', 'off');
            set(handles.handles.DBSCANDoStatsToggle, 'Enable', 'off');
        end
        
        if(handles.DBSCAN(currChan).ContourMethod == 2)
            set(handles.handles.DBSCANContourPopup, 'Value', handles.DBSCAN(currChan).ContourMethod);
            set(handles.handles.DBSCANSettingsEdit(6), 'enable', 'off');
        end


        handles.handles.DBSCANSettingsButton = uicontrol('Style', 'pushbutton', ...
            'String', 'Continue', 'parent', handles.handles.DBSCANSettingsFig, ...
            'Position', [165 2 85 30], 'Callback', @DBSCANSetAndContinue);

        set(handles.handles.DBSCANSettingsFig, 'CloseRequestFcn', @DBSCANCloseOutWindow);

        DBSCANUseThreshold();

        uiwait;

        function popupContourCallback(hobj, ~)
            val = get(hobj, 'Value');
            if(val == 1)
                set(handles.handles.DBSCANSettingsEdit(6), 'Enable', 'on');
            else
                set(handles.handles.DBSCANSettingsEdit(6), 'Enable', 'off');
            end
        end
        
        function DBSCANCloseOutWindow(varargin)
            % Cancel, don't execute further
            returnVal = 0;
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

            oldCh = currChan;
            currChan = varargin{2}.Source.Value;

            handles.DBSCAN(oldCh).Epsilon = str2double(get(handles.handles.DBSCANSettingsEdit(1),'string'));
            handles.DBSCAN(oldCh).MinPts = str2double(get(handles.handles.DBSCANSettingsEdit(2),'string'));
            handles.DBSCAN(oldCh).Cutoff = str2double(get(handles.handles.DBSCANSettingsEdit(3),'string'));
            handles.DBSCAN(oldCh).Threads = str2double(get(handles.handles.DBSCANSettingsEdit(4),'string'));
            handles.DBSCAN(oldCh).Lr_rThreshRad = str2double(get(handles.handles.DBSCANSettingsEdit(5),'string'));
            handles.DBSCAN(oldCh).SmoothingRad = str2double(get(handles.handles.DBSCANSettingsEdit(6),'string'));
            handles.DBSCAN(oldCh).UseLr_rThresh = (get(handles.handles.DBSCANSetToggle, 'value')) == get(handles.handles.DBSCANSetToggle, 'Max');
            handles.DBSCAN(oldCh).DoStats = (get(handles.handles.DBSCANDoStatsToggle, 'value')) == get(handles.handles.DBSCANDoStatsToggle, 'Max');
            handles.DBSCAN(oldCh).ColorForClusters = get(handles.handles.DBSCANColorClustersToggle, 'value') == 1;
            handles.DBSCAN(oldCh).ContourMethod = get(handles.handles.DBSCANContourPopup, 'value');

            %disp(handles.DBSCAN(oldCh));

            set(handles.handles.DBSCANSettingsEdit(1), 'String', num2str(handles.DBSCAN(currChan).Epsilon));
            set(handles.handles.DBSCANSettingsEdit(2), 'String', num2str(handles.DBSCAN(currChan).MinPts));
            set(handles.handles.DBSCANSettingsEdit(3), 'String', num2str(handles.DBSCAN(currChan).Cutoff));
            set(handles.handles.DBSCANSettingsEdit(4), 'String', num2str(handles.DBSCAN(currChan).Threads));
            set(handles.handles.DBSCANSettingsEdit(5), 'String', num2str(handles.DBSCAN(currChan).Lr_rThreshRad));
            set(handles.handles.DBSCANSettingsEdit(6), 'String', num2str(handles.DBSCAN(currChan).SmoothingRad));       
            set(handles.handles.DBSCANSetToggle, 'Value', handles.DBSCAN(currChan).UseLr_rThresh);
            set(handles.handles.DBSCANDoStatsToggle, 'Value', handles.DBSCAN(currChan).DoStats);
            set(handles.handles.DBSCANColorClustersToggle, 'Value', handles.DBSCAN(currChan).ColorForClusters);
            set(handles.handles.DBSCANContourPopup, 'Value', handles.DBSCAN(currChan).ContourMethod);
            
            if(get(handles.handles.DBSCANContourPopup, 'Value') == 1)
                set(handles.handles.DBSCANSettingsEdit(6), 'enable', 'on');
            else
                set(handles.handles.DBSCANSettingsEdit(6), 'enable', 'off');
            end
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
            handles.DBSCAN(currChan).Epsilon = str2double(get(handles.handles.DBSCANSettingsEdit(1),'string'));
            handles.DBSCAN(currChan).MinPts = str2double(get(handles.handles.DBSCANSettingsEdit(2),'string'));
            handles.DBSCAN(currChan).Cutoff = str2double(get(handles.handles.DBSCANSettingsEdit(3),'string'));
            handles.DBSCAN(currChan).Threads = str2double(get(handles.handles.DBSCANSettingsEdit(4),'string'));
            handles.DBSCAN(currChan).Lr_rThreshRad = str2double(get(handles.handles.DBSCANSettingsEdit(5),'string'));
            handles.DBSCAN(currChan).SmoothingRad = str2double(get(handles.handles.DBSCANSettingsEdit(6),'string'));
            handles.DBSCAN(currChan).UseLr_rThresh = (get(handles.handles.DBSCANSetToggle, 'value')) == get(handles.handles.DBSCANSetToggle, 'Max');
            handles.DBSCAN(currChan).DoStats = (get(handles.handles.DBSCANDoStatsToggle, 'value')) == get(handles.handles.DBSCANDoStatsToggle, 'Max');
            handles.DBSCAN(currChan).ColorForClusters = get(handles.handles.DBSCANColorClustersToggle, 'value') == 1;
            handles.DBSCAN(currChan).ContourMethod = get(handles.handles.DBSCANContourPopup, 'value');

            returnVal = 1;
            uiresume;
            delete(handles.handles.DBSCANSettingsFig);
        end    
    end % DBSCAN


    % Pop-up window to set DoC parameters
    function [handles, returnValue] = setDoCParameters(handles)

        isCombined = handles.ProcessType == handles.CONST.PROCESS_COMBINED;

        handles.handles.DoCSettingsFig = figure();
        set(handles.handles.DoCSettingsFig, 'Tag', 'DoCSettingsFig');
        
        WIDTH = 510;
        HEIGHT = 340;
        HSPACE1 = 35;
        HSPACE2 = 25;
        
        resizeFig(handles.handles.DoCSettingsFig, [WIDTH HEIGHT]);
        set(handles.handles.DoCSettingsFig, 'toolbar', 'figure', 'menubar', 'none', ...
            'name', 'DoC Parameters');

        ch = 1;
        if(isCombined)
            ch = 3;
        end

        ypos = HEIGHT - 40;
        handles.handles.DoCSettingsTitleText(1) = uicontrol('Style', 'text', ...
            'String', 'Degree of Colocalization Parameters', 'parent', handles.handles.DoCSettingsFig,...
            'Position', [0 ypos 200 35], 'horizontalalignment', 'center', 'Fontsize', 10);
        
        ypos = ypos - 5;
        handles.handles.DoCSettingsTitleText(2) = uicontrol('Style', 'text', ...
            'String', '_____________________', 'parent', handles.handles.DoCSettingsFig,...
            'Position', [0 ypos 200 20], 'horizontalalignment', 'center', 'Fontsize', 10);
        %%%%%%
        
        channels = cell(handles.Nchannels, 1);
        for ii = 1:handles.Nchannels
            channels{ii, 1} = sprintf('Ch%d', ii);
        end
        
        ypos = ypos - HSPACE1;
        handles.handles.DoCSettingsTextTCR = uicontrol('Style', 'text', ...
            'String', 'TCR:', 'parent', handles.handles.DoCSettingsFig,...
            'Position', [0 ypos 100 20], 'horizontalalignment', 'right');
        
        handles.handles.DoCTCRPopup = uicontrol('Style', 'popup', 'String', channels,...
            'Position', [120 ypos 80 20],'Callback', @popupTCRCallback, 'value', handles.DoC.TCR);
        
        ypos = ypos - HSPACE1;
        handles.handles.DoCSettingsTextSignal = uicontrol('Style', 'text', ...
            'String', 'Signal:', 'parent', handles.handles.DoCSettingsFig,...
            'Position', [0 ypos 100 20], 'horizontalalignment', 'right');
        
        handles.handles.DoCSignalPopup = uicontrol('Style', 'popup', 'String', channels,...
            'Position', [120 ypos 80 20],'Callback', @popupSignalCallback, 'value', handles.DoC.Signal);
        
        
        ypos = ypos - HSPACE1;
        handles.handles.DoCSettingsText(1) = uicontrol('Style', 'text', ...
            'String', 'L(r) - r radius (nm):', 'parent', handles.handles.DoCSettingsFig,...
            'Position', [0 ypos 100 20], 'horizontalalignment', 'right');
        
        handles.handles.DoCSettingsEdit(1) = uicontrol('Style', 'edit', ...
            'String', num2str(handles.DoC.Lr_rRad), 'parent', handles.handles.DoCSettingsFig,...
            'Position', [120 ypos 60 20]);

        ypos = ypos - HSPACE1;
        handles.handles.DoCSettingsText(2) = uicontrol('Style', 'text', ...
            'String', 'Rmax (nm):', 'parent', handles.handles.DoCSettingsFig,...
            'Position', [0 ypos 100 20], 'horizontalalignment', 'right');
        
        handles.handles.DoCSettingsEdit(2) = uicontrol('Style', 'edit', ...
            'String', num2str(handles.DoC.Rmax), 'parent', handles.handles.DoCSettingsFig,...
            'Position', [120 ypos 60 20]);

        ypos = ypos - HSPACE1;
        handles.handles.DoCSettingsText(3) = uicontrol('Style', 'text', ...
            'String', 'Step (nm):', 'parent', handles.handles.DoCSettingsFig,...
            'Position', [0 ypos 100 20], 'horizontalalignment', 'right');
        
        handles.handles.DoCSettingsEdit(3) = uicontrol('Style', 'edit', ...
            'String', num2str(handles.DoC.Step), 'parent', handles.handles.DoCSettingsFig,...
            'Position', [120 ypos 60 20]);

        ypos = ypos - HSPACE1;
        handles.handles.DoCSettingsText(4) = uicontrol('Style', 'text', ...
            'String', 'Colocalization Threshold:', 'parent', handles.handles.DoCSettingsFig,...
            'Position', [0 ypos 100 30], 'horizontalalignment', 'right');
        
        handles.handles.DoCSettingsEdit(4) = uicontrol('Style', 'edit', ...
            'String', num2str(handles.DoC.ColoThres), 'parent', handles.handles.DoCSettingsFig,...
            'Position', [120 ypos 60 20]);


        ypos = ypos - HSPACE1;
        handles.handles.DoCSettingsText(5) = uicontrol('Style', 'text', ...
            'String', 'Min Coloc''d Points/Cluster:', 'parent', handles.handles.DoCSettingsFig,...
            'Position', [0 ypos 100 30], 'horizontalalignment', 'right');
        
        handles.handles.DoCSettingsEdit(5) = uicontrol('Style', 'edit', ...
            'String', num2str(handles.DoC.NbThresh), 'parent', handles.handles.DoCSettingsFig,...
            'Position', [120 ypos 60 20]);

        %%%%%%%%%%

        %%%%%%%%%%%%%%%
        % DoC - DBSCAN settings
        str = 'DBSCAN Parameters for channels';
        if(isCombined)
            str = 'DBSCAN Parameters for combined data';
        end
        
        ypos = HEIGHT - 40;  
        handles.handles.DBSCANSettingsTitleText(1) = uicontrol('Style', 'text', ...
            'String', str, 'parent', handles.handles.DoCSettingsFig,...
            'Position', [260 ypos 250 35], 'horizontalalignment', 'center', 'Fontsize', 10);

        %%%%%%%%
        if(~isCombined)
            ypos = ypos - 25;
        else
            ypos = ypos - 5;
        end
        if verLessThan('matlab', '8.4')
            handles.handles.DBSCANChannelToggle = uibuttongroup('Visible', 'on', 'Position',[.55 ypos/HEIGHT .4 .11],...
                'SelectionChangeFcn', @changeDBSCANChannel);
        else
            handles.handles.DBSCANChannelToggle = uibuttongroup('Visible', 'on', 'Position',[.55 ypos/HEIGHT .4 .11],...
                'SelectionChangedFcn', @changeDBSCANChannel);
        end

        handles.handles.DBSCANChannelSelect(1) = uicontrol(handles.handles.DBSCANChannelToggle, ...
            'Style', 'radiobutton', 'String', 'TCR', 'position', [39 7 70 20]);

        handles.handles.DBSCANChannelSelect(2) = uicontrol(handles.handles.DBSCANChannelToggle, ...
            'Style', 'radiobutton', 'String', 'Signal', 'position', [120 7 70 20]);

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
            %handles.handles.DBSCANSettingsTitleText(2) = uicontrol('Style', 'text', ...
            %    'String', '_____________________', 'parent', handles.handles.DoCSettingsFig,...
            %    'Position', [260 197+SUP 250 20], 'horizontalalignment', 'center', 'Fontsize', 10);
        end

        %%%%%%%%


        %%%%%%
        ypos = ypos - 30;
        handles.handles.DBSCANSettingsText(1) = uicontrol('Style', 'text', ...
            'String', 'Epsilon (nm):', 'parent', handles.handles.DoCSettingsFig,...
            'Position', [260 ypos 110 20], 'horizontalalignment', 'right');
        
        handles.handles.DBSCANSettingsEdit(1) = uicontrol('Style', 'edit', ...
            'String', num2str(handles.DBSCAN(ch).Epsilon), 'parent', handles.handles.DoCSettingsFig,...
            'Position', [375 ypos 60 20]);

        ypos = ypos - HSPACE2;
        handles.handles.DBSCANSettingsText(2) = uicontrol('Style', 'text', ...
            'String', 'minPts:', 'parent', handles.handles.DoCSettingsFig,...
            'Position', [260 ypos 110 20], 'horizontalalignment', 'right');
        
        handles.handles.DBSCANSettingsEdit(2) = uicontrol('Style', 'edit', ...
            'String', num2str(handles.DBSCAN(ch).MinPts), 'parent', handles.handles.DoCSettingsFig,...
            'Position', [375 ypos 60 20]);

        ypos = ypos - HSPACE2;
        handles.handles.DBSCANSettingsText(3) = uicontrol('Style', 'text', ...
            'String', 'Plot Cutoff:', 'parent', handles.handles.DoCSettingsFig,...
            'Position', [260 ypos 110 20], 'horizontalalignment', 'right');
        
        handles.handles.DBSCANSettingsEdit(3) = uicontrol('Style', 'edit', ...
            'String', num2str(handles.DBSCAN(ch).Cutoff), 'parent', handles.handles.DoCSettingsFig,...
            'Position', [375 ypos 60 20]);

        ypos = ypos - HSPACE2;
        handles.handles.DBSCANSettingsText(4) = uicontrol('Style', 'text', ...
            'String', 'Processing Threads:', 'parent', handles.handles.DoCSettingsFig,...
            'Position', [260 ypos 110 20], 'horizontalalignment', 'right');
        
        handles.handles.DBSCANSettingsEdit(4) = uicontrol('Style', 'edit', ...
            'String', num2str(handles.DBSCAN(ch).Threads), 'parent', handles.handles.DoCSettingsFig,...
            'Position', [375 ypos 60 20]);

        ypos = ypos - HSPACE2;
        handles.handles.DBSCANSettingsText(5) = uicontrol('Style', 'text', ...
            'String', 'L(r) - r Radius (nm):', 'parent', handles.handles.DoCSettingsFig,...
            'Position', [260 ypos 110 20], 'horizontalalignment', 'right');
        
        handles.handles.DBSCANSettingsEdit(5) = uicontrol('Style', 'edit', ...
            'String', num2str(handles.DBSCAN(ch).Lr_rThreshRad), 'parent', handles.handles.DoCSettingsFig,...
            'Position', [375 ypos 60 20]);

        handles.handles.DBSCANSettingsText(6) = uicontrol('Style', 'text', ...
            'String', 'Use', 'parent', handles.handles.DoCSettingsFig,...
            'Position', [450 ypos 30 20], 'horizontalalignment', 'right');
        
        handles.handles.DBSCANSetToggle = uicontrol('Style', 'checkbox', ...
            'Value', handles.DBSCAN(ch).UseLr_rThresh, ...
            'position', [485 ypos 20 20], 'callback', @DBSCANUseThreshold);

        ypos = ypos - HSPACE2;
        handles.handles.DBSCANSettingsText(8) = uicontrol('Style', 'text', ...
            'String', 'Calc Stats:', 'parent', handles.handles.DoCSettingsFig,...
            'Position', [260 ypos 110 20], 'horizontalalignment', 'right');
        
        handles.handles.DBSCANDoStatsToggle = uicontrol('Style', 'checkbox', ...
            'Value', handles.DBSCAN(ch).DoStats, ...
            'position', [375 ypos 20 20]);
        
        % plot options
        ypos = ypos - HSPACE2;
        handles.handles.DBSCANSettingsText(7) = uicontrol('Style', 'text', ...
            'String', 'Color clusters:', 'parent', handles.handles.DoCSettingsFig,...
            'Position', [260 ypos 120 20], 'horizontalalignment', 'right');
        
        handles.handles.DBSCANColorClustersToggle = uicontrol('Style', 'checkbox', ...
            'Value', handles.DBSCAN(ch).ColorForClusters, 'position', [375 ypos 20 20]);
        
        ypos = ypos - HSPACE2;
        handles.handles.DBSCANSettingsText(8) = uicontrol('Style', 'text', ...
            'String', 'Contour method:', 'parent', handles.handles.DoCSettingsFig,...
            'Position', [260 ypos 120 20], 'horizontalalignment', 'right');
        
        handles.handles.DBSCANContourPopup = uicontrol('Style', 'popup', 'String', {'Smoothing', 'Alpha shape'},...
            'Position', [375 ypos 130 20],'Callback', @popupContourCallback);
        
        ypos = ypos - HSPACE2;
        handles.handles.DBSCANSettingsText(9) = uicontrol('Style', 'text', ...
            'String', 'Smooth Radius (nm):', 'parent', handles.handles.DoCSettingsFig,...
            'Position', [260 ypos 120 20], 'horizontalalignment', 'right');
        
        handles.handles.DBSCANSettingsEdit(6) = uicontrol('Style', 'edit', ...
            'String', num2str(handles.DBSCAN(ch).SmoothingRad), 'parent', handles.handles.DoCSettingsFig,...
            'Position', [375 ypos 60 20]);
        
        
        %%%%%%%%%%

        set(handles.handles.DBSCANSettingsEdit, 'Callback', @DoCCheckEditBox);

        %%%%%%
        set(handles.handles.DBSCANSetToggle, 'Enable', 'off');
        set(handles.handles.DBSCANDoStatsToggle, 'Enable', 'off');

        %%%%%%
        if(handles.DBSCAN(ch).ContourMethod == 2)
            set(handles.handles.DBSCANContourPopup, 'Value', handles.DBSCAN(ch).ContourMethod);
            set(handles.handles.DBSCANSettingsEdit(6), 'enable', 'off');
        end
        

        handles.handles.DoCSettingsButton = uicontrol('Style', 'pushbutton', ...
            'String', 'Continue', 'parent', handles.handles.DoCSettingsFig, ...
            'Position', [425 4 85 30], 'Callback', @DoCSetAndContinue);

        set(handles.handles.DoCSettingsFig, 'CloseRequestFcn', @DoCCloseOutWindow);

        DoCUseThreshold();

        uiwait;
        
        function popupTCRCallback(hobj, ~)
        end
        
        function popupSignalCallback(hobj, ~)
        end
        
        function popupContourCallback(hobj, ~)
            val = get(hobj, 'Value');
            if(val == 1)
                set(handles.handles.DBSCANSettingsEdit(6), 'Enable', 'on');
            else
                set(handles.handles.DBSCANSettingsEdit(6), 'Enable', 'off');
            end
        end

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

            if strcmp(changeToValue.String, 'TCR')
                ch = 1;
                oldCh = 2;
            elseif strcmp(changeToValue.String, 'Signal')
                ch = 2;
                oldCh = 1;
            end

            handles.DBSCAN(oldCh).Epsilon = str2double(get(handles.handles.DBSCANSettingsEdit(1),'string'));
            handles.DBSCAN(oldCh).MinPts = str2double(get(handles.handles.DBSCANSettingsEdit(2),'string'));
            handles.DBSCAN(oldCh).Cutoff = str2double(get(handles.handles.DBSCANSettingsEdit(3),'string'));
            handles.DBSCAN(oldCh).Threads = str2double(get(handles.handles.DBSCANSettingsEdit(4),'string'));
            handles.DBSCAN(oldCh).Lr_rThreshRad = str2double(get(handles.handles.DBSCANSettingsEdit(5),'string'));
            handles.DBSCAN(oldCh).SmoothingRad = str2double(get(handles.handles.DBSCANSettingsEdit(6),'string'));
            handles.DBSCAN(oldCh).UseLr_rThresh = (get(handles.handles.DBSCANSetToggle, 'value')) == get(handles.handles.DBSCANSetToggle, 'Max');
            handles.DBSCAN(oldCh).DoStats = (get(handles.handles.DBSCANDoStatsToggle, 'value')) == get(handles.handles.DBSCANDoStatsToggle, 'Max');
            handles.DBSCAN(oldCh).ColorForClusters = get(handles.handles.DBSCANColorClustersToggle, 'value') == 1;
            handles.DBSCAN(oldCh).ContourMethod = get(handles.handles.DBSCANContourPopup, 'value');
            
    %         disp(handles.DBSCAN(oldCh));

            set(handles.handles.DBSCANSettingsEdit(1), 'String', num2str(handles.DBSCAN(ch).Epsilon));
            set(handles.handles.DBSCANSettingsEdit(2), 'String', num2str(handles.DBSCAN(ch).MinPts));
            set(handles.handles.DBSCANSettingsEdit(3), 'String', num2str(handles.DBSCAN(ch).Cutoff));
            set(handles.handles.DBSCANSettingsEdit(4), 'String', num2str(handles.DBSCAN(ch).Threads));
            set(handles.handles.DBSCANSettingsEdit(5), 'String', num2str(handles.DBSCAN(ch).Lr_rThreshRad));
            set(handles.handles.DBSCANSettingsEdit(6), 'String', num2str(handles.DBSCAN(ch).SmoothingRad));       
            set(handles.handles.DBSCANSetToggle, 'Value', handles.DBSCAN(ch).UseLr_rThresh);
            set(handles.handles.DBSCANDoStatsToggle, 'Value', handles.DBSCAN(ch).DoStats);
            set(handles.handles.DBSCANColorClustersToggle, 'Value', handles.DBSCAN(ch).ColorForClusters);
            set(handles.handles.DBSCANContourPopup, 'Value', handles.DBSCAN(ch).ContourMethod);
            
            if(get(handles.handles.DBSCANContourPopup, 'Value') == 1)
                set(handles.handles.DBSCANSettingsEdit(6), 'enable', 'on');
            else
                set(handles.handles.DBSCANSettingsEdit(6), 'enable', 'off');
            end

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
            handles.DoC.TCR = get(handles.handles.DoCTCRPopup, 'value');
            handles.DoC.Signal = get(handles.handles.DoCSignalPopup, 'value');
            handles.DoC.Lr_rRad = str2double(get(handles.handles.DoCSettingsEdit(1),'string'));
            handles.DoC.Rmax = str2double(get(handles.handles.DoCSettingsEdit(2),'string'));
            handles.DoC.Step = str2double(get(handles.handles.DoCSettingsEdit(3),'string'));
            handles.DoC.ColoThres = str2double(get(handles.handles.DoCSettingsEdit(4), 'string'));
            handles.DoC.NbThresh = str2double(get(handles.handles.DoCSettingsEdit(5), 'string'));

            % Collect inputs and set parameters in guidata
            handles.DBSCAN(ch).Epsilon = str2double(get(handles.handles.DBSCANSettingsEdit(1),'string'));
            handles.DBSCAN(ch).MinPts = str2double(get(handles.handles.DBSCANSettingsEdit(2),'string'));
            handles.DBSCAN(ch).Cutoff = str2double(get(handles.handles.DBSCANSettingsEdit(3),'string'));
            handles.DBSCAN(ch).Threads = str2double(get(handles.handles.DBSCANSettingsEdit(4),'string'));
            handles.DBSCAN(ch).Lr_rThreshRad = str2double(get(handles.handles.DBSCANSettingsEdit(5),'string'));
            handles.DBSCAN(ch).SmoothingRad = str2double(get(handles.handles.DBSCANSettingsEdit(6),'string'));
            handles.DBSCAN(ch).UseLr_rThresh = (get(handles.handles.DBSCANSetToggle, 'value')) == get(handles.handles.DBSCANSetToggle, 'Max');
            handles.DBSCAN(ch).DoStats = (get(handles.handles.DBSCANDoStatsToggle, 'value')) == get(handles.handles.DBSCANDoStatsToggle, 'Max');
            handles.DBSCAN(ch).ColorForClusters = get(handles.handles.DBSCANColorClustersToggle, 'value') == 1;
            handles.DBSCAN(ch).ContourMethod = get(handles.handles.DBSCANContourPopup, 'value');
            
            returnValue = 1;
            uiresume;
            delete(handles.handles.DoCSettingsFig);

        end  

    end % DoC


    % Pop-up window to set PoC parameters
    function [handles, returnValue] = setPoCParameters(handles)

        isCombined = handles.ProcessType == handles.CONST.PROCESS_COMBINED;

        handles.handles.PoCSettingsFig = figure();
        set(handles.handles.PoCSettingsFig, 'Tag', 'PoCSettingsFig');
        
        WIDTH = 510;
        HEIGHT = 340;
        HSPACE1 = 35;
        HSPACE2 = 25;
        
        resizeFig(handles.handles.PoCSettingsFig, [WIDTH HEIGHT]);
        set(handles.handles.PoCSettingsFig, 'toolbar', 'figure', 'menubar', 'none', ...
            'name', 'PoC Parameters');

        ch = 1;
        if(isCombined)
            ch = 3;
        end

        ypos = HEIGHT - 40;
        handles.handles.PoCSettingsTitleText(1) = uicontrol('Style', 'text', ...
            'String', 'Probability of Colocalization Parameters', 'parent', handles.handles.PoCSettingsFig,...
            'Position', [0 ypos 200 35], 'horizontalalignment', 'center', 'Fontsize', 10);
        
        ypos = ypos - 5;
        handles.handles.PoCSettingsTitleText(2) = uicontrol('Style', 'text', ...
            'String', '_____________________', 'parent', handles.handles.PoCSettingsFig,...
            'Position', [0 ypos 200 20], 'horizontalalignment', 'center', 'Fontsize', 10);
        
        channels = cell(handles.Nchannels, 1);
        for ii = 1:handles.Nchannels
            channels{ii, 1} = sprintf('Ch%d', ii);
        end
        
        ypos = ypos - HSPACE1;
        handles.handles.PoCSettingsTextTCR = uicontrol('Style', 'text', ...
            'String', 'TCR:', 'parent', handles.handles.PoCSettingsFig,...
            'Position', [0 ypos 100 20], 'horizontalalignment', 'right');
        
        handles.handles.PoCTCRPopup = uicontrol('Style', 'popup', 'String', channels,...
            'Position', [120 ypos 80 20],'Callback', @popupTCRCallback, 'value', handles.PoC.TCR);
        
        ypos = ypos - HSPACE1;
        handles.handles.PoCSettingsTextSignal = uicontrol('Style', 'text', ...
            'String', 'Signal:', 'parent', handles.handles.PoCSettingsFig,...
            'Position', [0 ypos 100 20], 'horizontalalignment', 'right');
        
        handles.handles.PoCSignalPopup = uicontrol('Style', 'popup', 'String', channels,...
            'Position', [120 ypos 80 20],'Callback', @popupSignalCallback, 'value', handles.PoC.Signal);

        %%%%%%
        ypos = ypos - HSPACE1;
        handles.handles.PoCSettingsText(1) = uicontrol('Style', 'text', ...
            'String', 'PoC_a=:', 'parent', handles.handles.PoCSettingsFig,...
            'Position', [0 ypos 100 20], 'horizontalalignment', 'right');
        
        handles.handles.PoCSettingsEdit(1) = uicontrol(handles.handles.PoCSettingsFig, 'Style', 'popup', 'String', ...
            {'sum_b/(sum_a+sum_b)', 'sum_b/sum_a'}, 'parent', handles.handles.PoCSettingsFig, ...
            'Position', [118 ypos 120 20]);

        ypos = ypos - HSPACE1;
        handles.handles.DoCSettingsText(2) = uicontrol('Style', 'text', ...
            'String', 'L(r) - r radius (nm):', 'parent', handles.handles.PoCSettingsFig,...
            'Position', [0 ypos 100 20], 'horizontalalignment', 'right');
        
        handles.handles.PoCSettingsEdit(2) = uicontrol('Style', 'edit', ...
            'String', num2str(handles.PoC.Lr_rRad), 'parent', handles.handles.PoCSettingsFig,...
            'Position', [120 ypos 60 20]);

        ypos = ypos - HSPACE1;
        handles.handles.PoCSettingsText(3) = uicontrol('Style', 'text', ...
            'String', 'Gaussian width (sigma):', 'parent', handles.handles.PoCSettingsFig,...
            'Position', [0 ypos 100 30], 'horizontalalignment', 'right');
        
        handles.handles.PoCSettingsEdit(3) = uicontrol('Style', 'edit', ...
            'String', num2str(handles.PoC.Sigma), 'parent', handles.handles.PoCSettingsFig,...
            'Position', [120 ypos 60 20]);

        ypos = ypos - HSPACE1;
        handles.handles.PoCSettingsText(4) = uicontrol('Style', 'text', ...
            'String', 'Colocalization Threshold:', 'parent', handles.handles.PoCSettingsFig,...
            'Position', [0 ypos 100 30], 'horizontalalignment', 'right');
        
        handles.handles.PoCSettingsEdit(4) = uicontrol('Style', 'edit', ...
            'String', num2str(handles.PoC.ColoThres), 'parent', handles.handles.PoCSettingsFig,...
            'Position', [120 ypos 60 20]);

        ypos = ypos - HSPACE1;
        handles.handles.PoCSettingsText(5) = uicontrol('Style', 'text', ...
            'String', 'Min Coloc''d Points/Cluster:', 'parent', handles.handles.PoCSettingsFig,...
            'Position', [0 ypos 100 30], 'horizontalalignment', 'right');
        
        handles.handles.PoCSettingsEdit(5) = uicontrol('Style', 'edit', ...
            'String', num2str(handles.PoC.NbThresh), 'parent', handles.handles.PoCSettingsFig,...
            'Position', [120 ypos 60 20]);


        %%%%%%%%%%%%%%%
        % PoC - DBSCAN settings

        str = 'DBSCAN Parameters for channels';
        if(isCombined)
            str = 'DBSCAN Parameters for combined data';
        end
        
        ypos = HEIGHT - 40;  
        handles.handles.DBSCANSettingsTitleText(1) = uicontrol('Style', 'text', ...
            'String', str, 'parent', handles.handles.PoCSettingsFig,...
            'Position', [260 ypos 250 35], 'horizontalalignment', 'center', 'Fontsize', 10);

        %%%%%%%%
        if(~isCombined)
            ypos = ypos - 25;
        else
            ypos = ypos - 5;
        end
        if verLessThan('matlab', '8.4')
            handles.handles.DBSCANChannelToggle = uibuttongroup('Visible', 'on', 'Position',[.55 ypos/HEIGHT .4 .11],...
                'SelectionChangeFcn', @changeDBSCANChannel);
        else
            handles.handles.DBSCANChannelToggle = uibuttongroup('Visible', 'on', 'Position',[.55 ypos/HEIGHT .4 .11],...
                'SelectionChangedFcn', @changeDBSCANChannel);
        end

        handles.handles.DBSCANChannelSelect(1) = uicontrol(handles.handles.DBSCANChannelToggle, ...
            'Style', 'radiobutton', 'String', 'TCR', 'position', [39 7 70 20]);

        handles.handles.DBSCANChannelSelect(2) = uicontrol(handles.handles.DBSCANChannelToggle, ...
            'Style', 'radiobutton', 'String', 'Signal', 'position', [120 7 70 20]);

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
            %handles.handles.DBSCANSettingsTitleText(2) = uicontrol('Style', 'text', ...
            %    'String', '_____________________', 'parent', handles.handles.PoCSettingsFig,...
            %    'Position', [260 197+SUP 250 20], 'horizontalalignment', 'center', 'Fontsize', 10);
        end

        %%%%%%%%


        %%%%%%
        ypos = ypos - 30;
        handles.handles.DBSCANSettingsText(1) = uicontrol('Style', 'text', ...
            'String', 'Epsilon (nm):', 'parent', handles.handles.PoCSettingsFig,...
            'Position', [260 ypos 110 20], 'horizontalalignment', 'right');
        
        handles.handles.DBSCANSettingsEdit(1) = uicontrol('Style', 'edit', ...
            'String', num2str(handles.DBSCAN(ch).Epsilon), 'parent', handles.handles.PoCSettingsFig,...
            'Position', [375 ypos 60 20]);

        ypos = ypos - HSPACE2;
        handles.handles.DBSCANSettingsText(2) = uicontrol('Style', 'text', ...
            'String', 'minPts:', 'parent', handles.handles.PoCSettingsFig,...
            'Position', [260 ypos 110 20], 'horizontalalignment', 'right');
        
        handles.handles.DBSCANSettingsEdit(2) = uicontrol('Style', 'edit', ...
            'String', num2str(handles.DBSCAN(ch).MinPts), 'parent', handles.handles.PoCSettingsFig,...
            'Position', [375 ypos 60 20]);

        ypos = ypos - HSPACE2;
        handles.handles.DBSCANSettingsText(3) = uicontrol('Style', 'text', ...
            'String', 'Plot Cutoff:', 'parent', handles.handles.PoCSettingsFig,...
            'Position', [260 ypos 110 20], 'horizontalalignment', 'right');
        
        handles.handles.DBSCANSettingsEdit(3) = uicontrol('Style', 'edit', ...
            'String', num2str(handles.DBSCAN(ch).Cutoff), 'parent', handles.handles.PoCSettingsFig,...
            'Position', [375 ypos 60 20]);

        ypos = ypos - HSPACE2;
        handles.handles.DBSCANSettingsText(4) = uicontrol('Style', 'text', ...
            'String', 'Processing Threads:', 'parent', handles.handles.PoCSettingsFig,...
            'Position', [260 ypos 110 20], 'horizontalalignment', 'right');
        
        handles.handles.DBSCANSettingsEdit(4) = uicontrol('Style', 'edit', ...
            'String', num2str(handles.DBSCAN(ch).Threads), 'parent', handles.handles.PoCSettingsFig,...
            'Position', [375 ypos 60 20]);

        ypos = ypos - HSPACE2;
        handles.handles.DBSCANSettingsText(5) = uicontrol('Style', 'text', ...
            'String', 'L(r) - r Radius (nm):', 'parent', handles.handles.PoCSettingsFig,...
            'Position', [260 ypos 110 20], 'horizontalalignment', 'right');
        
        handles.handles.DBSCANSettingsEdit(5) = uicontrol('Style', 'edit', ...
            'String', num2str(handles.DBSCAN(ch).Lr_rThreshRad), 'parent', handles.handles.PoCSettingsFig,...
            'Position', [375 ypos 60 20]);

        handles.handles.DBSCANSettingsText(6) = uicontrol('Style', 'text', ...
            'String', 'Use', 'parent', handles.handles.PoCSettingsFig,...
            'Position', [450 ypos 30 20], 'horizontalalignment', 'right');
        
        handles.handles.DBSCANSetToggle = uicontrol('Style', 'checkbox', ...
            'Value', handles.DBSCAN(ch).UseLr_rThresh, 'position', [485 ypos 20 20], ...
            'callback', @DBSCANUseThreshold);

        ypos = ypos - HSPACE2;
        handles.handles.DBSCANSettingsText(8) = uicontrol('Style', 'text', ...
            'String', 'Calc Stats:', 'parent', handles.handles.PoCSettingsFig,...
            'Position', [260 ypos 110 20], 'horizontalalignment', 'right');
        
        handles.handles.DBSCANDoStatsToggle = uicontrol('Style', 'checkbox', ...
            'Value', handles.DBSCAN(ch).DoStats, 'position', [375 ypos 20 20]);
        
        % plot options
        ypos = ypos - HSPACE2;
        handles.handles.DBSCANSettingsText(7) = uicontrol('Style', 'text', ...
            'String', 'Color clusters:', 'parent', handles.handles.PoCSettingsFig,...
            'Position', [260 ypos 120 20], 'horizontalalignment', 'right');
        
        handles.handles.DBSCANColorClustersToggle = uicontrol('Style', 'checkbox', ...
            'Value', handles.DBSCAN(ch).ColorForClusters, 'position', [375 ypos 20 20]);
        
        ypos = ypos - HSPACE2;
        handles.handles.DBSCANSettingsText(8) = uicontrol('Style', 'text', ...
            'String', 'Contour method:', 'parent', handles.handles.PoCSettingsFig,...
            'Position', [260 ypos 120 20], 'horizontalalignment', 'right');
        
        handles.handles.DBSCANContourPopup = uicontrol('Style', 'popup', 'String', {'Smoothing', 'Alpha shape'},...
            'Position', [375 ypos 130 20],'Callback', @popupContourCallback);
        
        ypos = ypos - HSPACE2;
        handles.handles.DBSCANSettingsText(9) = uicontrol('Style', 'text', ...
            'String', 'Smooth Radius (nm):', 'parent', handles.handles.PoCSettingsFig,...
            'Position', [260 ypos 120 20], 'horizontalalignment', 'right');
        
        handles.handles.DBSCANSettingsEdit(6) = uicontrol('Style', 'edit', ...
            'String', num2str(handles.DBSCAN(ch).SmoothingRad), 'parent', handles.handles.PoCSettingsFig,...
            'Position', [375 ypos 60 20]);

        %%%%%%%%%%


        set(handles.handles.DBSCANSettingsEdit, 'Callback', @PoCCheckEditBox);


        set(handles.handles.DBSCANSetToggle, 'Enable', 'off');
        set(handles.handles.DBSCANDoStatsToggle, 'Enable', 'off');
        
        if(handles.DBSCAN(ch).ContourMethod == 2)
            set(handles.handles.DBSCANContourPopup, 'Value', handles.DBSCAN(ch).ContourMethod);
            set(handles.handles.DBSCANSettingsEdit(6), 'enable', 'off');
        end

        %%%%%%


        handles.handles.PoCSettingsButton = uicontrol('Style', 'pushbutton', ...
            'String', 'Continue', 'parent', handles.handles.PoCSettingsFig, ...
            'Position', [425 4 85 30], 'Callback', @PoCSetAndContinue);

        set(handles.handles.PoCSettingsFig, 'CloseRequestFcn', @PoCCloseOutWindow);

        PoCUseThreshold();

        uiwait;
        
        function popupTCRCallback(hobj, ~)
        end
        
        function popupSignalCallback(hobj, ~)
        end
        
        function popupContourCallback(hobj, ~)
            val = get(hobj, 'Value');
            if(val == 1)
                set(handles.handles.DBSCANSettingsEdit(6), 'Enable', 'on');
            else
                set(handles.handles.DBSCANSettingsEdit(6), 'Enable', 'off');
            end
        end

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

            if strcmp(changeToValue.String, 'TCR')
                ch = 1;
                oldCh = 2;
            elseif strcmp(changeToValue.String, 'Signal')
                ch = 2;
                oldCh = 1;
            end

            handles.DBSCAN(oldCh).Epsilon = str2double(get(handles.handles.DBSCANSettingsEdit(1),'string'));
            handles.DBSCAN(oldCh).MinPts = str2double(get(handles.handles.DBSCANSettingsEdit(2),'string'));
            handles.DBSCAN(oldCh).Cutoff = str2double(get(handles.handles.DBSCANSettingsEdit(3),'string'));
            handles.DBSCAN(oldCh).Threads = str2double(get(handles.handles.DBSCANSettingsEdit(4),'string'));
            handles.DBSCAN(oldCh).Lr_rThreshRad = str2double(get(handles.handles.DBSCANSettingsEdit(5),'string'));
            handles.DBSCAN(oldCh).SmoothingRad = str2double(get(handles.handles.DBSCANSettingsEdit(6),'string'));
            handles.DBSCAN(oldCh).UseLr_rThresh = (get(handles.handles.DBSCANSetToggle, 'value')) == get(handles.handles.DBSCANSetToggle, 'Max');
            handles.DBSCAN(oldCh).DoStats = (get(handles.handles.DBSCANDoStatsToggle, 'value')) == get(handles.handles.DBSCANDoStatsToggle, 'Max');
            handles.DBSCAN(oldCh).ColorForClusters = get(handles.handles.DBSCANColorClustersToggle, 'value') == 1;
            handles.DBSCAN(oldCh).ContourMethod = get(handles.handles.DBSCANContourPopup, 'value');
            
    %         disp(handles.DBSCAN(oldCh));

            set(handles.handles.DBSCANSettingsEdit(1), 'String', num2str(handles.DBSCAN(ch).Epsilon));
            set(handles.handles.DBSCANSettingsEdit(2), 'String', num2str(handles.DBSCAN(ch).MinPts));
            set(handles.handles.DBSCANSettingsEdit(3), 'String', num2str(handles.DBSCAN(ch).Cutoff));
            set(handles.handles.DBSCANSettingsEdit(4), 'String', num2str(handles.DBSCAN(ch).Threads));
            set(handles.handles.DBSCANSettingsEdit(5), 'String', num2str(handles.DBSCAN(ch).Lr_rThreshRad));
            set(handles.handles.DBSCANSettingsEdit(6), 'String', num2str(handles.DBSCAN(ch).SmoothingRad));       
            set(handles.handles.DBSCANSetToggle, 'Value', handles.DBSCAN(ch).UseLr_rThresh);
            set(handles.handles.DBSCANDoStatsToggle, 'Value', handles.DBSCAN(ch).DoStats);
            set(handles.handles.DBSCANColorClustersToggle, 'Value', handles.DBSCAN(ch).ColorForClusters);
            set(handles.handles.DBSCANContourPopup, 'Value', handles.DBSCAN(ch).ContourMethod);
            
            if(get(handles.handles.DBSCANContourPopup, 'Value') == 1)
                set(handles.handles.DBSCANSettingsEdit(6), 'enable', 'on');
            else
                set(handles.handles.DBSCANSettingsEdit(6), 'enable', 'off');
            end

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
            handles.PoC.TCR = get(handles.handles.PoCTCRPopup, 'value');
            handles.PoC.Signal = get(handles.handles.PoCSignalPopup, 'value');
            handles.PoC.FuncType = get(handles.handles.PoCSettingsEdit(1),'value');
            handles.PoC.Lr_rRad = str2double(get(handles.handles.PoCSettingsEdit(2),'string'));
            handles.PoC.Sigma = str2double(get(handles.handles.PoCSettingsEdit(3),'string'));
            handles.PoC.ColoThres = str2double(get(handles.handles.PoCSettingsEdit(4), 'string'));
            handles.PoC.NbThresh = str2double(get(handles.handles.PoCSettingsEdit(5), 'string'));

            % Collect inputs and set parameters in guidata
            handles.DBSCAN(ch).Epsilon = str2double(get(handles.handles.DBSCANSettingsEdit(1),'string'));
            handles.DBSCAN(ch).MinPts = str2double(get(handles.handles.DBSCANSettingsEdit(2),'string'));
            handles.DBSCAN(ch).Cutoff = str2double(get(handles.handles.DBSCANSettingsEdit(3),'string'));
            handles.DBSCAN(ch).Threads = str2double(get(handles.handles.DBSCANSettingsEdit(4),'string'));
            handles.DBSCAN(ch).Lr_rThreshRad = str2double(get(handles.handles.DBSCANSettingsEdit(5),'string'));
            handles.DBSCAN(ch).SmoothingRad = str2double(get(handles.handles.DBSCANSettingsEdit(6),'string'));
            handles.DBSCAN(ch).UseLr_rThresh = (get(handles.handles.DBSCANSetToggle, 'value')) == get(handles.handles.DBSCANSetToggle, 'Max');
            handles.DBSCAN(ch).DoStats = (get(handles.handles.DBSCANDoStatsToggle, 'value')) == get(handles.handles.DBSCANDoStatsToggle, 'Max');
            handles.DBSCAN(ch).ColorForClusters = get(handles.handles.DBSCANColorClustersToggle, 'value') == 1;
            handles.DBSCAN(ch).ContourMethod = get(handles.handles.DBSCANContourPopup, 'value');
            
            returnValue = 1;
            uiresume;
            delete(handles.handles.PoCSettingsFig);

        end  

    end % PoC


    function [handles, returnVal] = setSettings(handles)
        
        handles.handles.SettingsFig = figure();
        set(handles.handles.SettingsFig, 'Tag', 'SettingsFig');
        
        WIDTH = 260;
        HEIGHT = 200;
        SPACE = 30;
        savedefault = 0;
        
        resizeFig(handles.handles.SettingsFig, [WIDTH HEIGHT]);
        set(handles.handles.SettingsFig, 'toolbar', 'none', 'menubar', 'none', ...
            'name', 'General settings');
        
        ypos = HEIGHT - 40;
        handles.handles.SettingsTitleText(1) = uicontrol('Style', 'text', ...
            'String', 'ROI size (when click to create ROI)', 'parent', handles.handles.SettingsFig,...
            'Position', [0 ypos 180 20], 'horizontalalignment', 'right', 'Fontsize', 10);

        handles.handles.SettingsEdit(1) = uicontrol('Style', 'edit', ...
            'String', num2str(handles.settings.RoiSize), 'parent', handles.handles.SettingsFig,...
            'Position', [190 ypos 50 20]);
        
        ypos = ypos - SPACE;
        handles.handles.SettingsTitleText(2) = uicontrol('Style', 'text', ...
            'String', 'Show scalebar', 'parent', handles.handles.SettingsFig,...
            'Position', [0 ypos 180 20], 'horizontalalignment', 'right', 'Fontsize', 10);
        
        handles.handles.SettingsScalebarToggle = uicontrol('Style', 'checkbox', ...
            'Value', handles.settings.ShowScalebar, 'position', [190 ypos 20 20]);
        
        ypos = ypos - SPACE;
        handles.handles.SettingsTitleText(3) = uicontrol('Style', 'text', ...
            'String', 'Draw points on alphashape', 'parent', handles.handles.SettingsFig,...
            'Position', [0 ypos 180 20], 'horizontalalignment', 'right', 'Fontsize', 10);
        
        handles.handles.SettingsDrawPointsToggle = uicontrol('Style', 'checkbox', ...
            'Value', handles.settings.DrawPointOnAlphaShape, 'position', [190 ypos 20 20]);
        
        ypos = ypos - SPACE;
        handles.handles.SettingsTitleText(4) = uicontrol('Style', 'text', ...
            'String', 'Also save plots as .fig', 'parent', handles.handles.SettingsFig,...
            'Position', [0 ypos 180 20], 'horizontalalignment', 'right', 'Fontsize', 10);
        
        handles.handles.SettingsSaveFigToggle = uicontrol('Style', 'checkbox', ...
            'Value', handles.settings.AlsoSaveFig, 'position', [190 ypos 20 20]);
        
        ypos = ypos - SPACE;
        handles.handles.SettingsTitleText(5) = uicontrol('Style', 'text', ...
            'String', 'Save as default (update cfg file)', 'parent', handles.handles.SettingsFig,...
            'Position', [0 ypos 180 20], 'horizontalalignment', 'right', 'Fontsize', 10);
        
        handles.handles.SettingsSaveDefaultToggle = uicontrol('Style', 'checkbox', ...
            'Value', savedefault, 'position', [190 ypos 20 20]);
        
        
        handles.handles.SettingsButton = uicontrol('Style', 'pushbutton', ...
            'String', 'Continue', 'parent', handles.handles.SettingsFig, ...
            'Position', [165 2 85 30], 'Callback', @SetAndContinue);
        
        set(handles.handles.SettingsFig, 'CloseRequestFcn', @CloseOutWindow);
        
        uiwait();
        
        function CloseOutWindow(varargin)
            % Cancel, don't execute further
            returnVal = 0;
            uiresume;
            delete(handles.handles.SettingsFig);
        end
        
        function SetAndContinue(varargin)
            handles.settings.RoiSize = str2double(get(handles.handles.SettingsEdit(1), 'String'));
            handles.settings.ShowScalebar = get(handles.handles.SettingsScalebarToggle, 'Value');
            handles.settings.DrawPointOnAlphaShape = get(handles.handles.SettingsDrawPointsToggle, 'Value');
            handles.settings.AlsoSaveFig = get(handles.handles.SettingsSaveFigToggle, 'Value');
            savedefault = get(handles.handles.SettingsSaveDefaultToggle, 'Value');
            if(savedefault ~= 0)
                returnVal = 2;
            else
                returnVal = 1;
            end
            
            uiresume;
            delete(handles.handles.SettingsFig);
        end
        
    end % settings


end % InputDialogs