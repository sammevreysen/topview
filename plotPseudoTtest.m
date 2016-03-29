function plotPseudoTtest(topview,tail)
    interconditions = fieldnames(topview.interconditions);
    try
        selected = cell2mat(struct2cell(structfun(@(x) x.selected,topview.interconditions,'UniformOutput',false)));
    catch
        intercondnames = fieldnames(topview.interconditions);
        for i=1:size(intercondnames,1)
           if(~isfield(topview.interconditions.(intercondnames{i}),'selected'))
               topview.interconditions.(intercondnames{i}).selected = false;
           end
        end
        selected = cell2mat(struct2cell(structfun(@(x) x.selected,topview.interconditions,'UniformOutput',false)));
    end
    interconditions = interconditions(selected);
    rows = sum(selected);
    suporinfra = topview.suporinfra;
    for j=1:length(suporinfra)
        fig = figure('Name',suporinfra{j});
        colormap jet;
        opengl('software');
        
        outerpos = [0 0 26 20];
        set(gcf,'WindowStyle','normal');
        set(gcf,'Units','centimeters');
        set(gcf,'OuterPosition',outerpos);
        set(fig,'PaperType','A4');
        set(fig,'PaperOrientation','landscape');
        set(fig,'PaperUnits','centimeters');
        set(fig,'PaperPositionMode','auto');
        marg1 = [0.01 0.01];
        marg2 = [0.01 0.05];
        
        cmenu = uicontextmenu;
        uimenu(cmenu, 'Label', 'Enlarge', 'Callback', @enlargesubplot);
        hMenu = uimenu(fig,'Label','Save');
        uimenu(hMenu,'Label','Save as PDF...','Callback',@saveFigAsPDF);
        columns = 4;
        hsp = zeros(rows,columns);
        for i=1:rows
            condnames = topview.interconditions.(interconditions{i}).conditions;
            x = topview.generalmodel.(topview.conditions.(condnames{1}).hemisphere).(['xi_' suporinfra{j}])./100; %(1,:)
            y = topview.generalmodel.(topview.conditions.(condnames{1}).hemisphere).(['yi_' suporinfra{j}])./100; %(:,1)
            hsp(i,1) = subplot_tight(rows,6,(i-1)*6+1,marg1);
            im = topview.conditions.(condnames{1}).(['topview_' suporinfra{j} '_mean_interpol_smooth']);
%             im = mat2im(im,jet(1000));
%             im = nan2white(im);
            pcolor_rgb(x,y,im);
%             imagesc(x,y,im);
            hold on;
            plot(topview.generalmodel.(topview.conditions.(condnames{1}).hemisphere).(['areas_' suporinfra{j}])/100,topview.generalmodel.(topview.conditions.(condnames{1}).hemisphere).bregmas(:,1)/100,'k-');
            hold off;
            title(['A: ' condnames{1}]);
            colorbar('location','EastOutside')
            
            hsp(i,2) = subplot_tight(rows,6,(i-1)*6+2,marg1);
            im = topview.conditions.(condnames{2}).(['topview_' suporinfra{j} '_mean_interpol_smooth']);
            pcolor_rgb(x,y,im);
%             imagesc(topview.generalmodel.(topview.conditions.(condnames{2}).hemisphere).(['xi_' suporinfra{j}])(1,:)/100,topview.generalmodel.(topview.conditions.(condnames{2}).hemisphere).(['yi_' suporinfra{j}])(:,1)/100,im);
            hold on;
            plot(topview.generalmodel.(topview.conditions.(condnames{2}).hemisphere).(['areas_' suporinfra{j}])/100,topview.generalmodel.(topview.conditions.(condnames{2}).hemisphere).bregmas(:,1)/100,'k-');
            hold off;
            title(['B: ' condnames{2}]);
            colorbar('location','EastOutside')
            
            hsp(i,3) = subplot_tight(rows,6,(i-1)*6+3,marg1);
            im = nandarken(topview.interconditions.(interconditions{i}).(['topviewABdiff_relative_' suporinfra{j}]),topview.interconditions.(interconditions{i}).(['nanmap_' suporinfra{j}]));
            pcolor_rgb(x,y,im);
