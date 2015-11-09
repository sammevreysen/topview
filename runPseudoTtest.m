function topview = runPseudoTtest(topview,condnameA,condnameB,suporinfra,equalvariances)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function runPseudoTtest
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

    %check if both conditions are from the same hemisphere %%%%CHANGE TO
    %MORE GENERIC FUNCTION
%     if ~strcmp(condnameA(end-1:end),condnameB(end-1:end))
%         error('Both conditions have to be from the same hemisphere')
%     end
    lr = {'left';'right'};
    hemisphere = lr{strcmp(condnameA(end-2:end),'_RH')+1};
    
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
    xs = topview.generalmodel.(hemisphere).(['mask_' suporinfra]);
    ys = topview.generalmodel.(hemisphere).bregmas;
    bregmas = ys(:,1);
    xa = topview.generalmodel.(hemisphere).(['areas_' suporinfra]);
    [xi yi] = meshgrid(min(xs(:)):max(xs(:)),min(ys(:)):max(ys(:)));
    percentage = 0;
    fprintf('%d%%',percentage);
%     hfig = figure();
    for jjj = 1:size(perms,1)
%         spi(jjj) = subplot(4,5,jjj);
        newpercentage = floor(jjj/size(perms,1)*100/20)*20;
        if(newpercentage > percentage)
            percentage = newpercentage;
            fprintf('-%d%%',percentage);
        end
        permname = ['perm' num2str(jjj)];
                
        %stack and align mice, interpolate per mouse, merge in condition and interpolate
        %condition A
        condA = nan(size(ys,1),size(xs,2),size(perms,2));
        condA_interpol = nan(size(yi,1),size(xi,2),size(perms,2));
        for kkk = 1:size(perms,2)
            bregmasel = ismember(bregmas,topview.mice.(perms{jjj,kkk}).bregmas);
            condA(bregmasel,:,kkk) = topview.mice.(perms{jjj,kkk}).(suporinfra);
            condA_interpol(:,:,kkk) = topview.mice.(perms{jjj,kkk}).([suporinfra 'interpol_gm']);
        end
        condA_mean = nanmean(condA,3);
        nnanA = ~isnan(condA_mean(:,1));
        condA_mean_interpol = griddata(xs(nnanA,:),ys(nnanA,:),condA_mean(nnanA,:),xi,yi);
                
        %condition B
        condB = nan(size(ys,1),size(xs,2),size(permscomplement,2));  
        condB_interpol = nan(size(yi,1),size(xi,2),size(permscomplement,2));
        for kkk = 1:size(permscomplement,2)
            bregmasel = ismember(bregmas,topview.mice.(permscomplement{jjj,kkk}).bregmas);
            condB(bregmasel,:,kkk) = topview.mice.(permscomplement{jjj,kkk}).(suporinfra);
            condB_interpol(:,:,kkk) = topview.mice.(permscomplement{jjj,kkk}).([suporinfra 'interpol_gm']);
        end
        condB_mean = nanmean(condB,3);
        nnanB = ~isnan(condB_mean(:,1));
        condB_mean_interpol = griddata(xs(nnanB,:),ys(nnanB,:),condB_mean(nnanB,:),xi,yi);
        
        %create mask to normalize against B
        nnanmask = nnanA & nnanB;
        temp = condB_mean(nnanmask,:);
        normB = mean(temp(:));
        
        condA_mean = nanmean(condA,3)./normB;
        nnanA = ~isnan(condA_mean(:,1));
        condA_mean_interpol = griddata(xs(nnanA,:),ys(nnanA,:),condA_mean(nnanA,:),xi,yi);
        
        condB_mean = nanmean(condB,3)./normB;
        nnanB = ~isnan(condB_mean(:,1));
        condB_mean_interpol = griddata(xs(nnanB,:),ys(nnanB,:),condB_mean(nnanB,:),xi,yi);
        
        
        %shift scale and take difference
        %shift scale
        scaleshift = abs(min(0,min(min(min(condA_mean_interpol)),min(min(condB_mean_interpol)))));
        topviewAB3D = nan(size(yi,1),size(xi,2),2);
        topviewAB3D(:,:,1) = condA_mean_interpol + scaleshift;
        topviewAB3D(:,:,2) = condB_mean_interpol + scaleshift;
        topviewABdiff = -diff(topviewAB3D,1,3); % condition A - condition B
        if(equalvariances)
            %assume equal variances
            topviewABvar = movingvar(topviewABdiff,25);
            tstat = topviewABdiff./sqrt(topviewABvar*((1/size(perms,2))+(1/size(permscomplement,2))));
        else
            %don't assume equal variances
            condAvar = movingFWHM(sum((condA_interpol-repmat(condA_mean_interpol,[1 1 size(perms,2)])).^2,3)./(size(perms,2)-1),5);
            condBvar = movingFWHM(sum((condB_interpol-repmat(condB_mean_interpol,[1 1 size(permscomplement,2)])).^2,3)./(size(permscomplement,2)-1),5);
            tstat = topviewABdiff./sqrt((condAvar/size(perms,2))+(condBvar/size(permscomplement,2)));
            
                        
