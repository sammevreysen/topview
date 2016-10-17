%L-M distances
mice = fieldnames(topview.mice);
h = size(topview.bregmas,1);
w = topview.segments;
y = floor(sqrt(length(mice)));
x = ceil(sqrt(length(mice)));
distfig = nan(y*h,x*w);
figure()
for i=1:length(mice)
    tempdiff = diff(topview.mice.(mice{i}).supracoxyprojected_smooth./topview.pixpermm,1,2);
    a = floor((i-1)/x)*h+1;
    b = mod(i-1,x)*w+1;
    distfig(a:a+size(tempdiff,1)-1,b:b+size(tempdiff,2)-1) = tempdiff;
    imagesc(distfig);
end
dists = distfig(:);
dists = dists(~isnan(dists));
dists = sort(dists,'descend');
dists(1:3)
figure()
boxplot(dists);

%error before and after smoothing per mouse
mice = fieldnames(topview.mice);
h = size(topview.bregmas,1);
w = topview.segments;
y = floor(sqrt(length(mice)));
x = ceil(sqrt(length(mice)));
errfig = nan(y*h,x*w);
errs = [];
figure()
for i=1:length(mice)
    temperr = abs(topview.mice.(mice{i}).supracoxyprojected-topview.mice.(mice{i}).supracoxyprojected_smooth)./topview.pixpermm;
    errs = [errs; reshape(temperr,[],1)];
    a = floor((i-1)/x)*h+1;
    b = mod(i-1,x)*w+1;
    errfig(a:a+size(temperr,1)-1,b:b+size(temperr,2)-1) = temperr;
end
pcolor(errfig);
shading flat;
axis ij equal;
colormap hot;
figure();
boxplot(errs);

figure();
plot(topview.mice.(mice{5}).supracoxyprojected./topview.pixpermm,repmat(topview.mice.(mice{5}).bregmas,1,topview.segments)./100,'bo');
hold on;
plot(topview.mice.(mice{5}).supracoxyprojected_smooth./topview.pixpermm,repmat(topview.mice.(mice{5}).bregmas,1,topview.segments)./100,'gx');
hold off;
axis ij equal;