%             imagesc(topview.interconditions.(interconditions{i}).([suporinfra{j} '_segments_interpol'])(1,:)/100,topview.interconditions.(interconditions{i}).([suporinfra{j} '_bregmas_interpol'])(:,1)/100,im);
            hold on;
            plot(topview.generalmodel.(topview.conditions.(condnames{1}).hemisphere).(['areas_' suporinfra{j}])/100,topview.generalmodel.(topview.conditions.(condnames{1}).hemisphere).bregmas(:,1)/100,'k-');
            plot_contours(topview,interconditions{i},suporinfra{j},tail,'stats');
%             plot_contours(topview,interconditions{i},suporinfra{j},tail,'power');
            plot(topview.generalmodel.(topview.conditions.(condnames{1}).hemisphere).(['areas_' suporinfra{j}])/100,topview.generalmodel.(topview.conditions.(condnames{1}).hemisphere).bregmas(:,1)/100,'k-');
            hold off;
            title('A-B')
            colorbar('location','EastOutside')
            
            hsp(i,4) = subplot_tight(rows,6,(i-1)*6+4,marg1);
            im = topview.interconditions.(interconditions{i}).(['tstat_' suporinfra{j}]);
            pcolor_rgb(topview.interconditions.(interconditions{i}).([suporinfra{j} '_segments_interpol'])./100,topview.interconditions.(interconditions{i}).([suporinfra{j} '_bregmas_interpol'])./100,im);
            set(gca,'Clim',[min(topview.interconditions.(interconditions{i}).(['tstat_' suporinfra{j}])(:)) max(topview.interconditions.(interconditions{i}).(['tstat_' suporinfra{j}])(:))]);
            hold on;
            plot_contours(topview,interconditions{i},suporinfra{j},tail,'stats');
            plot(topview.generalmodel.(topview.conditions.(condnames{1}).hemisphere).(['areas_' suporinfra{j}])/100,topview.generalmodel.(topview.conditions.(condnames{1}).hemisphere).bregmas(:,1)/100,'k-');
            hold off;
            title('Pseudo T-test');
            colorbar('location','EastOutside')
            
            hsp(i,5) = subplot_tight(rows,6,(i-1)*6+5,marg2);
            switch tail
                case '1-tailed Activation'
                    [val x] = hist(topview.interconditions.(interconditions{i}).(['Tmax_activation_' suporinfra{j}]));
                    bar(x,val,'hist');
                    ylims = get(gca,'Ylim');
                    hold on;
                    plot(repmat(topview.interconditions.(interconditions{i}).(['criticalvalue_activation_1tailed_' suporinfra{j}]),1,2),ylims,'r-');
                    hold off;
                    xlim([min(x)-mean(diff(x))/2 max(x)+mean(diff(x))/2]);
                case '1-tailed Deactivation'
                    [val x] = hist(topview.interconditions.(interconditions{i}).(['Tmax_deactivation_' suporinfra{j}]));
                    bar(x,val);
                    ylims = get(gca,'Ylim');
                    hold on;
                    plot(repmat(topview.interconditions.(interconditions{i}).(['criticalvalue_deactivation_1tailed_' suporinfra{j}]),1,2),ylims,'r-');
                    hold off;
                    xlim([min(x)-mean(diff(x))/2 max(x)+mean(diff(x))/2]);
                case '2-tailed'
                    [val1 x1] = hist(topview.interconditions.(interconditions{i}).(['Tmax_deactivation_' suporinfra{j}]));
                    tmp = topview.interconditions.(interconditions{i}).(['Tmax_deactivation_' suporinfra{j}])(:);
                    x1 = min(tmp):-min(tmp)/10:0;
                    x1b = min(tmp)-min(tmp)/20:-min(tmp)/10:0;
                    val1 = histcounts(tmp,[x1(1:end-1) inf]);
                    tmp = topview.interconditions.(interconditions{i}).(['Tmax_activation_' suporinfra{j}]);
                    x2 = 0:max(tmp)/10:max(tmp);
                    x2b = max(tmp)/20:max(tmp)/10:max(tmp);
                    val2 = histcounts(tmp,[-inf x2(2:end)]);
                    bar([x1b x2b],[val1 val2]);
                    ylims = get(gca,'Ylim');
                    hold on;
                    plot(repmat(topview.interconditions.(interconditions{i}).(['criticalvalue_activation_2tailed_' suporinfra{j}]),1,2),ylims,'r-');
                    plot(repmat(topview.interconditions.(interconditions{i}).(['criticalvalue_deactivation_2tailed_' suporinfra{j}]),1,2),ylims,'r-');
                    hold off;
                    xlim([min(x1)-mean(diff(x1))/2 max(x2)+mean(diff(x2))/2]);
                    
            end