%             
%             for i=1:3
%                 h(i) = subplot(3,4,i);
%                 imagesc(condA_segments_interpol(bregmaA),condA_bregmas_interpol(bregmaA),condA_interpol_striped(:,:,i));
%             end
%             h(4) = subplot(3,4,4);
%             imagesc(condA_segments_interpol(bregmaA),condA_bregmas_interpol(bregmaA),condA_mean);
%             for i=1:3
%                 h(4+i) = subplot(3,4,4+i);
%                 imagesc(condB_segments_interpol(bregmaB),condB_bregmas_interpol(bregmaB),condB_interpol_striped(:,:,i));
%             end 
%             h(8) = subplot(3,4,8);
%             imagesc(condA_segments_interpol(bregmaB),condB_bregmas_interpol(bregmaB),condB_mean);
%             h(9) = subplot(3,4,9);
%             imagesc(condA_segments_interpol(bregmaA),condA_bregmas_interpol(bregmaA),condAvar);
%             h(10) = subplot(3,4,10);
%             imagesc(condB_segments_interpol(bregmaB),condB_bregmas_interpol(bregmaB),condBvar);
%             h(11) = subplot(3,4,11);
%             imagesc(condA_segments_interpol(bregmaA),condA_bregmas_interpol(bregmaA),tstat);
%             h(12) = subplot(3,4,12);
%             imagesc(condA_segments_interpol(bregmaA),condA_bregmas_interpol(bregmaA),(condA_mean-condB_mean)./(condA_mean+condB_mean));
            
        end
        
%         imagesc(condA_segments_interpol(bregmaA),condA_bregmas_interpol(bregmaA),tstat);
%         title(sprintf('%0.1f - %0.1f',min(tstat(:)),max(tstat(:))));
        
        %Tmax value
%         topview.interconditions.(conditioncombname).(['Tmax_2sided_' suporinfra])(jjj) = max(abs(tstat(:)));
        topview.interconditions.(conditioncombname).(['Tmax_deactivation_' suporinfra])(jjj) = min(tstat(:));
        topview.interconditions.(conditioncombname).(['Tmax_activation_' suporinfra])(jjj) = max(tstat(:));
        if jjj == 1
            topview.conditions.(condnameA).([suporinfra '_mean_interpol']) = condA_mean_interpol;
            topview.conditions.(condnameA).([suporinfra '_segments_interpol']) = xi;
            topview.conditions.(condnameA).([suporinfra '_bregmas_interpol']) = yi;
            topview.conditions.(condnameB).([suporinfra '_mean_interpol']) = condB_mean_interpol;
            topview.conditions.(condnameB).([suporinfra '_segments_interpol']) = xi;
            topview.conditions.(condnameB).([suporinfra '_bregmas_interpol']) = yi;
            topview.interconditions.(conditioncombname).(['topviewABdiff_' suporinfra]) = topviewABdiff;
            topview.interconditions.(conditioncombname).(['topviewABdiff_relative_' suporinfra]) = topviewABdiff./sum(topviewAB3D,3);
            topview.interconditions.(conditioncombname).([suporinfra '_bregmas_interpol']) = yi;
            topview.interconditions.(conditioncombname).([suporinfra '_segments_interpol']) = xi;
            topview.interconditions.(conditioncombname).(['tstat_' suporinfra]) = tstat;
            topview.interconditions.(conditioncombname).(['nanmap_' suporinfra]) = any(isnan(cat(3,condA_interpol,condB_interpol)),3);
        end
    end
