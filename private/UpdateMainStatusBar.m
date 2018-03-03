function UpdateMainStatusBar(str)
    figObj = findobj('Tag', 'PALM GUI');
    statusbar(figObj, str);
end