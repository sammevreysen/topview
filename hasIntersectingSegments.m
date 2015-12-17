function idx = hasIntersectingSegments(setuptable)
    restop = cell2mat(cellfun(@(x) all(diff(x.topcoxy(:,1),1) > 0,1) | all(diff(x.topcoxy(:,1),1) < 0,1),setuptable(:,6),'UniformOutput',false));
    resmid = cell2mat(cellfun(@(x) all(diff(x.midcoxy(:,1),1) > 0,1) | all(diff(x.midcoxy(:,1),1) < 0,1),setuptable(:,6),'UniformOutput',false));
    resbot = cell2mat(cellfun(@(x) all(diff(x.botcoxy(:,1),1) > 0,1) | all(diff(x.botcoxy(:,1),1) < 0,1),setuptable(:,6),'UniformOutput',false));
    
    idx = find(~(restop & resmid & resbot));
    
%%
% midcoxy = setuptable{562,6}.midcoxy;
% botcoxy = setuptable{562,6}.botcoxy;
% 
% plot([botcoxy(:,1)'; midcoxy(:,1)'],[botcoxy(:,2)'; midcoxy(:,2)'])
% 
% %%
% 
% l1 = nan(ceil(size(midcoxy(1:2:end,:),1)*3),2);
% l1(1:3:end,:) = midcoxy(1:2:end,:);
% l1(2:3:end,:) = botcoxy(1:2:end,:);
% 
% l2 = nan(ceil(size(midcoxy(2:2:end,:),1)*3),2);
% l2(1:3:end,:) = midcoxy(2:2:end,:);
% l2(2:3:end,:) = botcoxy(2:2:end,:);
% 
% plot(l2(:,1),l2(:,2))
% hold on;
% plot(l1(:,1),l1(:,2))
% hold off;
% 
% [x,y,~,~] = intersections(l1(:,1),l1(:,2),l2(:,1),l2(:,2));