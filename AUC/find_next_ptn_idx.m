function ptn_idx = find_next_ptn_idx(trace , idx)
        traceS = sign(trace);
        dtrace = diff(traceS(idx:end));
        ptn_idx = find(dtrace <0 , 1 , 'first');