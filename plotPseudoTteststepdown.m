function plotPseudoTteststepdown(topview,tail)
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
        opengl('hardware');
        
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
            hsp(i,1) = subplot_tight(rows,columns,(i-1)*columns+1,marg1);
            im = topview.conditions.(condnames{1}).(['topview_' suporinfra{j} '_mean_interpol_smooth']);
%             im = mat2im(im,jet(1000));
%             im = nan2white(im);
            pcolor_rgb(x,y,im);
%             imagesc(x,y,im);
            hold on;
            plot_contours(interconditions{i},suporinfra{j},tail);
            plot(topview.generalmodel.(topview.conditions.(condnames{1}).hemisphere).(['areas_' suporinfra{j}])/100,topview.generalmodel.(topview.conditions.(condnames{1}).hemisphere).bregmas(:,1)/100,'k-');
            hold off;
            title(['A: ' condnames{1}]);
                        
            hsp(i,2) = subplot_tight(rows,columns,(i-1)*columns+2,marg1);
            im = topview.conditions.(condnames{2}).(['topview_' suporinfra{j} '_mean_interpol_smooth']);
            pcolor_rgb(x,y,im);
%             imagesc(topview.generalmodel.(topview.conditions.(condnames{2}).hemisphere).(['xi_' suporinfra{j}])(1,:)/100,topview.generalmodel.(topview.conditions.(condnames{2}).hemisphere).(['yi_' suporinfra{j}])(:,1)/100,im);
            hold on;
            plot_contours(interconditions{i},suporinfra{j},tail);
            plot(topview.generalmodel.(topview.conditions.(condnames{2}).hemisphere).(['areas_' suporinfra{j}])/100,topview.generalmodel.(topview.conditions.(condnames{2}).hemisphere).bregmas(:,1)/100,'k-');
            hold off;
            title(['B: ' condnames{2}]);
                        
            hsp(i,3) = subplot_tight(rows,columns,(i-1)*columns+3,marg1);
            im = topview.interconditions.(interconditions{i}).(['topviewABdiff_relative_' suporinfra{j}]); %,isnan(topview.interconditions.(interconditions{i}).(['tstat_' suporinfra{j}])));
            pcolor_rgb(x,y,im);
%             imagesc(topview.interconditions.(interconditions{i}).([suporinfra{j} '_segments_interpol'])(1,:)/100,topview.interconditions.(interconditions{i}).([suporinfra{j} '_bregmas_interpol'])(:,1)/100,im);
            hold on;
            plot(topview.generalmodel.(topview.conditions.(condnames{1}).hemisphere).(['areas_' suporinfra{j}])/100,topview.generalmodel.(topview.conditions.(condnames{1}).hemisphere).bregmas(:,1)/100,'k-');
            plot_contours(interconditions{i},suporinfra{j},tail);
%             plot_contours(topview,interconditions{i},suporinfra{j},tail,'power');
            plot(topview.generalmodel.(topview.conditions.(condnames{1}).hemisphere).(['areas_' suporinfra{j}])/100,topview.generalmodel.(topview.conditions.(condnames{1}).hemisphere).bregmas(:,1)/100,'k-');
            hold off;
            title('A-B')
                        
            hsp(i,4) = subplot_tight(rows,columns,(i-1)*columns+4,marg1);
            switch tail
                case '1-tailed Activation'
                    im = topview.interconditions.(interconditions{i}).(['Psdmax' suporinfra{j}]);
                case '1-tailed Deactivation'
                    im = topview.interconditions.(interconditions{i}).(['Psdmin' suporinfra{j}]);
                case '2-tailed'
                    
            end
            pcolor_rgb(x,y,im);
            hold on;
            plot_contours(interconditions{i},suporinfra{j},tail);
            plot(topview.generalmodel.(topview.conditions.(condnames{1}).hemisphere).(['areas_' suporinfra{j}])/100,topview.generalmodel.(topview.conditions.(condnames{1}).hemisphere).bregmas(:,1)/100,'k-');
            hold off;
            title('Pseudo T-test');
            
            ticks = fliplr(0.05:-0.005:1/topview.interconditions.(interconditions{i}).N);
            ticksstr = arrayfun(@num2str,ticks,'unif',0);
            
            for k=1:3
                axes(hsp(i,k));
                colormap(hsp(i,k),jet);
                colorbar;
            end
                        
        end
        
        
        ylim = cell2mat(get(hsp(:,1:4),'Ylim'));
        set(hsp(:,1:4),'Ylim',[min(ylim(:,1)) max(ylim(:,2))]);
