function coxyprojected = projectToTopview(coxy,midlinep)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function projectToTopview projects points according to midline to topview
% plane
%
%   INPUT:  - coxy: size is N x 2 with coordinates to be projected
%           - midlinep: midline described by 1th order polynomial vector
%   OUTPUT: - coxyprojected: projected coordinates
%
%   Samme Vreysen
%
%   27/03/2015
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    m = midlinep(1);
    C = midlinep(2);
    R = (-C+coxy(:,2)+1/m*coxy(:,1))/(m+1/m);
    S = m*R+C;
    coxyprojected = sign(coxy(:,1)-R).*sqrt(sum(diff(cat(3,coxy,[R S]),1,3).^2,2));
                    
                  