%% Setup
record_distance = false;

set_hBs = [1.5,2,3,6,9];
set_num_bs = 1:2;
set_Vc = 60:5:140;

idx_len = length(set_hBs)*length(set_num_bs)*length(set_Vc);
[hBshBs,nbsnbs,vcvc] =  meshgrid(set_hBs,set_num_bs,set_Vc);

% vehicle parameters
Vb = 140; % blocking vehicle speed (km/h)

AI = getenv('SLURM_ARRAY_TASK_ID')

if(isempty(AI))
    warning('Not running on HPC.')
    AI = '1';
    NAI = str2num(AI);
    MAX_ITER = 2; % # of reinitialization and simulation
    NUM_BLOCK = 1000; % # of blockage events to record each iteration
    
    hBs = 3; % BS antenna height (in meters) BS antenna height (in meters) 8->1 Lane 5->2 Lanes  2->3 Lanes
    numBs = 5; % # of BSs in coverage area
else
    NAI = str2num(AI);
    
    MAX_ITER = 10; % # of reinitialization and simulation
    NUM_BLOCK = 1000; % # of blockage events to record each iteration
    idx = mod(NAI-1,idx_len)+1;
    hBs = hBshBs(idx)  % BS antenna height (in meters) 8->1 Lane 5->2 Lanes  2->3 Lanes
    numBs = nbsnbs(idx) % # of BSs in coverage area
    Vc = vcvc(idx); % communicating vehicle speed (km/h)
end

%%
% Shuffle RNG if running in MATLAB, not Octave
if ~exist ('OCTAVE_VERSION', 'builtin')
    rng(str2num(AI),'twister');
end


% Input parameters---------------------------------

% Simulation parameters
delta = 1; % simulation granularity in ms

% road parameters
numLane = 4; % number of lanes
whereisCV = 4; % lane on which the communicating vehicle goes
if whereisCV>numLane
    printf('vehicle is not on the road')
    exit
end
widthLane = 3.5;



lambda_vehicle = 0.0138406675; % There are 19310 vehicle on 7 lanes for 3 hours
% vehicle/lane/hour is apprx 919 vehicles.
% in one hour they travel about 72000m, each vehicle is 6.5m long on avg.
% (72000 - 6.5 * 919)/919 is the mean spacing per vehicle. 1/this is the
% lambda vehicle. Available on this link
% https://docs.google.com/spreadsheets/d/1IH6ruqNTP6ze9IHhhbslzzmgfgH6JRiYcM9jvc54I3o/edit?usp=sharing


Vc = Vc/3600; % Vc in m/ms
Vb = Vb/3600; % Vc in m/ms

% height parameters
ha = 1.46; % vehicle antenna height (in meters) mean height of class 1 vehicle

% BS parameters
Rlos = 200; % LoS coverage distance
%--------------------------------------------------


% Other parameters to compute----------------------
% Indicate possibly blocking lanes
blockingLanes = 1:whereisCV - 1;

% Compute coverage area
temp = sqrt(Rlos^2-(hBs-ha)^2);
temp = sqrt(temp^2-((whereisCV-1/2)*widthLane)^2);
Rcov = temp*2; % Horizontal LoS coverage distance

% Compute inter-BS distance
dBs = Rcov/numBs;
%--------------------------------------------------

% Variables----------------------------------------
probabilityIter = cell(MAX_ITER,1);
durationIter = cell(MAX_ITER,1);
numBlockIter = cell(MAX_ITER,1);

if record_distance
    distanceIter = cell(MAX_ITER,1);
    connectionStateIter = cell(MAX_ITER,1);
end

% Initializing vehicle locationss
yLocs=fliplr((blockingLanes-0.5)*widthLane);

for iter = 1:MAX_ITER
    tic
    iter
    %     if rem(iter,(MAX_ITER/10))==0
    %         iter
    %         toc
    %     end
    blockageCount = 0; % # of blockages that has been observed
    % Initializing the scenario
    locCv = [Rcov/2,(whereisCV-1/2)*widthLane]; % initial location of the communicating vehicle
    % Initializing BS locations
    initialBsLoc = randi(floor(dBs)); % random location for the first BS in the coverage range
    % locBs = initialBsLoc:dBs:(numBs-1)*dBs+initialBsLoc; % initial BS locations
    locBs = initialBsLoc:dBs:min(Rcov, ceil(numBs-1)*dBs+initialBsLoc); % initial BS locations
    %     locBsProjected = computeBsProjections(locBs,whereisCV,blockingLanes,locCv);
    % Initializing blocker locations
    [carStartPositions, carLengths, carHeights] = generateBlockers(lambda_vehicle,blockingLanes,200); %initial blocker locations
    
    % Initialize blocking state
    locBsProjected = computeBsProjections(locBs,whereisCV,blockingLanes,locCv);
    
    output = checkConnection(carStartPositions,carLengths,carHeights,locBsProjected,blockingLanes,hBs, whereisCV, ha,locBs,locCv);
    state=output{1};
    isBs_blocked = output{2};
    if record_distance
        distance = output{3};
    end
    
    time = 0;
    blockageDuration = 0;
    blockageVec = zeros(1,NUM_BLOCK);
    time_limit = max(max(max(carStartPositions)))/(Vc-Vb);
    if record_distance
        distances = zeros(ceil(numBs),floor(time_limit*0.9));
        connectionStates = zeros(ceil(numBs),floor(time_limit*0.9));
    end
    while time<=floor(time_limit*0.9)
        time = time + delta;
        locCv(1) = locCv(1) + delta*Vc; % move the communicating vehicle
        
        newBsLoc = locBs(end)+dBs;
        
        if (newBsLoc <= locCv(1)+Rcov/2)
            locBs = [locBs newBsLoc];
        end
        
        if(locBs(1)<locCv(1)-Rcov/2) % if the first BS is out of range, create another BS
            locBs = [locBs(2:end)];
        end
        
        locBsProjected = computeBsProjections(locBs,whereisCV,blockingLanes,locCv);
        
        
        
        carStartPositions = carStartPositions + delta*Vb; % move all blocking vehicles
        pre_state = state;
        output = checkConnection(carStartPositions,carLengths,carHeights,locBsProjected,blockingLanes,hBs, whereisCV, ha,locBs,locCv);
        state=output{1};
        isBs_blocked = output{2};
        if record_distance
            distance = output{3};
            distances(1:length(locBs),time) = distance';
            connectionStates(1:length(locBs),time) = isBs_blocked';
        end
        
        
        
        if(pre_state == 0)
            blockageDuration = blockageDuration + delta;
            if(state==1) % end of blockage, record duration
                blockageCount = blockageCount + 1;
                blockageVec(blockageCount) = blockageDuration;
                blockageDuration = 0;
            end
        end
    end
    probabilityIter{iter} = sum(blockageVec)/time;
    durationIter{iter} = blockageVec(1:blockageCount);
    numBlockIter{iter} = blockageCount;
    if record_distance
        distanceIter{iter}= distances;
        connectionStateIter{iter} = connectionStates;
    end
    toc
end
save_file_string = ['data/numBS_', num2str(numBs), '-heightBS_', num2str(hBs), '-BlockageDurationPercentage-BlockageDurations-',AI];
save_file_string = strrep(save_file_string,'.',',')

if record_distance
    save(save_file_string, 'probabilityIter','durationIter', 'numBlockIter', 'connectionStateIter', 'distanceIter');
else
    save(save_file_string, 'probabilityIter','durationIter', 'numBlockIter');
end








