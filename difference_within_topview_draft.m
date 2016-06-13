[x,y] = meshgrid(1:10,1:10);
test = zeros(10);
test(2:4,4:5) = 1;
test(8:10,7:9) = 0.5;
test(2:6,8:10) = 1;
test(6:8,1:3) = 0.5;

a = 1;
for i=1:numel(test)-1
    for j=i+1:numel(test)
        cor(a,:) = [x(i)+x(j) y(i)+y(j) test(i)+test(j)];
        ids(a,:) = [x(i) y(i) x(j) y(j)];
        a = a + 1;
    end
end
%%
test = topview.conditions.P120_3DME.supra;
figure()
subplot(1,2,1)
imagesc(test);
hold on;
subplot(1,2,2)
cor2 = cor./repmat(mean(cor,1),size(cor,1),1);
T = clusterdata(cor2,'distance','euclidean','maxclust',5);
scatter3(cor2(:,1),cor2(:,2),cor2(:,3),100,T,'filled')
colormap(lines(5));

corsel = ids(T==3,:);
ph = plot(corsel(:,1),corsel(:,2),'rx',corsel(:,3),corsel(:,4),'gx');
delete(ph);


%% version 1 tstat
sz = size(test);
perm = nchoosek(1:prod(sz(1:2)),2);
observed_tstat = zeros(size(perm,1),1);
parfor_progress(size(perm,1));
parfor i=1:size(perm,1)
    [Ax,Ay]=ind2sub(sz(1:2),perm(i,1));
    [Bx,By]=ind2sub(sz(1:2),perm(i,2));
    observed_tstat(i) = (nanmean(test(Ax,Ay,:))-nanmean(test(Bx,By,:)))./sqrt((nanstd(test(Ax,Ay,:))+nanstd(test(Bx,By,:)))./size(test,3));
    parfor_progress;
end
[observed_tstat_sorted,observed_tstat_ind] = sort(observed_tstat);
parfor_progress(0);

%%
observed_heatmap2 = observed_heatmap';
a = 1;
for i=1:size(observed_heatmap2,2)-1
    for j=i+1:size(observed_heatmap2,1)
        observed_tstat(a) = observed_heatmap2(j,i);
        a = a + 1;
    end
end

observed_heatmap = nan(max(perm(:)));
for i=1:size(perm,1)
    observed_heatmap(perm(i,1),perm(i,2)) = observed_tstat(i);
end
figure()
imagesc(observed_heatmap);

%%
a = 1;
sz = size(test);
perm = nchoosek(1:size(test,3)*2,size(test,3));
for i=1:prod(sz(1:2))-1
    for j=i+1:prod(sz(1:2))
        [Ax,Ay]=ind2sub(sz(1:2),i);
        [Bx,By]=ind2sub(sz(1:2),j);
        observed_tstat = (nanmean(test(Ax,Ay,:))-nanmean(test(Bx,By,:)))./sqrt((nanstd(test(Ax,Ay,:))+nanstd(test(Bx,By,:)))./size(test,3));
        for k=2:size(perm,1)
           tstat 
        end
    end
end
%%

        
        
        [Ax,Ay]=ind2sub(sz(1:2),i);
        [Bx,By]=ind2sub(sz(1:2),j);
        A(a,:) = squeeze(test(Ax,Ay,:));
        B(a,:) = squeeze(test(Bx,By,:));
        a = a + 1;
        
        
%%

