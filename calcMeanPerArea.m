function out = calcMeanPerArea(topview)
    out = struct();
    for suporinfra=topview.suporinfra'
        tmp = load(['visual_areas_mask\' suporinfra{:} '_P120_C57Bl6J.mat'],'mask');
        mask = tmp.mask;
        outperview = table();
        for cond=fieldnames(topview.conditions)'
            for mouse=topview.conditions.(cond{:}).mice';
                tmp = table();
                tmp.condition = cond{:};
                I = topview.mice.(mouse{:}).([suporinfra{:} 'interpol_gm']);
                for area=fieldnames(mask)'
                    sel = roipoly(topview.conditions.(cond{:}).(['topview_' suporinfra{:} '_xi'])(1,:)/100,-topview.conditions.(cond{:}).(['topview_' suporinfra{:} '_yi'])(:,1)/100,I,mask.(area{:}).contour(1,:),mask.(area{:}).contour(2,:));
                    tmp.(area{:}) = nanmean(reshape(I(sel),1,[]));
                end
                outperview = [outperview; tmp];
            end
        end
        out.(suporinfra{:}) = outperview;
    end