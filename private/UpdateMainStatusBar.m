function UpdateMainStatusBar(str)
    figObj = findobj('Tag', 'PALM GUI');
    warning('off');
    statusbar(figObj, str);
    warning('on');
end