[sort1,id1] = sortrows(observed_heatmap',1:size(observed_heatmap',2));%:-1:1); %sort columns bottom to top
sort1 = sort1';
id1 = id1';
[sort2,id2] = sortrows(sort1,1:size(sort1,2));%:-1:1); %sort rows right to left
[sort3,id3] = sortrows(sort2',1:size(sort2',2));
sort3 = sort3';
id3 = id3';
[sort4,id4] = sortrows(sort3,1:size(sort3,2));
% sort5 = inpaint_nans(sort4(1:749,1:749)',3);


pcutL = quantile(sort4(:),0.025);
pcutH = quantile(sort4(:),0.975);
figure();
imagesc(sort4>=pcutH);
set(gca,'XTick',1:length(colnames));
set(gca,'YTick',1:length(rownames));
set(gca,'XTickLabel',colnames);
set(gca,'YTickLabel',rownames);

figure()
hist(sort4(:),100);

hold on;
yl = ylim;
plot([pcutL pcutL],yl,'r-');
plot([pcutH pcutH],yl,'r-');
hold off;

roi = roipoly();
[xi,yi]=ind2sub(size(roi),find(observed_heatmap<quantile(observed_heatmap(:),0.01)));
figure();
imagesc(observed_heatmap);
hold on;
plot(xi,yi,'kx');
hold off;

xiyi = unique(sort([xi yi],2),'rows');

% ri = id1(id3(xi));
% ci = id2(id4(yi));
[rix,riy] = ind2sub(size(test),xiyi(:,1));
[cix,ciy] = ind2sub(size(test),xiyi(:,2));


figure();
lst = randi(length(rix),50,1);
imagesc(nanmean(test,3));
hold on;
plot([rix(lst)';cix(lst)'],[riy(lst)';ciy(lst)'],'kx-');
hold off;



figure();
subplot(1,5,1)
imagesc(observed_heatmap);
subplot(1,5,2);
imagesc(sort1);
subplot(1,5,3)
imagesc(sort2);
subplot(1,5,4);
imagesc(sort3);
subplot(1,5,5);
imagesc(sort4);
% yl = ylim;
% xl = xlim;
% subplot(1,6,6);
% imagesc(sort5);
% ylim(yl);
% xlim(xl);

%% version 2 tstat
parfor_progress(numel(test));
otstat = [];
for i=1:size(test,1)
    for j=1:size(test,2)
        tmp = (nanmean(test(i,j,:))-nanmean(test,3))./sqrt((nanstd(test(i,j,:))+nanstd(test,0,3))./size(test,3));
        tmp(isinf(tmp)) = 0;
        tmp(isnan(tmp)) = 0;
        [i2,j2] = ind2sub(size(tmp),1:numel(tmp));
        otstat = [otstat; repmat([i j],length(i2),1) i2' j2' tmp(:)];
        parfor_progress;
    end
end
parfor_progress(0);

%%
[wcoeff,score,latent,tsquared,explained] = pca(otstat(abs(otstat(:,5))>quantile(abs(otstat(:,5)),0.95),:));
coefforth = inv(diag(std(otstat)))*wcoeff;
figure()
subplot(1,size(score,2),1);
bar(explained);
for i=1:size(score,2)-1
    subplot(1,size(score,2),i+1)
    plot(score(:,i),score(:,i+1),'+') 
    xlabel(sprintf('PC %d',i));
    ylabel(sprintf('PC %d',i+1));
end

otstatPC = score(:,4:5);
figure();
[clusters,centroid] = kmeans(otstatPC,6);
gscatter(otstatPC(:,1),otstatPC(:,2),clusters);

net = newsom(otstatPC',[4 4]);
net = train(net,otstatPC');

distances = dist(otstatPC,net.IW{1}');
[d,center] = min(distances,[],2);
% center gives the cluster index

figure
gscatter(otstatPC(:,1),otstatPC(:,2),center); legend off;
hold on
plotsom(net.iw{1,1},net.layers{1}.distances);
hold off

figure()
groups = unique(center);
for i=1:length(groups)
    subplot(4,4,i)
    imagesc(nanmean(test,3));
    hold on;
    plot(otstat(center == i,1),otstat(center == i,2),'kx');
    plot(otstat(center == i,3),otstat(center == i,4),'wo');
    hold off;
    title(sprintf('Group %d',i));
end