%% Data Parser
datadir = '/data';

set_hBs = [1.5,2,3,6,9];
set_num_bs = 1:5;

[hBshBs,nbsnbs] =  meshgrid(set_hBs,set_num_bs);


for NAI = 1:length(hBshBs(:))
    hBs = hBshBs(NAI)  % BS antenna height (in meters) 8->1 Lane 5->2 Lanes  2->3 Lanes
    numBs = nbsnbs(NAI) % # of BSs in coverage area
    string_1 = [datadir, '/numBS_',num2str(numBs),'-heightBS_',num2str(hBs)];
    string_1 = strrep(string_1,'.',',')
    matrix_list = dir(['.',string_1,'*'])
    if length(matrix_list) >0
        load(['.',datadir,'/',strtrim(matrix_list(1).name)]);
    else
        continue;
    end
    iter_size = size(durationIter,1);
    num_iter = size(matrix_list,1);
    CellDuration = cell(1,iter_size*num_iter);
    CellNumBlock = cell(iter_size*num_iter,1);
    CellProbability = cell(iter_size*num_iter,1);
    for jj=1:length(matrix_list)
        load(['.',datadir,'/',strtrim(matrix_list(jj).name)]);
        CellDuration(1, ((jj-1)*iter_size +1):((jj)*iter_size)) = durationIter;
        CellNumBlock(((jj-1)*iter_size +1):((jj)*iter_size),1) = numBlockIter;
        CellProbability(((jj-1)*iter_size +1):((jj)*iter_size),1) = probabilityIter;
    end
    durationList = cell2mat(CellDuration);
    CellDuration =0;
    NumBlock = cell2mat(CellNumBlock);
    CellNumBlock = 0;
    Probability = cell2mat(CellProbability);
    CellProbability =0;
    mkdir(['.',datadir,'/combined_data']);
    string_2 = [datadir,'/combined_data', '/combined-numBS_',num2str(numBs),'-heightBS_',num2str(hBs),'-Durations-Probabilities'];
    string_2 = strrep(string_2,'.',',');
    save(['.',string_2,'.mat'], 'NumBlock','Probability','durationList')
    string_3 = [datadir,'/combined_data','/combined-numBS_',num2str(numBs),'-heightBS_',num2str(hBs),'-DurationList'];
    string_3 = strrep(string_3,'.',',');
    save(['.',string_3,'.mat'], 'durationList')
end


