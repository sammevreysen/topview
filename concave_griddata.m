function vi = concave_griddata(x,y,v,xi,yi)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function concave_griddata performs linear interpolation on scattered data
% and removes extrapolated points from concave shaped data.
%
% INPUT:     see griddata
%            x,y: 2D spacially ordered coordinates
%
% Samme Vreysen
% 28/01/2016
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %interpolate scattered data
    vi = griddata(x,y,v,xi,yi);
    xs = reshape(x',[],1);
    ys = reshape(y',[],1);
    %remove extrapolated points from concave shaped data
    [m,n] = size(v);
    %find edge
    c = [1:n 2*n:n:(m-1)*n m*n:-1:(m-1)*n+1 (m-2)*n+1:-n:n+1 1];
    bw = roipoly(xi,yi,vi,xs(c),ys(c));
    vi(~bw) = NaN;