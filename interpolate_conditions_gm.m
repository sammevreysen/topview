function conditions = interpolate_conditions_gm(topview)
    for i=1:size(topview.conditionnames,1)
        condition = topview.conditionnames{i};
        conditions.(condition) = interpolate_condition(topview,condition);
    end
end

function out = interpolate_condition(topview,condition)
    suporinfra = topview.suporinfra;
    micelist = topview.conditions.(condition).mice;
    arealborders = topview.arealborders;
    bregmalist = [];
    segments = 1:topview.segments;
%     for jjj = 1:size(micelist,1)
%         bregmalist = [bregmalist; topview.mice.(micelist{jjj}).bregmas];
%     end
    out = topview.conditions.(condition);
    out.bregmas = topview.bregmas;
    out.segments = segments;
    %stack and align all animal in matrix (bregmas x segments x
    %animals)
    for i=1:length(suporinfra)
        out.(suporinfra{i}) = nan(size(out.bregmas,1),size(segments,2),size(micelist,1),topview.noLayers);
        out.(['arearel' suporinfra{i}]) = nan(size(out.bregmas,1),arealborders,size(micelist,1));
        for jjj = 1:size(micelist,1)
            for kkk=1:topview.noLayers
                out.(suporinfra{i})(ismember(out.bregmas,topview.mice.(micelist{jjj}).bregmas),:,jjj,kkk) = topview.mice.(micelist{jjj}).(suporinfra{i})(:,:,kkk).*topview.mice.(micelist{jjj}).(['normalizefactor_' suporinfra{i}]);
            end
            out.(['arearel' suporinfra{i}])(ismember(out.bregmas,topview.mice.(micelist{jjj}).bregmas),:,jjj) = topview.mice.(micelist{jjj}).(['arearel' suporinfra{i}]);
        end
        %interpolate per animal to grid without extrapolation (already done
        %in createTopviewFile
%         for jjj = 1:size(out.(suporinfra{i}),3)
%             tmp = out.(suporinfra{i})(:,1,jjj);
%             sel = true(size(tmp));
%             %remove outerpolation
%             idf = find(~isnan(tmp),1,'first');
%             if(idf > 1)
%                 sel(1:idf-1) = 0;
%             end
%             idf = find(~isnan(tmp),1,'last');
%             if(idf < length(tmp))
%                 sel(idf+1:end) = 0;
%             end
%             %smart interpolate
%             out.(suporinfra{i})(sel,:,jjj) = inpaint_nans(out.(suporinfra{i})(sel,:,jjj),3);
%         end
        out.([suporinfra{i} '_mean']) = nanmean(out.(suporinfra{i}),3);
        out.(['arearel' suporinfra{i} '_mean']) = nanmean(out.(['arearel' suporinfra{i}]),3);
        
        %interpolate
        %flatmount
        [x,y] = meshgrid(segments,out.bregmas);
        [xi,yi] = meshgrid(1:0.1:size(x,2),y(1):1:y(end));
        for jjj=1:topview.noLayers
            out.([suporinfra{i} '_mean_interpol'])(:,:,jjj) = interp2(x,y,out.([suporinfra{i} '_mean'])(:,:,jjj),xi,yi,'linear');
        end
        out.segmentsinterpol = xi(1,:);
        out.bregmasinterpol = yi(:,1);
        [xa,ya] = meshgrid(1:topview.arealborders,out.bregmas);
        [xai,yai] = meshgrid(1:topview.arealborders,ya(1):1:ya(end));
        out.(['arearel' suporinfra{i} '_mean_interpol']) = interp2(xa,ya,out.(['arearel' suporinfra{i} '_mean']),xai,yai,'linear');
        %topview
        xs = topview.generalmodel.(out.hemisphere).(['mask_' suporinfra{i}]);
        ys = topview.generalmodel.(out.hemisphere).bregmas;
        xi = topview.generalmodel.(out.hemisphere).(['xi_' suporinfra{i}]);
        yi = topview.generalmodel.(out.hemisphere).(['yi_' suporinfra{i}]);
        %      v = nan(size(xs));
        for jjj=1:topview.noLayers
            v = out.([suporinfra{i} '_mean'])(:,:,jjj);
            vnnan = ~isnan(v(:,1));%ismember(topview.bregmas,out.bregmas);
            
            tmp = concave_griddata(xs(vnnan,:),ys(vnnan,:),v(vnnan,:),xi,yi);
            %      tmp = griddata(xs,ys,v,xi,yi,'linear');
            vinan = any(~isnan(tmp),2);
            tmp([find(vinan,1,'first') find(vinan,1,'last')],:) = NaN;
            out.(['topview_' suporinfra{i} '_mean_interpol'])(:,:,jjj) = tmp;
            out.(['topview_' suporinfra{i} '_mean_interpol_smooth'])(:,:,jjj) = smoothfct(topview,tmp);
        end
        out.(['topview_' suporinfra{i} '_xi']) = xi;
        out.(['topview_' suporinfra{i} '_yi']) = yi;
        [xa,ya] = meshgrid(1:topview.arealborders,topview.bregmas);
        [xai,yai] = meshgrid(1:topview.arealborders,min(ys(:)):max(ys(:)));
        va = topview.generalmodel.(out.hemisphere).(['areas_' suporinfra{i}]);
        out.(['topview_area_' suporinfra{i} '_mean_interpol']) = interp2(xa,ya,va,xai,yai,'linear');
        out.(['topview_area_' suporinfra{i} '_xi']) = xai;
        out.(['topview_area_' suporinfra{i} '_yi']) = yai;
    end
end