%             xlim = get(hsp(i,5),'Xlim');
%             if(all(topview.interconditions.(interconditions{i}).(['Tmax_' suporinfra{j}]) >= 0))
%                 set(hsp(i,5),'Xlim',[0 xlim(2)]);
%             else
%                 set(hsp(i,5),'Xlim',[xlim(1) 0]);
%             end
            title('Tmax distribution');
            
%             hsp(i,6) = subplot_tight(rows,6,(i-1)*6+6,marg1);
%             switch tail
%                 case '1-tailed Activation'
%                     im = topview.interconditions.(interconditions{i}).(['power_activation_1tailed_' suporinfra{j}]);
%                 case '1-tailed Deactivation'
%                     im = topview.interconditions.(interconditions{i}).(['power_deactivation_1tailed_' suporinfra{j}]);
%                 case '2-tailed'
%                     im = topview.interconditions.(interconditions{i}).(['power_deactivation_1tailed_' suporinfra{j}]);
%             end
%             pcolor_rgb(topview.interconditions.(interconditions{i}).([suporinfra{j} '_segments_interpol'])./100,topview.interconditions.(interconditions{i}).([suporinfra{j} '_bregmas_interpol'])./100,im);
%             hold on;
%             plot_contours(topview,interconditions{i},suporinfra{j},tail,'power');
%             plot(topview.generalmodel.(topview.conditions.(condnames{1}).hemisphere).(['areas_' suporinfra{j}])/100,topview.generalmodel.(topview.conditions.(condnames{1}).hemisphere).bregmas(:,1)/100,'k-');
%             hold off;
% %             set(gca,'Clim',[nanmin(topview.interconditions.(interconditions{i}).(['power_' tailstr suporinfra{j}])(:)) nanmax(topview.interconditions.(interconditions{i}).(['power_' tailstr suporinfra{j}])(:))]);
%             title('Power pT-test');
%             colorbar('location','EastOutside')
        end
        ylim = cell2mat(get(hsp(:,1:4),'Ylim'));
        set(hsp(:,1:4),'Ylim',[min(ylim(:,1)) max(ylim(:,2))]);
        clim = cell2mat(get(hsp(:,1:2),'Clim'));
        set(hsp(:,1:2),'Clim',[min(clim(:,1)) max(clim(:,2))]);
        set(hsp(:,3),'Clim',[-1 1]);
        set(hsp(:,1:4),'DataAspectRatio',[1 1 1]);
        if(size(hsp,1) > 1)
            pos = cell2mat(get(hsp(:,5),'Position'));
        else
            pos = get(hsp(5),'Position');
        end
        for k=1:size(hsp,1)
            set(hsp(k,5),'Position',[pos(k,1) pos(k,2)+pos(k,4)*0.2 pos(k,3) pos(k,4)*0.6])
        end
        set(hsp, 'Uicontextmenu',cmenu);
%         colormap(gcf,'jet');
        set(findobj('Type','axes'),'FontSize',7)
        set(hsp,'TitleFontSizeMultiplier',1);
