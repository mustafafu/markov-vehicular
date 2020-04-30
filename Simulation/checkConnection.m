function output = checkConnection(carStartPositions,carLengths,carHeights,locBsProjected,blockingLanes,hBs, whereisCV, ha,reallocBs,locCv)
output = cell(3,1);
numBs = size(locBsProjected,2);
isBS_blocked = zeros(1,numBs);
distances = zeros(1,numBs);
isConnected = 0;
for bInd = 1:numBs % go over all BSs
    x_pos_BS = reallocBs(bInd);
    y_pos_BS = 0;
    z_pos_BS = hBs;
    x_pos_CV = locCv(1);
    y_pos_CV = locCv(2);
    z_pos_CV = ha;
    distances(bInd) = sqrt( abs(x_pos_BS - x_pos_CV)^2 + abs(y_pos_BS-y_pos_CV)^2 + abs(z_pos_BS-z_pos_CV)^2 );
    for jInd = blockingLanes
        locBs = locBsProjected(jInd,bInd);
        % BS-UE line of sight link height
        criticalHeight = (hBs - ha) * (whereisCV-jInd) / (whereisCV - 0.5) + ha; %triangle similarity
        vehicleInd = find(carStartPositions(jInd,:)<locBs,1,'last');
        if (carStartPositions(jInd,vehicleInd) + carLengths(jInd,vehicleInd)) > locBs 
          if carHeights(jInd,vehicleInd) > criticalHeight % vehicle is blocking the BS projection
            isBS_blocked(bInd) = 1;
            break;
          end
        end
    end
    %instead of stopping once we found a connected BS we will keep going over the other base stations for statistical purposes hence the break inside this if statement is commented out
    if isBS_blocked(bInd) == 0
        nbId = bInd;
        isConnected = 1;
        %break;
    end
    
end


output{1} = isConnected;
output{2} = isBS_blocked;
output{3} = distances;  
end

