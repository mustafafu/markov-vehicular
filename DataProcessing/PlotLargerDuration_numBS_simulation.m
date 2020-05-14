
datadir = '/simulation_data';
set_hBs = [1.5,2,3,6,9];
ha = [1.46];
cv_lane = [ 4];

num_bs = 1:5;


set_target_latency = [25, 40, 200, 500, 800, 1000]; %in ms target latency,
%script will return what percentage of the time the latency is less than this target duration.

% Dur_sim = zeros(length(set_hBs),length(num_bs));
Cant_Achieve = zeros(length(set_hBs),length(num_bs),length(set_target_latency));

for hRidx = 1:length(set_hBs)
    for nRidx = 1:length(num_bs)
        hBs = set_hBs(hRidx)  % BS antenna height (in meters) 8->1 Lane 5->2 Lanes  2->3 Lanes
        numBs = num_bs(nRidx) % # of BSs in coverage area
        
        string_3 = [datadir, '/combined-numBS_',num2str(numBs),'-heightBS_',num2str(hBs),'-Durations-Probabilities'];
        string_3 = strrep(string_3,'.',',');
        load(['.',string_3,'.mat'])
        
        P_b = mean(Probability);
        durationList = sort(durationList)';
        
        for tl_idx = 1:length(set_target_latency)
            target_latency = set_target_latency(tl_idx);
            if ~isempty(durationList)
                if ~isempty(find(target_latency < durationList,1))
                    tgtIdx = find(target_latency < durationList,1);
                else
                    tgtIdx = length(durationList);
                end
            else
                Cant_Achieve(hRidx,nRidx,tl_idx) = P_b;
                continue;
            end
            achieved_duration = sum(durationList(1:tgtIdx));
            total_blockage_duration = sum(durationList);
            if ~isempty(tgtIdx)
                Cant_Achieve(hRidx,nRidx,tl_idx) = P_b  -  P_b * (achieved_duration/total_blockage_duration);
            else
                Cant_Achieve(hRidx,nRidx,tl_idx) = P_b;
            end
        end
        
    end
end





% 
% 
% markers = {'--bx','--b*','--bs','--bp','--b+'};
% %h=figure();
% for ii=[1,5]%1:length(set_hBs)
%     %         errorbar(num_bs,TB_sim(ii,:),TB_ste(ii,:),markers{ii});
%     semilogy(num_bs,Cant_Achieve(ii,:),markers{ii},'DisplayName',['Sim hBs = ', num2str(set_hBs(ii))]);
%     hold on;
% end
% grid on;
% legend();
% xlabel('Number of Base Stations (nBs)')
% ylabel('Probability of Tb > Dt')
% set(gca, 'YScale', 'log')