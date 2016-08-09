function topview = createTopviewFile(setuptable,gridsize,pixpermm)
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
    suporinfra = {'supra';'infra';'total'};
    toporbot = {'top';'bot';'top'}; %assume total
    topview.gridsize = gridsize; %0.1; %0.2 for rat
    topview.pixpermm = pixpermm; %52.3864;
    topview.smoothwindow = topview.gridsize*2; %0.2;
     
    bregmas = cellfun(@(x) num2str(x.bregma),setuptable(:,5),'UniformOutput',false);
    tmp = [setuptable bregmas];
    [setuptable idx] = sortrows(tmp,[1 2 7]);
    topview.conditionnames = unique(setuptable(:,1));
    topview.micenames = unique(setuptable(:,2));
    bregmas = unique(cell2mat(arrayfun(@(x) x{:}.bregma,setuptable(:,5),'UniformOutput',false)));
    topview.bregmas = (min(bregmas):topview.gridsize*100:max(bregmas))';
    topview.segments = unique(setuptable{1,6}.segments);
    topview.arealborders = unique(setuptable{1,5}.arealborders);
    topview.areas = setuptable{1,5}.areas;
    topview.lr = lr;
    topview.suporinfra = suporinfra;
    topview.noLayers = size(setuptable{1,5}.meanbg,1);
   
    
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
            for h=1:length(suporinfra)
                %calc relative signal and interpolate missing valuesµ
                tmp = cell2mat(cellfun(@(x) permute(x.(['mean' suporinfra{h}]),[3 2 1]), setuptable(strcmp(setuptable(:,2),mouse),6),'UniformOutput',false));
                for j=1:topview.noLayers
                    topview.mice.(mouse).(suporinfra{h})(:,:,j) = inpaint_nans_no_extrapolation(tmp(:,:,j));
                end
                topview.mice.(mouse).(['arearel' suporinfra{h}]) = cell2mat(cellfun(@(x) x.([toporbot{h} 'arealrel']),setuptable(strcmp(setuptable(:,2),mouse),6),'UniformOutput',false));
            end
        catch
            fprintf('problem %d - %s\n',i,topview.micenames{i});
        end
    end
    topview.normalizetomouse = NaN;
    for i=1:size(topview.micenames,1)
        for h=1:length(suporinfra)
            topview.mice.(topview.micenames{i}).(['normalizefactor_' suporinfra{h}]) = 1;
        end
    end

     for i=1:size(setuptable,1)
        for h=1:length(suporinfra)
            setuptable{i,6}.([toporbot{h} 'coxyprojected']) = projectToTopview(getCenterCoXY(setuptable{i,6}.([toporbot{h} 'coxy'])),setuptable{i,5}.midlinep);
            setuptable{i,5}.([toporbot{h} 'areaxyprojected']) = projectToTopview(setuptable{i,5}.([toporbot{h} 'areaxy']),setuptable{i,5}.midlinep);
        end
    end
    oldmouse = '';
    for i=1:size(setuptable,1)
        mouse = setuptable{i,2};
        for h=1:length(suporinfra)
            if(~strcmp(oldmouse,mouse))
                topview.mice.(mouse).([toporbot{h} 'areaxyprojected']) = nan(length(topview.mice.(mouse).bregmas),topview.arealborders);
                oldmouse = mouse;
            end
            tmpcoxy = getCenterCoXY(setuptable{i,6}.([toporbot{h} 'coxy']));
            topview.mice.(mouse).([suporinfra{h} 'coxy'])(topview.mice.(mouse).bregmas == setuptable{i,5}.bregma,:,:) = reshape(tmpcoxy,[1 size(tmpcoxy)]);
            tmpcoxy = getCenterCoXY(setuptable{i,5}.([toporbot{h} 'areaxy']));
            topview.mice.(mouse).([suporinfra{h} 'areacoxy'])(topview.mice.(mouse).bregmas == setuptable{i,5}.bregma,:,:) = reshape(tmpcoxy,[1 size(tmpcoxy)]);
            
            topview.mice.(mouse).([suporinfra{h} 'coxyprojected'])(topview.mice.(mouse).bregmas == setuptable{i,5}.bregma,:) = setuptable{i,6}.([toporbot{h} 'coxyprojected']);
            topview.mice.(mouse).([suporinfra{h} 'areaxyprojected'])(topview.mice.(mouse).bregmas == setuptable{i,5}.bregma,:) = setuptable{i,5}.([toporbot{h} 'areaxyprojected']);
        end
        topview.mice.(mouse).midlinep(topview.mice.(mouse).bregmas == setuptable{i,5}.bregma,:) = setuptable{i,5}.midlinep;
    end
    %clim
    for h=1:length(suporinfra)
        clim_low(h) = min(cell2mat(cellfun(@(x) min(topview.mice.(x).(suporinfra{h})(:)),topview.micenames,'UniformOutput',false)));
        clim_high(h) = max(cell2mat(cellfun(@(x) max(topview.mice.(x).(suporinfra{h})(:)),topview.micenames,'UniformOutput',false)));
    end
    topview.clim = [min(clim_low) max(clim_high)];
    
    %smooth projection
    mice = fieldnames(topview.mice);
    for i=1:size(mice,1)
        mouse = mice{i};
        for h=1:length(suporinfra)
            topview.mice.(mouse).([suporinfra{h} 'coxyprojected_smooth']) = smoothProjection(topview.mice.(mouse).([suporinfra{h} 'coxyprojected']),topview.mice.(mouse).([suporinfra{h} 'coxy']),topview.mice.(mouse).midlinep);
            for j=1:size(topview.mice.(mouse).([suporinfra{h} 'areaxyprojected']),2)
                topview.mice.(mouse).([suporinfra{h} 'areaxyprojected_smooth'])(:,j) = smoothLine(topview.mice.(mouse).([suporinfra{h} 'areaxyprojected'])(:,j),5);
            end
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
                for h=1:length(suporinfra)
                    tmpgeneralmodel.(lr{i}).(['mask_' suporinfra{h}])(ismember(topview.bregmas,topview.mice.(mouse).bregmas),:,j) = topview.mice.(mouse).([suporinfra{h} 'coxyprojected_smooth']);
                    tmpgeneralmodel.(lr{i}).(['areas_' suporinfra{h}])(ismember(topview.bregmas,topview.mice.(mouse).bregmas),:,j) = topview.mice.(mouse).([suporinfra{h} 'areaxyprojected_smooth']);
                end
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
            if(any(isnan(topview.generalmodel.(lr{i}).(['mask_' suporinfra{h}])(:,1))))
                topview.generalmodel.(lr{i}).(['mask_' suporinfra{h}]) = inpaint_nans(topview.generalmodel.(lr{i}).(['mask_' suporinfra{h}]),3);
            end
            if(any(isnan(topview.generalmodel.(lr{i}).(['areas_' suporinfra{h}])(:,1))))
                for k=1:size(topview.generalmodel.(lr{i}).(['areas_' suporinfra{h}]),2)
                    tmp = topview.generalmodel.(lr{i}).(['areas_' suporinfra{h}])(:,k);
                    if(~all(isnan(tmp)))
                        topview.generalmodel.(lr{i}).(['areas_' suporinfra{h}])(:,k) = interp1(topview.bregmas(~isnan(tmp)),tmp(~isnan(tmp)),topview.bregmas);
                    end
                end
            end
            for j=1:size(topview.generalmodel.(lr{i}).(['mask_' suporinfra{h}]),2)
                topview.generalmodel.(lr{i}).(['mask_' suporinfra{h}])(:,j) = smoothLine(topview.generalmodel.(lr{i}).(['mask_' suporinfra{h}])(:,j),5);
            end
            for j=1:size(topview.generalmodel.(lr{i}).(['areas_' suporinfra{h}]),2)
                topview.generalmodel.(lr{i}).(['areas_' suporinfra{h}])(:,j) = smoothLine(topview.generalmodel.(lr{i}).(['areas_' suporinfra{h}])(:,j),5);
            end
            
        end
    end
    %create topviews for each mouse based on general mouse model
    topview.mice = catstruct(topview.mice,interpolate_mice_gm(topview));
    %create topview per condition based on general mouse model
    topview.conditions = catstruct(topview.conditions,interpolate_conditions_gm(topview));
    