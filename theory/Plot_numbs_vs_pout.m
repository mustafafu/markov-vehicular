set_hBs = [1.5,2,3,4,5,6,7,8,9,10];
set_ha = [1.46, 1.5, 1.74, 2,  2.32, 4.19];
set_lane = [3, 4];

num_bs = 1:5;


for ha_idx = 1:length(set_ha)
    for lane_idx = 1:length(set_lane)
        ha = set_ha(ha_idx);
        cv_lane = set_lane(lane_idx);
        
        
        load_file_string = ['veh_height', num2str(ha),'-veh_lane', num2str(cv_lane)];
        load_file_string = strrep(load_file_string,'.',',')
        
        
        outputs = dir(['data/',load_file_string,'*']);
        num_files = length(outputs);
        
        legend_string = [];
        h=figure();
        for ii=1:num_files
            aa = load([outputs(ii).folder,'/',outputs(ii).name]);
            semilogy(num_bs,aa.P_b,'DisplayName',['hBs = ', num2str(aa.hBs)])
            hold on;
        end
        grid on;
        legend();
        title(['cv height = ',num2str(ha),' on lane = ', num2str(cv_lane)])
        
        
        save_fig_string = strcat(['cv_height_',num2str(ha),'_on_lane_', num2str(cv_lane)]);
        save_fig_string = strrep(save_fig_string,'.',',');
        save_fig_string = ['./Figures/',save_fig_string, '.jpeg'];
        saveas(h,save_fig_string);
    end
end
