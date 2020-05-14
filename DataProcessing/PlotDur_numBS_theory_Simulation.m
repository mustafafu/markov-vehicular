set_hBs = [1.5,2,3,6,9];
ha = [1.46];
cv_lane = [ 4];

num_bs = 1:5;



load_file_string = ['veh_height', num2str(ha),'-veh_lane', num2str(cv_lane)];
load_file_string = strrep(load_file_string,'.',',')


outputs = dir([load_file_string,'*']);
num_files = length(outputs);

legend_string = [];
h=figure();
for ii=1:num_files
    aa = load([outputs(ii).folder,'/',outputs(ii).name]);
    semilogy(num_bs,aa.T_b,'DisplayName',['Thry hBs = ', num2str(aa.hBs)])
    hold on;
end
grid on;
xlabel('Number of Base Stations (nBs)')
ylabel('Average Duration of Blockage (ms)')



datadir = '/simulation_data/';


TB_sim = zeros(length(set_hBs),length(num_bs));
TB_ste = zeros(length(set_hBs),length(num_bs));



for hRidx = 1:length(set_hBs)
    for nRidx = 1:length(num_bs)
        hBs = set_hBs(hRidx)  % BS antenna height (in meters) 8->1 Lane 5->2 Lanes  2->3 Lanes
        numBs = num_bs(nRidx) % # of BSs in coverage area
        
        string_2 = [datadir, 'combined-numBS_',num2str(numBs),'-heightBS_',num2str(hBs),'-DurationList'];
        string_2 = strrep(string_2,'.',',');
        load(['.',string_2,'.mat'])
        
        
        TB_sim(hRidx,nRidx) = mean(mean(durationList));
        TB_ste(hRidx,nRidx) = std(durationList)/ sqrt( length(durationList) );
    end
end

markers = {'--bx','--b*','--bs','--bp','--b+'};
%h=figure();
for ii=1:length(set_hBs)
        errorbar(num_bs,TB_sim(ii,:),TB_ste(ii,:),markers{ii});
%     semilogy(num_bs,TB_sim(ii,:),markers{ii},'DisplayName',['Sim hBs = ', num2str(set_hBs(ii))]);
    hold on;
end
grid on;
legend();

xlabel('Number of Base Stations (nBs)')
ylabel('Average Duration of Blockage (ms)')
set(gca, 'YScale', 'log')




save_fig_string = strcat(['Duration-cv_height_',num2str(ha),'_on_lane_', num2str(cv_lane)]);
save_fig_string = strrep(save_fig_string,'.',',');
save_fig_string = ['../Figures/',save_fig_string, '.jpeg'];
saveas(h,save_fig_string);
save_fig_string = ['../Figures/',save_fig_string, '.fig'];
saveas(h,save_fig_string);

