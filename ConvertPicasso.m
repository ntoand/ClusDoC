function ConvertPicasso(varargin)
    close all; % for easier debugging
    clear;
    
    figObj = findobj('Tag', 'CONVERT GUI');
    if ~isempty(figObj)
        figure(figObj);
    else
        DoCGUIInitialize();
    end
end

function DoCGUIInitialize(varargin)

    figObj = findobj('Tag', 'CONVERT GUI');
    settings = LoadSettings();
    
    if ~isempty(figObj) % If figure already exists, clear it out and reset it.
        clf(figObj);
        handles = guidata(figObj);
        fig1 = figObj;
    else
        WIDTH = 800;
        HEIGHT = 550;
        ss = get(0,'screensize');
        left = (ss(3) - WIDTH) / 2;
        bottom = (ss(4) - HEIGHT) / 2;
        title = sprintf('Convert picasso data %s', settings.Version);
        fig1 = figure('Name',title, 'Tag', 'CONVERT GUI', 'Units', 'pixels',...
            'Position',[left bottom WIDTH HEIGHT], 'color', [1 1 1]);%'Position',[0.05 0.3 760/scrsz(3) 650/scrsz(4)] );
        
        set(fig1, 'CloseRequestFcn', @CloseGUIFunction);

        handles.handles.MainFig = fig1;
    end
    handles.settings = settings;
    fprintf('GUI version %s\n', settings.Version);
    
    % controls
    vpos = 0.9;
    vdelta = 0.09;
    % channel 1
    handles.handles.hLoadCh1 =  uicontrol(fig1, 'Units', 'normalized', 'Style', 'pushbutton', 'String', 'Load channel 1',...
        'Position', [0.01    vpos    0.1500    0.05], 'Callback', @LoadChannel1, 'Enable', 'on');

    handles.handles.hCh1Text = uicontrol(fig1, 'Style', 'text', 'Units', 'normalized', ...
        'Position',[0.200    vpos    0.75    0.06], 'BackgroundColor', [1 1 1], ...
        'String', '(empty)', 'HorizontalAlignment','left');
    
    % channel 2
    vpos = vpos - vdelta;
    handles.handles.hLoadCh2 =  uicontrol(fig1, 'Units', 'normalized', 'Style', 'pushbutton', 'String', 'Load channel 2',...
        'Position', [0.01    vpos   0.1500    0.05], 'Callback', @LoadChannel2, 'Enable', 'off');

    handles.handles.hCh2Text = uicontrol(fig1, 'Style', 'text', 'Units', 'normalized', ...
        'Position',[0.200    vpos    0.75    0.06], 'BackgroundColor', [1 1 1], ...
        'String', '(empty)', 'HorizontalAlignment','left');
    
    % channel 3
    vpos = vpos - vdelta;
    handles.handles.hLoadCh3 =  uicontrol(fig1, 'Units', 'normalized', 'Style', 'pushbutton', 'String', 'Load channel 3',...
        'Position', [0.01    vpos   0.1500    0.05], 'Callback', @LoadChannel3, 'Enable', 'off');

    handles.handles.hCh3Text = uicontrol(fig1, 'Style', 'text', 'Units', 'normalized', ...
        'Position',[0.200    vpos    0.75    0.06], 'BackgroundColor', [1 1 1], ...
        'String', '(empty)', 'HorizontalAlignment','left');
    
    % channel 4
    vpos = vpos - vdelta;
    handles.handles.hLoadCh4 =  uicontrol(fig1, 'Units', 'normalized', 'Style', 'pushbutton', 'String', 'Load channel 4',...
        'Position', [0.01    vpos   0.1500    0.05], 'Callback', @LoadChannel4, 'Enable', 'off');

    handles.handles.hCh4Text = uicontrol(fig1, 'Style', 'text', 'Units', 'normalized', ...
        'Position',[0.200    vpos    0.75    0.06], 'BackgroundColor', [1 1 1], ...
        'String', '(empty)', 'HorizontalAlignment','left');
    
    % channel 5
    vpos = vpos - vdelta;
    handles.handles.hLoadCh5 =  uicontrol(fig1, 'Units', 'normalized', 'Style', 'pushbutton', 'String', 'Load channel 5',...
        'Position', [0.01    vpos   0.1500    0.05], 'Callback', @LoadChannel5, 'Enable', 'off');

    handles.handles.hCh5Text = uicontrol(fig1, 'Style', 'text', 'Units', 'normalized', ...
        'Position',[0.200    vpos    0.75    0.06], 'BackgroundColor', [1 1 1], ...
        'String', '(empty)', 'HorizontalAlignment','left');
    
    % channel 6
    vpos = vpos - vdelta;
    handles.handles.hLoadCh6 =  uicontrol(fig1, 'Units', 'normalized', 'Style', 'pushbutton', 'String', 'Load channel 6',...
        'Position', [0.01    vpos   0.1500    0.05], 'Callback', @LoadChannel6, 'Enable', 'off');

    handles.handles.hCh6Text = uicontrol(fig1, 'Style', 'text', 'Units', 'normalized', ...
        'Position',[0.200    vpos    0.75    0.06], 'BackgroundColor', [1 1 1], ...
        'String', '(empty)', 'HorizontalAlignment','left');
    
    % 
    vpos = vpos - 1.5*vdelta;
    handles.handles.hPixelSizeText = uicontrol(fig1, 'Style', 'text', 'Units', 'normalized', ...
        'Position',[0.02    vpos    0.2    0.05], 'BackgroundColor', [1 1 1], ...
        'String', 'Pixel size (nm): ', 'HorizontalAlignment','left');
    
    handles.handles.hPixelSizeEdit = uicontrol(fig1, 'Style', 'edit', 'Units', 'normalized', ...
        'Position',[0.2    vpos+0.01    0.15    0.05], 'BackgroundColor', [1 1 1], ...
        'String', '65');
    
    vpos = vpos - 1.5*vdelta;
    handles.handles.hConvert =  uicontrol(fig1, 'Units', 'normalized', 'Style', 'pushbutton', 'String', 'CONVERT',...
        'Position', [0.01    vpos    0.2    0.1],...
        'Callback', @Convert);
    
    handles.handles.hStatus = uicontrol(fig1, 'Style', 'text', 'Units', 'normalized', ...
        'Position',[0.02    0.06    0.8    0.07], 'BackgroundColor', [1 1 1], ...
        'String', '(status)', 'HorizontalAlignment','left');
    
    
    set(handles.handles.hConvert, 'enable', 'off');
    handles.files = cell(6, 1);
    handles.numChannels = 0;
    handles.currDir = '';
    
    guidata(handles.handles.MainFig, handles);

