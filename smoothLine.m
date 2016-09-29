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
        maxsecdiff = max(abs(secdiff(2:end-1)));
        w = 1-(abs(secdiff)./maxsecdiff);
        w([1 length(w)]) = 0.85;
        vout = wmean(vin,w,span);
    else
        vout = vin;
    end