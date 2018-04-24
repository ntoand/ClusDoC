function scalebar(handle, maxsize)
% draw scale bar on a plot given handle

axes(handle);

if(maxsize > 40000)
    length = 4000;
    str = '4000nm';
    offset = 800;
    pos = [800 800];
    
elseif(maxsize > 10000)
    length = 2000;
    str = '2000nm';
    offset = 350;
    pos = [400 400];
elseif(maxsize > 5000)
    length = 1000;
    str = '1000nm';
    offset = 120;
    pos = [200 200];
else
    length = 100;
    str = '100nm';
    offset = 30;
    pos = [50 30];
end

pos = pos + [handle.XLim(1) handle.YLim(1)];
x = [pos(1) pos(1)+length];
y = [pos(2) pos(2)];
line(x, y, 'LineWidth', 2, 'Color', 'black');
text(pos(1)+length/2, pos(2)+offset, str, 'HorizontalAlignment', 'center');