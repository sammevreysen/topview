function out = inpaint_nans_no_extrapolation(in)
    tmp = in(:,1);
    sel = true(size(tmp));
    %remove outerpolation
    idf = find(~isnan(tmp),1,'first');
    if(idf > 1)
        sel(1:idf-1) = 0;
    end
    idf = find(~isnan(tmp),1,'last');
    if(idf < length(tmp))
        sel(idf+1:end) = 0;
    end
    %smart interpolate
    out = inpaint_nans(in(sel,:),3);