function [MM,nb_indices,min_blocked_bs] = create_markov_matrix(num_bs,num_bl,lambda,mu)
%CREATE_MARKOV_MATRIX for given number of base stations and possible
%blocking lanes. 
%   Lambda and mu are num_blx1 vectors for each arrival and
%departure rate of the function
num_states=2^(num_bs*num_bl);
nb_indices = zeros(num_states,1);
nb_number = 0;
% MM=sparse(num_states,num_states);
min_blocked_bs = zeros(1,num_states);
rows = zeros(num_states*(num_bs*num_bl),1);
cols = zeros(num_states*(num_bs*num_bl),1);
values = zeros(num_states*(num_bs*num_bl),1);
ii=1;
for ss=1:num_states
    current_state = de2bi(ss-1,num_bs*num_bl);
    min_blockage = 100;
    is_ss_blocked = 1;
    for iBs=1:num_bs
        for iBl=1:num_bl
            bit_index = (iBs-1)*num_bl + iBl;
            next_state = current_state;
            if current_state(1,bit_index)==1
                next_state(1,bit_index) = 0;
                ss2 = bi2de(next_state)+1;
                rows(ii) = ss;
                cols(ii) = ss2;
                values(ii) = mu(iBl);
                ii=ii+1;
            elseif current_state(1,bit_index)==0
                next_state(1,bit_index) = 1;
                ss2 = bi2de(next_state)+1;
                rows(ii) = ss;
                cols(ii) = ss2;
                values(ii) = lambda(iBl);
                ii=ii+1;
            else
                print('something is wrong')
            end
        end
        if sum(current_state((iBs-1)*num_bl+1:iBs*num_bl))<1
            is_ss_blocked = 0;
        end
        this_blockage_number = sum(current_state((iBs-1)*num_bl+1:iBs*num_bl));
        if this_blockage_number<min_blockage
            min_blockage = this_blockage_number;
        end
    end
    min_blocked_bs(ss) = min_blockage;
    if is_ss_blocked == 0
        nb_number = nb_number+1;
        nb_indices(nb_number)=ss;
    end
%     MM(ss,ss) = -sum(MM(ss,:));
end

MM = sparse(rows(1:ii-1),cols(1:ii-1),values(1:ii-1),num_states,num_states);
diag_elements = -1*MM*ones(num_states,1);
A = spdiags(diag_elements,0,num_states,num_states);
MM = MM+A;
MM = [MM ones(num_states,1)];
nb_indices = nb_indices(1:nb_number);
end

