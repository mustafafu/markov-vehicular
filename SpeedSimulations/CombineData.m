%% Data Parser
datadir = '/data';
set_hBs = [1.5,2,3,6,9];
set_num_bs = 1:2;
set_Vb = 60:5:135;

idx_len = length(set_hBs)*length(set_num_bs)*length(set_Vb);
[hBshBs,nbsnbs,vbvb] =  meshgrid(set_hBs,set_num_bs,set_Vb);



BlockageDurations = cell(length(set_hBs),length(set_num_bs),length(set_Vb));


for NAI = 1:length(hBshBs(:))
    hBs = hBshBs(NAI)  % BS antenna height (in meters) 8->1 Lane 5->2 Lanes  2->3 Lanes
    numBs = nbsnbs(NAI) % # of BSs in coverage area
    Vb = vbvb(NAI)
    string_1 = [datadir, '/numBS_',num2str(numBs),'-heightBS_',num2str(hBs),'-Vb_',num2str(Vb)];
    string_1 = strrep(string_1,'.',',')
    matrix_list = dir(['.',string_1,'*'])
    
    if length(matrix_list) >0
        load(['.',datadir,'/',strtrim(matrix_list(1).name)]);
    else
        continue;
    end
    CellDuration = cell(length(matrix_list),1);
    for jj=1:length(matrix_list)
        load(['.',datadir,'/',strtrim(matrix_list(jj).name)]);
        
        CellDuration{jj,1} = cell2mat(durationIter);
    end
    durationList = cell2mat(CellDuration);
    
    
    
    
    
    mkdir(['.',datadir,'/combined_data']);
    string_2 = [datadir,'/combined_data', '/combined-numBS_',num2str(numBs),'-heightBS_',num2str(hBs),'-Vb_',num2str(Vb)];
    string_2 = strrep(string_2,'.',',');
    save(['.',string_2,'.mat'], 'durationList')
end