%     clim = cell2mat(get(spi,'CLim'));
%     set(spi,'CLim',[min(clim(:,1)) max(clim(:,2))]);
    topview.interconditions.(conditioncombname).(['Tmax_deactivation_' suporinfra]) = sort(topview.interconditions.(conditioncombname).(['Tmax_deactivation_' suporinfra]),'descend');
    topview.interconditions.(conditioncombname).(['Tmax_activation_' suporinfra]) = sort(topview.interconditions.(conditioncombname).(['Tmax_activation_' suporinfra]));
    alpha = 0.05;
    topview.interconditions.(conditioncombname).criticalpos_1tailed = floor(alpha*size(perms,1))+1;
    topview.interconditions.(conditioncombname).criticalpos_2tailed = floor(alpha/2*size(perms,1))+1;
    topview.interconditions.(conditioncombname).(['criticalvalue_deactivation_1tailed_' suporinfra]) = topview.interconditions.(conditioncombname).(['Tmax_deactivation_' suporinfra])(end-topview.interconditions.(conditioncombname).criticalpos_1tailed+1);
    topview.interconditions.(conditioncombname).(['criticalvalue_activation_1tailed_' suporinfra]) = topview.interconditions.(conditioncombname).(['Tmax_activation_' suporinfra])(end-topview.interconditions.(conditioncombname).criticalpos_1tailed+1);
    topview.interconditions.(conditioncombname).(['cutoff_activation_1tailed_' suporinfra]) = topview.interconditions.(conditioncombname).(['tstat_' suporinfra]) >= topview.interconditions.(conditioncombname).(['criticalvalue_activation_1tailed_' suporinfra]);
    topview.interconditions.(conditioncombname).(['cutoff_deactivation_1tailed_' suporinfra]) = topview.interconditions.(conditioncombname).(['tstat_' suporinfra]) <= topview.interconditions.(conditioncombname).(['criticalvalue_deactivation_1tailed_' suporinfra]);
    topview.interconditions.(conditioncombname).(['criticalvalue_deactivation_2tailed_' suporinfra]) = topview.interconditions.(conditioncombname).(['Tmax_deactivation_' suporinfra])(end-topview.interconditions.(conditioncombname).criticalpos_2tailed+1);
    topview.interconditions.(conditioncombname).(['criticalvalue_activation_2tailed_' suporinfra]) = topview.interconditions.(conditioncombname).(['Tmax_activation_' suporinfra])(end-topview.interconditions.(conditioncombname).criticalpos_2tailed+1);
    topview.interconditions.(conditioncombname).(['cutoff_activation_2tailed_' suporinfra]) = topview.interconditions.(conditioncombname).(['tstat_' suporinfra]) >= topview.interconditions.(conditioncombname).(['criticalvalue_activation_2tailed_' suporinfra]);
    topview.interconditions.(conditioncombname).(['cutoff_deactivation_2tailed_' suporinfra]) = topview.interconditions.(conditioncombname).(['tstat_' suporinfra]) <= topview.interconditions.(conditioncombname).(['criticalvalue_deactivation_2tailed_' suporinfra]);
    % calculate power
    topview.interconditions.(conditioncombname).(['power_1tailed_' suporinfra]) = normcdf(abs(topview.interconditions.(conditioncombname).(['tstat_' suporinfra])) - norminv(1-alpha));
    topview.interconditions.(conditioncombname).(['power_2tailed_' suporinfra]) = normcdf(topview.interconditions.(conditioncombname).(['tstat_' suporinfra]) - norminv(1-alpha/2))+normcdf(-topview.interconditions.(conditioncombname).(['tstat_' suporinfra]) - norminv(1-alpha/2));
    topview.interconditions.(conditioncombname).selected = true;
    topview.interconditions.(conditioncombname).equalvariances = equalvariances;
    topview.interconditions.(conditioncombname).topview = true;
   
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    