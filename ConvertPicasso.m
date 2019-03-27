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
        WIDTH = 700;
        HEIGHT = 400;
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
    handles.handles.hLoadCh1 =  uicontrol(fig1, 'Units', 'normalized', 'Style', 'pushbutton', 'String', 'Load channel 1',...
        'Position', [0.01    0.86    0.1500    0.08],...
        'Callback', @LoadChannel1);

    handles.handles.hCh1Text = uicontrol(fig1, 'Style', 'text', 'Units', 'normalized', ...
        'Position',[0.200    0.86    0.75    0.07], 'BackgroundColor', [1 1 1], ...
        'String', '(channel 1 file)', 'HorizontalAlignment','left');
    
    handles.handles.hLoadCh2 =  uicontrol(fig1, 'Units', 'normalized', 'Style', 'pushbutton', 'String', 'Load channel 2',...
        'Position', [0.01    0.71    0.1500    0.08],...
        'Callback', @LoadChannel2);

    handles.handles.hCh2Text = uicontrol(fig1, 'Style', 'text', 'Units', 'normalized', ...
        'Position',[0.200    0.71    0.75    0.07], 'BackgroundColor', [1 1 1], ...
        'String', '(channel 2 file)', 'HorizontalAlignment','left');
    
    handles.handles.hPixelSizeText = uicontrol(fig1, 'Style', 'text', 'Units', 'normalized', ...
        'Position',[0.02    0.53    0.2    0.07], 'BackgroundColor', [1 1 1], ...
        'String', 'Pixel size (nm): ', 'HorizontalAlignment','left');
    
    handles.handles.hPixelSizeEdit = uicontrol(fig1, 'Style', 'edit', 'Units', 'normalized', ...
        'Position',[0.2    0.55    0.2    0.07], 'BackgroundColor', [1 1 1], ...
        'String', '65');
    
    handles.handles.hConvert =  uicontrol(fig1, 'Units', 'normalized', 'Style', 'pushbutton', 'String', 'CONVERT',...
        'Position', [0.01    0.3    0.2    0.1],...
        'Callback', @Convert);
    
    handles.handles.hStatus = uicontrol(fig1, 'Style', 'text', 'Units', 'normalized', ...
        'Position',[0.02    0.15    0.8    0.07], 'BackgroundColor', [1 1 1], ...
        'String', '(status)', 'HorizontalAlignment','left');
    
    
    set(handles.handles.hConvert, 'enable', 'off');
    handles.filechan1 = [];
    handles.filechan2 = [];
    
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


function LoadChannel1(~, ~, ~)
    handles = guidata(findobj('Tag', 'CONVERT GUI'));
    [fileName, pathName] = uigetfile({'*.hdf5', 'Picasso export file'}, 'Select first channel hdf5 file', 'MultiSelect', 'off');
    handles.filechan1 = fullfile(pathName, fileName);
    set(handles.handles.hCh1Text, 'String', fullfile(pathName, fileName));
    
    if(~isempty(handles.filechan2))
        set(handles.handles.hConvert, 'enable', 'on');
    end
    
    guidata(handles.handles.MainFig, handles);
end

function LoadChannel2(~, ~, ~)
    handles = guidata(findobj('Tag', 'CONVERT GUI'));
    [fileName, pathName] = uigetfile({'*.hdf5', 'Picasso export file'}, 'Select second channel hdf5 file', 'MultiSelect', 'off');
    handles.filechan2 = fullfile(pathName, fileName);
    set(handles.handles.hCh2Text, 'String', fullfile(pathName, fileName));
    
    if(~isempty(handles.filechan1))
        set(handles.handles.hConvert, 'enable', 'on');
    end
    
    guidata(handles.handles.MainFig, handles);
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
        
        % first channel
        set(handles.handles.hStatus, 'String', 'Converting first channel...');
        drawnow;
    
        locs = h5read(handles.filechan1, '/locs');
        numrows = numel(locs.frame);
        % now convert data 
        % ref (_csv2hdf):
        % https://github.com/jungmannlab/picasso/blob/master/picasso/__main__.py 
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
            rowdata(10) = locs.ellipticity(row);    % chi square. need double check. is it important?
            rowdata(11) = locs.sx(row) * pixelsize; % PSF half width. need double check
            rowdata(12) = 1;                        % channel
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
        
        % second channel
        set(handles.handles.hStatus, 'String', 'Converting second channel...');
        drawnow;
        
        locs = h5read(handles.filechan2, '/locs');
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
            rowdata(10) = locs.ellipticity(row);    % chi square. need double check. is it important?
            rowdata(11) = locs.sx(row) * pixelsize; % PSF half width. need double check
            rowdata(12) = 2;                        % channel
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