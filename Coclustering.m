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
input.Approach2a.Enabled = true; % only run if enabled
input.Approach2a.Dir = fullfile(input.Dir, 'Approach2a');
input.Approach2a.OverlapDistance = 50; % maximum distance between 2 cluster to mark as coclustered
input.Approach2a.MaskChannel = 1; % a mask channel to compare to e.g. TCR
% Approach2b
input.Approach2b = {};
input.Approach2b.Enabled = true; % only run if enabled
input.Approach2b.Dir = fullfile(input.Dir, 'Approach2b');
input.Approach2a.NumNeighbours = 10; % Number of nearesh neighbours

if DEBUG
    % for quick Debug
    load(fullfile(input.Dir, 'dbscanResults.mat'));

else
    % load channel 1 to find number of regions
    fprintf('Loading DBSCAN results...\n');
    load(fullfile(input.Dir, sprintf('Ch%d', 1), 'DBSCAN_Cluster_Result.mat'));
    num_regions = numel(ClusterSmoothTable);
    
    dbscanResults = cell(num_regions, input.NumChannels);
    for rr=1:num_regions
        for ii=1:input.NumChannels
            fprintf('Loading DBSCAN result region %d channel %d...\n', rr, ii);
            load(fullfile(input.Dir, sprintf('Ch%d', ii), 'DBSCAN_Cluster_Result.mat'));
            result = {};
            result.ClusterSmoothTable = ClusterSmoothTable{1,1};
            result.Result = Result{1,1};
            dbscanResults{rr,ii} = result;
        end
    end
    clearvars ClusterSmoothTable Result
    % uncomment the following line to save for DEBUG
    %save(fullfile(input.Dir, 'dbscanResults.mat'), 'dbscanResults');
end

%% Main process
pointtypes = {'r.', 'g.', 'b.'};
linetypes = {'r', 'g', 'b'};
close all;

num_regions = size(dbscanResults, 1);
for rr=1:num_regions
    
    fprintf('Processing region %d ...\n', rr);
    
    % display points
    if input.ShowFigures
        figure;
        title(sprintf('Region %d', rr));
        hold on
    end

    for ii=1:input.NumChannels
        cmt = dbscanResults{rr, ii}.ClusterSmoothTable;
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
    end
    if input.ShowFigures
        hold off
    end

    % Approach2a
    if input.Approach2a.Enabled
        
        fprintf('Region %d Approach2a ...\n', rr);
        mkdir(input.Approach2a.Dir);
        maskClusters = dbscanResults{rr, input.Approach2a.MaskChannel}.ClusterSmoothTable;
        result2A = cell(numel(maskClusters), input.NumChannels-1);
        curChan = 0;
        for ii=1:input.NumChannels
            if ii == input.Approach2a.MaskChannel
                continue;
            end
            curChan = curChan + 1;
            curClusters = dbscanResults{rr, ii}.ClusterSmoothTable;
            fprintf('Comparing mask channel %d with channel %d ...\n', input.Approach2a.MaskChannel, ii);

            for c1 = 1:numel(maskClusters)
                result2A{c1, 2*(curChan-1)+1} = []; % channels
                result2A{c1, 2*(curChan-1)+2} = []; % min distances
                for c2 = 1:numel(curClusters)
                    D = pdist2(maskClusters{c1}.Points, curClusters{c2}.Points);
                    minD = min(D(:)); 
                    if(minD <= input.Approach2a.OverlapDistance)
                        if minD < 10
                            minD = 0;
                        end
                        result2A{c1, 2*(curChan-1)+1} = [result2A{c1, 2*(curChan-1)+1} c2];
                        result2A{c1, 2*(curChan-1)+2} = [result2A{c1, 2*(curChan-1)+2} minD];
                    end
                end
            end
        end
        
        % write results to files
        fprintf('Region %d Approach2a: saving results to files ...\n', rr);
        save(fullfile(input.Approach2a.Dir, sprintf('Approach2a_ROI%d_MaskChan%d.mat', rr, input.Approach2a.MaskChannel)), 'result2A');
        f = fopen(fullfile(input.Approach2a.Dir, sprintf('Approach2a_ROI%d_MaskChan%d.csv', rr, input.Approach2a.MaskChannel)), 'wt');
        fprintf(f, 'CluseterIndex,ClusterSize,Ch1_NumOverlap,Ch1_OverlapClusters,Ch1_MinDistances,Ch2_NumOverlap,Ch2_OverlapClusters,Ch2_MinDistances\n');
        for ii=1:size(result2A, 1)
            fprintf(f, '%d,%d,%d,%s,%s,%d,%s,%s\n',ii, numel(maskClusters{ii,1}.Points), numel(result2A{ii, 1}),array2str(result2A{ii, 1}),array2str(result2A{ii, 2}, 3), ...
                                                   numel(result2A{ii, 3}), array2str(result2A{ii, 3}), array2str(result2A{ii, 4}, 3));
        end
        fclose(f);
        
    end % approach 2a


    % Approach2b
    if input.Approach2b.Enabled
        
        fprintf('Region %d Approach2b ...\n', rr);
        mkdir(input.Approach2b.Dir);
        for ii=1:input.NumChannels

            Clusters1 = dbscanResults{rr, ii}.ClusterSmoothTable;

            for jj=1:input.NumChannels
                if jj == ii
                    continue;
                end
                fprintf('Region %d Approach2b between Ch%d and Ch%d ...\n', rr, ii, jj);
                result2B = zeros(numel(Clusters1), input.Approach2a.NumNeighbours);
                Clusters2 = dbscanResults{rr, jj}.ClusterSmoothTable;

                for c1 = 1:numel(Clusters1)
                    dists = zeros(numel(Clusters2), 1);
                    for c2=1:numel(Clusters2)
                        D = pdist2(Clusters1{c1}.Points, Clusters2{c2}.Points);
                        dists(c2) = min(D(:));
                        if (dists(c2) < 10)
                            dists(c2) = 0;
                        end
                    end
                    dists = sort(dists);
                    result2B(c1, :) = dists(1:input.Approach2a.NumNeighbours, 1);
                end

                % save result Ch{ii} Ch{jj}
                dlmwrite(fullfile(input.Approach2b.Dir, sprintf('Approach2b_ROI%d_Ch%d_Ch%d.csv', rr, ii, jj)), result2B);
                save(fullfile(input.Approach2b.Dir, sprintf('Approach2b_ROI%d_Ch%d_Ch%d.mat', rr, ii, jj)), 'result2B');
            end
        end
        
    end % approach2b
    
end  %regions

% Helpers
function res = array2str(arr, real)
    if nargin == 1
        real = false;
    end
    if real == false
        format = '%d';
    else
        format = '%0.2f';
    end
    res = '';
    if numel(arr) > 1
        res = sprintf(format, arr(1));
    end
    for ii=2:numel(arr)
        res = [res, ' ', sprintf(format, arr(ii))];
    end
end