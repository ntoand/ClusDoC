function save_plot(tif_filename, h, save_as_fig)
% Save plot handle h to tiff and fig if (save_as_fig = true)

print(tif_filename, h, '-dtiff');

if(nargin > 2 && save_as_fig)
    [pathstr,name] = fileparts(tif_filename);
    fig_filename = fullfile(pathstr, [name '.fig']);
    saveas(h, fig_filename);
end