%         clim = cell2mat(get(hsp(:,1:2),'Clim'));
%         set(hsp(:,1:2),'Clim',[min(clim(:,1)) max(clim(:,2))]);
        set(hsp(:,1:2),'Clim',[0 100]);
        set(hsp(:,3),'Clim',[-1 1]);
        set(hsp(:,1:4),'DataAspectRatio',[1 1 1]);
        set(hsp, 'Uicontextmenu',cmenu);
%         colormap(gcf,'jet');
        set(findobj('Type','axes'),'FontSize',7)
        set(hsp,'TitleFontSizeMultiplier',1);
        for i=1:rows
            axes(hsp(i,4));
            colormap([flipud(autumn(128)); 0 0 0]);
            caxis(hsp(i,4),[1/topview.interconditions.(interconditions{i}).N 0.050001]);
            ch = colorbar;
            tickl = get(ch,'TickLabels');
            tickl{end} = ['>' tickl{end}];
            set(ch,'TickLabels',tickl);
        end
    end
    function plot_contours(intercondition,suporinfra,tail)
        %debug
        topview.interconditions.(intercondition).hemisphere = 'left';
        linestyle = {'-',':','--'};
        alpha = [0.05 0.01 0.001];
        alpha = alpha(alpha >= 1/topview.interconditions.(intercondition).N);
        for ii = 1:length(alpha)
            switch tail
                case '1-tailed Activation'
                    contours = topview.interconditions.(intercondition).(['Psdmax' suporinfra]) <= alpha(ii);
                    if(sum(contours(:))>0)
                        contour(topview.generalmodel.(topview.interconditions.(intercondition).hemisphere).(['xi_' suporinfra])/100,topview.generalmodel.(topview.interconditions.(intercondition).hemisphere).(['yi_' suporinfra])/100,contours,'k','LineStyle',linestyle{ii});
                    end
                case '1-tailed Deactivation'
                    contours = topview.interconditions.(intercondition).(['Psdmin' suporinfra]) <= alpha(ii);
                    if(sum(contours(:))>0)
                        contour(topview.generalmodel.(topview.interconditions.(intercondition).hemisphere).(['xi_' suporinfra])/100,topview.generalmodel.(topview.interconditions.(intercondition).hemisphere).(['yi_' suporinfra])/100,contours,'w','LineStyle',linestyle{ii});
                    end
                case '2-tailed'
                    contours = topview.interconditions.(intercondition).(['Psdmax' suporinfra]) <= alpha(ii)/2;
                    if(sum(contours(:))>0)
                        contour(topview.generalmodel.(topview.interconditions.(intercondition).hemisphere).(['xi_' suporinfra])/100,topview.generalmodel.(topview.interconditions.(intercondition).hemisphere).(['yi_' suporinfra])/100,contours,'k','LineStyle',linestyle{ii});
                    end
                    contours = topview.interconditions.(intercondition).(['Psdmin' suporinfra]) <= alpha(ii)/2;
                    if(sum(contours(:))>0)
                        contour(topview.generalmodel.(topview.interconditions.(intercondition).hemisphere).(['xi_' suporinfra])/100,topview.generalmodel.(topview.interconditions.(intercondition).hemisphere).(['yi_' suporinfra])/100,contours,'w','LineStyle',linestyle{ii});
                    end
            end
        end
    end
end
        