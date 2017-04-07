function topview = runPseudoTteststepdown(topview,condnameA,condnameB,suporinfra,equalvariances,varargin)
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
    tic;
    %check if both conditions are from the same hemisphere %%%%CHANGE TO
    %MORE GENERIC FUNCTION
%     if ~strcmp(condnameA(end-1:end),condnameB(end-1:end))
%         error('Both conditions have to be from the same hemisphere')
%     end
    lr = topview.lr;
    hemisphere = lr{strcmp(condnameA(end-2:end),'_RH')+1};
    conditioncombname = [condnameA '_' condnameB];
    
    % Set the permutations that will be calculated. If N equals the number
    % of all possible permutations, the full set of permutations is used.
    % If N is smaller, random permutations are sampled
    miceconditionA = topview.conditions.(condnameA).mice;
    miceconditionB = topview.conditions.(condnameB).mice;
    
    n_A = length(miceconditionA);
    n_B = length(miceconditionB);
    
    all_mice         = [miceconditionA; miceconditionB];
    n_permutations   = topview.interconditions.(conditioncombname).n_permutations;
    max_permutations = nchoosek(n_A + n_B,n_A);
    
    if n_permutations == max_permutations
        perms           = nchoosek(all_mice, n_A);
        permscomplement = cell(size(perms,1),n_B);
        
        for j = 1:size(perms,1)
            permscomplement(j,:) = all_mice(~ismember(all_mice,perms(j,:)))';
        end
    else
        perms = cell(n_permutations,n_A);
        permscomplement = cell(n_permutations, n_B);
        perms(1,:) = miceconditionA;
        permscomplement(1,:) = miceconditionB;
        
        for j = 2:n_permutations
            perms(j,:) = all_mice(randperm(n_A+n_B,n_A));
            permscomplement(j,:) = all_mice(~ismember(all_mice,perms(j,:)));
        end
    end
    
    topview.interconditions.(conditioncombname).perms = perms;
    topview.interconditions.(conditioncombname).permscomplement = permscomplement;
    
    % Get generalmodel parameters
    xs = topview.generalmodel.(hemisphere).(['mask_' suporinfra]);
    ys = topview.generalmodel.(hemisphere).bregmas;
    bregmas = ys(:,1);
    xi = topview.generalmodel.(hemisphere).(['xi_' suporinfra]);
    yi = topview.generalmodel.(hemisphere).(['yi_' suporinfra]);
    
    %slice variables
    Cmax = ones(numel(xi),1);
    Cmin = ones(numel(xi),1);
    
    %initiate progress report
    if(nargin<6)
        parfor_progress(n_permutations);
    end
