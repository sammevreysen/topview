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


%%
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

[sort1,id1] = sortrows(observed_heatmap',size(observed_heatmap',2):-1:1); %sort columns bottom to top
sort1 = sort1';
id1 = id1';
[sort2,id2] = sortrows(sort1,size(sort1,2):-1:1); %sort rows right to left
[sort3,id3] = sortrows(sort2,1:size(sort2,2)); %sort rows left to right
[sort4,id4] = sortrows(sort3',1:size(sort3',2)); %sort columns top to bottom
sort4 = sort4';
id4 = id4';
sort5 = inpaint_nans(sort4(1:749,1:749)',3);

figure();
subplot(1,6,1)
imagesc(observed_heatmap);
subplot(1,6,2);
imagesc(sort1);
subplot(1,6,3)
imagesc(sort2);
subplot(1,6,4);
imagesc(sort3);
subplot(1,6,5);
imagesc(sort4);
yl = ylim;
xl = xlim;
subplot(1,6,6);
imagesc(sort5);
ylim(yl);
xlim(xl);