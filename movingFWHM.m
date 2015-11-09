function v = movingFWHM(x,m)
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
    %apply moving FWHM filter and replace original values  
    K=inline('exp(-(x.^2+y.^2)/2/sig^2)');
    [dx,dy] = meshgrid(-floor(m/2):floor(m/2));
    weight = K(1,dx,dy)/sum(sum(K(1,dx,dy)));
    v(~isnan(x(:,1)),:) = conv2(a,weight,'same');