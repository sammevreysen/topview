function topview = runPseudoTtest_flatmount(topview,condnameA,condnameB,suporinfra,equalvariances)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function runPseudoTtest for flatmounts
%
% INPUT:    topview: topview structure
%           condA: name of condition A
%           condB: name of condition B
%           equalvariances: assume equal variances between condition A & B
% 
% OUTPUT:   topview: topview structure
%
%
% Samme Vreysen
% 
% 24-03-2015
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %create intercondition structure
    conditioncombname = [condnameA '_' condnameB];
    topview.interconditions.(conditioncombname).conditions = {condnameA condnameB};
    %permutations and its complement
    miceconditionA = topview.conditions.(condnameA).mice;
    miceconditionB = topview.conditions.(condnameB).mice;
    mice = [miceconditionA; miceconditionB];
    perms = nchoosek(mice, size(miceconditionA,1));
    for jjj = 1:size(perms,1)
        permscomplement(jjj,:) = mice(~ismember(mice,perms(jjj,:)))';
    end
    topview.interconditions.(conditioncombname).perms = perms;
    topview.interconditions.(conditioncombname).permscomplement = permscomplement;
    %calculate all permutations
    percentage = 0;
    fprintf('%d%%',percentage);
%     figure();
    for jjj = 1:size(perms,1)
%         spi(jjj) = subplot(4,5,jjj);
        newpercentage = floor(jjj/size(perms,1)*100/20)*20;
        if(newpercentage > percentage)
            percentage = newpercentage;
            fprintf('-%d%%',percentage);
        end
        permname = ['perm' num2str(jjj)];
        clear bregmalist segmentlist;
        bregmalist{1} = [];
        segmentlist{1} = [];
        bregmalist{2} = [];
        segmentlist{2} = [];
        for kkk = 1:size(perms,2)
            bregmalist{1} = [bregmalist{1}; topview.mice.(perms{jjj,kkk}).bregmas];
            segmentlist{1} = [segmentlist{1} topview.mice.(perms{jjj,kkk}).segments];
        end
        bregmalist{1} = unique(bregmalist{1});
        segmentlist{1} = unique(segmentlist{1});
        for kkk = 1:size(permscomplement,2)
            bregmalist{2} = [bregmalist{2}; topview.mice.(permscomplement{jjj,kkk}).bregmas];
            segmentlist{2} = [segmentlist{2} topview.mice.(permscomplement{jjj,kkk}).segments];
        end
        bregmalist{2} = unique(bregmalist{2});
        segmentlist{2} = unique(segmentlist{2});
        
        %stack and align mice, interpolate per mouse, merge in condition and interpolate
        %condition A
        condA = nan(size(bregmalist{1},1),size(segmentlist{1},2),size(perms,2));
        [xx yy] = meshgrid(segmentlist{1},bregmalist{1});
        [xxi yyi] = meshgrid(1:0.1:size(xx,2),yy(1):1:yy(end));
        condA_interpol = nan(size(xxi,1),size(yyi,2),size(perms,2));
        for kkk = 1:size(perms,2)
            condA(ismember(bregmalist{1},topview.mice.(perms{jjj,kkk}).bregmas),:,kkk) = topview.mice.(perms{jjj,kkk}).(suporinfra).*topview.mice.(perms{jjj,kkk}).(['normalizefactor_' suporinfra]);
            condA_interpol(:,:,kkk) = interp2(xx,yy,condA(:,:,kkk),xxi,yyi,'linear');
        end
        condA_mean = nanmean(condA,3);
        condA_mean_interpol = interp2(xx,yy,condA_mean,xxi,yyi,'linear');
        condA_segments_interpol = xxi(1,:);
        condA_bregmas_interpol = yyi(:,1);
        
        %condition B
        condB = nan(size(bregmalist{2},1),size(segmentlist{2},2),size(permscomplement,2));        
        [xx yy] = meshgrid(segmentlist{2},bregmalist{2});
        [xxi yyi] = meshgrid(1:0.1:size(xx,2),yy(1):1:yy(end));
        condB_interpol = nan(size(xxi,1),size(yyi,2),size(perms,2));
        for kkk = 1:size(permscomplement,2)
            condB(ismember(bregmalist{2},topview.mice.(permscomplement{jjj,kkk}).bregmas),:,kkk) = topview.mice.(permscomplement{jjj,kkk}).(suporinfra).*topview.mice.(permscomplement{jjj,kkk}).(['normalizefactor_' suporinfra]);
            condB_interpol(:,:,kkk) = interp2(xx,yy,condB(:,:,kkk),xxi,yyi,'linear');
        end
        condB_mean = nanmean(condB,3);
        condB_mean_interpol = interp2(xx,yy,condB_mean,xxi,yyi,'linear');
        condB_segments_interpol = xxi(1,:);
        condB_bregmas_interpol = yyi(:,1);
        
        %strip
        bregmaA = ismember(condA_bregmas_interpol,condB_bregmas_interpol);
        bregmaB = ismember(condB_bregmas_interpol,condA_bregmas_interpol);
        
        condA_mean_interpol_striped = condA_mean_interpol(bregmaA,:) ;
        condB_mean_interpol_striped = condB_mean_interpol(bregmaB,:);
        condA_interpol_striped = condA_interpol(bregmaA,:,:);
        condB_interpol_striped = condB_interpol(bregmaB,:,:);
        nanmap = any(isnan(cat(3,condA_interpol_striped,condB_interpol_striped)),3);
        
        %shift scale and take difference
        %shift scale
        scaleshift = abs(min(0,min(min(min(condA_mean_interpol)),min(min(condB_mean_interpol)))));
        topviewAB3D = nan(sum(bregmaA),length(condA_segments_interpol),2);
        topviewAB3D(:,:,1) = condA_mean_interpol_striped + scaleshift;
        topviewAB3D(:,:,2) = condB_mean_interpol_striped + scaleshift;
        topviewABdiff = -diff(topviewAB3D,1,3); % condition A - condition B
        if(equalvariances)
            %assume equal variances
            topviewABvar = movingvar(topviewABdiff,25);
            tstat = topviewABdiff./sqrt(topviewABvar*((1/size(perms,2))+(1/size(permscomplement,2))));
        else
            %don't assume equal variances
            condAvar = movingFWHM(sum((condA_interpol_striped-repmat(condA_mean_interpol_striped,[1 1 size(perms,2)])).^2,3)./(size(perms,2)-1),5);
            condBvar = movingFWHM(sum((condB_interpol_striped-repmat(condB_mean_interpol_striped,[1 1 size(permscomplement,2)])).^2,3)./(size(permscomplement,2)-1),5);
            tstat = topviewABdiff./sqrt((condAvar/size(perms,2))+(condBvar/size(permscomplement,2)));
            
            
