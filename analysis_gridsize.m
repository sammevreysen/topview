mice = fieldnames(topview.mice);
distfig = nan(6*26,7*30);
figure()
for i=1:length(mice)
    tempdiff = diff(topview.mice.(mice{i}).supracoxyprojected_smooth./topview.pixpermm,1,2);
    a = floor((i-1)/7)*26+1;
    b = mod(i-1,7)*30+1;
    distfig(a:a+size(tempdiff,1)-1,b:b+size(tempdiff,2)-1) = tempdiff;
    imagesc(distfig);
end
dists = distfig(:);
dists = dists(~isnan(dists));
dists = sort(dists,'descend');
dists(1:3)
figure()
boxplot(dists);
