% save fig for publication
name = 'Figure8b';
path = '\\bio-srv-df002\DFN\SammeV\Documents\Doctoraat\Publicaties\ISH analysis technical paper\Figures\';
width = 8.4; %cm
height = 6; %17.4;
set(gcf,'Units','centimeters')
set(gcf,'Position',[1 1 width height]);
% set(gca,'Units','normalized');
% set(gca,'OuterPosition',[0 0 1 1]);
savefile = [path genvarname(name)];
print(gcf,'-depsc',savefile,'-painters');
savefig(savefile);

% %title(name);
% set(gca,'FontWeight','bold');
% set(gca,'LineWidth',1);
% 
% set(gcf,'PaperUnits','centimeters');
% set(gcf,'PaperPositionMode','auto');
% set(gcf,'PaperSize',[26 20]);



%%
%fig 1E
%load topview file
mask = nan(27,30,1);
a = 1;
for i=4:9
    cond = topview.conditionnames{i};
    for j=1:size(topview.conditions.(cond).mice,1)
        mouse = topview.conditions.(cond).mice{j};
        mask(ismember(topview.bregmas,topview.mice.(mouse).bregmas),:,a) = topview.mice.(mouse).totalcoxyprojected_smooth;
        mask(:,:,a) = inpaint_nans_no_extrapolation(mask(:,:,a));
        a = a + 1;
    end
end
varmask = nanstd(mask./100,0,3);
figure()
nans = any(isnan(mask),3);
id1 = find(~nans(:,1),1,'first')-1;
id2 = find(~nans(:,1),1,'last')+1;
hold on;
rectangle('Position',[-4,-topview.generalmodel.left.bregmas(id1,1)./100,3.5,0.5],'FaceColor',[0.9 0.9 0.9],'EdgeColor','none');
rectangle('Position',[-4,-topview.generalmodel.left.bregmas(end,1)./100-0.5,3.5,(topview.generalmodel.left.bregmas(end,1)-topview.generalmodel.left.bregmas(id2,1))./100+0.5],'FaceColor',[0.9 0.9 0.9],'EdgeColor','none');
scatter(topview.generalmodel.left.mask_total(:)./100,-topview.generalmodel.left.bregmas(:)./100,36*(varmask(:)./max(varmask(:))),varmask(:),'filled')
ylim([-4.7 -1.9])
colorbar
axis xy equal tight;

%%
colorbar('SouthOutside');
%%
% calculate mean value across map for each animal within each condition
conditions = fieldnames(topview.conditions);
areanames = {'V2L','V1','V2ML','V2MM'};
areas = [];
total = [];
totalgroup = [];
totalgroup2 = [];
group = {};
group2 = [];
for i=[5 4 7 8 9]
    for k=1:length(topview.conditions.(conditions{i}).mice)
        for j=1:size(topview.generalmodel.left.areas_total,2)-1
            tmp = topview.conditions.(conditions{i}).total(:,:,k);
            roi = roipoly(topview.conditions.(conditions{i}).topview_total_xi,topview.conditions.(conditions{i}).topview_total_yi,tmp,[topview.generalmodel.left.areas_total(:,j); flipud(topview.generalmodel.left.areas_total(:,j+1))],[topview.generalmodel.left.bregmas(:,1); flipud(topview.generalmodel.left.bregmas(:,1))]);
            areas = [areas; nanmean(nanmean(tmp(roi)))];
            group = [group; {[strrep(conditions{i},'_',' ') '-' areanames{j}]}];
            group2 = [group2; i j];
        end
        total = [total; nanmean(nanmean(tmp))];
        totalgroup = [totalgroup; {[strrep(conditions{i},'_',' ') '-total']}];
        totalgroup2 = [totalgroup2; i];
    end
end
%%
a = 1;
for i=[9 5 4 7 8]
    for j=1:size(topview.generalmodel.left.areas_total,2)-1
        areasmean(a,j) = mean(areas(group2(:,2)==j & group2(:,1)==i));
        areasste(a,j) = std(areas(group2(:,2)==j & group2(:,1)==i))/sqrt(sum(group2(:,2)==j & group2(:,1)==i));
    end
    totalmean(a,1) = mean(total(totalgroup2==i));
    totalste(a,1) = std(total(totalgroup2==i))/sqrt(sum(totalgroup2==i));
    a = a + 1;
    
end

data = [totalmean areasmean]';
ste = [totalste areasste]';
%%
figure();
bar(data);
hold on;
numgroups = size([totalmean areasmean], 1); 
numbars = size([totalmean areasmean], 2); 
groupwidth = min(0.8, numbars/(numbars+1.5));
for i = 1:numbars
      % Based on barweb.m by Bolu Ajiboye from MATLAB File Exchange
      x = (1:numgroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*numbars);  % Aligning error bar with individual bar
      errorbar(x, data(:,i), zeros(size(ste(:,i))), ste(:,i), 'k', 'linestyle', 'none');
end
set(gca,'XTickLabels',[{'Total'} areanames]);
legend(strrep(strrep(strrep(conditions([9 5 4 7 8]),'_',' '),'W','w'),'D','d'),'Location','northeast');
ylabel('Relative zif expression');
box off;

%%
figure()
hold on;
colors = parula(5);
a = 1;
for j=1:size(topview.generalmodel.left.areas_total,2)-1
    b = 1;
    for i=[5 4 7 8 9]
        tmp = areas(group2(:,2)==j & group2(:,1)==i);
        hb = bar(a,mean(tmp));
        set(hb,'FaceColor',colors(b,:));
        errorbar(a,mean(tmp),0,std(tmp)/sqrt(length(tmp)),'k','linestyle','none');
        scatter(a+zeros(size(tmp)),tmp,[],[0 0 0]);
        a = a + 1;
        b = b + 1;
    end
    a = a + 0.5;
end
hold off;

%%
p = [];
cpval = [];
for i=1:size(topview.generalmodel.left.areas_total,2)-1
    [p(i),tbl,stats] = kruskalwallis(areas(group2(:,2)==i),group(group2(:,2)==i),'off');
    [c,m,~,gnames] = multcompare(stats,'Display','off');
    csel = c(c(:,6)<=0.05,:);
    cpval{i} = [gnames(csel(:,1)) gnames(csel(:,2)) num2cell(csel(:,6))];
end

%%
total = [];
supra = [];
infra = [];
group = {};
for i=[5 4 7 8 9]
    for j=1:length(topview.conditions.(conditions{i}).mice)
        total = [total; nanmean(nanmean(topview.conditions.(conditions{i}).total(:,:,j)))];
        supra = [supra; nanmean(nanmean(topview.conditions.(conditions{i}).supra(:,:,j)))];
        infra = [infra; nanmean(nanmean(topview.conditions.(conditions{i}).infra(:,:,j)))];
        group = [group; conditions(i)];
    end
end
[p,tbl,stats] = kruskalwallis(total,group);
[c,m] = multcompare(stats);
csel = c(c(:,6)<=0.05,:);
cpval = [gnames(csel(:,1)) gnames(csel(:,2)) num2cell(csel(:,6))];

boxplot(total,group);

for i=[5 4 7 8 9]
    fprintf('%0.2f\n',mean(total(strcmp(group,conditions{i}))));
end
