hold on;
areaname = 'V1';
I = imread(['H:\MATLAB\ISHAnalysis\visual_areas_mask\Total-' areaname '.tif']);
% imagesc([-4.5 -1],[-1.5 -4],I)
xscale = (-4.5+1)/(size(I,2)-1);
yscale = (-4+1.5)/(size(I,1)-1);
[x,y] = meshgrid(-4.5:-xscale:-1,-1.5:yscale:-4);
J = ~im2bw(I,0.9);
% imagesc([-4.5 -1],[-1.5 -4],J)

area.(areaname).mask = J;
c = contour(x,y,J,[1 1],'r-');
axis xy equal tight
area.(areaname).contour = c(:,2:end);

% imagesc([-4.5 -1],[-1.5 -4],bwmorph(imdilate(area.V1,strel('sphere',5)),'shrink',5))
% axis xy equal tight
% hold on;