% save fig for publication
name = 'Figure3colorbars';
path = '\\bio-srv-df002\DFN\SammeV\Documents\Doctoraat\Publicaties\ISH analysis technical paper\Figures\';
width = 17.4; %cm
height = 17.4;
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