%     total_tstat = nan(size(xi,1),size(xi,2),N);
    
    %run observed condition first
    tstat_observed_ind = zeros(numel(xi),1);
    [observed_tstat,observed_topviewABdiff,observed_topviewABdiff_relative] = pseudottestcondition(perms(1,:),permscomplement(1,:));
    [tstat_observed_sorted,tstat_observed_ind] = sort(reshape(observed_tstat',[],1));
    if(nargin<6)
        parfor_progress;
    end
    
%     total_tstat(:,:,1) = observed_tstat;
    
    %run all other permutations
    for j = 2:n_permutations
        [tstat,~,~] = pseudottestcondition(perms(j,:),permscomplement(j,:));
%         total_tstat(:,:,j) = tstat;
        [cmin,cmax] = stepdowntest(tstat);
        Cmax = Cmax + cmax;
        Cmin = Cmin + cmin;
        
        %report progress
        if(nargin<6)
            parfor_progress;
        end
    end
    % pvalues
    Psdmax_accent = Cmax./n_permutations;
    Psdmin_accent = Cmin./n_permutations;
    %enforce monotonicity
    Psdmax(tstat_observed_ind) = enforce_max_monotonicity(Psdmax_accent);
    Psdmin(tstat_observed_ind) = enforce_min_monotonicity(Psdmin_accent);
    
    Psdmax = reshape(Psdmax,fliplr(size(xi)))';
    Psdmax(isnan(observed_tstat)) = NaN;
    Psdmin = reshape(Psdmin,fliplr(size(xi)))';
    Psdmin(isnan(observed_tstat)) = NaN;
    
    topview.interconditions.(conditioncombname).(['topviewABdiff_' suporinfra]) = squeeze(observed_topviewABdiff);
    topview.interconditions.(conditioncombname).(['topviewABdiff_relative_' suporinfra]) = squeeze(observed_topviewABdiff_relative);
    topview.interconditions.(conditioncombname).(['tstat_' suporinfra]) = squeeze(observed_tstat);
    topview.interconditions.(conditioncombname).(['nanmap_' suporinfra]) = ~isnan(observed_tstat);
    topview.interconditions.(conditioncombname).(['Psdmax' suporinfra]) = Psdmax;
    topview.interconditions.(conditioncombname).(['Psdmin' suporinfra]) = Psdmin;
%     topview.interconditions.(conditioncombname).(['tstattotal_' suporinfra]) = total_tstat;
    topview.interconditions.(conditioncombname).hemisphere = topview.conditions.(condnameA).hemisphere;
    
    %clean progress report
    if(nargin<6)
        parfor_progress(0);
    end
    time = toc;
%     fprintf('Time elapsed %d seconds\n',round(time));
    
    function [tstat,topviewABdiff,topviewABdiffrelative] = pseudottestcondition(perms,permscomplement)
        %stack and align mice, interpolate per mouse, merge in condition and interpolate
        %condition A
        condA = nan(size(ys,1),size(xs,2),size(perms,2));
        condA_interpol = nan(size(yi,1),size(xi,2),size(perms,2));
        for kkk = 1:size(perms,2)
            bregmasel = ismember(bregmas,topview.mice.(perms{kkk}).bregmas);
            condA(bregmasel,:,kkk) = topview.mice.(perms{kkk}).(suporinfra);
            condA_interpol(:,:,kkk) = topview.mice.(perms{kkk}).([suporinfra 'interpol_gm_smooth']);
        end
        
        %condition B
        condB = nan(size(ys,1),size(xs,2),size(permscomplement,2));
        condB_interpol = nan(size(yi,1),size(xi,2),size(permscomplement,2));
        for kkk = 1:size(permscomplement,2)
            bregmasel = ismember(bregmas,topview.mice.(permscomplement{kkk}).bregmas);
            condB(bregmasel,:,kkk) = topview.mice.(permscomplement{kkk}).(suporinfra);
            condB_interpol(:,:,kkk) = topview.mice.(permscomplement{kkk}).([suporinfra 'interpol_gm_smooth']);
        end
        
        %mean
        condA_mean = nanmean(condA,3);
        condB_mean = nanmean(condB,3);
        
        %create mask to normalize against B
        nnanA = ~isnan(condA_mean(:,1));
        nnanB = ~isnan(condB_mean(:,1));
        nnanmask = nnanA & nnanB;
        tmp = condB_mean(nnanmask,:);
        normB = mean(tmp(:));
        
%         condA_mean = condA_mean./normB;
%         condA_interpol = condA_interpol./normB;
        condA_mean_interpol = smoothfct(topview,concave_griddata(xs(nnanA,:),ys(nnanA,:),condA_mean(nnanA,:),xi,yi));
        
%         condB_mean = condB_mean./normB;
%         condB_interpol = condB_interpol./normB;
        condB_mean_interpol = smoothfct(topview,concave_griddata(xs(nnanB,:),ys(nnanB,:),condB_mean(nnanB,:),xi,yi));
        
        
        %shift scale and take difference
        %shift scale
        scaleshift = abs(min(0,min(min(min(condA_mean_interpol)),min(min(condB_mean_interpol)))));
        topviewAB3D = nan(size(yi,1),size(xi,2),2);
        topviewAB3D(:,:,1) = condA_mean_interpol + scaleshift;
        topviewAB3D(:,:,2) = condB_mean_interpol + scaleshift;
        topviewABdiff = -diff(topviewAB3D,1,3); % condition A - condition B
        topviewABdiffrelative = topviewABdiff./sum(topviewAB3D,3);
        if(equalvariances)
            %assume equal variances
            topviewABvar = movingvar(topviewABdiff,25);
            tstat = topviewABdiff./sqrt(topviewABvar*((1/size(perms,2))+(1/size(permscomplement,2))));
        else
            %don't assume equal variances
            condAvar = movingFWHM(sum((condA_interpol-repmat(condA_mean_interpol,[1 1 size(perms,2)])).^2,3)./(size(perms,2)-1),5);
            condBvar = movingFWHM(sum((condB_interpol-repmat(condB_mean_interpol,[1 1 size(permscomplement,2)])).^2,3)./(size(permscomplement,2)-1),5);
            tstat = topviewABdiff./sqrt((condAvar/size(perms,2))+(condBvar/size(permscomplement,2)));
        end
         
    end

    function [cmin,cmax] = stepdowntest(tstat)
        %successive maxima
        tk = reshape(tstat',[],1);
        vmax = successive_maxima(tk(tstat_observed_ind));
        vmin = successive_minima(tk(tstat_observed_ind));
        cmax = vmax >= tstat_observed_sorted;
        cmin = vmin <= tstat_observed_sorted;
    end
    
end

function v = successive_maxima(tk)
    v = nan(size(tk));
    v(1) = tk(1);
    for i=2:length(tk)
        v(i) = max(v(i-1),tk(i));
    end
end

function v = successive_minima(tk)
    v = nan(size(tk));
    v(end) = tk(end);
    for i=length(v)-1:-1:1
        v(i) = min(v(i+1),tk(i));
    end
end
    
function Psd = enforce_max_monotonicity(Psd_accent)
   Psd = nan(size(Psd_accent));
   Psd(end) = Psd_accent(end);
   for i= length(Psd_accent)-1:-1:1
       Psd(i) = max(Psd(i+1),Psd_accent(i));
   end
end

function Psd = enforce_min_monotonicity(Psd_accent)
   Psd = nan(size(Psd_accent));
   Psd(1) = Psd_accent(1);
   for i= 2:length(Psd_accent)
       Psd(i) = max(Psd(i-1),Psd_accent(i));
   end
end
    