end % DoCGUIInitialize


function CloseGUIFunction(varargin)
    delete(findobj('Tag', 'CONVERT GUI'));
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


function LoadChannel(ch)
    handles = guidata(findobj('Tag', 'CONVERT GUI'));
    if(ch == 1)
        [fileName, pathName] = uigetfile({'*.hdf5', 'Picasso export file'}, 'Select first channel hdf5 file', 'MultiSelect', 'off');
    else
        [fileName, pathName] = uigetfile({'*.hdf5', 'Picasso export file'}, 'Select first channel hdf5 file', 'MultiSelect', 'off', handles.currDir);
    end
    if fileName==0
        return;
    end
    
    fullFilename = fullfile(pathName, fileName);
    handles.files{ch} = fullFilename;
    handles.currDir = pathName;
    handles.numChannels = max(handles.numChannels, ch);
    
    if(ch == 1)
        set(handles.handles.hCh1Text, 'String', fullFilename);
        set(handles.handles.hLoadCh2, 'Enable', 'on');
    elseif(ch == 2)
        set(handles.handles.hCh2Text, 'String', fullFilename);
        set(handles.handles.hLoadCh3, 'Enable', 'on');
    elseif(ch == 3)
        set(handles.handles.hCh3Text, 'String', fullFilename);
        set(handles.handles.hLoadCh4, 'Enable', 'on');
    elseif(ch == 4)
        set(handles.handles.hCh4Text, 'String', fullFilename);
        set(handles.handles.hLoadCh5, 'Enable', 'on');
    elseif(ch == 5)
        set(handles.handles.hCh5Text, 'String', fullFilename);
        set(handles.handles.hLoadCh6, 'Enable', 'on');
    elseif(ch == 6)
        set(handles.handles.hCh6Text, 'String', fullFilename);
    end
    
    if(ch > 1)
        set(handles.handles.hConvert, 'enable', 'on');
    end
    
    guidata(handles.handles.MainFig, handles);
