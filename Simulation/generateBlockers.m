function [carStartPositions, carLengths, carHeights] = generateBlockers(lambda,blockingLanes,sizeMat)

jj = length(blockingLanes);

distanceVec = exprnd(1/lambda,jj,sizeMat);


%now we dont generate car lengths exponentially but from real world statistics 
% We have 5 vehicle classes. See
% https://docs.google.com/spreadsheets/d/1zVJ7LzDxbMI70hdvk_Qo-tDJyLVL9hnRRxhgTWmrMHM/edit?usp=sharing
% we want to compute the probability that a
% vehicle is higher than the critical height at that lane.

% Class length
lengths = [4.8400, 4.9150, 5.0300, 15.2400, 17.3200];
length_sigmas = [0.1566666667, 0.275, 0.5766666667, 1.016666667, 0.2733333333];
% Class height
heights = [1.46, 1.74, 2.32, 4.19, 4.135];
height_sigmas = [0.02, 0.07333333333, 0.1933333333, 0.07666666667, 0.045];
% Class probabilities
vehicleProb = [0.2731603749, 0.5313034022, 0.06384961939, 0.008906840661,0.1227797628];

% taking random class samples with corresponding probabilities
Prob = cumsum([0 vehicleProb]);
[~,~,H] = histcounts(rand(jj, sizeMat),Prob);

% we will get height and length of the random sampled class using H as a
% mask matrix.
carHeights = zeros(jj, sizeMat);
carLengths = zeros(jj, sizeMat);
for idx_class = 1:length(heights)
    carHeights = carHeights + (H==idx_class).* normrnd(heights(idx_class), height_sigmas(idx_class), [jj, sizeMat]);
    carLengths = carLengths + (H==idx_class).* normrnd(lengths(idx_class), length_sigmas(idx_class), [jj, sizeMat]);
end

shiftedSum = distanceVec + [zeros(jj,1) carLengths(:,1:end-1)];
carStartPositions = cumsum(shiftedSum,2); % starting positions of the vehicles on each lane

end

