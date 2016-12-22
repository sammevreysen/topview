mice = {'M41_4_LH';'M42_1_LH';'M42_2_LH';'M66_1_LH';'M66_2_LH';'M66_3_LH'};
mouse = mice{1};

topview.mice.(mouse).bregmas = (1:25)';
topview.mice.(mouse).segments = (1:25)';
topview.mice.(mouse).segments = (1:30)';
topview.mice.(mouse).total = ones(25,30);
[x,y] = meshgrid(1:30,1:25);
topview.mice.(mouse).totalcoxy = cat(3,x,y);
[x,y] = meshgrid([1 30],1:25);
topview.mice.(mouse).totalareacoxy = cat(3,x,y);
topview.mice.(mouse).totalcoxyprojected = topview.mice.(mouse).totalcoxy;
topview.mice.(mouse).totalareaxyprojected = topview.mice.(mouse).totalareacoxy;
topview.mice.(mouse).midlinep = repmat([0 0],25,1);
topview.mice.(mouse).totalcoxyprojected_smooth = topview.mice.(mouse).totalcoxyprojected;
topview.mice.(mouse).totalareaxyprojected_smooth = topview.mice.(mouse).totalareaxyprojected;
[xi,yi] = meshgrid(1:0.1:30,1:0.1:25);
[x,y] = meshgrid(1:30,1:25);
topview.mice.(mouse).totalinterpol_gm = interp2(x,y,topview.mice.(mouse).total,xi,yi);
topview.mice.(mouse).totalinterpol_gm_smooth = topview.mice.(mouse).totalinterpol_gm;
imagesc(topview.mice.(mouse).totalinterpol_gm)

mice = {'M41_4_LH';'M42_1_LH';'M42_2_LH';'M66_1_LH';'M66_2_LH';'M66_3_LH'};
for i=1:3
    mouse = mice{i};
    topview.mice.(mouse).total = randn(size(data)).*20+50; %ones(size(data));
%     topview.mice.(mouse).total(5:20,5:25) = 20;
    topview.mice.(mouse).totalinterpol_gm = interp2(x,y,topview.mice.(mouse).total,xi,yi);
    topview.mice.(mouse).totalinterpol_gm_smooth = topview.mice.(mouse).totalinterpol_gm;
end

conditions = {'Control1';'Control2'};
for i=1:2
    cond = conditions{i};
    if(i==1)
        list = 1:3;
    else
        list = 4:6;
    end
    for j=list
        mouse = mice{j};
        topview.conditions.(cond).total(:,:,mod(j-1,3)+1) = topview.mice.(mouse).total;
    end
    topview.conditions.(cond).total_mean = mean(topview.conditions.(cond).total,3);
    topview.conditions.(cond).total_mean_interpol = interp2(x,y,topview.conditions.(cond).total_mean,xi,yi);
    topview.conditions.(cond).topview_total_mean_interpol = topview.conditions.(cond).total_mean_interpol;
    topview.conditions.(cond).topview_total_mean_interpol_smooth = topview.conditions.(cond).total_mean_interpol;
end

figure()
subplot(1,2,1)
imagesc(topview.conditions.(conditions{1}).total_mean);
caxis([0 100]);
subplot(1,2,2)
imagesc(topview.conditions.(conditions{2}).total_mean);
caxis([0 100]);

%%

subplot(2,3,1)
imagesc(condA_mean_interpol)
axis equal tight
subplot(2,3,2)
imagesc(condB_mean_interpol)
axis equal tight
subplot(2,3,3)
imagesc(topviewABdiff)
axis equal tight
subplot(2,3,4)
imagesc(topviewABdiffrelative)
axis equal tight
subplot(2,3,5)
imagesc(topviewABdiff)
axis equal tight
subplot(2,3,6)
imagesc(tstat)
axis equal tight

%%
cdata = get(gco,'CData');
set(gco,'CData',log10(cdata));
caxis([-3 0]);
set(gco,'Ticks',log10([0.001 0.025 0.25 1]))
set(gco,'TickLabels',[0.001 0.025 0.25 1])

%%
128/abs((log10(0.001)-log10(0.05))/3)
275-128
newcmap = [pval_cmap(1:end-1,:); flipud(gray(147))];
colormap(gca,newcmap)

%% check FWER (family wise error rate)
[totmax,totmin] = FWERchecker(topview);
sum(squeeze(any(any(totmax <= 0.05,1),2)))./1000 % = 0.0510
(sum(squeeze(any(any(totmax <= 0.025,1),2)))+sum(squeeze(any(any(totmin <= 0.025,1),2))))./1000 %n moet > 3 zijn (deze nacht runnen)
