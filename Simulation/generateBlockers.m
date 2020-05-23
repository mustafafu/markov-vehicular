function [carStartPositions, carLengths, carHeights] = generateBlockers(lambda,blockingLanes,sizeMat)

jj = length(blockingLanes);

distanceVec = exprnd(1/lambda,jj,sizeMat);


%now we dont generate car lengths exponentially but from real world statistics
% We have 5 vehicle classes. See
% https://docs.google.com/spreadsheets/d/1zVJ7LzDxbMI70hdvk_Qo-tDJyLVL9hnRRxhgTWmrMHM/edit?usp=sharing
% we want to compute the probability that a
% vehicle is higher than the critical height at that lane.

% Class length
lengths = [  4.37,    4.09,  3.3,    12.19,    16.5 ;
    4.8400, 4.9150, 5.0300, 15.2400, 17.3200;
    5.31,    5.74,  6.76,   18.29,    18.14];
length_sigmas = [0.1566666667, 0.275, 0.5766666667, 1.016666667, 0.2733333333];
% Class height
heights = [1.4,  1.52,  1.73,  3.96,  4;
    1.46,  1.74,  2.32,  4.19,  4.135;
    1.52,   1.96,   2.9,   4.42,   4.27];
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
%%% Turncated gaussian here
for idx_class = 1:length(height_sigmas)
    height_class_range = [heights(1,idx_class) heights(3,idx_class)] - heights(2,idx_class);
    length_class_range = [lengths(1,idx_class) lengths(3,idx_class)] - lengths(2,idx_class);
    carHeights = carHeights + (H==idx_class).* (heights(2,idx_class) + TruncatedGaussian(height_sigmas(idx_class),height_class_range, size(carHeights)));
    carLengths = carLengths + (H==idx_class).* (lengths(2,idx_class) + TruncatedGaussian(length_sigmas(idx_class),length_class_range, size(carLengths)));
end

shiftedSum = distanceVec + [zeros(jj,1) carLengths(:,1:end-1)];
carStartPositions = cumsum(shiftedSum,2); % starting positions of the vehicles on each lane

end

