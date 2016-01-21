function vout = smoothLine(vin,span)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function smoothLine smooths a vector using weighted moving average with
% weight the complement of the relative 2nd differential
%
%   INPUT: vin   - input vector
%          span  - the span of the moving average
%   OUTPUT: vout - the smoothed vector
%
%   Samme Vreysen
%   22/04/2015
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    vin = vin(:);
    if(length(vin) > 2)
        secdiff = diff([vin(2); vin; vin(end-1)],2);
        w = 1-(abs(secdiff)./max(abs(secdiff)));
        vout = wmean(vin,w,span);
    else
        vout = vin;
    end