%         set(hsp,'YDir','normal');
    end
    
    function plot_contours(topview,intercondition,suporinfra,tail,mode)
        switch tail
            case '1-tailed Activation'
                if(strcmp(mode,'stats'))
                    if(sum(topview.interconditions.(intercondition).(['cutoff_activation_1tailed_' suporinfra])(:)) > 0)
                        contour(topview.interconditions.(intercondition).([suporinfra '_segments_interpol'])/100,topview.interconditions.(intercondition).([suporinfra '_bregmas_interpol'])/100,topview.interconditions.(intercondition).(['cutoff_activation_1tailed_' suporinfra]),'k-');
                    end
                else
                    contour(topview.interconditions.(intercondition).([suporinfra '_segments_interpol'])/100,topview.interconditions.(intercondition).([suporinfra '_bregmas_interpol'])/100,topview.interconditions.(intercondition).(['power_activation_1tailed_' suporinfra]),[80 80],'k-.');
                    contour(topview.interconditions.(intercondition).([suporinfra '_segments_interpol'])/100,topview.interconditions.(intercondition).([suporinfra '_bregmas_interpol'])/100,topview.interconditions.(intercondition).(['power_activation_1tailed_' suporinfra]),[90 90],'k:');
                end
            case '1-tailed Deactivation'
                if(strcmp(mode,'stats'))
                    if(sum(topview.interconditions.(intercondition).(['cutoff_deactivation_1tailed_' suporinfra])(:)) > 0)
                        contour(topview.interconditions.(intercondition).([suporinfra '_segments_interpol'])/100,topview.interconditions.(intercondition).([suporinfra '_bregmas_interpol'])/100,topview.interconditions.(intercondition).(['cutoff_deactivation_1tailed_' suporinfra]),[1 1],'w-');
                    end
                else
                    contour(topview.interconditions.(intercondition).([suporinfra '_segments_interpol'])/100,topview.interconditions.(intercondition).([suporinfra '_bregmas_interpol'])/100,topview.interconditions.(intercondition).(['power_deactivation_1tailed_' suporinfra]),[80 80],'w-.');
                    contour(topview.interconditions.(intercondition).([suporinfra '_segments_interpol'])/100,topview.interconditions.(intercondition).([suporinfra '_bregmas_interpol'])/100,topview.interconditions.(intercondition).(['power_deactivation_1tailed_' suporinfra]),[90 90],'w:');
                end
            case '2-tailed'
                if(strcmp(mode,'stats'))
                    if(sum(topview.interconditions.(intercondition).(['cutoff_activation_2tailed_' suporinfra])(:)) > 0)
                        contour(topview.interconditions.(intercondition).([suporinfra '_segments_interpol'])/100,topview.interconditions.(intercondition).([suporinfra '_bregmas_interpol'])/100,topview.interconditions.(intercondition).(['cutoff_activation_2tailed_' suporinfra]),'k-');
                    end
                else
                    contour(topview.interconditions.(intercondition).([suporinfra '_segments_interpol'])/100,topview.interconditions.(intercondition).([suporinfra '_bregmas_interpol'])/100,topview.interconditions.(intercondition).(['power_activation_2tailed_' suporinfra]),[80 80],'k-.');
                    contour(topview.interconditions.(intercondition).([suporinfra '_segments_interpol'])/100,topview.interconditions.(intercondition).([suporinfra '_bregmas_interpol'])/100,topview.interconditions.(intercondition).(['power_activation_2tailed_' suporinfra]),[90 90],'k:');
                end
                if(strcmp(mode,'stats'))
                    if(sum(topview.interconditions.(intercondition).(['cutoff_deactivation_2tailed_' suporinfra])(:)) > 0)
                        contour(topview.interconditions.(intercondition).([suporinfra '_segments_interpol'])/100,topview.interconditions.(intercondition).([suporinfra '_bregmas_interpol'])/100,topview.interconditions.(intercondition).(['cutoff_deactivation_2tailed_' suporinfra]),'w-');
                    end
                else
                    contour(topview.interconditions.(intercondition).([suporinfra '_segments_interpol'])/100,topview.interconditions.(intercondition).([suporinfra '_bregmas_interpol'])/100,topview.interconditions.(intercondition).(['power_deactivation_2tailed_' suporinfra]),[80 80],'w-.');
                    contour(topview.interconditions.(intercondition).([suporinfra '_segments_interpol'])/100,topview.interconditions.(intercondition).([suporinfra '_bregmas_interpol'])/100,topview.interconditions.(intercondition).(['power_deactivation_2tailed_' suporinfra]),[90 90],'w:');
                end
        end
    
        