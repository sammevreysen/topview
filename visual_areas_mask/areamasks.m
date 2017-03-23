areas = {'V1','RL','PM','LM','LLA','LI','AM','A','AL'};
for i=1:length(areas)
    areaname = areas{i};
    I = imread(['S:\Matlab\ISH Matlab Area Mask\Supra-' areaname '.tif']);
    % imagesc([-4.5 -1],[-1.5 -4],I)
    xscale = (-4.5+1)/(size(I,2)-1);
    yscale = (-4+1.5)/(size(I,1)-1);
    [x,y] = meshgrid(-4.5:-xscale:-1,-1.5:yscale:-4);
    J = ~im2bw(I,0.9);
    % imagesc([-4.5 -1],[-1.5 -4],J)

    mask.(areaname).mask = J;
    c = contour(x,y,J,[1 1],'r-');
    mask.(areaname).contour = c(:,2:end);
    mask.(areaname).color = [1 0 0];
    mask.(areaname).linewidth = 1;
    mask.(areaname).linestyle = '-';
end

figure()
hold on;
for i=1:length(areas)
    
    plot(mask.(areas{i}).contour(1,:),mask.(areas{i}).contour(2,:),'r-');
end
axis xy equal tight
hold on;