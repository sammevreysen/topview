function mice = interpolate_mice_gm(topview)
    suporinfra = topview.suporinfra;
    micenames = fieldnames(topview.mice);
    for h=1:length(suporinfra)
        for i=1:size(micenames,1)
            mouse = micenames{i};
            x = topview.generalmodel.(topview.mice.(mouse).hemisphere).(['mask_' suporinfra{h}]);
            y = topview.generalmodel.(topview.mice.(mouse).hemisphere).bregmas;
            xi = topview.generalmodel.(topview.mice.(mouse).hemisphere).(['xi_' suporinfra{h}]);
            yi = topview.generalmodel.(topview.mice.(mouse).hemisphere).(['yi_' suporinfra{h}]);
            for j=1:topview.noLayers
                v = topview.mice.(mouse).(suporinfra{h})(:,:,j).*topview.mice.(mouse).(['normalizefactor_' suporinfra{h}]);
                vnnan = ismember(topview.generalmodel.(topview.mice.(mouse).hemisphere).bregmas(:,1),topview.mice.(mouse).bregmas);
                mice.(mouse).([suporinfra{h} 'interpol_gm'])(:,:,j) = concave_griddata(x(vnnan,:),y(vnnan,:),v,xi,yi);
                mice.(mouse).([suporinfra{h} 'interpol_gm_smooth'])(:,:,j) = smoothfct(topview,mice.(mouse).([suporinfra{h} 'interpol_gm'])(:,:,j));
            end
        end
    end