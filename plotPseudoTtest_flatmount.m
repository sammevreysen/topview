function plotPseudoTtest_flatmount(topview)
    interconditions = fieldnames(topview.interconditions);
    selected = cell2mat(struct2cell(structfun(@(x) x.selected,topview.interconditions,'UniformOutput',false)));
    interconditions = interconditions(selected);
    rows = sum(selected);
    supraorinfra = {'supra','infra'};
    for j=1:2
        suporinfra = supraorinfra{j};
        fig = figure();
        cmenusupra = uicontextmenu;
        uimenu(cmenusupra, 'Label', 'Enlarge', 'Callback', @enlargesubplot);
        hMenu = uimenu(fig,'Label','Save');
        uimenu(hMenu,'Label','Save as PDF...','Callback',@saveFigAsPDF);
        hsp = zeros(rows,5);
        for i=1:rows
            condnames = topview.interconditions.(interconditions{i}).conditions;
            hsp(i,1) = subplot(rows,5,(i-1)*5+1);
            imagesc(topview.conditions.(condnames{1}).([suporinfra '_segments_interpol']),topview.conditions.(condnames{1}).([suporinfra '_bregmas_interpol']),topview.conditions.(condnames{1}).([suporinfra '_mean_interpol']));
            hold on;
            plot(topview.conditions.(condnames{1}).(['arearel' suporinfra '_mean_interpol']),topview.conditions.(condnames{1}).bregmasinterpol,'k-');
            hold off;
            title({['A: ' condnames{1}]; suporinfra});
            hsp(i,2) = subplot(rows,5,(i-1)*5+2);
            imagesc(topview.conditions.(condnames{2}).([suporinfra '_segments_interpol']),topview.conditions.(condnames{2}).([suporinfra '_bregmas_interpol']),topview.conditions.(condnames{2}).([suporinfra '_mean_interpol']));
%             hold on;
%             plot(topview.conditions.(condnames{2}).(['arearel' suporinfra '_mean_interpol']),topview.conditions.(condnames{1}).bregmasinterpol,'k-');
%             hold off;
            title({['B: ' condnames{2}]; suporinfra});
            hsp(i,3) = subplot(rows,5,(i-1)*5+3);
            im = nandarken(topview.interconditions.(interconditions{i}).(['topviewABdiff_relative_' suporinfra]),topview.interconditions.(interconditions{i}).(['nanmap_' suporinfra]));
            imagesc(topview.interconditions.(interconditions{i}).([suporinfra '_segments_interpol']),topview.interconditions.(interconditions{i}).([suporinfra '_bregmas_interpol']),im);
            hold on;
            plot(topview.conditions.(condnames{1}).(['arearel' suporinfra '_mean_interpol']),topview.conditions.(condnames{1}).bregmasinterpol,'k-');
            hold off;
            title('B-A')
            hold on;
            contour(topview.interconditions.(interconditions{i}).([suporinfra '_segments_interpol']),topview.interconditions.(interconditions{i}).([suporinfra '_bregmas_interpol']),topview.interconditions.(interconditions{i}).(['cutoff_activation_' suporinfra]),'k-');
            contour(topview.interconditions.(interconditions{i}).([suporinfra '_segments_interpol']),topview.interconditions.(interconditions{i}).([suporinfra '_bregmas_interpol']),topview.interconditions.(interconditions{i}).(['cutoff_deactivation_' suporinfra]),'w-');
            hold off;
            hsp(i,4) = subplot(rows,5,(i-1)*5+4);
            imagesc(topview.interconditions.(interconditions{i}).([suporinfra '_segments_interpol']),topview.interconditions.(interconditions{i}).([suporinfra '_bregmas_interpol']),topview.interconditions.(interconditions{i}).(['tstat_' suporinfra]));
            hold on;
            contour(topview.interconditions.(interconditions{i}).([suporinfra '_segments_interpol']),topview.interconditions.(interconditions{i}).([suporinfra '_bregmas_interpol']),topview.interconditions.(interconditions{i}).(['cutoff_activation_' suporinfra]),'k-');
            contour(topview.interconditions.(interconditions{i}).([suporinfra '_segments_interpol']),topview.interconditions.(interconditions{i}).([suporinfra '_bregmas_interpol']),topview.interconditions.(interconditions{i}).(['cutoff_deactivation_' suporinfra]),'w-');
            hold off;
            title('Pseudo T-test');
            hsp(i,5) = subplot(rows,5,(i-1)*5+5);
            hist(topview.interconditions.(interconditions{i}).(['Tmax_' suporinfra]));
            title('Tmax distribution');
        end
        ylim = cell2mat(get(hsp(:,1:4),'Ylim'));
        set(hsp(:,1:4),'Ylim',[min(ylim(:,1)) max(ylim(:,2))]);
        clim = cell2mat(get(hsp(:,1:2),'Clim'));
        set(hsp(:,1:2),'Clim',[min(clim(:,1)) max(clim(:,2))]);
        set(hsp(:,3),'Clim',[-1 1]);
    end