%             figure();
%             for i=1:3
%                 h(i) = subplot(3,4,i);
%                 imagesc(condA_segments_interpol(bregmaA),condA_bregmas_interpol(bregmaA),condA_interpol_striped(:,:,i));
%             end
%             h(4) = subplot(3,4,4);
%             imagesc(condA_segments_interpol(bregmaA),condA_bregmas_interpol(bregmaA),condA_mean_interpol_striped);
%             for i=1:3
%                 h(4+i) = subplot(3,4,4+i);
%                 imagesc(condB_segments_interpol(bregmaB),condB_bregmas_interpol(bregmaB),condB_interpol_striped(:,:,i));
%             end 
%             h(8) = subplot(3,4,8);
%             imagesc(condA_segments_interpol(bregmaB),condB_bregmas_interpol(bregmaB),condB_mean_interpol_striped);
%             h(9) = subplot(3,4,9);
%             imagesc(condA_segments_interpol(bregmaA),condA_bregmas_interpol(bregmaA),condAvar);
%             h(10) = subplot(3,4,10);
%             imagesc(condB_segments_interpol(bregmaB),condB_bregmas_interpol(bregmaB),condBvar);
%             h(11) = subplot(3,4,11);
%             imagesc(condA_segments_interpol(bregmaA),condA_bregmas_interpol(bregmaA),tstat);
%             h(12) = subplot(3,4,12);
%             imagesc(condA_segments_interpol(bregmaA),condA_bregmas_interpol(bregmaA),(condA_mean_interpol_striped-condB_mean_interpol_striped)./(condA_mean_interpol_striped+condB_mean_interpol_striped));
            
        end
        
%         imagesc(condA_segments_interpol(bregmaA),condA_bregmas_interpol(bregmaA),tstat);
%         title(sprintf('%0.1f - %0.1f',min(tstat(:)),max(tstat(:))));
        
        %Tmax value
        topview.interconditions.(conditioncombname).(['Tmax_' suporinfra])(jjj) = max(tstat(:));
        if jjj == 1
            topview.conditions.(condnameA).([suporinfra '_mean_interpol']) = condA_mean_interpol;
            topview.conditions.(condnameA).([suporinfra '_segments_interpol']) = condA_segments_interpol;
            topview.conditions.(condnameA).([suporinfra '_bregmas_interpol']) = condA_bregmas_interpol;
            topview.conditions.(condnameB).([suporinfra '_mean_interpol']) = condB_mean_interpol;
            topview.conditions.(condnameB).([suporinfra '_segments_interpol']) = condB_segments_interpol;
            topview.conditions.(condnameB).([suporinfra '_bregmas_interpol']) = condB_bregmas_interpol;
            topview.interconditions.(conditioncombname).(['topviewABdiff_' suporinfra]) = topviewABdiff;
            topview.interconditions.(conditioncombname).(['topviewABdiff_relative_' suporinfra]) = topviewABdiff./sum(topviewAB3D,3);
            topview.interconditions.(conditioncombname).([suporinfra '_bregmas_interpol']) = condA_bregmas_interpol(bregmaA);
            topview.interconditions.(conditioncombname).([suporinfra '_segments_interpol']) = condA_segments_interpol;
            topview.interconditions.(conditioncombname).(['tstat_' suporinfra]) = tstat;
            topview.interconditions.(conditioncombname).(['nanmap_' suporinfra]) = nanmap;
        end
    end
%     clim = cell2mat(get(spi,'CLim'));
%     set(spi,'CLim',[min(clim(:,1)) max(clim(:,2))]);
    topview.interconditions.(conditioncombname).(['Tmax_' suporinfra]) = sort(topview.interconditions.(conditioncombname).(['Tmax_' suporinfra]));
    topview.interconditions.(conditioncombname).criticalpos = floor(0.05*size(perms,1))+1;
    topview.interconditions.(conditioncombname).(['criticalvalue_' suporinfra]) = topview.interconditions.(conditioncombname).(['Tmax_' suporinfra])(end-topview.interconditions.(conditioncombname).criticalpos+1);
    topview.interconditions.(conditioncombname).(['cutoff_activation_' suporinfra]) = topview.interconditions.(conditioncombname).(['tstat_' suporinfra]) >= topview.interconditions.(conditioncombname).(['criticalvalue_' suporinfra]);
    topview.interconditions.(conditioncombname).(['cutoff_deactivation_' suporinfra]) = topview.interconditions.(conditioncombname).(['tstat_' suporinfra]) <= -topview.interconditions.(conditioncombname).(['criticalvalue_' suporinfra]);
    topview.interconditions.(conditioncombname).selected = true;
    topview.interconditions.(conditioncombname).equalvariances = equalvariances;
   