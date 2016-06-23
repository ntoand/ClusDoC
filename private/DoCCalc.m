function [Data_DegColoc, SizeROI] = DoCCalc(Data, Lr_rad, Rmax, Step, roiHere)


    %%%%%%% Threshold measure at the randomness
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fprintf(1, 'Segment clustered points from background... \n');

    SizeROI = max(roiHere(3:4));

    dataOut = zeros(size(Data, 1), 7);
    dataOut(:,4) = Data(:,12);

    % All the value (data, idx, Dis, Density) are calculated for the
    % total number of particle regardless which channel they belong to
    [dataOut(:,1:3), ~, ~, dataOut(:,5)] = Lr_Subfun(Data(:,5), Data(:,6), Data(:,5), Data(:,6), Lr_rad, SizeROI); % data=[X Y Lr Kfuncans], Density=global;

    % Value calculated for a specific channel
    % unused
    [~, ~, ~, dataOut(dataOut(:,4) == 1, 7) ] = Lr_Subfun(Data(Data(:,12) == 1,5), Data(Data(:,12) == 1,6), ...
        Data(Data(:,12) == 1,5), Data(Data(:,12) == 1,6), Lr_rad, SizeROI); 
    [~, ~, ~, dataOut(dataOut(:,4) == 2, 7) ] = Lr_Subfun(Data(Data(:,12) == 2,5), Data(Data(:,12) == 2,6), ...
        Data(Data(:,12) == 2,5), Data(Data(:,12) == 2,6), Lr_rad, SizeROI);   

    % Split data up to reduce overhead passed to workers
    x1 = dataOut(dataOut(:,4) == 1, 1);
    y1 = dataOut(dataOut(:,4) == 1, 2); 

    x2 = dataOut(dataOut(:,4) == 2, 1);
    y2 = dataOut(dataOut(:,4) == 2, 2); 


    %[idx1,Dis]=rangesearch([x1 y1],[x1 y1],Rmax);
    %D1max=(cellfun(@length,idx1)-1)/(Rmax^2);
    D1max = sum(dataOut(:,4) == 1)/SizeROI^2;

    %[idx2,Dis]=rangesearch([x2 y2],[x1 y1],Rmax);
    %D2max=(cellfun(@length,idx2))/(Rmax^2);
    D2maxCh1Ch2 = sum(dataOut(:,4) == 2)/SizeROI^2; % why is this defined one

    D2maxCh2Ch1 = (cellfun(@length, rangesearch([x1 y1], [x2 y2], Rmax)))/(Rmax^2); % check for Ch2 points that are Rmax within Ch1

    %i=0;
    N11 = zeros(sum(dataOut(:,4) == 1), ceil(Rmax/Step));
    N12 = zeros(sum(dataOut(:,4) == 1), ceil(Rmax/Step));
    N22 = zeros(sum(dataOut(:,4) == 2), ceil(Rmax/Step));
    N21 = zeros(sum(dataOut(:,4) == 2), ceil(Rmax/Step));
    
    tic
    
    fprintf(1, 'Calculating DoC scores...\n');
    % DoC calculation for Chan1 -> Chan1, Chan1 -> Chan2
    parfor i = 1:ceil(Rmax/Step)

        r = Step*i;                           

        num_points = kdtree2rnearest(x1, y1, x1, y1, r)-1; % Ch1 -> Ch1
        N11(:, i) = num_points ./ (D1max*r^2);

        num_points = kdtree2rnearest(x2, y2, x1, y1, r); % Ch1 -> Ch2
        N12(:, i) = num_points ./ (D2maxCh1Ch2*r^2);

        num_points = kdtree2rnearest(x2, y2, x2, y2, r)-1; % Ch2 -> Ch2
        N22(:, i) = num_points ./ (D1max*r^2);

        num_points = kdtree2rnearest(x1, y1, x2, y2, r); % Ch2 -> Ch1
        N21(:, i) = num_points' ./ (D2maxCh2Ch1*r^2);

    end

    fprintf(1, 'Correlating coefficients...\n');

    SA1 = zeros(size(x1, 1), 1);
    SA2 = zeros(size(x2, 1), 1);

    for i=1:size(x1, 1)

        SA1(i,1) = corr(N11(i,:)', N12(i,:)', 'type', 'spearman');
        
        if le(i, size(x2, 1)) % Don't try to calc chan2 results if there aren't any chan2 ponits left!
            SA2(i,1) = corr(N22(i,:)', N21(i,:)','type','spearman');
        end

    end

%     SA1a = SA1;
    SA1(isnan(SA1)) = 0;

%     SA2a = SA2;
    SA2(isnan(SA2)) = 0;

    [~, NND1] = knnsearch([x2 y2], [x1 y1]);
    dataOut(dataOut(:,4) == 1, 6) = SA1.*exp(-NND1/Rmax);

    [~, NND2] = knnsearch([x1 y1], [x2 y2]);
    dataOut(dataOut(:,4) == 2, 6) = SA2.*exp(-NND2/Rmax);

%     DoCcoef.SA1a = SA1a; 
%     DoCcoef.SA1 = SA1;
%     DoCcoef.CA1 = CA1;
% 
%     DoCcoef.SA2a = SA2a;
%     DoCcoef.SA2 = SA2;
%     DoCcoef.CA2 = CA2;

    toc

    dataOut = array2table(dataOut,'VariableNames',{'X' 'Y' 'Lr' 'Ch' 'Density' 'DoC' 'D1_D2'});

    Data_DegColoc = dataOut;% dataOut=[X Y Lr Kf Ch Density ColocalCoef]
        
end

% Lr_rSubfun as subfunction form of Lr_rfun 
% here to avoid issues with private function calls
function [ data,idx,Dis,Density] = Lr_Subfun(X1, Y1, X2, Y2, r, SizeROI)

% SizeROI= size of the square (inmost case 4000nm)
       
        if isempty(X1) || isempty(X2)
            data = [];
            idx = [];
            Dis = [];
            Density = [];
        else
            
           if length(X1) ~= length(X2) 
               k = 0;
           elseif X1 ~= X2
               k = 0;
           elseif X1 == X2
               k = 1;
           end
               
        [idx, Dis] = rangesearch([X1, Y1], [X2, Y2], r); % find element of [x y] in a raduis of r from element of [x y]
        Kfuncans = cellfun('length', idx) - k;     % remove the identity
        Density = cellfun('length', idx) / (pi*r^2); %/(length(X2)/SizeROI^2); % Relative Density
        
        Lr = ((SizeROI)^2*Kfuncans / (length(X2) - 1)/pi).^0.5;     % calculate L(r)
        data=[X2, Y2, Lr];

        end 
end

