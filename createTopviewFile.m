function topview = createTopviewFile(setuptable)
%%%%%%%%%%%%%%%%%%%%%%%%
% function createTopviewFile creates a structure with data sorted by mice
% and conditions
%
%   INPUT: setuptable
%   OUTPUT: topview
%
%   Samme Vreysen
%   13/03/2015
%
%%%%%%%%%%%%%%%%%%%%%%%%
    lr = {'left';'right'};
    suporinfra = {'supra';'infra'};
    bregmas = cellfun(@(x) num2str(x.bregma),setuptable(:,5),'UniformOutput',false);
    tmp = [setuptable bregmas];
    [setuptable idx] = sortrows(tmp,[1 2 7]);
    topview.conditionnames = unique(setuptable(:,1));
    topview.micenames = unique(setuptable(:,2));
    topview.bregmas = unique(cell2mat(arrayfun(@(x) x{:}.bregma,setuptable(:,5),'UniformOutput',false)));
    topview.segments = unique(setuptable{1,6}.segments);
    topview.arealborders = unique(setuptable{1,5}.arealborders);
    topview.areas = setuptable{1,5}.areas;
    topview.pixpermm = 52.3864;
    for i=1:size(topview.conditionnames,1)
        topview.conditions.(topview.conditionnames{i}).mice = unique(setuptable(strcmp(setuptable(:,1),topview.conditionnames{i}),2));
        topview.conditions.(topview.conditionnames{i}).hemisphere = lr{strcmp(topview.conditionnames{i}(end-2:end),'_RH')+1};
    end
    
    for i=1:size(topview.micenames,1)
        mouse = topview.micenames{i};
        try
            topview.mice.(mouse).hemisphere = lr{strcmp(mouse(end-2:end),'_RH')+1};
            topview.mice.(mouse).bregmas = cell2mat(cellfun(@(x) x.bregma,setuptable(strcmp(setuptable(:,2),mouse),5),'UniformOutput',false));
            topview.mice.(mouse).segments = cell2mat(cellfun(@(x) x.bregma,setuptable(strcmp(setuptable(:,2),mouse),5),'UniformOutput',false));
            topview.mice.(mouse).supra = (1-(cell2mat(cellfun(@(x) x.meansupra_raw, setuptable(strcmp(setuptable(:,2),mouse),6),'UniformOutput',false))./repmat(cell2mat(cellfun(@(x) x.meanbg, setuptable(strcmp(setuptable(:,2),mouse),5),'UniformOutput',false)),1,topview.segments))).*100;
            topview.mice.(mouse).infra = (1-(cell2mat(cellfun(@(x) x.meaninfra_raw, setuptable(strcmp(setuptable(:,2),mouse),6),'UniformOutput',false))./repmat(cell2mat(cellfun(@(x) x.meanbg, setuptable(strcmp(setuptable(:,2),mouse),5),'UniformOutput',false)),1,topview.segments))).*100;
            topview.mice.(mouse).arearelsupra = cell2mat(cellfun(@(x) x.toparealrel,setuptable(strcmp(setuptable(:,2),mouse),6),'UniformOutput',false));
            topview.mice.(mouse).arearelinfra = cell2mat(cellfun(@(x) x.botarealrel,setuptable(strcmp(setuptable(:,2),mouse),6),'UniformOutput',false));
        catch
            fprintf('problem %d - %s',i,topview.micenames{i});
        end
    end
    topview.normalizetomouse = NaN;
    for i=1:size(topview.micenames,1)
        topview.mice.(topview.micenames{i}).normalizefactor_supra = 1;
        topview.mice.(topview.micenames{i}).normalizefactor_infra = 1;
    end

