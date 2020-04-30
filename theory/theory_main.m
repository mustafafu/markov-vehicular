tic
% Trying to formulate lambda and mu processes when there are more than 1
% types of vehicles (depending on blockages)
set_hBs = [1.5,2,3,4,5,6,7,8,9,10];
set_ha = [1.46, 1.5, 1.74, 2,  2.32, 4.19];
set_lane = [3, 4];

num_bs = 1:5;

[hBshBs,haha,iiii] =  meshgrid(set_hBs,set_ha,set_lane);


AI = getenv('SLURM_ARRAY_TASK_ID')



if (isempty(AI))
    warning('Not running on HPC.')
    AI = '1';
    NAI = str2num(AI);
    % input parameters
    hBs = 6; % BS antenna height (in meters) 8->1 Lane 5->2 Lanes  2->3 Lanes
    ha = 1.5; % vehicle antenna height (in meters)
    cv_lane = 3;
    ii = cv_lane;
else
    NAI = str2num(AI);
    % input parameters
    hBs = hBshBs(NAI) % BS antenna height (in meters) 8->1 Lane 5->2 Lanes  2->3 Lanes
    ha = haha(NAI) % vehicle antenna height (in meters)
    cv_lane =  iiii(NAI)
    ii = cv_lane
end

rng(str2num(AI),'twister');

widthLane = 3.5;
Vc = 105; % communicating vehicle speed (km/h)
Vb = 100; % blocking vehicle speed (km/h)
% End of input parameters


% lambda_vehicle = 1/(Vb/3.6*2);  %following distance with a mean of 2 seconds between cars.
s_average = 1/0.0346; % average distance between vehicles
% mu_vehicle = 0.25; %random vehicle lengths with mean 4m.

Vc = Vc/3600; % Vc in m/ms
Vb = Vb/3600; % Vc in m/ms
criticalHeight = zeros(1,ii-1);
for jj = 1:ii-1
    criticalHeight(jj) = ha+(hBs-ha)*(ii-jj)/(ii-1/2); %using triangle similarity.
end


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
vehicleProb = [0.4022268255, 0.4022268255, 0.06385292595, 0.008907301916, 0.1227861212];

NUM_CLASSES = length(vehicleProb);

p_greater = zeros(ii-1,NUM_CLASSES); % each row: lane, each column: class of vehicle
p_smaller = zeros(ii-1,NUM_CLASSES); % each row: lane, each column: class of vehicle

mu_vehicle = zeros(1,ii-1);
lambda_vehicle = zeros(1,ii-1);

for jj=1:ii-1
    p_greater(jj,:) = qfunc((criticalHeight(jj)-heights)./height_sigmas);
    p_smaller(jj,:) = 1-p_greater(jj,:);
    mu_vehicle(jj) = 1/(sum(vehicleProb.*lengths.*p_greater(jj,:)/sum(vehicleProb.*p_greater(jj,:))));
    lambda_vehicle(jj) = 1/((1-sum(vehicleProb.*p_greater(jj,:)))/sum(vehicleProb.*p_greater(jj,:))*(s_average+sum(lengths.*p_smaller(jj,:)/sum(p_smaller(jj,:))))+s_average);
end


% Calculate corresponding arrival and service rates for each blocking lane
% blockingLanes = 1:ii-1;
% blockingLanes = check_blocking_lanes(hBs,ha,hb,ii);
blockingLanes = 1:ii-1;
% projection of the speed of the car in blocking lanes
Vbs = Vc*(blockingLanes-1/2)./(ii-1/2);
% calculate lambda and mu for each lane.
% lambda = fliplr(lambda_vehicle*p_sifting.*abs(Vbs-Vb));
lambda = fliplr(lambda_vehicle(1:length(Vbs)).*abs(Vbs-Vb));
mu = fliplr(mu_vehicle(1:length(Vbs)).*abs(Vbs-Vb));


%Creates the markov chain matrix with transition probabilities for given scenario.
P_b = zeros(size(num_bs));
T_b = zeros(size(num_bs));

for pp = num_bs
    [MM,nb_indices,min_blocked_bs] = create_markov_matrix(pp,length(blockingLanes),lambda,mu);
    
    b = sparse(1,size(MM,2),1,1,size(MM,2));
    pVec = b/MM;
    
    P_NB = full(sum(pVec(nb_indices)));
    P_b(pp) = 1-P_NB;
    
    %%  Blockage Duration
    MM2 = MM(1:end,1:end-1);
    T_little = computeLittlesLaw(MM,nb_indices,min_blocked_bs,pVec);
    T_b(pp) = T_little;
end

save_file_string = ['data/veh_height', num2str(ha),'-veh_lane', num2str(cv_lane), '-BS_height', num2str(hBs),'-Theory-',AI];
save_file_string = strrep(save_file_string,'.',',')

save(save_file_string,'P_b','T_b','ha','cv_lane','hBs');
toc