end

function LoadChannel1(~, ~, ~)
    LoadChannel(1);
end

function LoadChannel2(~, ~, ~)
    LoadChannel(2);
end

function LoadChannel3(~, ~, ~)
    LoadChannel(3);
end

function LoadChannel4(~, ~, ~)
    LoadChannel(4);
end

function LoadChannel5(~, ~, ~)
    LoadChannel(5);
end

function LoadChannel6(~, ~, ~)
    LoadChannel(6);
end


function Convert(~, ~, ~)
    
    handles = guidata(findobj('Tag', 'CONVERT GUI'));
    pixelsize = str2double(get(handles.handles.hPixelSizeEdit, 'String'));
    
    set(handles.handles.hConvert, 'enable', 'off');
    set(handles.handles.MainFig, 'pointer', 'watch');
    
    [file, path] = uiputfile({'*.txt', 'ZEN export table'}, 'Save to ZEN txt file', '1.txt');
    
    header = {'Index', 'First Frame', 'Number Frames', 'Frames Missing', 'Position X [nm]', 'Position Y [nm]', 'Precision [nm]', ...	
        'Number Photons', 'Background variance', 'Chi square', 'PSF width [nm]', 'Channel', 'Z Slice'};
    
    f = fopen(fullfile(path, file), 'wt');
    if(f > 0)
        % header
        for ii=1:12
            fprintf(f, '%s\t', header{ii});
        end
        fprintf(f, '%s\n', header{13});
        
        % now convert data 
        % ref (_csv2hdf):
        % https://github.com/jungmannlab/picasso/blob/master/picasso/__main__.py 
        for cc = 1:handles.numChannels
            set(handles.handles.hStatus, 'String', sprintf('Converting channel %d ...', cc));
            drawnow;
            
            locs = h5read(handles.files{cc}, '/locs');
            numrows = numel(locs.frame);
            
            for row = 1:numrows
                rowdata = zeros(1, 13);
                rowdata(1) = row;                       % index
                rowdata(2) = locs.frame(row) + 1;       % first frame
                rowdata(3) = 1;                         % number frames
                rowdata(4) = 0;                         % frames missing
                rowdata(5) = locs.x(row) * pixelsize;   % x_nm
                rowdata(6) = locs.y(row) * pixelsize;   % y_nm
                rowdata(7) = locs.lpx(row) * pixelsize; % precision
                rowdata(8) = locs.photons(row);         % number photons
                rowdata(9) = locs.bg(row);              % background variance
                if isfield(locs, 'ellipticity')
                    rowdata(10) = locs.ellipticity(row);    % chi square. need double check. is it important?
                end
                rowdata(11) = locs.sx(row) * pixelsize; % PSF half width. need double check
                rowdata(12) = cc;                       % channel
                rowdata(13) = 1;                        % z slice

                for ii=1:4
                    fprintf(f, '%d\t', rowdata(ii));
                end
                for ii=5:11
                    fprintf(f, '%0.1f\t', rowdata(ii));
                end
                fprintf(f, '%d\t', rowdata(12));
                fprintf(f, '%d\n', rowdata(13)); 
            end
        end     
        
        fclose(f);
        
        set(handles.handles.hStatus, 'String', 'Converted successfully!');
        drawnow;
        
    else
        set(handles.handles.hStatus, 'String', 'Cannot create file to write');
        drawnow;
    end
    
    set(handles.handles.hConvert, 'enable', 'on');
    set(handles.handles.MainFig, 'pointer', 'arrow');
    
end