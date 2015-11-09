function vout = wmean(vin,w,span)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function wmean performs a moving average over a vector vin based on a
% local weight within the window
%
%   INPUT: vin   - input vector
%          w     - weight vector with same dimensions as input vector vin
%          span  - the span of the moving average
%   OUTPUT: vout - the smoothed vector
%
%   Samme Vreysen
%   22/04/2015
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    vout = nan(size(vin));    
    vin = vin(:);
    window = -floor(span/2):floor(span/2);
    for i=1:size(vin,1)
        cw = window + i;
        cw = cw(cw > 0 & cw <= size(vin,1));
        vout(i) = sum(w(cw).*vin(cw))./sum(w(cw));
    end