% Post process: analyse coclustering (Approach2ab) from DBSCAN results
% You need to run DBSCAN on separate clusters first. The DBSCAN results will
% be stored in "DBSCAN Results" folder

close all
clear
DEBUG = false;

%% Input and loading
input = {};
input.Dir = '/Users/toand/git/mivp/projects/nsw-melbourne/cluster_analysis/ClusDoC/test_dataset/3channels/Condition1_3G/Extracted_Region/DBSCAN Results';
input.NumChannels = 3;
input.ShowFigures = true;
% Approach2a
input.Approach2a = {};
input.Approach2a.Dir = fullfile(input.Dir, 'Approach2a');
input.Approach2a.OverlapDistance = 10; % maximum distance between 2 cluster to mark as coclustered
input.Approach2a.MaskChannel = 1; % a mask channel to compare to e.g. TCR

if DEBUG
    % for quick Debug
    load(fullfile(input.Dir, 'dbscanResults.mat'));

else
    dbscanResults = cell(input.NumChannels, 1);
    for ii=1:input.NumChannels
        load(fullfile(input.Dir, sprintf('Ch%d', ii), 'DBSCAN_Cluster_Result.mat'));
        result = {};
        result.ClusterSmoothTable = ClusterSmoothTable{1,1};
        result.Result = Result{1,1};
        dbscanResults{ii, 1} = result;
    end
    save(fullfile(input.Dir, 'dbscanResults.mat'), 'dbscanResults');
    
end

%% Display input data
pointtypes = {'r.', 'g.', 'b.'};
linetypes = {'r', 'g', 'b'};
close all;
if input.ShowFigures
    figure;
    hold on
end

for ii=1:input.NumChannels
    cmt = dbscanResults{ii, 1}.ClusterSmoothTable;
    points = [];
    for c=1:numel(cmt)
        points = [points; cmt{c}.Points];
        Contour = cmt{c}.Contour;
        if input.ShowFigures
            plot(Contour(:, 1), Contour(:, 2), linetypes{ii}, 'LineWidth',1);
        end
    end
    if input.ShowFigures
        scatter(points(:, 1), points(:, 2), pointtypes{ii});
    end
    dbscanResults{ii}.points = points;
end
if input.ShowFigures
    hold off
end

%% Approach2a
maskClusters = dbscanResults{input.Approach2a.MaskChannel, 1}.ClusterSmoothTable;
result2A = cell(numel(maskClusters), input.NumChannels-1);
curChan = 0;
disp('Run Approach2a');
for ii=1:input.NumChannels
    if ii == input.Approach2a.MaskChannel
        continue;
    end
    curChan = curChan + 1;
    curClusters = dbscanResults{ii, 1}.ClusterSmoothTable;
    fprintf('Compare with channel %d\n', ii);
    
    for c1 = 1:numel(maskClusters)
        result2A{c1, 2*(curChan-1)+1} = []; % channels
        result2A{c1, 2*(curChan-1)+2} = []; % min distances
        for c2 = 1:numel(curClusters)
            D = pdist2(maskClusters{c1}.Points, curClusters{c2}.Points);
            minD = min(D(:));
            if(minD <= input.Approach2a.OverlapDistance)
                result2A{c1, 2*(curChan-1)+1} = [result2A{c1, 2*(curChan-1)+1} c2];
                result2A{c1, 2*(curChan-1)+2} = [result2A{c1, 2*(curChan-1)+2} minD];
            end
        end
    end
end


%% Approach2a write result to csv file
mkdir(input.Approach2a.Dir);
save(fullfile(input.Approach2a.Dir, sprintf('Approach2a_MaskChan%d.mat', input.Approach2a.MaskChannel)), 'result2A');
f = fopen(fullfile(input.Approach2a.Dir, sprintf('Approach2a_MaskChan%d.csv', input.Approach2a.MaskChannel)), 'wt');
fprintf(f, 'CluseterIndex, ClusterSize, Ch1_NumOverlap, Ch1_OverlapClusters, Ch1_MinDistances, Ch2_NumOverlap, Ch2_OverlapClusters, Ch2_MinDistances\n');
for ii=1:size(result2A, 1)
    fprintf(f, '%d, %d, %d, %s, %s, %d, %s, %s\n',ii, numel(maskClusters{ii,1}.Points), numel(result2A{ii, 1}),mat2str(result2A{ii, 1}),mat2str(result2A{ii, 2}, 2), ...
                                           numel(result2A{ii, 3}),mat2str(result2A{ii, 3}),mat2str(result2A{ii, 4}, 2));
end
fclose(f);
