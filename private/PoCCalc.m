function [dataOut, SizeROI] = PoCCalc(Data, FuncType, Lr_rad, Sigma, roiHere)

    %%%%%%% Threshold measure at the randomness
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fprintf(1, 'Segment clustered points from background... \n');
    UpdateMainStatusBar('Segment clustered points from background...');

    SizeROI = polyarea(roiHere(:,1), roiHere(:,2));

    dataOut = zeros(size(Data, 1), 8);
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

    % Pass along data that meet threshold criteria
    % Original threshold is so convoluted that it basically equals Lr_rad.
    % Lr_Threshold should be number of points within Lr_r for a random
    % distrubution of the same number of points in the current ROI
    Lr_Threshold = (size(Data, 1)/SizeROI)*pi*Lr_rad^2;
    
    
    %Nrandom = (size(Data, 1)/SizeROI)*pi*Lr_rad^2; % Number of particles per Lr_rad circle expected
    %Lr_Threshold = ((SizeROI)*Nrandom/(size(Data, 1) - 1)/pi).^0.5;
    dataOut(:,8) = dataOut(:,3) > Lr_Threshold; % Particle has Lr_r score above that of a random distribution
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fprintf(1, 'Calculating PoC scores...\n');
    UpdateMainStatusBar('Calculating PoC scores...');

    [sum1, sum2] = calpoc(Data(:, 5), Data(:, 6), Data(:, 12), Sigma);
    sum1 = sum1(:); % convert to column array
    sum2 = sum2(:);
    PoC = zeros(size(sum1));
    c1_mask = Data(:, 12) == 1;
    c2_mask = Data(:, 12) == 2;
    if(FuncType == 1)
        sum = sum1 + sum2;
        PoC(c1_mask) = sum2(c1_mask) ./ sum(c1_mask);
        PoC(c2_mask) = sum1(c2_mask) ./ sum(c2_mask);
    else
        PoC(c1_mask) = sum2(c1_mask) ./ sum1(c1_mask);
        PoC(c2_mask) = sum1(c2_mask) ./ sum2(c2_mask);
    end

    dataOut(:, 6) = PoC;
             
    dataOut = array2table(dataOut,'VariableNames',{'X' 'Y' 'Lr' 'Ch' 'Density' 'PoC' 'D1_D2' 'Lr_rAboveThresh'});
        
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


