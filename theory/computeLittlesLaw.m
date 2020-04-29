function T_little = computeLittlesLaw(MM,nb_indices,min_blocked_bs,pVec)
%UNTITLED10 Summary of this function goes here
%   Detailed explanation goes here


indices = 1:size(MM,1);
b_indices = find(~ismember(indices,nb_indices));
sel_b_indices = zeros(size(MM,2),1);
sel_b_indices(b_indices)=1;
weighted_sum_rate = pVec(nb_indices)*MM(nb_indices,:)*sel_b_indices;
expected_num = min_blocked_bs(b_indices)*pVec(b_indices).';



T_little = expected_num/weighted_sum_rate;
end

