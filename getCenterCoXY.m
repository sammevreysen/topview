function midcoxy = getCenterCoXY(coxy)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function getCenterCoXY calculates the coordinate in between adjacent
% points
%
%   INPUT:  coxy: size is N x 2 with coordinates
%   OUTPUT: midcoxy: center coordinates (size is N-1 x 2)
%
%   Samme Vreysen
%
%   21/04/2015
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    midcoxy = mean(cat(3,coxy(1:end-1,:),coxy(2:end,:)),3);