function conditions = interpolate_conditions_gm(topview)
    for i=1:size(topview.conditionnames,1)
        condition = topview.conditionnames{i};
        conditions.(condition) = interpolate_condition(topview,condition);
    end
    
function out = interpolate_condition(topview,condition)
    suporinfra = topview.suporinfra;
    micelist = topview.conditions.(condition).mice;
    arealborders = topview.arealborders;
    bregmalist = [];
    segments = 1:topview.segments;
    for jjj = 1:size(micelist,1)
        bregmalist = [bregmalist; topview.mice.(micelist{jjj}).bregmas];
    end
    bregmalist = unique(bregmalist);
    out = topview.conditions.(condition);
    out.bregmas = bregmalist;
    out.segments = segments;
    %stack and align all animal in matrix (bregmas x segments x
    %animals)
    for i=1:length(suporinfra)
        out.(suporinfra{i}) = nan(size(bregmalist,1),size(segments,2),size(micelist,1));
        out.(['arearel' suporinfra{i}]) = nan(size(bregmalist,1),arealborders,size(micelist,1));
        for jjj = 1:size(micelist,1)
            out.(suporinfra{i})(ismember(bregmalist,topview.mice.(micelist{jjj}).bregmas),:,jjj) = topview.mice.(micelist{jjj}).(suporinfra{i}).*topview.mice.(micelist{jjj}).(['normalizefactor_' suporinfra{i}]);
            out.(['arearel' suporinfra{i}])(ismember(bregmalist,topview.mice.(micelist{jjj}).bregmas),:,jjj) = topview.mice.(micelist{jjj}).(['arearel' suporinfra{i}]);
        end
        out.([suporinfra{i} '_mean']) = nanmean(out.(suporinfra{i}),3);
        out.(['arearel' suporinfra{i} '_mean']) = nanmean(out.(['arearel' suporinfra{i}]),3);
        
        %interpolate
        %flatmount
        [x,y] = meshgrid(segments,out.bregmas);
        [xi,yi] = meshgrid(1:0.1:size(x,2),y(1):1:y(end));
        out.([suporinfra{i} '_mean_interpol']) = interp2(x,y,out.([suporinfra{i} '_mean']),xi,yi,'linear');
        out.segmentsinterpol = xi(1,:);
        out.bregmasinterpol = yi(:,1);
        [xa,ya] = meshgrid(1:topview.arealborders,bregmalist);
        [xai,yai] = meshgrid(1:topview.arealborders,ya(1):1:ya(end));
        out.(['arearel' suporinfra{i} '_mean_interpol']) = interp2(xa,ya,out.(['arearel' suporinfra{i} '_mean']),xai,yai,'linear');
        %topview
        xs = topview.generalmodel.(out.hemisphere).(['mask_' suporinfra{i}]);
        ys = topview.generalmodel.(out.hemisphere).bregmas;
        xi = topview.generalmodel.(out.hemisphere).(['xi_' suporinfra{i}]);
        yi = topview.generalmodel.(out.hemisphere).(['yi_' suporinfra{i}]);
        %      v = nan(size(xs));
        vnnan = ismember(topview.bregmas,out.bregmas);
        v = out.([suporinfra{i} '_mean']);
        
        tmp = concave_griddata(xs(vnnan,:),ys(vnnan,:),v,xi,yi);
        %      tmp = griddata(xs,ys,v,xi,yi,'linear');
        vinan = any(~isnan(tmp),2);
        tmp([find(vinan,1,'first') find(vinan,1,'last')],:) = NaN;
        out.(['topview_' suporinfra{i} '_mean_interpol']) = tmp;
        out.(['topview_' suporinfra{i} '_xi']) = xi;
        out.(['topview_' suporinfra{i} '_yi']) = yi;
        [xa,ya] = meshgrid(1:topview.arealborders,topview.bregmas);
        [xai,yai] = meshgrid(1:topview.arealborders,min(ys(:)):max(ys(:)));
        va = topview.generalmodel.(out.hemisphere).(['areas_' suporinfra{i}]);
        out.(['topview_area_' suporinfra{i} '_mean_interpol']) = interp2(xa,ya,va,xai,yai,'linear');
        out.(['topview_area_' suporinfra{i} '_xi']) = xai;
        out.(['topview_area_' suporinfra{i} '_yi']) = yai;
    end