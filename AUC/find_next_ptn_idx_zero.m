function ptn_idx = find_next_ptn_idx_zero(trace)
       ptn_idx = find(trace==0, 1, 'first');