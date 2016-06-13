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
    if 1
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
            marg1 = [0.03 0.03];
            marg2 = [0.01 0.05];
            
            cmenu = uicontextmenu;
            uimenu(cmenu, 'Label', 'Enlarge', 'Callback', @enlargesubplot);
            hMenu = uimenu(fig,'Label','Save');
            uimenu(hMenu,'Label','Save as PDF...','Callback',@saveFigAsPDF);
            if(strcmp(tail,'2-tailed'))
                columns = 5;
            else
                columns = 4;
            end
            hsp = zeros(rows,columns);
            for i=1:rows
                condnames = topview.interconditions.(interconditions{i}).conditions;
                x = topview.generalmodel.(topview.conditions.(condnames{1}).hemisphere).(['xi_' suporinfra{j}])./100; %(1,:)
                y = topview.generalmodel.(topview.conditions.(condnames{1}).hemisphere).(['yi_' suporinfra{j}])./100; %(:,1)
                hsp(i,1) = subplot_tight(rows,columns,(i-1)*columns+1,marg1);
                im = topview.conditions.(condnames{1}).(['topview_' suporinfra{j} '_mean_interpol_smooth']);
                %             im = mat2im(im,jet(1000));
                %             im = nan2white(im);
                pcolor_rgb(x,-y,im);
                %             imagesc(x,y,im);
                hold on;
                plot_contours(interconditions{i},suporinfra{j},tail);
                plot(topview.generalmodel.(topview.conditions.(condnames{1}).hemisphere).(['areas_' suporinfra{j}])/100,-topview.generalmodel.(topview.conditions.(condnames{1}).hemisphere).bregmas(:,1)/100,'k-');
                hold off;
                title(['A: ' condnames{1}]);
                axis xy equal tight;
                
                hsp(i,2) = subplot_tight(rows,columns,(i-1)*columns+2,marg1);
                im = topview.conditions.(condnames{2}).(['topview_' suporinfra{j} '_mean_interpol_smooth']);
                pcolor_rgb(x,-y,im);
                %             imagesc(topview.generalmodel.(topview.conditions.(condnames{2}).hemisphere).(['xi_' suporinfra{j}])(1,:)/100,topview.generalmodel.(topview.conditions.(condnames{2}).hemisphere).(['yi_' suporinfra{j}])(:,1)/100,im);
                hold on;
                plot_contours(interconditions{i},suporinfra{j},tail);
                plot(topview.generalmodel.(topview.conditions.(condnames{2}).hemisphere).(['areas_' suporinfra{j}])/100,-topview.generalmodel.(topview.conditions.(condnames{2}).hemisphere).bregmas(:,1)/100,'k-');
                hold off;
                title(['B: ' condnames{2}]);
                axis xy equal tight;
                
                hsp(i,3) = subplot_tight(rows,columns,(i-1)*columns+3,marg1);
                im = topview.interconditions.(interconditions{i}).(['topviewABdiff_relative_' suporinfra{j}]); %,isnan(topview.interconditions.(interconditions{i}).(['tstat_' suporinfra{j}])));
                pcolor_rgb(x,-y,im);
                %             imagesc(topview.interconditions.(interconditions{i}).([suporinfra{j} '_segments_interpol'])(1,:)/100,topview.interconditions.(interconditions{i}).([suporinfra{j} '_bregmas_interpol'])(:,1)/100,im);
                hold on;
                plot(topview.generalmodel.(topview.conditions.(condnames{1}).hemisphere).(['areas_' suporinfra{j}])/100,-topview.generalmodel.(topview.conditions.(condnames{1}).hemisphere).bregmas(:,1)/100,'k-');
                plot_contours(interconditions{i},suporinfra{j},tail);
                %             plot_contours(topview,interconditions{i},suporinfra{j},tail,'power');
                hold off;
                title('A-B')
                axis xy equal tight;
                
                
                if(strcmp(tail,'2-tailed'))
                    imact = topview.interconditions.(interconditions{i}).(['Psdmax' suporinfra{j}]);
                    imdeact = topview.interconditions.(interconditions{i}).(['Psdmin' suporinfra{j}]);
                    
                    hsp(i,4) = subplot_tight(rows,columns,(i-1)*columns+4,marg1);
                    pcolor_rgb(x,-y,imact);
                    hold on;
                    plot_contours(interconditions{i},suporinfra{j},'2-tailed Activation');
                    plot(topview.generalmodel.(topview.conditions.(condnames{1}).hemisphere).(['areas_' suporinfra{j}])/100,-topview.generalmodel.(topview.conditions.(condnames{1}).hemisphere).bregmas(:,1)/100,'k-');
                    hold off;
                    title('Pseudo T-test Act');
                    set(gca,'Tag','pval_cmap');
                    axis xy equal tight;
                    
                    hsp(i,5) = subplot_tight(rows,columns,(i-1)*columns+5,marg1);
                    pcolor_rgb(x,-y,imdeact);
                    hold on;
                    plot_contours(interconditions{i},suporinfra{j},'2-tailed Deactivation');
                    plot(topview.generalmodel.(topview.conditions.(condnames{1}).hemisphere).(['areas_' suporinfra{j}])/100,-topview.generalmodel.(topview.conditions.(condnames{1}).hemisphere).bregmas(:,1)/100,'k-');
                    hold off;
                    title('Pseudo T-test Deact');
                    set(gca,'Tag','pval_cmap');
                    axis xy equal tight;
                    specialcolormapcols = [4 5];
                else
                    switch tail
                        case '1-tailed Activation'
                            im = topview.interconditions.(interconditions{i}).(['Psdmax' suporinfra{j}]);
                        case '1-tailed Deactivation'
                            im = topview.interconditions.(interconditions{i}).(['Psdmin' suporinfra{j}]);
                    end
                    hsp(i,4) = subplot_tight(rows,columns,(i-1)*columns+4,marg1);
                    pcolor_rgb(x,-y,im);
                    hold on;
                    plot_contours(interconditions{i},suporinfra{j},tail);
                    plot(topview.generalmodel.(topview.conditions.(condnames{1}).hemisphere).(['areas_' suporinfra{j}])/100,-topview.generalmodel.(topview.conditions.(condnames{1}).hemisphere).bregmas(:,1)/100,'k-');
                    hold off;
                    title('Pseudo T-test');
                    set(gca,'Tag','pval_cmap');
                    axis xy equal tight;
                    specialcolormapcols = 4;
                    
                end
                
                for k=1:3
                    axes(hsp(i,k));
                    colormap(hsp(i,k),jet);
                    %                 colorbar;
                end
                
            end
            
            
            yl = cell2mat(get(hsp(:,1:4),'Ylim'));
            xl = cell2mat(get(hsp(:,1:4),'Xlim'));
            set(hsp(:,[1:4 specialcolormapcols]),'Ylim',[min(yl(:,1)) max(yl(:,2))]);
            set(hsp(:,[1:4 specialcolormapcols]),'Xlim',[min(xl(:,1))*1.1 max(xl(:,2))*0.9]);
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
                for k=specialcolormapcols
                    axes(hsp(i,k));
                    colormap([flipud(autumn(128)); 0 0 0]);
                    caxis(hsp(i,k),[0.001 0.050001]); %1/topview.interconditions.(interconditions{i}).N
                    %                 ch = colorbar;
                    %                 tickl = get(ch,'TickLabels');
                    %                 tickl{end} = ['>' tickl{end}];
                    %                 set(ch,'TickLabels',tickl);
                end
            end
        end
    elseif 0
        fig = figure();
        opengl('hardware');
        outerpos = [0 0 26 20];
        set(gcf,'WindowStyle','normal');
        set(gcf,'Units','centimeters');
        set(gcf,'OuterPosition',outerpos);
        set(fig,'PaperType','A4');
        set(fig,'PaperOrientation','landscape');
        set(fig,'PaperUnits','centimeters');
        set(fig,'PaperPositionMode','auto');
        marg1 = [0.03 0.03];
        marg2 = [0.01 0.05];
        
        cmenu = uicontextmenu;
        uimenu(cmenu, 'Label', 'Enlarge', 'Callback', @enlargesubplot);
        hMenu = uimenu(fig,'Label','Save');
        uimenu(hMenu,'Label','Save as PDF...','Callback',@saveFigAsPDF);
        if(strcmp(tail,'2-tailed'))
            columns = 5;
        else
            columns = 4;
        end
        hsp = zeros(rows*2,columns);
        for j=1:2%length(suporinfra)
            for i=1:rows
                condnames = topview.interconditions.(interconditions{i}).conditions;
                x = topview.generalmodel.(topview.conditions.(condnames{1}).hemisphere).(['xi_' suporinfra{j}])./100; %(1,:)
                y = topview.generalmodel.(topview.conditions.(condnames{1}).hemisphere).(['yi_' suporinfra{j}])./100; %(:,1)
                hsp((j-1)*rows+i,1) = subplot_tight(rows*2,columns,(j-1)*rows*columns+(i-1)*columns+1,marg1);
                im = topview.conditions.(condnames{1}).(['topview_' suporinfra{j} '_mean_interpol_smooth']);
                %             im = mat2im(im,jet(1000));
                %             im = nan2white(im);
                pcolor_rgb(x,-y,im);
                %             imagesc(x,y,im);
                hold on;
                plot_contours(interconditions{i},suporinfra{j},tail);
                plot(topview.generalmodel.(topview.conditions.(condnames{1}).hemisphere).(['areas_' suporinfra{j}])/100,-topview.generalmodel.(topview.conditions.(condnames{1}).hemisphere).bregmas(:,1)/100,'k-');
                hold off;
                title(['A: ' strrep(condnames{1},'_',' ')]);
                axis xy equal tight;
                
                hsp((j-1)*rows+i,2) = subplot_tight(rows*2,columns,(j-1)*rows*columns+(i-1)*columns+2,marg1);
                im = topview.conditions.(condnames{2}).(['topview_' suporinfra{j} '_mean_interpol_smooth']);
                pcolor_rgb(x,-y,im);
                %             imagesc(topview.generalmodel.(topview.conditions.(condnames{2}).hemisphere).(['xi_' suporinfra{j}])(1,:)/100,topview.generalmodel.(topview.conditions.(condnames{2}).hemisphere).(['yi_' suporinfra{j}])(:,1)/100,im);
                hold on;
                plot_contours(interconditions{i},suporinfra{j},tail);
                plot(topview.generalmodel.(topview.conditions.(condnames{2}).hemisphere).(['areas_' suporinfra{j}])/100,-topview.generalmodel.(topview.conditions.(condnames{2}).hemisphere).bregmas(:,1)/100,'k-');
                hold off;
                title(['B: ' strrep(condnames{2},'_',' ')]);
                axis xy equal tight;
                
                hsp((j-1)*rows+i,3) = subplot_tight(rows*2,columns,(j-1)*rows*columns+(i-1)*columns+3,marg1);
                im = topview.interconditions.(interconditions{i}).(['topviewABdiff_relative_' suporinfra{j}]); %,isnan(topview.interconditions.(interconditions{i}).(['tstat_' suporinfra{j}])));
                pcolor_rgb(x,-y,im);
                %             imagesc(topview.interconditions.(interconditions{i}).([suporinfra{j} '_segments_interpol'])(1,:)/100,topview.interconditions.(interconditions{i}).([suporinfra{j} '_bregmas_interpol'])(:,1)/100,im);
                hold on;
                plot(topview.generalmodel.(topview.conditions.(condnames{1}).hemisphere).(['areas_' suporinfra{j}])/100,-topview.generalmodel.(topview.conditions.(condnames{1}).hemisphere).bregmas(:,1)/100,'k-');
                plot_contours(interconditions{i},suporinfra{j},tail);
                %             plot_contours(topview,interconditions{i},suporinfra{j},tail,'power');
                hold off;
                title('A-B')
                axis xy equal tight;
                
                
                if(strcmp(tail,'2-tailed'))
                    imact = topview.interconditions.(interconditions{i}).(['Psdmax' suporinfra{j}]);
                    imdeact = topview.interconditions.(interconditions{i}).(['Psdmin' suporinfra{j}]);
                    
                    hsp((j-1)*rows+i,4) = subplot_tight(rows*2,columns,(j-1)*rows*columns+(i-1)*columns+4,marg1);
                    pcolor_rgb(x,-y,imact);
                    hold on;
                    plot_contours(interconditions{i},suporinfra{j},'2-tailed Activation');
                    plot(topview.generalmodel.(topview.conditions.(condnames{1}).hemisphere).(['areas_' suporinfra{j}])/100,-topview.generalmodel.(topview.conditions.(condnames{1}).hemisphere).bregmas(:,1)/100,'k-');
                    hold off;
                    title('Pseudo t-test Act');
                    set(gca,'Tag','pval_cmap');
                    axis xy equal tight;
                    
                    hsp((j-1)*rows+i,5) = subplot_tight(rows*2,columns,(j-1)*rows*columns+(i-1)*columns+5,marg1);
                    pcolor_rgb(x,-y,imdeact);
                    hold on;
                    plot_contours(interconditions{i},suporinfra{j},'2-tailed Deactivation');
                    plot(topview.generalmodel.(topview.conditions.(condnames{1}).hemisphere).(['areas_' suporinfra{j}])/100,-topview.generalmodel.(topview.conditions.(condnames{1}).hemisphere).bregmas(:,1)/100,'k-');
                    hold off;
                    title('Pseudo t-test Deact');
                    set(gca,'Tag','pval_cmap');
                    axis xy equal tight;
                    specialcolormapcols = [4 5];
                else
                    switch tail
                        case '1-tailed Activation'
                            im = topview.interconditions.(interconditions{i}).(['Psdmax' suporinfra{j}]);
                        case '1-tailed Deactivation'
                            im = topview.interconditions.(interconditions{i}).(['Psdmin' suporinfra{j}]);
                    end
                    hsp((j-1)*rows+i,4) = subplot_tight(rows*2,columns,(j-1)*rows*columns+(i-1)*columns+4,marg1);
                    pcolor_rgb(x,-y,im);
                    hold on;
                    plot_contours(interconditions{i},suporinfra{j},tail);
                    plot(topview.generalmodel.(topview.conditions.(condnames{1}).hemisphere).(['areas_' suporinfra{j}])/100,-topview.generalmodel.(topview.conditions.(condnames{1}).hemisphere).bregmas(:,1)/100,'k-');
                    hold off;
                    title('Pseudo t-test');
                    set(gca,'Tag','pval_cmap');
                    axis xy equal tight;
                    specialcolormapcols = 4;
                    
                end
                
                for k=1:3
                    axes(hsp((j-1)*rows+i,k));
                    colormap(hsp((j-1)*rows+i,k),jet);
                    %                 colorbar;
                end
                
            end
        end
            
            
        yl = cell2mat(get(hsp(:,1:4),'Ylim'));
        xl = cell2mat(get(hsp(:,1:4),'Xlim'));
        set(hsp(:,[1:4 specialcolormapcols]),'Ylim',[min(yl(:,1)) max(yl(:,2))]);
        set(hsp(:,[1:4 specialcolormapcols]),'Xlim',[min(xl(:,1))*1.1 max(xl(:,2))*0.9]);
        %         clim = cell2mat(get(hsp(:,1:2),'Clim'));
        %         set(hsp(:,1:2),'Clim',[min(clim(:,1)) max(clim(:,2))]);
        set(hsp(:,1:2),'Clim',[0 100]);
        set(hsp(:,3),'Clim',[-1 1]);
        set(hsp(:,1:4),'DataAspectRatio',[1 1 1]);
        set(hsp, 'Uicontextmenu',cmenu);
        %         colormap(gcf,'jet');
        set(findobj('Type','axes'),'FontSize',7)
        set(hsp,'TitleFontSizeMultiplier',1);
        for i=1:rows*2
            for k=specialcolormapcols
                axes(hsp(i,k));
                colormap([flipud(autumn(128)); 0 0 0]);
                caxis(hsp(i,k),[0.001 0.050001]); %1/topview.interconditions.(interconditions{i}).N
                %                 ch = colorbar;
                %                 tickl = get(ch,'TickLabels');
                %                 tickl{end} = ['>' tickl{end}];
                %                 set(ch,'TickLabels',tickl);
            end
        end
        
    elseif 0
        fig = figure();
        opengl('hardware');
        outerpos = [0 0 26 20];
        set(gcf,'WindowStyle','normal');
        set(gcf,'Units','centimeters');
        set(gcf,'OuterPosition',outerpos);
        set(fig,'PaperType','A4');
        set(fig,'PaperOrientation','landscape');
        set(fig,'PaperUnits','centimeters');
        set(fig,'PaperPositionMode','auto');
        marg1 = [0.03 0.03];
        marg2 = [0.01 0.05];
        
        cmenu = uicontextmenu;
        uimenu(cmenu, 'Label', 'Enlarge', 'Callback', @enlargesubplot);
        hMenu = uimenu(fig,'Label','Save');
        uimenu(hMenu,'Label','Save as PDF...','Callback',@saveFigAsPDF);
        
        hsp = zeros(2,rows);
        a = 1;
        for j=1:2%length(suporinfra)
            for i=1:rows
                condnames = topview.interconditions.(interconditions{i}).conditions;
                x = topview.generalmodel.(topview.conditions.(condnames{1}).hemisphere).(['xi_' suporinfra{j}])./100; %(1,:)
                y = topview.generalmodel.(topview.conditions.(condnames{1}).hemisphere).(['yi_' suporinfra{j}])./100; %(:,1)
                hsp(j,i) = subplot_tight(2,rows,a,marg1);
                im = topview.conditions.(condnames{1}).(['topview_' suporinfra{j} '_mean_interpol_smooth']);
                %             im = mat2im(im,jet(1000));
                %             im = nan2white(im);
                pcolor_rgb(x,-y,im);
                %             imagesc(x,y,im);
                hold on;
                plot_contours(interconditions{i},suporinfra{j},tail);
                plot(topview.generalmodel.(topview.conditions.(condnames{1}).hemisphere).(['areas_' suporinfra{j}])/100,-topview.generalmodel.(topview.conditions.(condnames{1}).hemisphere).bregmas(:,1)/100,'k-');
                hold off;
                title(strrep(strrep(strrep(condnames{1},'_',' '),'W','w'),'D','d'));
                axis xy equal tight;
                colormap jet;
                a = a + 1;
            end
        end
            
            
        yl = cell2mat(get(hsp,'Ylim'));
        xl = cell2mat(get(hsp,'Xlim'));
        set(hsp,'Ylim',[min(yl(:,1)) max(yl(:,2))]);
        set(hsp,'Xlim',[min(xl(:,1))*1.1 max(xl(:,2))*0.9]);
        %         clim = cell2mat(get(hsp(:,1:2),'Clim'));
        %         set(hsp(:,1:2),'Clim',[min(clim(:,1)) max(clim(:,2))]);
        set(hsp,'Clim',[0 100]);
        set(hsp,'DataAspectRatio',[1 1 1]);
        set(hsp, 'Uicontextmenu',cmenu);
        %         colormap(gcf,'jet');
        set(findobj('Type','axes'),'FontSize',7)
        set(hsp,'TitleFontSizeMultiplier',1);
                
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
                        contour(topview.generalmodel.(topview.interconditions.(intercondition).hemisphere).(['xi_' suporinfra])/100,-topview.generalmodel.(topview.interconditions.(intercondition).hemisphere).(['yi_' suporinfra])/100,contours,'k','LineStyle',linestyle{ii});
                    end
                case '1-tailed Deactivation'
                    contours = topview.interconditions.(intercondition).(['Psdmin' suporinfra]) <= alpha(ii);
                    if(sum(contours(:))>0)
                        contour(topview.generalmodel.(topview.interconditions.(intercondition).hemisphere).(['xi_' suporinfra])/100,-topview.generalmodel.(topview.interconditions.(intercondition).hemisphere).(['yi_' suporinfra])/100,contours,'w','LineStyle',linestyle{ii});
                    end
                case '2-tailed'
                    contours = topview.interconditions.(intercondition).(['Psdmax' suporinfra]) <= alpha(ii)/2;
                    if(sum(contours(:))>0)
                        contour(topview.generalmodel.(topview.interconditions.(intercondition).hemisphere).(['xi_' suporinfra])/100,-topview.generalmodel.(topview.interconditions.(intercondition).hemisphere).(['yi_' suporinfra])/100,contours,'k','LineStyle',linestyle{ii});
                    end
                    contours = topview.interconditions.(intercondition).(['Psdmin' suporinfra]) <= alpha(ii)/2;
                    if(sum(contours(:))>0)
                        contour(topview.generalmodel.(topview.interconditions.(intercondition).hemisphere).(['xi_' suporinfra])/100,-topview.generalmodel.(topview.interconditions.(intercondition).hemisphere).(['yi_' suporinfra])/100,contours,'w','LineStyle',linestyle{ii});
                    end
                case '2-tailed Activation'
                    contours = topview.interconditions.(intercondition).(['Psdmax' suporinfra]) <= alpha(ii)/2;
                    if(sum(contours(:))>0)
                        contour(topview.generalmodel.(topview.interconditions.(intercondition).hemisphere).(['xi_' suporinfra])/100,-topview.generalmodel.(topview.interconditions.(intercondition).hemisphere).(['yi_' suporinfra])/100,contours,'k','LineStyle',linestyle{ii});
                    end
                case '2-tailed Deactivation'
                    contours = topview.interconditions.(intercondition).(['Psdmin' suporinfra]) <= alpha(ii)/2;
                    if(sum(contours(:))>0)
                        contour(topview.generalmodel.(topview.interconditions.(intercondition).hemisphere).(['xi_' suporinfra])/100,-topview.generalmodel.(topview.interconditions.(intercondition).hemisphere).(['yi_' suporinfra])/100,contours,'w','LineStyle',linestyle{ii});
                    end
            end
        end
    end
end
        