%     if(~isfield(topview.mice.(topview.micenames{1}),'topcoxyprojected'))
    tmp = zeros(size(setuptable,1),1);
    for i=1:size(setuptable,1)
        setuptable{i,6}.topcoxyprojected = projectToTopview(getCenterCoXY(setuptable{i,6}.topcoxy),setuptable{i,5}.midlinep);
        setuptable{i,6}.botcoxyprojected = projectToTopview(getCenterCoXY(setuptable{i,6}.botcoxy),setuptable{i,5}.midlinep);
        setuptable{i,5}.topareaxyprojected = projectToTopview(setuptable{i,5}.topareaxy,setuptable{i,5}.midlinep);
        setuptable{i,5}.botareaxyprojected = projectToTopview(setuptable{i,5}.botareaxy,setuptable{i,5}.midlinep);
        tmp(i) = length(setuptable{i,5}.topareaxyprojected);
    end
    oldmouse = '';
    for i=1:size(setuptable,1)
        mouse = setuptable{i,2};
        if(~strcmp(oldmouse,mouse))
            topview.mice.(mouse).topareaxyprojected = nan(length(topview.mice.(mouse).bregmas),topview.arealborders);
            topview.mice.(mouse).botareaxyprojected = nan(length(topview.mice.(mouse).bregmas),topview.arealborders);
            oldmouse = mouse;
        end
        tmpcoxy = getCenterCoXY(setuptable{i,6}.topcoxy);
        topview.mice.(mouse).topcoxy(topview.mice.(mouse).bregmas == setuptable{i,5}.bregma,:,:) = reshape(tmpcoxy,[1 size(tmpcoxy)]);
        tmpcoxy = getCenterCoXY(setuptable{i,6}.botcoxy);
        topview.mice.(mouse).botcoxy(topview.mice.(mouse).bregmas == setuptable{i,5}.bregma,:,:) = reshape(tmpcoxy,[1 size(tmpcoxy)]);
        tmpcoxy = getCenterCoXY(setuptable{i,5}.topareaxy);
        topview.mice.(mouse).topareacoxy(topview.mice.(mouse).bregmas == setuptable{i,5}.bregma,:,:) = reshape(tmpcoxy,[1 size(tmpcoxy)]);
        tmpcoxy = getCenterCoXY(setuptable{i,5}.botareaxy);
        topview.mice.(mouse).botareacoxy(topview.mice.(mouse).bregmas == setuptable{i,5}.bregma,:,:) = reshape(tmpcoxy,[1 size(tmpcoxy)]);
        topview.mice.(mouse).midlinep(topview.mice.(mouse).bregmas == setuptable{i,5}.bregma,:) = setuptable{i,5}.midlinep;
        topview.mice.(mouse).topcoxyprojected(topview.mice.(mouse).bregmas == setuptable{i,5}.bregma,:) = setuptable{i,6}.topcoxyprojected;
        topview.mice.(mouse).botcoxyprojected(topview.mice.(mouse).bregmas == setuptable{i,5}.bregma,:) = setuptable{i,6}.botcoxyprojected;
        topview.mice.(mouse).topareaxyprojected(topview.mice.(mouse).bregmas == setuptable{i,5}.bregma,:) = setuptable{i,5}.topareaxyprojected;
        topview.mice.(mouse).botareaxyprojected(topview.mice.(mouse).bregmas == setuptable{i,5}.bregma,:) = setuptable{i,5}.botareaxyprojected;
    end
    %clim
    clim_sup_low = min(cell2mat(cellfun(@(x) min(topview.mice.(x).supra(:)),topview.micenames,'UniformOutput',false)));
    clim_inf_low = min(cell2mat(cellfun(@(x) min(topview.mice.(x).infra(:)),topview.micenames,'UniformOutput',false)));
    clim_sup_high = max(cell2mat(cellfun(@(x) max(topview.mice.(x).supra(:)),topview.micenames,'UniformOutput',false)));
    clim_inf_high = max(cell2mat(cellfun(@(x) max(topview.mice.(x).infra(:)),topview.micenames,'UniformOutput',false)));
    topview.clim = [min(clim_sup_low,clim_inf_low) max(clim_sup_high,clim_inf_high)];
    
    %smooth projection
    mice = fieldnames(topview.mice);
    for i=1:size(mice,1)
        mouse = mice{i};
        topview.mice.(mouse).topcoxyprojected_smooth = smoothProjection(topview.mice.(mouse).topcoxyprojected,topview.mice.(mouse).topcoxy,topview.mice.(mouse).midlinep);
        topview.mice.(mouse).botcoxyprojected_smooth = smoothProjection(topview.mice.(mouse).botcoxyprojected,topview.mice.(mouse).botcoxy,topview.mice.(mouse).midlinep);
        for j=1:size(topview.mice.(mouse).topareaxyprojected,2)
            topview.mice.(mouse).topareaxyprojected_smooth(:,j) = smoothLine(topview.mice.(mouse).topareaxyprojected(:,j),5);
            topview.mice.(mouse).botareaxyprojected_smooth(:,j) = smoothLine(topview.mice.(mouse).botareaxyprojected(:,j),5);
        end
    end
    %general mouse model
    for i=1:length(lr)
        for h=1:length(suporinfra)
            tmpgeneralmodel.(lr{i}).(['mask_' suporinfra{h}]) = nan(size(topview.bregmas,1),topview.segments,size(mice,1));
            tmpgeneralmodel.(lr{i}).(['areas_' suporinfra{h}]) = nan(size(topview.bregmas,1),topview.arealborders,size(mice,1));
        end
        for j=1:size(mice,1)
            mouse = mice{j};
            if(strcmp(topview.mice.(mouse).hemisphere,lr{i}))
                tmpgeneralmodel.(lr{i}).mask_supra(ismember(topview.bregmas,topview.mice.(mouse).bregmas),:,j) = topview.mice.(mouse).topcoxyprojected_smooth;
                tmpgeneralmodel.(lr{i}).mask_infra(ismember(topview.bregmas,topview.mice.(mouse).bregmas),:,j) = topview.mice.(mouse).botcoxyprojected_smooth;
                tmpgeneralmodel.(lr{i}).areas_supra(ismember(topview.bregmas,topview.mice.(mouse).bregmas),:,j) = topview.mice.(mouse).topareaxyprojected_smooth;
                tmpgeneralmodel.(lr{i}).areas_infra(ismember(topview.bregmas,topview.mice.(mouse).bregmas),:,j) = topview.mice.(mouse).botareaxyprojected_smooth;
                if(isfield(topview,'mousemask') & isfield(topview.generalmodel,lr{i}) & isfield(topview.generalmodel.(lr{i}),'mice'))
                    topview.generalmodel.(lr{i}).mice = [topview.generalmodel.(lr{i}).mice {mouse}];
                else
                    topview.generalmodel.(lr{i}).mice = {mouse};
                end
            end
        end
    end
    
    for i=1:length(lr)
        for h=1:length(suporinfra)
            topview.generalmodel.(lr{i}).(['mask_' suporinfra{h}]) = nan(size(topview.bregmas,1),topview.segments);
            topview.generalmodel.(lr{i}).(['areas_' suporinfra{h}]) = nan(size(topview.bregmas,1),topview.arealborders);
            topview.generalmodel.(lr{i}).bregmas = repmat(topview.bregmas,1,topview.segments);
            for j=1:size(tmpgeneralmodel.(lr{i}).(['mask_' suporinfra{h}]),1)
                for k=1:size(tmpgeneralmodel.(lr{i}).(['mask_' suporinfra{h}]),2)
                    if(~all(isnan(tmpgeneralmodel.(lr{i}).(['mask_' suporinfra{h}])(j,k,:))))
                        topview.generalmodel.(lr{i}).(['mask_' suporinfra{h}])(j,k) = mean(smoothLine(tmpgeneralmodel.(lr{i}).(['mask_' suporinfra{h}])(j,k,~isnan(tmpgeneralmodel.(lr{i}).(['mask_' suporinfra{h}])(j,k,:))),5));
                    end
                end
            end
            for j=1:size(tmpgeneralmodel.(lr{i}).(['areas_' suporinfra{h}]),1)
                for k=1:size(tmpgeneralmodel.(lr{i}).(['areas_' suporinfra{h}]),2)
                    if(~all(isnan(tmpgeneralmodel.(lr{i}).(['areas_' suporinfra{h}])(j,k,:))))
                        topview.generalmodel.(lr{i}).(['areas_' suporinfra{h}])(j,k) = mean(smoothLine(tmpgeneralmodel.(lr{i}).(['areas_' suporinfra{h}])(j,k,~isnan(tmpgeneralmodel.(lr{i}).(['areas_' suporinfra{h}])(j,k,:))),5));
                    end
                end
            end
            topview.generalmodel.(lr{i}).(['mask_' suporinfra{h}]) = topview.generalmodel.(lr{i}).(['mask_' suporinfra{h}])/topview.pixpermm*100;
            topview.generalmodel.(lr{i}).(['areas_' suporinfra{h}]) = topview.generalmodel.(lr{i}).(['areas_' suporinfra{h}])/topview.pixpermm*100;
            xs = topview.generalmodel.(lr{i}).(['mask_' suporinfra{h}]);
            ys = topview.generalmodel.(lr{i}).bregmas;
            [xi yi] = meshgrid(min(xs(:)):max(xs(:)),min(ys(:)):max(ys(:)));
            topview.generalmodel.(lr{i}).(['xi_' suporinfra{h}]) = xi;
            topview.generalmodel.(lr{i}).(['yi_' suporinfra{h}]) = yi;
        end
    end
    for i=1:length(lr)
        for h=1:length(suporinfra)
            for j=1:size(topview.generalmodel.(lr{i}).(['mask_' suporinfra{h}]),2)
                topview.generalmodel.(lr{i}).(['mask_' suporinfra{h}])(:,j) = smoothLine(topview.generalmodel.(lr{i}).(['mask_' suporinfra{h}])(:,j),5);
            end
            for j=1:size(topview.generalmodel.(lr{i}).(['areas_' suporinfra{h}]),2)
                topview.generalmodel.(lr{i}).(['areas_' suporinfra{h}])(:,j) = smoothLine(topview.generalmodel.(lr{i}).(['areas_' suporinfra{h}])(:,j),5);
            end
            topview.generalmodel.(lr{i}).(['mask_' suporinfra{h}]) = inpaint_nans(topview.generalmodel.(lr{i}).(['mask_' suporinfra{h}]),3);
            topview.generalmodel.(lr{i}).(['areas_' suporinfra{h}]) = inpaint_nans(topview.generalmodel.(lr{i}).(['areas_' suporinfra{h}]),3);
        end
    end
    %make topviews for each mouse based on general mouse model
    for h=1:length(suporinfra)
        for i=1:size(mice,1)
            mouse = mice{i};
            xs = topview.generalmodel.(topview.mice.(mouse).hemisphere).(['mask_' suporinfra{h}]);
            ys = topview.generalmodel.(topview.mice.(mouse).hemisphere).bregmas;
            v = topview.mice.(mouse).(suporinfra{h}).*topview.mice.(mouse).(['normalizefactor_' suporinfra{h}]);
            [xi yi] = meshgrid(min(xs(:)):max(xs(:)),min(ys(:)):max(ys(:)));
            vnnan = ismember(topview.generalmodel.(topview.mice.(mouse).hemisphere).bregmas(:,1),topview.mice.(mouse).bregmas);
            topview.mice.(mouse).([suporinfra{h} 'interpol_gm']) = griddata(xs(vnnan,:),ys(vnnan,:),v,xi,yi,'linear');
        end
    end
%     end