function v = movingaverage(x,m)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function movingFWHM applies FWHM (Full Width at Half-Maximum) function to
% an 2-D matrix without interference of padding NaN's along first dimension
% using a sliding window.
%
% INPUT:     x: 2-D matrix with NaN's padding along the first dimension alowed
%            m: window size
%
% Samme Vreysen
% 14/04/2015
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %remove nan's in first dimension
    a = x(~isnan(x(:,1)),:);
    v = x;
    %apply moving average filter and replace original values
    f = fspecial('average',m);
    v(~isnan(x(:,1)),:) = filter2(f,a);
 