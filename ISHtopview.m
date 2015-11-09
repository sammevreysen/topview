function handles = ISHtopview(handles,type)
    %check pivot is on 0
    if(handles.setuptable{1,6}.pivot ~= 0)
        warning('Pivot has to be set on 0 (none)');
    end
    %check if bregma level is registered
    if(size(handles.setuptable,2) < 7 | any(isempty(handles.setuptable(:,7))))
        for i=1:size(handles.setuptable,1)
            bregma = regexp(handles.setuptable{i,3}(end-8:end),'_\d{3}','match','once');
            handles.setuptable{i,7} = str2num(bregma(2:4));
        end
    end
    
    %group per condition per bregma
    topview.conditionnames = unique(handles.setuptable(:,1));
    topview.micenames = unique(handles.setuptable(:,2));
    topview.bregmas = unique(cell2mat(handles.setuptable(:,7)));
    topview.segments = unique(handles.setuptable{1,6}.segments);
    for i=1:size(topview.conditionnames,1)
        topview.conditions.(topview.conditionnames{i}).mice = unique(handles.setuptable(strcmp(handles.setuptable(:,1),topview.conditionnames{i}),2));
%         topview.conditions.(topview.conditionnames{i}).supra = nan(size(topview.bregmas,1),setuptable{1,6}.segments,size(topview.conditions.(topview.conditionnames{i}).mice,1));
%         topview.conditions.(topview.conditionnames{i}).infra = nan(size(topview.bregmas,1),setuptable{1,6}.segments,size(topview.conditions.(topview.conditionnames{i}).mice,1));
%         topview.conditions.(topview.conditionnames{i}).arearelsupra = nan(size(topview.bregmas,1),setuptable{1,5}.arealborders,size(topview.conditions.(topview.conditionnames{i}).mice,1));
%         topview.conditions.(topview.conditionnames{i}).arearelinfra = nan(size(topview.bregmas,1),setuptable{1,5}.arealborders,size(topview.conditions.(topview.conditionnames{i}).mice,1));
%         topview.conditions.(topview.conditionnames{i}).bregmahist(:,1) = unique(cell2mat(setuptable(strcmp(setuptable(:,1),topview.conditionnames{i}),7)));
%         topview.conditions.(topview.conditionnames{i}).bregmahist(:,2) = hist(cell2mat(setuptable(strcmp(setuptable(:,1),topview.conditionnames{i}),7)),topview.conditions.(topview.conditionnames{i}).bregmahist(:,1));
    end
    for i=1:size(topview.micenames,1)
        topview.mice.(topview.micenames{i}).bregmas = unique(cell2mat(handles.setuptable(strcmp(handles.setuptable(:,2),topview.micenames{i}),7)));
        topview.mice.(topview.micenames{i}).supra = nan(size(topview.mice.(topview.micenames{i}).bregmas,1),handles.setuptable{1,6}.segments);
        topview.mice.(topview.micenames{i}).infra = nan(size(topview.mice.(topview.micenames{i}).bregmas,1),handles.setuptable{1,6}.segments);
        topview.mice.(topview.micenames{i}).arearelsupra = nan(size(topview.mice.(topview.micenames{i}).bregmas,1),handles.setuptable{1,5}.arealborders);
        topview.mice.(topview.micenames{i}).arearelinfra = nan(size(topview.mice.(topview.micenames{i}).bregmas,1),handles.setuptable{1,5}.arealborders);
    end
        
    for i=1:size(handles.setuptable,1)
%         mouseno = find(strcmp(topview.conditions.(setuptable{i,1}).mice,setuptable{i,2}));
%         topview.conditions.(setuptable{i,1}).supra(topview.bregmas == cell2mat(setuptable(i,7)),:,mouseno) = setuptable{i,6}.meansupra;
%         topview.conditions.(setuptable{i,1}).infra(topview.bregmas == cell2mat(setuptable(i,7)),:,mouseno) = setuptable{i,6}.meaninfra;
%         topview.conditions.(setuptable{i,1}).arearelsupra(topview.bregmas == cell2mat(setuptable(i,7)),:,mouseno) = setuptable{i,6}.toparealrel;
%         topview.conditions.(setuptable{i,1}).arearelinfra(topview.bregmas == cell2mat(setuptable(i,7)),:,mouseno) = setuptable{i,6}.botarealrel;
        mouse = handles.setuptable{i,2};
        topview.mice.(mouse).supra(topview.mice.(mouse).bregmas == cell2mat(handles.setuptable(i,7)),:) = (1-(handles.setuptable{i,6}.meansupra_raw./handles.setuptable{i,5}.meanbg)).*100;
        topview.mice.(mouse).infra(topview.mice.(mouse).bregmas == cell2mat(handles.setuptable(i,7)),:) = (1-(handles.setuptable{i,6}.meaninfra_raw./handles.setuptable{i,5}.meanbg)).*100;
        topview.mice.(mouse).arearelsupra(topview.mice.(mouse).bregmas == cell2mat(handles.setuptable(i,7)),:) = handles.setuptable{i,6}.toparealrel;
        topview.mice.(mouse).arearelinfra(topview.mice.(mouse).bregmas == cell2mat(handles.setuptable(i,7)),:) = handles.setuptable{i,6}.botarealrel;
        
    end
    
    %Initiate figures for supra and infra and menu's
    figsupra = figure();
    cmenusupra = uicontextmenu;
    uimenu(cmenusupra, 'Label', 'Enlarge', 'Callback', @(src,evt)enlargesubplot(src,evt,handles));
    hMenu = uimenu(figsupra,'Label','Topview functions');
    handles.hSubmenu.setcolorscale_supra = uimenu(hMenu,'Label','Set Color Scale','Callback',@(src,evt)colorscale(src,evt,handles));
    handles.hSubmenu.normalizeto_supra = uimenu(hMenu,'Label','Normalize to none','Callback',@(src,evt)normalizeto(src,evt,handles));
    handles.hSubmenu.createcondition_supra = uimenu(hMenu,'Label','Create topview per condition','Callback',@(src,evt)createconditions(src,evt,handles));
    handles.hSubmenu.savetopview_supra = uimenu(hMenu,'Label','Save current topview state','Callback',@(src,evt)savetopview(src,evt,handles));
    
    figinfra = figure();
    cmenuinfra = uicontextmenu;
    uimenu(cmenuinfra, 'Label', 'Enlarge', 'Callback', @(src,evt)enlargesubplot(src,evt,handles));
    hMenu = uimenu(figinfra,'Label','Topview functions');
    handles.hSubmenu.setcolorscale_infra = uimenu(hMenu,'Label','Set Color Scale','Callback',@(src,evt)colorscale(src,evt,handles));
    handles.hSubmenu.normalizeto_infra = uimenu(hMenu,'Label','Normalize to none','Callback',@(src,evt)normalizeto(src,evt,handles));
    handles.hSubmenu.createcondition_infra = uimenu(hMenu,'Label','Create topview per condition','Callback',@(src,evt)createconditions(src,evt,handles));
    handles.hSubmenu.savetopview_infra = uimenu(hMenu,'Label','Save current topview state','Callback',@(src,evt)savetopview(src,evt,handles));
   
    switch type
%         case 'conditions'
%             figsubsupra = [];
%             figsubinfra = [];
%             minbregmasupra = [];
%             maxbregmasupra = [];
%             minbregmainfra = [];
%             maxbregmainfra = [];
%             climsupra = [];
%             climinfra = [];
%             
%             for i=1:size(topview.conditionnames,1)
%                 %mean per condition
%                 topview.conditions.(topview.conditionnames{i}).supramean = nanmean(topview.conditions.(topview.conditionnames{i}).supra,3);
%                 topview.conditions.(topview.conditionnames{i}).inframean = nanmean(topview.conditions.(topview.conditionnames{i}).infra,3);
%                 topview.conditions.(topview.conditionnames{i}).arearelsupramean = nanmean(topview.conditions.(topview.conditionnames{i}).arearelsupra,3);
%                 topview.conditions.(topview.conditionnames{i}).arearelinframean = nanmean(topview.conditions.(topview.conditionnames{i}).arearelinfra,3);
%                 %shrink table
%                 nanlist = all(~isnan(topview.conditions.(topview.conditionnames{i}).supramean),2);
%                 topview.conditions.(topview.conditionnames{i}).bregmas = topview.bregmas(nanlist);
%                 topview.conditions.(topview.conditionnames{i}).supramean = topview.conditions.(topview.conditionnames{i}).supramean(nanlist,:);
%                 topview.conditions.(topview.conditionnames{i}).inframean = topview.conditions.(topview.conditionnames{i}).inframean(nanlist,:);
%                 topview.conditions.(topview.conditionnames{i}).suprameanbinned = [] %TODO bin per 200µm en dan interpoleren en ev smoothen
%                 topview.conditions.(topview.conditionnames{i}).arearelsupramean = topview.conditions.(topview.conditionnames{i}).arearelsupramean(nanlist,:);
%                 topview.conditions.(topview.conditionnames{i}).arearelinframean = topview.conditions.(topview.conditionnames{i}).arearelinframean(nanlist,:);
%                 
%                 %interpolate data
%                 [x y] = meshgrid(1:size(topview.conditions.(topview.conditionnames{i}).supramean,2),topview.conditions.(topview.conditionnames{i}).bregmas);
%                 [xi yi] = meshgrid(1:0.1:size(x,2),y(1):1.2:y(end)); %for rat and mice: 12µm sections, 1.2µm interpolation
%                 topview.conditions.(topview.conditionnames{i}).suprameaninterpol = interp2(x,y,topview.conditions.(topview.conditionnames{i}).supramean,xi,yi,'cubic');
%                 topview.conditions.(topview.conditionnames{i}).inframeaninterpol = interp2(x,y,topview.conditions.(topview.conditionnames{i}).inframean,xi,yi,'cubic');
%                 
%                 topview.conditions.(topview.conditionnames{i}).suprameangriddatacub = griddata(x,y,topview.conditions.(topview.conditionnames{i}).supramean,xi,yi,'cubic');
%                 topview.conditions.(topview.conditionnames{i}).suprameangriddatanear = griddata(x,y,topview.conditions.(topview.conditionnames{i}).supramean,xi,yi,'nearest');
%                 topview.conditions.(topview.conditionnames{i}).inframeangriddata = griddata(x,y,topview.conditions.(topview.conditionnames{i}).inframean,xi,yi);
%                 topview.segmentsinterpol = xi(1,:);
%                 topview.bregmasinterpol = yi(:,1);
%                 %interpolate areas
%                 [xa ya] = meshgrid(1:size(topview.conditions.(topview.conditionnames{i}).arearelsupra,2),topview.conditions.(topview.conditionnames{i}).bregmas);
%                 [xai yai] = meshgrid(1:size(topview.conditions.(topview.conditionnames{i}).arearelsupra,2),y(1):1.2:y(end));
%                 topview.conditions.(topview.conditionnames{i}).arearelsuprainterpol = interp2(xa,ya,topview.conditions.(topview.conditionnames{i}).arearelsupramean,xai,yai,'cubic');
%                 topview.conditions.(topview.conditionnames{i}).arearelinfrainterpol = interp2(xa,ya,topview.conditions.(topview.conditionnames{i}).arearelinframean,xai,yai,'cubic');
%                 topview.conditions.(topview.conditionnames{i}).arearelsuprainterpollin = interp2(xa,ya,topview.conditions.(topview.conditionnames{i}).arearelsupramean,xai,yai,'linear');
%                 topview.conditions.(topview.conditionnames{i}).arearelinfrainterpollin = interp2(xa,ya,topview.conditions.(topview.conditionnames{i}).arearelinframean,xai,yai,'linear');
%                 for j=1:4
%                     topview.conditions.(topview.conditionnames{i}).arearelsuprainterpolsmooth(:,j) = smooth(topview.conditions.(topview.conditionnames{i}).arearelsuprainterpollin(:,j),5);
%                     topview.conditions.(topview.conditionnames{i}).arearelinfrainterpolsmooth(:,j) = smooth(topview.conditions.(topview.conditionnames{i}).arearelinfrainterpollin(:,j),5);
%                 end
%                 
% %                 topview.conditions.(topview.conditionnames{i}).arearelsuprainterpolsmooth = topview.conditions.(topview.conditionnames{i}).arearelsuprainterpol;
% %                 topview.conditions.(topview.conditionnames{i}).arearelinfrainterpolsmooth = topview.conditions.(topview.conditionnames{i}).arearelinfrainterpol;
%                 
%                 %supra
%                 figure(figsupra);
%                 figsubsupra(i) = subplot(floor(size(topview.conditionnames,1)/3)+1,min(size(topview.conditionnames,1),3),i);
%                 set(figsubsupra(i), 'Uicontextmenu',cmenusupra);
%                 imagesc(topview.segmentsinterpol,topview.bregmasinterpol,topview.conditions.(topview.conditionnames{i}).suprameaninterpol);
%                 hold on;
% %                 plot(topview.conditions.(topview.conditionnames{i}).arearelsuprainterpol,topview.bregmasinterpol,'b-');
%                 plot(ones(size(topview.conditions.(topview.conditionnames{i}).bregmas,1),1),topview.conditions.(topview.conditionnames{i}).bregmas,'k>');
%                 plot(topview.conditions.(topview.conditionnames{i}).arearelsuprainterpollin,topview.bregmasinterpol,'w-');
%                 plot(topview.conditions.(topview.conditionnames{i}).arearelsuprainterpolsmooth,topview.bregmasinterpol,'k-');
%                 plot(smooth(topview.conditions.(topview.conditionnames{i}).arearelsuprainterpollin(:,2),20),topview.bregmasinterpol,'b-');
%                 plot(smooth(topview.conditions.(topview.conditionnames{i}).arearelsuprainterpollin(:,2),50),topview.bregmasinterpol,'m-');
%                 hold off;
%                 title([topview.conditionnames{i} ' - Supra']);
%                 lims = ylim;
%                 bregmasupra(i,:) = lims;
%                 climsupra(i,:) = caxis;
%                 
% %                 %temp
% %                 figure();
% %                 
% %                 imagesc(topview.segmentsinterpol,topview.bregmasinterpol,topview.conditions.(topview.conditionnames{i}).suprameangriddatacub);
% %                 hold on;
% % %                 plot(topview.conditions.(topview.conditionnames{i}).arearelsuprainterpol,topview.bregmasinterpol,'b-');
% %                 plot(ones(size(topview.conditions.(topview.conditionnames{i}).bregmas,1),1),topview.conditions.(topview.conditionnames{i}).bregmas,'k>');
% %                 plot(topview.conditions.(topview.conditionnames{i}).arearelsuprainterpollin,topview.bregmasinterpol,'w-');
% %                 plot(topview.conditions.(topview.conditionnames{i}).arearelsuprainterpolsmooth,topview.bregmasinterpol,'k-');
% %                 plot(smooth(topview.conditions.(topview.conditionnames{i}).arearelsuprainterpollin(:,2),20),topview.bregmasinterpol,'b-');
% %                 plot(smooth(topview.conditions.(topview.conditionnames{i}).arearelsuprainterpollin(:,2),50),topview.bregmasinterpol,'m-');
% %                 barh(topview.conditions.(topview.conditionnames{i}).bregmahist(:,1),-topview.conditions.(topview.conditionnames{i}).bregmahist(:,2));
% %                 hold off;
%                 
%                 
%                 %infra
%                 figure(figinfra);
%                 figsubinfra(i) = subplot(floor(size(topview.conditionnames,1)/3)+1,min(size(topview.conditionnames,1),3),i);
%                 set(figsubinfra(i), 'Uicontextmenu',cmenuinfra);
%                 imagesc(topview.segmentsinterpol,topview.bregmasinterpol,topview.conditions.(topview.conditionnames{i}).inframeaninterpol);
%                 hold on;
%                 plot(topview.conditions.(topview.conditionnames{i}).arearelinfrainterpolsmooth,topview.bregmasinterpol,'k-');
%                 plot(topview.conditions.(topview.conditionnames{i}).arearelinfrainterpollin,topview.bregmasinterpol,'w-');
%                 plot(ones(size(topview.conditions.(topview.conditionnames{i}).bregmas,1),1),topview.conditions.(topview.conditionnames{i}).bregmas,'k>');
%                 hold off;
%                 title([topview.conditionnames{i} ' - Infra']);
%                 lims = ylim;
%                 bregmainfra(i,:) = lims;
%                 climinfra(i,:) = caxis;
%                 
%             end
%             
%             
        case 'flatmount'
            for i=1:size(topview.micenames,1)
                %interpolate data
                [x y] = meshgrid(1:size(topview.mice.(topview.micenames{i}).supra,2),topview.mice.(topview.micenames{i}).bregmas);
                [xisupra yisupra] = meshgrid(1:0.1:size(x,2),y(1):1:y(end)); %for rat and mice: 120µm sections, 10µm interpolation = 1unit
                topview.mice.(topview.micenames{i}).suprainterpol = interp2(x,y,topview.mice.(topview.micenames{i}).supra,xisupra,yisupra,'linear');
                topview.mice.(topview.micenames{i}).infrainterpol = interp2(x,y,topview.mice.(topview.micenames{i}).infra,xisupra,yisupra,'linear');
                topview.mice.(topview.micenames{i}).segmentsinterpol = xisupra(1,:);
                topview.mice.(topview.micenames{i}).bregmasinterpol = yisupra(:,1);
                topview.mice.(topview.micenames{i}).segments = x(1,:);
                %interpolate areas
                [xa ya] = meshgrid(1:size(topview.mice.(topview.micenames{i}).arearelsupra,2),topview.mice.(topview.micenames{i}).bregmas);
                [xai yai] = meshgrid(1:size(topview.mice.(topview.micenames{i}).arearelsupra,2),y(1):1:y(end));
                topview.mice.(topview.micenames{i}).arearelsuprainterpol = interp2(xa,ya,topview.mice.(topview.micenames{i}).arearelsupra,xai,yai,'linear');
                topview.mice.(topview.micenames{i}).arearelinfrainterpol = interp2(xa,ya,topview.mice.(topview.micenames{i}).arearelinfra,xai,yai,'linear');
                %topview.mice.(topview.micenames{i}).arearelinfrainterpollin = interp2(xa,ya,topview.mice.(topview.micenames{i}).arearelinfra,xai,yai,'linear');
                %         for j=1:4
                %             topview.conditions.(topview.conditionnames{i}).arearelsuprainterpolsmooth(:,j) = smooth(topview.conditions.(topview.conditionnames{i}).arearelsuprainterpol(:,j),5);
                %             topview.conditions.(topview.conditionnames{i}).arearelinfrainterpolsmooth(:,j) = smooth(topview.conditions.(topview.conditionnames{i}).arearelinfrainterpol(:,j),5);
                %         end
                
                topview.mice.(topview.micenames{i}).arearelsuprainterpolsmooth = topview.mice.(topview.micenames{i}).arearelsuprainterpol;
                topview.mice.(topview.micenames{i}).arearelinfrainterpolsmooth = topview.mice.(topview.micenames{i}).arearelinfrainterpol;
                
                %supra
                figure(figsupra);
                figsubsupra(i) = subplot(floor(size(topview.micenames,1)/3)+1,min(size(topview.micenames,1),3),i);
                imagesc(topview.mice.(topview.micenames{i}).segmentsinterpol,topview.mice.(topview.micenames{i}).bregmasinterpol,topview.mice.(topview.micenames{i}).suprainterpol);
                hold on;
                plot(topview.mice.(topview.micenames{i}).arearelsuprainterpolsmooth,topview.mice.(topview.micenames{i}).bregmasinterpol,'k-');
                plot(ones(size(topview.mice.(topview.micenames{i}).bregmas,1),1),topview.mice.(topview.micenames{i}).bregmas,'k>');
                hold off;
                set(figsubsupra(i), 'Uicontextmenu',cmenusupra);
                set(figsubsupra(i),'Tag','jet');
                title([topview.micenames{i} ' - Supra']);
                lims = ylim;
                bregmasupra(i,:) = lims;
                climsupra(i,:) = caxis;
                
                %infra
                figure(figinfra);
                figsubinfra(i) = subplot(floor(size(topview.micenames,1)/3)+1,min(size(topview.micenames,1),3),i);
                imagesc(topview.mice.(topview.micenames{i}).segmentsinterpol,topview.mice.(topview.micenames{i}).bregmasinterpol,topview.mice.(topview.micenames{i}).infrainterpol);
                hold on;
                plot(topview.mice.(topview.micenames{i}).arearelinfrainterpolsmooth,topview.mice.(topview.micenames{i}).bregmasinterpol,'k-');
%                 plot(topview.mice.(topview.micenames{i}).arearelinfrainterpollin,topview.bregmasinterpol,'w-');
                plot(ones(size(topview.mice.(topview.micenames{i}).bregmas,1),1),topview.mice.(topview.micenames{i}).bregmas,'k>');
                hold off;
                set(figsubinfra(i), 'Uicontextmenu',cmenuinfra);
                set(figsubinfra(i),'Tag','jet');
                title([topview.micenames{i} ' - Infra']);
                lims = ylim;
                bregmainfra(i,:) = lims;
                climinfra(i,:) = caxis;
            end
            
        case 'top'
%             if(~isfield(handles.setuptable{1,6},'topcoxyprojected') || ~isfield(handles.setuptable{1,6},'botcoxyprojected'))
                for i=1:size(handles.setuptable,1)
                    %projection segments
                    PQ = zeros(1,size(handles.setuptable{i,6}.topcoxy,1)-1);
                    for j=1:size(handles.setuptable{i,6}.topcoxy,1)-1
                        P(1) = (handles.setuptable{i,6}.topcoxy(j,1)+handles.setuptable{i,6}.topcoxy(j+1,1))/2;
                        P(2) = (handles.setuptable{i,6}.topcoxy(j,2)+handles.setuptable{i,6}.topcoxy(j+1,2))/2;
                        m = handles.setuptable{i,5}.midlinep(1);
                        C = handles.setuptable{i,5}.midlinep(2);
                        Q(1) = (-C+P(2)+1/m*P(1))/(m+1/m);
                        Q(2) = m*Q(1)+C;
                        PQ(j) = sign(P(1)-Q(1))*sqrt(sum(diff([P;Q]).^2));
                    end
                    handles.setuptable{i,6}.topcoxyprojected = PQ;
                    
                    PQ = zeros(1,size(handles.setuptable{i,6}.botcoxy,1)-1);
                    for j=1:size(handles.setuptable{i,6}.botcoxy,1)-1
                        P(1) = (handles.setuptable{i,6}.botcoxy(j,1)+handles.setuptable{i,6}.botcoxy(j+1,1))/2;
                        P(2) = (handles.setuptable{i,6}.botcoxy(j,2)+handles.setuptable{i,6}.botcoxy(j+1,2))/2;
                        m = handles.setuptable{i,5}.midlinep(1);
                        C = handles.setuptable{i,5}.midlinep(2);
                        Q(1) = (-C+P(2)+1/m*P(1))/(m+1/m);
                        Q(2) = m*Q(1)+C;
                        PQ(j) = sign(P(1)-Q(1))*sqrt(sum(diff([P;Q]).^2));
                    end
                    handles.setuptable{i,6}.botcoxyprojected = PQ;
                    
                    %projection areas
                    PQ = zeros(1,size(handles.setuptable{i,5}.topareaxy,1));
                    for j=1:size(handles.setuptable{i,5}.topareaxy,1)
                        P = handles.setuptable{i,5}.topareaxy(j,:);
                        m = handles.setuptable{i,5}.midlinep(1);
                        C = handles.setuptable{i,5}.midlinep(2);
                        Q(1) = (-C+P(2)+1/m*P(1))/(m+1/m);
                        Q(2) = m*Q(1)+C;
                        PQ(j) = sign(P(1)-Q(1))*sqrt(sum(diff([P;Q]).^2));
                    end
                    handles.setuptable{i,5}.topareaxyprojected = PQ;
                    
                    PQ = zeros(1,size(handles.setuptable{i,5}.botareaxy,1));
                    for j=1:size(handles.setuptable{i,5}.botareaxy,1)
                        P = handles.setuptable{i,5}.botareaxy(j,:);
                        m = handles.setuptable{i,5}.midlinep(1);
                        C = handles.setuptable{i,5}.midlinep(2);
                        Q(1) = (-C+P(2)+1/m*P(1))/(m+1/m);
                        Q(2) = m*Q(1)+C;
                        PQ(j) = sign(P(1)-Q(1))*sqrt(sum(diff([P;Q]).^2));
                    end
                    handles.setuptable{i,5}.botareaxyprojected = PQ;

                end
%             end
            
            for i=1:size(handles.setuptable,1)
                mouse = handles.setuptable{i,2};
                topview.mice.(mouse).topcoxyprojected(topview.mice.(mouse).bregmas == cell2mat(handles.setuptable(i,7)),:) = handles.setuptable{i,6}.topcoxyprojected;
                topview.mice.(mouse).botcoxyprojected(topview.mice.(mouse).bregmas == cell2mat(handles.setuptable(i,7)),:) = handles.setuptable{i,6}.botcoxyprojected;
                topview.mice.(mouse).topareaxyprojected(topview.mice.(mouse).bregmas == cell2mat(handles.setuptable(i,7)),:) = handles.setuptable{i,5}.topareaxyprojected;
                topview.mice.(mouse).botareaxyprojected(topview.mice.(mouse).bregmas == cell2mat(handles.setuptable(i,7)),:) = handles.setuptable{i,5}.botareaxyprojected;
            end    
            
            pixelpermm = 2000;
            
            for i=1:size(topview.micenames,1)
                %build griddata vectors
                %segments
                xsupra = topview.mice.(topview.micenames{i}).topcoxyprojected(:);
%                 xsupra = xsupra./max(abs(xsupra)).*100; %make relative
                xsupra = xsupra./pixelpermm;
                xinfra = topview.mice.(topview.micenames{i}).botcoxyprojected(:);
%                 xinfra = xinfra./max(abs(xinfra)).*100; %make relative
                xinfra = xinfra./pixelpermm;
                y = repmat(topview.mice.(topview.micenames{i}).bregmas(:),1,topview.segments);
                y = y(:);
                vsupra = topview.mice.(topview.micenames{i}).supra(:);
                vinfra = topview.mice.(topview.micenames{i}).infra(:);
                %area
%                 xareasupra = topview.mice.(topview.micenames{i}).topareaxyprojected./max(abs(xsupra)).*100; %make relative;
%                 xareainfra = topview.mice.(topview.micenames{i}).botareaxyprojected./max(abs(xsupra)).*100; %make relative;
                
                %interpolate data
                [xisupra yisupra] = meshgrid(min(min(xsupra),0):abs(min(min(xsupra),0)-max(max(xsupra),0))/100:max(max(xsupra),0),y(1):0.1:y(end));
%                 [xiinfra yiinfra] = meshgrid(min(xinfra):0.1:max(xinfra),y(1):1:y(end));
%                 [xa ya] = meshgrid(1:size(xareasupra,2),topview.mice.(topview.micenames{i}).bregmas);
%                 [xai yai] = meshgrid(1:size(xareasupra,2),y(1):1:y(end));
                topview.mice.(topview.micenames{i}).suprainterpolprojected = griddata(xsupra,y,vsupra,xisupra,yisupra,'linear');
%                 topview.mice.(topview.micenames{i}).infrainterpolprojected = griddata(xinfra,y,vinfra,xiinfra,yiinfra,'linear');
                topview.mice.(topview.micenames{i}).segmentsinterpolsupraprojected = xisupra(1,:);
%                 topview.mice.(topview.micenames{i}).segmentsinterpolinfraprojected = xiinfra(1,:);
                topview.mice.(topview.micenames{i}).bregmasinterpolprojected = yisupra(:,1);
                %interpolate areas
%                 topview.mice.(topview.micenames{i}).arearelsuprainterpolprojected = interp2(xa,ya,xareasupra,xai,yai,'linear');
%                 topview.mice.(topview.micenames{i}).arearelinfrainterpolprojected = interp2(xa,ya,xareainfra,xai,yai,'linear');
               
                %plotting
                %supra
                figure(figsupra);
                figsubsupra(i) = subplot(floor((size(topview.micenames,1)-1)/3)+1,min(size(topview.micenames,1),3),i);
                pcolor(topview.mice.(topview.micenames{i}).segmentsinterpolsupraprojected,topview.mice.(topview.micenames{i}).bregmasinterpolprojected./100,topview.mice.(topview.micenames{i}).suprainterpolprojected);
%                 hold on;
%                 plot(topview.mice.(topview.micenames{i}).arearelsuprainterpolprojected,topview.mice.(topview.micenames{i}).bregmasinterpolprojected,'k-');
%                 plot(ones(size(topview.mice.(topview.micenames{i}).bregmas,1),1),topview.mice.(topview.micenames{i}).bregmas,'k>');
%                 hold off;
                shading flat;
                set(gca, 'ydir', 'reverse');
                set(figsubsupra(i), 'Uicontextmenu',cmenusupra);
                set(figsubsupra(i),'Tag','jet');
                title([topview.micenames{i} ' - Supra']);
                lims = ylim;
                bregmasupra(i,:) = lims;
                climsupra(i,:) = caxis;
                
                %infra
%                 figure(figinfra);
%                 figsubinfra(i) = subplot(floor(size(topview.micenames,1)/3)+1,min(size(topview.micenames,1),3),i);
%                 pcolor(topview.mice.(topview.micenames{i}).segmentsinterpolinfraprojected,topview.mice.(topview.micenames{i}).bregmasinterpolprojected,topview.mice.(topview.micenames{i}).infrainterpolprojected);
%                 hold on;
%                 plot(topview.mice.(topview.micenames{i}).arearelsuprainterpolprojected,topview.mice.(topview.micenames{i}).bregmasinterpolprojected,'k-');
% %                 plot(topview.mice.(topview.micenames{i}).arearelinfrainterpollin,topview.bregmasinterpol,'w-');
%                 plot(ones(size(topview.mice.(topview.micenames{i}).bregmas,1),1),topview.mice.(topview.micenames{i}).bregmas,'k>');
%                 hold off;
%                 shading flat;
%                 set(gca, 'ydir', 'reverse');
%                 set(figsubinfra(i), 'Uicontextmenu',cmenuinfra);
%                 set(figsubinfra(i),'Tag','jet');
%                 title([topview.micenames{i} ' - Infra']);
%                 lims = ylim;
%                 bregmainfra(i,:) = lims;
%                 climinfra(i,:) = caxis;
            end
                
    end
    
    %align Y and C axes
    if(exist('figsubsupra','var'))
        set(figsubsupra,'Ylim',[max(bregmasupra(:,1)) min(bregmasupra(:,2))]);
        set(figsubsupra,'CLim',[min(climsupra(:,1)) max(climsupra(:,2))]);
        set(figsubsupra,'Color',[1 1 1]);
        set(figsubsupra,'Box','off');
        set(figsubsupra,'XDir','reverse');
        handles.climsupra = [min(climsupra(:,1)) max(climsupra(:,2))];
        handles.climsupra_original = handles.climsupra;
        handles.bregmasupra = bregmasupra;
        handles.figsubsupra = figsubsupra;
    end
    if(exist('figsubinfra','var'))
        set(figsubinfra,'Ylim',[min(bregmainfra(:,1)) max(bregmainfra(:,2))]);
        set(figsubinfra,'CLim',[min(climinfra(:,1)) max(climinfra(:,2))]);
        set(figsubinfra,'Color',[0 0 0]);
        handles.climinfra = [min(climinfra(:,1)) max(climinfra(:,2))];
        handles.climinfra_original = handles.climinfra;
        handles.bregmainfra = bregmainfra;
        handles.figsubinfra = figsubinfra;
    end
    handles.topview = topview;
    
    %debug REMOVE LATER!!!
    warndlg('Debug mode! Random normalisation factor used!');
    for i=1:size(topview.micenames)
        handles.topview.mice.(topview.micenames{i}).normfactor_supra = 70 + randi([-20 20],1);
        handles.topview.mice.(topview.micenames{i}).normfactor_infra = 70 + randi([-20 20],1);
    end
    
    set(handles.fig_ISH_setup,'UserData',handles);
    
    %menu's
end
            
function handles = colorscale(src,evt,handles)
    handles = get(handles.fig_ISH_setup,'UserData');
    if(~isfield(handles,'colorscale'))
        handlescolorscale = ISHtopviewColorscale(handles);
    end
    set(handles.fig_ISH_setup,'UserData',handles);
end

function enlargesubplot(src,evt,handles)
    handles = get(handles.fig_ISH_setup,'UserData');
    maxposition = [0.05 0.05 0.9 0.9];
    plottitle = get(get(gca,'Title'),'String');
    handles.invokingsubploth = gca;
    figtitle = get(get(gca,'Title'),'String');
    cmapname = get(gca,'Tag');
    if(exist(cmapname)==0)
        cmap = load(cmapname);
        cmap = cmap.(cmapname);
    else
        eval('cmap = cmapname;');
    end
    tempAxes = copyobj(gca,gcf);

    h = figure('Resize','on',...
        'IntegerHandle','off',...
        'NumberTitle','off',...
        'Name',plottitle,...
        'Interruptible','off',...
        'BackingStore','off',...
        'Color',get(0,'DefaultUIControlBackgroundColor'));
    set(tempAxes,'Position', maxposition,'Parent',h);
    colormap(cmap);
    title(figtitle);
    hmenuenlarge = uimenu(gcf,'Label','Normalisation');
    uimenu(hmenuenlarge, 'Label', 'Define Normalisation Area','Accelerator','n','Callback', @(src,evt)definenormalisationarea(src,evt,handles));
    set(handles.fig_ISH_setup,'UserData',handles);

end

function handles = definenormalisationarea(src,evt,handles)
    imagename = get(get(gca,'Title'),'String');
    imagename = regexprep(imagename,' \(.*\)','');
    ms = regexprep(imagename,'(?i) - (sup|inf)ra','');
    handles = get(handles.fig_ISH_setup,'UserData');
    title('Draw area for normalisation, right click in area and choose Create Mask');
    Imask = roipoly;
    if(~isempty(Imask))
        if(~isempty(regexpi(imagename,'supra')))
            handles.topview.mice.(ms).normfactor_supra = nanmean(nanmean(handles.topview.mice.(ms).suprainterpol(Imask)));
        else
            handles.topview.mice.(ms).normfactor_infra = nanmean(nanmean(handles.topview.mice.(ms).infrainterpol(Imask)));
        end
        close(gcf);
        set(get(handles.invokingsubploth,'Title'),'String',[get(get(handles.invokingsubploth,'Title'),'String') ' *']);
        set(handles.fig_ISH_setup,'UserData',handles);
    end
end

function handles = normalizeto(src,evt,handles)
    %get real handles
    handles = get(handles.fig_ISH_setup,'UserData');
    %check if all mice have a normalisation area defined
    myfunc = @(x) (isfield(x,'normfactor_supra')); %&& isfield(x,'normfactor_infra'));
    if(all(structfun(myfunc,handles.topview.mice)))
        %choose mouse to normalize against
        sellist = [handles.topview.micenames;{'None'}];
        [sel ok] = listdlg('PromptString','Choose a mouse to normalize to','ListString',sellist,'SelectionMode','single');
        if(ok && sel~=0)
            %store normalisation info
            handles.topview.normalizeto = sellist{sel};

            %supra
            for ii=1:size(handles.figsubsupra,2)
                axes(handles.figsubsupra(ii));
                imagename = get(get(gca,'Title'),'String');
                imagename = regexprep(imagename,' \(.*\)','');
                ms = regexprep(imagename,'(?i) - (sup|inf)ra.*','');
                if(sel < size(handles.topview.micenames,1))
                    factor = (handles.topview.mice.(handles.topview.micenames{sel}).normfactor_supra/handles.topview.mice.(ms).normfactor_supra);
                    imagesc(handles.topview.mice.(ms).segmentsinterpol,handles.topview.mice.(ms).bregmasinterpol,handles.topview.mice.(ms).suprainterpol.*factor);
                    handles.topview.mice.(ms).normalizefactor_supra = factor;
                else
                    imagesc(handles.topview.mice.(ms).segmentsinterpol,handles.topview.mice.(ms).bregmasinterpol,handles.topview.mice.(ms).suprainterpol);
                    handles.topview.mice.(ms).normalizefactor_supra = NaN;
                end
                
                hold on;
                plot(handles.topview.mice.(ms).arearelsuprainterpolsmooth,handles.topview.mice.(ms).bregmasinterpol,'k-');
                plot(ones(size(handles.topview.mice.(ms).bregmas,1),1),handles.topview.mice.(ms).bregmas,'k>');
                hold off;
                if(sel < size(handles.topview.micenames,1))
                    if(strcmp(ms,handles.topview.micenames{sel}))
                        title([handles.topview.micenames{ii} sprintf(' - Supra (N ST %0.2f)',factor)]);
                    else
                        title([handles.topview.micenames{ii} sprintf(' - Supra (N %0.2f)',factor)]);
                    end
                else
                    title([handles.topview.micenames{ii} ' - Supra']);
                end
                set(gca,'Ylim',[min(handles.bregmasupra(:,1)) max(handles.bregmasupra(:,2))]);

            end
            %infra
            for ii=1:size(handles.figsubinfra,2)
                axes(handles.figsubinfra(ii));
                imagename = get(get(gca,'Title'),'String');
                imagename = regexprep(imagename,' \(.*\)','');
                ms = regexprep(imagename,'(?i) - (sup|inf)ra.*','');
                if(sel < size(handles.topview.micenames,1))
                    factor = (handles.topview.mice.(handles.topview.micenames{sel}).normfactor_infra/handles.topview.mice.(ms).normfactor_infra);
                    imagesc(handles.topview.mice.(ms).segmentsinterpol,handles.topview.mice.(ms).bregmasinterpol,handles.topview.mice.(ms).infrainterpol.*factor);
                    handles.topview.mice.(ms).normalizefactor_infra = factor;
                else
                    imagesc(handles.topview.mice.(ms).segmentsinterpol,handles.topview.mice.(ms).bregmasinterpol,handles.topview.mice.(ms).infrainterpol);
                    handles.topview.mice.(ms).normalizefactor_infra = NaN;
                end
                
                hold on;
                plot(handles.topview.mice.(ms).arearelinfrainterpolsmooth,handles.topview.mice.(ms).bregmasinterpol,'k-');
                plot(ones(size(handles.topview.mice.(ms).bregmas,1),1),handles.topview.mice.(ms).bregmas,'k>');
                hold off;
                if(sel < size(handles.topview.micenames,1))
                    if(strcmp(ms,handles.topview.micenames{sel}))
                        title([handles.topview.micenames{ii} sprintf(' - Infra (N ST %0.2f)',factor)]);
                    else
                        title([handles.topview.micenames{ii} sprintf(' - Infra (N %0.2f)',factor)]);
                    end
                else
                    title([handles.topview.micenames{ii} ' - Infra']);
                end
                set(gca,'Ylim',[min(handles.bregmainfra(:,1)) max(handles.bregmainfra(:,2))]);

            end
            %set menu label
            if(sel < size(handles.topview.micenames,1))
                set(handles.hSubmenu.normalizeto_supra,'Label',['Normalize to ' handles.topview.micenames{sel}]);
                set(handles.hSubmenu.normalizeto_infra,'Label',['Normalize to ' handles.topview.micenames{sel}]);
            else
                set(handles.hSubmenu.normalizeto_infra,'Label','Normalize to none');
                set(handles.hSubmenu.normalizeto_infra,'Label','Normalize to none');
            end
            set(handles.fig_ISH_setup,'UserData',handles);
        end
    else
        errordlg('You didn''t register a normalisation area for all animals. Check for missing stars (*) in the plot titles, right click on the axes, choose Enlarge and choose ''Define Normalisation area'' in the menu.');
    end
end

function createconditions(src,evt,handles)
    %get real handles
    handles = get(handles.fig_ISH_setup,'UserData');
    %figures
%     suprafig = figure();
%     cmenusupra = uicontextmenu;
%     uimenu(cmenusupra, 'Label', 'Enlarge', 'Callback', @(src,evt)enlargesubplot(src,evt,handles));
%     infrafig = figure();
%     cmenuinfra = uicontextmenu;
%     uimenu(cmenuinfra, 'Label', 'Enlarge', 'Callback', @(src,evt)enlargesubplot(src,evt,handles));

    %load colormap
    stats_cmap = load('stats_cmap','stats_cmap');
    stats_cmap = stats_cmap.('stats_cmap');
    stats_cmap_levels = load('stats_cmap_levels','stats_cmap_levels');
    stats_cmap_levels = stats_cmap_levels.('stats_cmap_levels');

    %fill conditons structure with normalized values
    for iii = 1:size(handles.topview.conditionnames,1)
        micelist = handles.topview.conditions.(handles.topview.conditionnames{iii}).mice;
        bregmalist = [];
        segmentlist = [];
        bregmainterpollist = [];
        segmentinterpollist = [];
        for jjj = 1:size(micelist,1)
            bregmalist = [bregmalist; handles.topview.mice.(micelist{jjj}).bregmas];
            bregmainterpollist = [bregmainterpollist; handles.topview.mice.(micelist{jjj}).bregmasinterpol];
            segmentlist = [segmentlist handles.topview.mice.(micelist{jjj}).segments];
            segmentinterpollist = [segmentinterpollist handles.topview.mice.(micelist{jjj}).segmentsinterpol];
        end
        bregmainterpollist = unique(bregmainterpollist);
        segmentinterpollist = unique(segmentinterpollist);
        bregmalist = unique(bregmalist);
        segmentlist = unique(segmentlist);
        handles.topview.conditions.(handles.topview.conditionnames{iii}).bregmas = bregmalist;
        handles.topview.conditions.(handles.topview.conditionnames{iii}).segments = segmentlist;
        %stack and align all animal in matrix (bregmas x segments x
        %animals)
        handles.topview.conditions.(handles.topview.conditionnames{iii}).supra = nan(size(bregmalist,1),size(segmentlist,2),size(micelist,1));
        handles.topview.conditions.(handles.topview.conditionnames{iii}).infra = nan(size(bregmalist,1),size(segmentlist,2),size(micelist,1));
        handles.topview.conditions.(handles.topview.conditionnames{iii}).arearelsupra = nan(size(bregmalist,1),handles.arealborders,size(micelist,1));
        handles.topview.conditions.(handles.topview.conditionnames{iii}).arearelinfra = nan(size(bregmalist,1),handles.arealborders,size(micelist,1));
        %normalize to selected mouse if applicable
        for jjj = 1:size(micelist,1)
            if(~strcmp(handles.topview.normalizeto,'None'))
                handles.topview.conditions.(handles.topview.conditionnames{iii}).supra(ismember(bregmalist,handles.topview.mice.(micelist{jjj}).bregmas),:,jjj) = handles.topview.mice.(micelist{jjj}).supra.*handles.topview.mice.(micelist{jjj}).normalizefactor_supra;
                handles.topview.conditions.(handles.topview.conditionnames{iii}).infra(ismember(bregmalist,handles.topview.mice.(micelist{jjj}).bregmas),:,jjj) = handles.topview.mice.(micelist{jjj}).infra.*handles.topview.mice.(micelist{jjj}).normalizefactor_infra;
            else
                handles.topview.conditions.(handles.topview.conditionnames{iii}).supra(ismember(bregmalist,handles.topview.mice.(micelist{jjj}).bregmas),:,jjj) = handles.topview.mice.(micelist{jjj}).supra;
                handles.topview.conditions.(handles.topview.conditionnames{iii}).infra(ismember(bregmalist,handles.topview.mice.(micelist{jjj}).bregmas),:,jjj) = handles.topview.mice.(micelist{jjj}).infra;
            end
            handles.topview.conditions.(handles.topview.conditionnames{iii}).arearelsupra(ismember(bregmalist,handles.topview.mice.(micelist{jjj}).bregmas),:,jjj) = handles.topview.mice.(micelist{jjj}).arearelsupra;
            handles.topview.conditions.(handles.topview.conditionnames{iii}).arearelinfra(ismember(bregmalist,handles.topview.mice.(micelist{jjj}).bregmas),:,jjj) = handles.topview.mice.(micelist{jjj}).arearelinfra;

        end
      
        %interpolate   %%%%%%%%%%%%%%%%%TTTTOOOOODDDOOOOOOOOOOOOOOOOO
        
        
%         
%         
%         if(ok && ~isempty(sel))
%             [~, bregmalevels] = ismember(bregmalist,bregmainterpollist);
%             [~, segmentlevels] = ismember(segmentlist,segmentinterpollist);
%             handles.topview.conditions.(handles.topview.conditionnames{iii}).bregmas = bregmalist;
%             handles.topview.conditions.(handles.topview.conditionnames{iii}).segments = segmentlist;
%             handles.topview.conditions.(handles.topview.conditionnames{iii}).suprainterpol_mean = nanmean(handles.topview.conditions.(handles.topview.conditionnames{iii}).suprainterpol(bregmalevels,segmentlevels,sel),3);
%             handles.topview.conditions.(handles.topview.conditionnames{iii}).infrainterpol_mean = nanmean(handles.topview.conditions.(handles.topview.conditionnames{iii}).infrainterpol(bregmalevels,segmentlevels,sel),3);
%             handles.topview.conditions.(handles.topview.conditionnames{iii}).arearelsupra_mean = nanmean(handles.topview.conditions.(handles.topview.conditionnames{iii}).arearelsupra(bregmalevels,:,sel),3);
%             handles.topview.conditions.(handles.topview.conditionnames{iii}).arearelinfra_mean = nanmean(handles.topview.conditions.(handles.topview.conditionnames{iii}).arearelinfra(bregmalevels,:,sel),3);
% 
%             %interpolate data
%             [xx yy] = meshgrid(segmentlist,bregmalist);
%             [xxi yyi] = meshgrid(1:0.1:size(xx,2),yy(1):1:yy(end)); %for rat and mice: 120µm sections, 10µm interpolation = 1unit
%             handles.topview.conditions.(handles.topview.conditionnames{iii}).suprainterpol_mean_interpol = interp2(xx,yy,handles.topview.conditions.(handles.topview.conditionnames{iii}).suprainterpol_mean,xxi,yyi,'linear');
%             handles.topview.conditions.(handles.topview.conditionnames{iii}).infrainterpol_mean_interpol = interp2(xx,yy,handles.topview.conditions.(handles.topview.conditionnames{iii}).infrainterpol_mean,xxi,yyi,'linear');
%             handles.topview.conditions.(handles.topview.conditionnames{iii}).segmentsinterpol = xxi(1,:);
%             handles.topview.conditions.(handles.topview.conditionnames{iii}).bregmasinterpol = yyi(:,1);
%             %interpolate area
%             [xxa yya] = meshgrid(1:handles.arealborders,bregmalist);
%             [xxai yyai] = meshgrid(1:handles.arealborders,yya(1):1:yya(end)); %for rat and mice: 120µm sections, 10µm interpolation = 1unit
%             handles.topview.conditions.(handles.topview.conditionnames{iii}).arearelsupra_mean_interpol = interp2(xxa,yya,handles.topview.conditions.(handles.topview.conditionnames{iii}).arearelsupra_mean,xxai,yyai,'linear');
%             handles.topview.conditions.(handles.topview.conditionnames{iii}).arearelinfra_mean_interpol = interp2(xxa,yya,handles.topview.conditions.(handles.topview.conditionnames{iii}).arearelinfra_mean,xxai,yyai,'linear');
%         end
    end
    
    %calculate T-statistics permutations
    conditioncomb = [1 6; 2 6; 3 6; 4 6; 5 6];
    
    for iii=1:size(conditioncomb,1)
        conditioncombname = [handles.topview.conditionnames{conditioncomb(iii,1)} '_' handles.topview.conditionnames{conditioncomb(iii,2)}];
        handles.topview.interconditions.(conditioncombname).conditions = handles.topview.conditionnames(conditioncomb(iii,1:2));
        miceconditionA = handles.topview.conditions.(handles.topview.conditionnames{conditioncomb(iii,1)}).mice;
        miceconditionB = handles.topview.conditions.(handles.topview.conditionnames{conditioncomb(iii,2)}).mice;
        mice = [miceconditionA; miceconditionB];
        %permutations and its complement
        perms = nchoosek(mice, size(miceconditionA,1));
        for jjj = 1:size(perms,1)
            permscomplement(jjj,:) = mice(~ismember(mice,perms(jjj,:)))';
        end
        handles.topview.interconditions.(conditioncombname).perms = perms;
        handles.topview.interconditions.(conditioncombname).permscomplement = permscomplement;
        figure();
        for jjj = 1:size(perms,1)
            permname = ['perm' num2str(jjj)];
            clear bregmalist segmentlist;
            bregmalist{1} = [];
            segmentlist{1} = [];
            bregmalist{2} = [];
            segmentlist{2} = [];
            for kkk = 1:size(perms,2)
                bregmalist{1} = [bregmalist{1}; handles.topview.mice.(perms{jjj,kkk}).bregmas];
                segmentlist{1} = [segmentlist{1} handles.topview.mice.(perms{jjj,kkk}).segments];
            end
            bregmalist{1} = unique(bregmalist{1});
            segmentlist{1} = unique(segmentlist{1});
            for kkk = 1:size(permscomplement,2)
                bregmalist{2} = [bregmalist{2}; handles.topview.mice.(permscomplement{jjj,kkk}).bregmas];
                segmentlist{2} = [segmentlist{2} handles.topview.mice.(permscomplement{jjj,kkk}).segments];
            end
            bregmalist{2} = unique(bregmalist{2});
            segmentlist{2} = unique(segmentlist{2});
            
            %stack and align mice
            handles.topview.interconditions.(conditioncombname).permutations.(permname).condA_supra = nan(size(bregmalist{1},1),size(segmentlist{1},2),size(perms,2));
            handles.topview.interconditions.(conditioncombname).permutations.(permname).condB_supra = nan(size(bregmalist{2},1),size(segmentlist{2},2),size(permscomplement,2));
            for kkk = 1:size(perms,2)
                if(~strcmp(handles.topview.normalizeto,'None'))
                    handles.topview.interconditions.(conditioncombname).permutations.(permname).condA_supra(ismember(bregmalist{1},handles.topview.mice.(perms{jjj,kkk}).bregmas),:,kkk) = handles.topview.mice.(perms{jjj,kkk}).supra.*handles.topview.mice.(perms{jjj,kkk}).normalizefactor_supra;
                else
                    handles.topview.interconditions.(conditioncombname).permutations.(permname).condA_supra(ismember(bregmalist{1},handles.topview.mice.(perms{jjj,kkk}).bregmas),:,kkk) = handles.topview.mice.(perms{jjj,kkk}).supra.*handles.topview.mice.(perms{jjj,kkk}).normalizefactor_supra;
                end
            end
            for kkk = 1:size(permscomplement,2)
                if(~strcmp(handles.topview.normalizeto,'None'))
                    handles.topview.interconditions.(conditioncombname).permutations.(permname).condB_supra(ismember(bregmalist{2},handles.topview.mice.(permscomplement{jjj,kkk}).bregmas),:,kkk) = handles.topview.mice.(permscomplement{jjj,kkk}).supra.*handles.topview.mice.(permscomplement{jjj,kkk}).normalizefactor_supra;
                else
                    handles.topview.interconditions.(conditioncombname).permutations.(permname).condB_supra(ismember(bregmalist{2},handles.topview.mice.(permscomplement{jjj,kkk}).bregmas),:,kkk) = handles.topview.mice.(permscomplement{jjj,kkk}).supra.*handles.topview.mice.(permscomplement{jjj,kkk}).normalizefactor_supra;
                end
            end
            %label identical to actual experiment or opposite
%             [dimA1 dimA2 ~] = size(handles.topview.permutations.(permname).condA_supra);
%             [dimB1 dimB2 ~] = size(handles.topview.permutations.(permname).condB_supra);
%             handles.topview.permutations.(permname).condA_label = repmat(reshape((-1).^(~ismember(perms(jjj,:),miceconditionA)),1,1,size(miceconditionA,1)),[dimA1,dimA2,1]);
%             handles.topview.permutations.(permname).condB_label = repmat(reshape((-1).^(~ismember(permscomplement(jjj,:),miceconditionB)),1,1,size(miceconditionB,1)),[dimB1,dimB2,1]);
            %merge
            handles.topview.interconditions.(conditioncombname).permutations.(permname).condA_supra_mean = nanmean(handles.topview.interconditions.(conditioncombname).permutations.(permname).condA_supra,3);
            handles.topview.interconditions.(conditioncombname).permutations.(permname).condB_supra_mean = nanmean(handles.topview.interconditions.(conditioncombname).permutations.(permname).condB_supra,3);
            %interpolate
            [xx yy] = meshgrid(segmentlist{1},bregmalist{1});
            [xxi yyi] = meshgrid(1:0.1:size(xx,2),yy(1):1:yy(end));
            handles.topview.interconditions.(conditioncombname).permutations.(permname).condA_supra_mean_interpol = interp2(xx,yy,handles.topview.interconditions.(conditioncombname).permutations.(permname).condA_supra_mean,xxi,yyi,'linear');
            handles.topview.interconditions.(conditioncombname).permutations.(permname).condA_segments_interpol = xxi(1,:);
            handles.topview.interconditions.(conditioncombname).permutations.(permname).condA_bregmas_interpol = yyi(:,1);
            [xx yy] = meshgrid(segmentlist{2},bregmalist{2});
            [xxi yyi] = meshgrid(1:0.1:size(xx,2),yy(1):1:yy(end));
            handles.topview.interconditions.(conditioncombname).permutations.(permname).condB_supra_mean_interpol = interp2(xx,yy,handles.topview.interconditions.(conditioncombname).permutations.(permname).condB_supra_mean,xxi,yyi,'linear');
            handles.topview.interconditions.(conditioncombname).permutations.(permname).condB_segments_interpol = xxi(1,:);
            handles.topview.interconditions.(conditioncombname).permutations.(permname).condB_bregmas_interpol = yyi(:,1);
            
            %shift scale
            scaleshift_supra = abs(min(min(min(handles.topview.interconditions.(conditioncombname).permutations.(permname).condA_supra_mean_interpol)),min(min(handles.topview.interconditions.(conditioncombname).permutations.(permname).condB_supra_mean_interpol))));
            handles.topview.interconditions.(conditioncombname).permutations.(permname).condA_supra_mean_interpol_ss = handles.topview.interconditions.(conditioncombname).permutations.(permname).condA_supra_mean_interpol + scaleshift_supra;
            handles.topview.interconditions.(conditioncombname).permutations.(permname).condB_supra_mean_interpol_ss = handles.topview.interconditions.(conditioncombname).permutations.(permname).condB_supra_mean_interpol + scaleshift_supra;
            %strip
            bregmaA = ismember(handles.topview.interconditions.(conditioncombname).permutations.(permname).condA_bregmas_interpol,handles.topview.interconditions.(conditioncombname).permutations.(permname).condB_bregmas_interpol);
            bregmaB = ismember(handles.topview.interconditions.(conditioncombname).permutations.(permname).condB_bregmas_interpol,handles.topview.interconditions.(conditioncombname).permutations.(permname).condA_bregmas_interpol);
            %difference
            topviewAB3D_supra = nan(sum(bregmaA),length(handles.topview.interconditions.(conditioncombname).permutations.(permname).condB_segments_interpol),2);
            topviewAB3D_supra(:,:,1) = handles.topview.interconditions.(conditioncombname).permutations.(permname).condA_supra_mean_interpol_ss(bregmaA,:);
            topviewAB3D_supra(:,:,2) = handles.topview.interconditions.(conditioncombname).permutations.(permname).condB_supra_mean_interpol_ss(bregmaB,:);
            handles.topview.interconditions.(conditioncombname).permutations.(permname).topviewABdiff_supra = diff(topviewAB3D_supra,1,3);
            handles.topview.interconditions.(conditioncombname).permutations.(permname).topviewABvar_supra = movingvar(handles.topview.interconditions.(conditioncombname).permutations.(permname).topviewABdiff_supra,25);
            handles.topview.interconditions.(conditioncombname).permutations.(permname).tstat_supra = handles.topview.interconditions.(conditioncombname).permutations.(permname).topviewABdiff_supra./sqrt(handles.topview.interconditions.(conditioncombname).permutations.(permname).topviewABvar_supra*((1/size(perms,2))+(1/size(permscomplement,2))));
            
            %Tmax value
            handles.topview.interconditions.(conditioncombname).Tmax(jjj) = max(max(handles.topview.interconditions.(conditioncombname).permutations.(permname).tstat_supra));
            %plot
            subp(jjj) = subplot(ceil(sqrt(size(perms,1))),ceil(sqrt(size(perms,1))),jjj);
            imagesc(handles.topview.interconditions.(conditioncombname).permutations.(permname).tstat_supra);
            title(['permutation ' num2str(jjj)]);
        end
        set(subp,'CLim',[min(min(cell2mat(get(subp,'CLim')))) max(max(cell2mat(get(subp,'Clim'))))]);
        %order Tmax values and determine critical value
        handles.topview.interconditions.(conditioncombname).Tmax = sort(handles.topview.interconditions.(conditioncombname).Tmax);
        handles.topview.interconditions.(conditioncombname).criticalpos = floor(0.05*size(perms,1))+1;
        handles.topview.interconditions.(conditioncombname).criticalvalue = handles.topview.interconditions.(conditioncombname).Tmax(end-handles.topview.interconditions.(conditioncombname).criticalpos+1);
        handles.topview.interconditions.(conditioncombname).cutoff = handles.topview.interconditions.(conditioncombname).permutations.perm1.tstat_supra >= handles.topview.interconditions.(conditioncombname).criticalvalue;
        figure();
        subplot(1,5,1);
        imagesc(handles.topview.interconditions.(conditioncombname).permutations.perm1.condA_supra_mean_interpol);
        title(['A: ' handles.topview.interconditions.(conditioncombname).conditions{1}]);
        subplot(1,5,2);
        imagesc(handles.topview.interconditions.(conditioncombname).permutations.perm1.condB_supra_mean_interpol);
        title(['B: ' handles.topview.interconditions.(conditioncombname).conditions{2}]);
        subplot(1,5,3);
        imagesc(handles.topview.interconditions.(conditioncombname).permutations.perm1.topviewABdiff_supra);
        title('A-B')
        hold on;
        contour(handles.topview.interconditions.(conditioncombname).cutoff);
        hold off;
        subplot(1,5,4);
        imagesc(handles.topview.interconditions.(conditioncombname).permutations.perm1.tstat_supra);
        title('pseudo T-test');
        subplot(1,5,5);
        hist(handles.topview.interconditions.(conditioncombname).Tmax);
        title('Tmax distribution');
    end
    
        
%     for iii=1:size(perms,1)
%         %plot
%         bregmaA = ismember(handles.topview.conditions.(handles.topview.conditionnames{perms(iii,1)}).bregmasinterpol,handles.topview.conditions.(handles.topview.conditionnames{perms(iii,2)}).bregmasinterpol);
%         bregmaB = ismember(handles.topview.conditions.(handles.topview.conditionnames{perms(iii,2)}).bregmasinterpol,handles.topview.conditions.(handles.topview.conditionnames{perms(iii,1)}).bregmasinterpol);
% 
%         %Condition A
%         figure(suprafig);
%         suprasubfig(iii,1) = subplot(size(perms,1),4,iii*4-3);
%         imagesc(handles.topview.conditions.(handles.topview.conditionnames{perms(iii,1)}).segmentsinterpol,handles.topview.conditions.(handles.topview.conditionnames{perms(iii,1)}).bregmasinterpol(bregmaA,:),handles.topview.conditions.(handles.topview.conditionnames{perms(iii,1)}).suprainterpol_mean_interpol(bregmaA,:));
%         hold on;
%         plot(handles.topview.conditions.(handles.topview.conditionnames{perms(iii,1)}).arearelsupra_mean_interpol(bregmaA,:),handles.topview.conditions.(handles.topview.conditionnames{perms(iii,1)}).bregmasinterpol(bregmaA,:),'k-');
%         plot(ones(size(handles.topview.conditions.(handles.topview.conditionnames{perms(iii,1)}).bregmas,1),1),handles.topview.conditions.(handles.topview.conditionnames{perms(iii,1)}).bregmas,'k>');
%         hold off;
%         title([handles.topview.conditionnames{perms(iii,1)} ' - Supra']);
%         colormap(jet);
%         set(gca,'Tag','jet');
%         freezeColors(suprasubfig(iii,1))
%         
%         figure(infrafig);
%         infrasubfig(iii,1) = subplot(size(perms,1),4,iii*4-3);
%         imagesc(handles.topview.conditions.(handles.topview.conditionnames{perms(iii,1)}).segmentsinterpol,handles.topview.conditions.(handles.topview.conditionnames{perms(iii,1)}).bregmasinterpol(bregmaA,:),handles.topview.conditions.(handles.topview.conditionnames{perms(iii,1)}).infrainterpol_mean_interpol(bregmaA,:));
%         hold on;
%         plot(handles.topview.conditions.(handles.topview.conditionnames{perms(iii,1)}).arearelinfra_mean_interpol(bregmaA,:),handles.topview.conditions.(handles.topview.conditionnames{perms(iii,1)}).bregmasinterpol(bregmaA,:),'k-');
%         plot(ones(size(handles.topview.conditions.(handles.topview.conditionnames{perms(iii,1)}).bregmas,1),1),handles.topview.conditions.(handles.topview.conditionnames{perms(iii,1)}).bregmas,'k>');
%         hold off;
%         title([handles.topview.conditionnames{perms(iii,1)} ' - infra']);
%         colormap(jet);
%         set(gca,'Tag','jet');
%         freezeColors(infrasubfig(iii,1))
%         %Condition B
%         figure(suprafig);
%         suprasubfig(iii,2) = subplot(size(perms,1),4,iii*4-2);
%         imagesc(handles.topview.conditions.(handles.topview.conditionnames{perms(iii,2)}).segmentsinterpol,handles.topview.conditions.(handles.topview.conditionnames{perms(iii,2)}).bregmasinterpol(bregmaB,:),handles.topview.conditions.(handles.topview.conditionnames{perms(iii,2)}).suprainterpol_mean_interpol(bregmaB,:));
%         hold on;
%         plot(handles.topview.conditions.(handles.topview.conditionnames{perms(iii,2)}).arearelsupra_mean_interpol(bregmaB,:),handles.topview.conditions.(handles.topview.conditionnames{perms(iii,2)}).bregmasinterpol(bregmaB,:),'k-');
%         plot(ones(size(handles.topview.conditions.(handles.topview.conditionnames{perms(iii,2)}).bregmas,1),1),handles.topview.conditions.(handles.topview.conditionnames{perms(iii,2)}).bregmas,'k>');
%         hold off;
%         title([handles.topview.conditionnames{perms(iii,2)} ' - Supra']);
%         colormap(jet);
%         set(gca,'Tag','jet');
%         freezeColors(suprasubfig(iii,2))
%         
%         figure(infrafig);
%         infrasubfig(iii,2) = subplot(size(perms,1),4,iii*4-2);
%         imagesc(handles.topview.conditions.(handles.topview.conditionnames{perms(iii,2)}).segmentsinterpol,handles.topview.conditions.(handles.topview.conditionnames{perms(iii,2)}).bregmasinterpol(bregmaB,:),handles.topview.conditions.(handles.topview.conditionnames{perms(iii,2)}).infrainterpol_mean_interpol(bregmaB,:));
%         hold on;
%         plot(handles.topview.conditions.(handles.topview.conditionnames{perms(iii,2)}).arearelinfra_mean_interpol(bregmaB,:),handles.topview.conditions.(handles.topview.conditionnames{perms(iii,2)}).bregmasinterpol(bregmaB,:),'k-');
%         plot(ones(size(handles.topview.conditions.(handles.topview.conditionnames{perms(iii,2)}).bregmas,1),1),handles.topview.conditions.(handles.topview.conditionnames{perms(iii,2)}).bregmas,'k>');
%         hold off;
%         title([handles.topview.conditionnames{perms(iii,2)} ' - infra']);
%         colormap(jet);
%         set(gca,'Tag','jet');
%         freezeColors(infrasubfig(iii,2))
% 
%         %difference between conditions SUPRA
%         topviewA_supra = handles.topview.conditions.(handles.topview.conditionnames{perms(iii,1)}).suprainterpol_mean_interpol(bregmaA,:);
%         topviewB_supra = handles.topview.conditions.(handles.topview.conditionnames{perms(iii,2)}).suprainterpol_mean_interpol(bregmaB,:);
%         topviewA_infra = handles.topview.conditions.(handles.topview.conditionnames{perms(iii,1)}).infrainterpol_mean_interpol(bregmaA,:);
%         topviewB_infra = handles.topview.conditions.(handles.topview.conditionnames{perms(iii,2)}).infrainterpol_mean_interpol(bregmaB,:);
%         scaleshift_supra = abs(min(min(min(topviewA_supra)),min(min(topviewB_supra))));
%         scaleshift_infra = abs(min(min(min(topviewA_infra)),min(min(topviewB_infra))));
%         topviewA_supra = topviewA_supra + scaleshift_supra;
%         topviewB_supra = topviewB_supra + scaleshift_supra;
%         topviewA_infra = topviewA_infra + scaleshift_infra;
%         topviewB_infra = topviewB_infra + scaleshift_infra;
%         
%         topviewAB3D_supra = [];
%         topviewAB3D_supra(:,:,1) = topviewA_supra;
%         topviewAB3D_supra(:,:,2) = topviewB_supra;
%         topviewAB3D_infra = [];
%         topviewAB3D_infra(:,:,1) = topviewA_infra;
%         topviewAB3D_infra(:,:,2) = topviewB_infra;
%         %STD version
%         %topviewAB = (std(topviewAB3D,0,3).*sign(diff(topviewAB3D,1,3)))./max(max(std(topviewAB3D,0,3)));
%         %relative difference version
%         %topviewAB = diff(topviewAB3D,1,3)./sum(topviewAB3D,3);
%         %topviewlims(iii,:) = [nanmin(nanmin(topviewAB)) nanmax(nanmax(topviewAB))];
% 
%         %pseudo-t-statistic
%         topviewAB_supra = diff(topviewAB3D_supra,1,3);
%         topviewABvar_supra = movingvar(topviewAB_supra,25);
%         tstat_supra = topviewAB_supra./sqrt(topviewABvar_supra); 
%         [tstatsorted ind_supra] = sort(tstat_supra(:));
%         series = (1:numel(tstat_supra))./numel(tstat_supra);
%         histcutoffs(1,1) = tstatsorted(find(series < 0.001/2,1,'last'));
%         histcutoffs(2,1) = tstatsorted(find(series < 0.01/2,1,'last'));
%         histcutoffs(3,1) = tstatsorted(find(series < 0.05/2,1,'last'));
%         histcutoffs(1,2) = tstatsorted(find(series > 1-(0.001/2),1,'first'));
%         histcutoffs(2,2) = tstatsorted(find(series > 1-(0.01/2),1,'first'));
%         histcutoffs(3,2) = tstatsorted(find(series > 1-(0.05/2),1,'first'));
%         histcutoffs(histcutoffs(:,1) > 0,1) = NaN;
%         histcutoffs(histcutoffs(:,2) < 0,2) = NaN;
%         topviewABpval_supra = zeros(size(tstat_supra));
%         topviewABpval_supra(ind_supra) = series;
%         topviewABpval_supra = reshape(topviewABpval_supra,size(tstat_supra));
%         
%         %tech paper figures
%         figure()
%         colormap('default')
%         hplot(1) = subplot(3,3,1);
%         imagesc(topviewA_supra);
%         colorbar;
%         freezeColors(hplot(1));
%         title(['A: ' handles.topview.conditionnames{perms(iii,1)}]);
%         hplot(2) = subplot(3,3,2);
%         imagesc(topviewB_supra);
%         colorbar;
%         freezeColors(hplot(2));
%         title(['B: ' handles.topview.conditionnames{perms(iii,2)}]);
%         hplot(3) = subplot(3,3,3);
%         imagesc(topviewAB_supra);
%         colorbar;
%         freezeColors(hplot(3));
%         title('B-A');
%         hplot(4) = subplot(3,3,4);
%         imagesc(topviewABvar_supra);
%         colorbar;
%         freezeColors(hplot(4));
%         title('Smoothed variance of B-A');
%         hplot(5) = subplot(3,3,5);
%         imagesc(tstat_supra);
%         colorbar;
%         freezeColors(hplot(5));
%         title('(B-A)/sqrt(Variance B-A)');
%         hplot(6) = subplot(3,3,6);
%         hist(tstat_supra(:),100);
%         ylims = get(gca,'YLim');
%         hold on;
%         plot(repmat(histcutoffs(1,:),2,1),ylims,'r-');
%         plot(repmat(histcutoffs(2,:),2,1),ylims,'y-');
%         plot(repmat(histcutoffs(3,:),2,1),ylims,'g-');
%         hold off;
%         ylim(ylims);
%         freezeColors(hplot(6));
%         title('Histogram T-statistic');
%         hplot(7) = subplot(3,3,7);
%         imagesc((topviewB_supra-topviewA_supra)./(topviewB_supra+topviewA_supra));
%         colorbar;
%         set(hplot(7),'CLim',[-max(abs(get(hplot(7),'Clim'))) max(abs(get(hplot(7),'Clim')))])
%         freezeColors(hplot(7));
%         title('Relative B-A');
%         hplot(8) = subplot(3,3,8);
%         ttestval = topviewABpval_supra;
%         ttnew = zeros(size(ttestval));
%         ttnew(ttestval < 0.001/2) = -3;
%         ttnew(ttestval >= 0.001/2 & ttestval < 0.01/2) = -2;
%         ttnew(ttestval >= 0.01/2 & ttestval < 0.05/2) = -1;
%         ttnew(ttestval >= 0.05/2 & ttestval <= (1-0.05/2)) = 0;
%         ttnew(ttestval > (1-0.001/2)) = 3;
%         ttnew(ttestval <= (1-0.001/2) & ttestval > (1-0.01/2)) = 2;
%         ttnew(ttestval <= (1-0.01/2) & ttestval > (1-0.05/2)) = 1;
%         imagesc(ttnew);
%         colormap(stats_cmap_levels);
%         colorbar;
%         freezeColors(hplot(8));
%         title('p-values');
%         hplot(9) = subplot(3,3,9);
%         imagesc((topviewB_supra-topviewA_supra)./(topviewB_supra+topviewA_supra));
%         colormap('default');
%         caxis auto;
%         colorbar;
%         freezeColors(hplot(9));
%         hold on;
%         posit = zeros(size(ttnew));
%         negat = zeros(size(ttnew));
%         posit(ttnew > 0) = ttnew(ttnew > 0);
%         negat(ttnew < 0) = ttnew(ttnew < 0);
%         [C hcontour] = contour(posit,'k');
%         [C hcontour] = contour(negat,'w');
%         hold off;
%         freezeColors(hplot(9));
%         title('Relative B-A with p-values');
%         
%         
%         topviewAB_infra = diff(topviewAB3D_infra,1,3);
%         topviewABvar_infra = movingvar(topviewAB_infra,25);
%         tstat_infra = abs(topviewAB_infra)./sqrt(topviewABvar_infra); 
%         [tstatsorted ind_infra] = sort(tstat_infra(:));
%         topviewABpval_infra = zeros(size(tstat_infra));
%         topviewABpval_infra(ind_infra) = 1-((1:numel(tstat_infra))./numel(tstat_infra));
%         topviewABpval_infra = reshape(topviewABpval_infra,size(tstat_infra));
%         
%         %combine areas
%         bregmalist = unique([handles.topview.conditions.(handles.topview.conditionnames{perms(iii,1)}).bregmas; handles.topview.conditions.(handles.topview.conditionnames{perms(iii,2)}).bregmas]);
%         bregmainterpollist = unique([handles.topview.conditions.(handles.topview.conditionnames{perms(iii,1)}).bregmasinterpol; handles.topview.conditions.(handles.topview.conditionnames{perms(iii,2)}).bregmasinterpol]);
%         [~, bregmalevels] = ismember(bregmalist,bregmainterpollist);
%         handles.topview.interconditions.([handles.topview.conditionnames{perms(iii,1)} '_' handles.topview.conditionnames{perms(iii,2)}]).arearelsupra = nan(size(bregmainterpollist,1),handles.arealborders,2);
%         handles.topview.interconditions.([handles.topview.conditionnames{perms(iii,1)} '_' handles.topview.conditionnames{perms(iii,2)}]).arearelinfra = nan(size(bregmainterpollist,1),handles.arealborders,2);
%         for jjj=1:2
%             handles.topview.interconditions.([handles.topview.conditionnames{perms(iii,1)} '_' handles.topview.conditionnames{perms(iii,2)}]).arearelsupra(find(handles.topview.conditions.(handles.topview.conditionnames{perms(iii,jjj)}).bregmasinterpol(1)==bregmainterpollist):find(handles.topview.conditions.(handles.topview.conditionnames{perms(iii,jjj)}).bregmasinterpol(end)==bregmainterpollist),:,jjj) = handles.topview.conditions.(handles.topview.conditionnames{perms(iii,jjj)}).arearelsupra_mean_interpol;
%             handles.topview.interconditions.([handles.topview.conditionnames{perms(iii,1)} '_' handles.topview.conditionnames{perms(iii,2)}]).arearelinfra(find(handles.topview.conditions.(handles.topview.conditionnames{perms(iii,jjj)}).bregmasinterpol(1)==bregmainterpollist):find(handles.topview.conditions.(handles.topview.conditionnames{perms(iii,jjj)}).bregmasinterpol(end)==bregmainterpollist),:,jjj) = handles.topview.conditions.(handles.topview.conditionnames{perms(iii,jjj)}).arearelinfra_mean_interpol;
%         end
%         handles.topview.interconditions.([handles.topview.conditionnames{perms(iii,1)} '_' handles.topview.conditionnames{perms(iii,2)}]).arearelsupra_mean = nanmean(handles.topview.interconditions.([handles.topview.conditionnames{perms(iii,1)} '_' handles.topview.conditionnames{perms(iii,2)}]).arearelsupra(bregmalevels,:,:),3);
%         handles.topview.interconditions.([handles.topview.conditionnames{perms(iii,1)} '_' handles.topview.conditionnames{perms(iii,2)}]).arearelinfra_mean = nanmean(handles.topview.interconditions.([handles.topview.conditionnames{perms(iii,1)} '_' handles.topview.conditionnames{perms(iii,2)}]).arearelinfra(bregmalevels,:,:),3);
%         handles.topview.interconditions.([handles.topview.conditionnames{perms(iii,1)} '_' handles.topview.conditionnames{perms(iii,2)}]).bregmas = bregmalist;
%         %interpolate area
%         [xxa yya] = meshgrid(1:handles.arealborders,bregmalevels);
%         [xxai yyai] = meshgrid(1:handles.arealborders,yya(1):1:yya(end)); %for rat and mice: 120µm sections, 10µm interpolation = 1unit
%         handles.topview.interconditions.([handles.topview.conditionnames{perms(iii,1)} '_' handles.topview.conditionnames{perms(iii,2)}]).arearelsupra_mean_interpol = interp2(xxa,yya,handles.topview.interconditions.([handles.topview.conditionnames{perms(iii,1)} '_' handles.topview.conditionnames{perms(iii,2)}]).arearelsupra_mean,xxai,yyai,'linear');
%         handles.topview.interconditions.([handles.topview.conditionnames{perms(iii,1)} '_' handles.topview.conditionnames{perms(iii,2)}]).arearelinfra_mean_interpol = interp2(xxa,yya,handles.topview.interconditions.([handles.topview.conditionnames{perms(iii,1)} '_' handles.topview.conditionnames{perms(iii,2)}]).arearelinfra_mean,xxai,yyai,'linear');
% 
%         %plotting difference map
%         figure(suprafig);
%         suprasubfig(iii,3) = subplot(size(perms,1),4,iii*4-1);
%         imagesc(handles.topview.conditions.(handles.topview.conditionnames{perms(iii,1)}).segmentsinterpol,handles.topview.conditions.(handles.topview.conditionnames{perms(iii,1)}).bregmasinterpol(bregmaA),topviewAB_supra);
%         hold on;
%         plot(handles.topview.interconditions.([handles.topview.conditionnames{perms(iii,1)} '_' handles.topview.conditionnames{perms(iii,2)}]).arearelsupra_mean_interpol(bregmaA,:),handles.topview.conditions.(handles.topview.conditionnames{perms(iii,1)}).bregmasinterpol(bregmaA,:),'k-');
%         plot(ones(size(bregmalist,1),1),bregmalist,'k>');
%         hold off;
% 
%         title('Relative difference');
%         set(gca,'Tag','jet');
%         freezeColors(suprasubfig(iii,3))
%         
%         figure(infrafig);
%         infrasubfig(iii,3) = subplot(size(perms,1),4,iii*4-1);
%         imagesc(handles.topview.conditions.(handles.topview.conditionnames{perms(iii,1)}).segmentsinterpol,handles.topview.conditions.(handles.topview.conditionnames{perms(iii,1)}).bregmasinterpol(bregmaA),topviewAB_infra);
%         hold on;
%         plot(handles.topview.interconditions.([handles.topview.conditionnames{perms(iii,1)} '_' handles.topview.conditionnames{perms(iii,2)}]).arearelinfra_mean_interpol(bregmaA,:),handles.topview.conditions.(handles.topview.conditionnames{perms(iii,1)}).bregmasinterpol(bregmaA,:),'k-');
%         plot(ones(size(bregmalist,1),1),bregmalist,'k>');
%         hold off;
% 
%         title('Relative difference');
%         set(gca,'Tag','jet');
%         freezeColors(infrasubfig(iii,3))
%         
%         %plot t-statistic
%         figure(suprafig);
%         suprasubfig(iii,4) = subplot(size(perms,1),4,iii*4);
%         imagesc(handles.topview.conditions.(handles.topview.conditionnames{perms(iii,1)}).segmentsinterpol,handles.topview.conditions.(handles.topview.conditionnames{perms(iii,1)}).bregmasinterpol(bregmaA),topviewABpval_supra.*sign(topviewAB_supra))
%         colormap(stats_cmap);
%         set(gca,'Clim',[-0.05 0.05]);
%         set(gca,'Tag','stats_cmap');
%         title('T-statistic B-A');
%         freezeColors(suprasubfig(iii,4));
%         
%         figure(infrafig);
%         infrasubfig(iii,4) = subplot(size(perms,1),4,iii*4);
%         imagesc(handles.topview.conditions.(handles.topview.conditionnames{perms(iii,1)}).segmentsinterpol,handles.topview.conditions.(handles.topview.conditionnames{perms(iii,1)}).bregmasinterpol(bregmaA),topviewABpval_infra.*sign(topviewAB_infra))
%         colormap(stats_cmap);
%         set(gca,'Clim',[-0.05 0.05]);
%         set(gca,'Tag','stats_cmap');
%         title('T-statistic B-A');
%         freezeColors(infrasubfig(iii,4));
%         
%         %plot t-statistic on difference map
%         figure(suprafig);
%         subplot(size(perms,1),4,iii*4-1);
%         ttestval = topviewABpval_supra;
%         ttnew = zeros(size(ttestval));
%         ttnew(ttestval < 0.001) = 3;
%         ttnew(ttestval >= 0.001 & ttestval < 0.01) = 2;
%         ttnew(ttestval >= 0.01 & ttestval < 0.05) = 1;
%         ttnew(ttestval >= 0.05) = 0;
%         hold on;
%         [C hcontour] = contour(handles.topview.conditions.(handles.topview.conditionnames{perms(iii,1)}).segmentsinterpol,handles.topview.conditions.(handles.topview.conditionnames{perms(iii,1)}).bregmasinterpol(bregmaA),ttnew,3,'k');
%         hold off;
%         
%         figure(infrafig);
%         subplot(size(perms,1),4,iii*4-1);
%         ttestval = topviewABpval_infra;
%         ttnew = zeros(size(ttestval));
%         ttnew(ttestval < 0.001) = 3;
%         ttnew(ttestval >= 0.001 & ttestval < 0.01) = 2;
%         ttnew(ttestval >= 0.01 & ttestval < 0.05) = 1;
%         ttnew(ttestval >= 0.05) = 0;
%         hold on;
%         [C hcontour] = contour(handles.topview.conditions.(handles.topview.conditionnames{perms(iii,1)}).segmentsinterpol,handles.topview.conditions.(handles.topview.conditionnames{perms(iii,1)}).bregmasinterpol(bregmaA),ttnew,3,'k');
%         hold off;
%     end
%     set(suprasubfig(:), 'Uicontextmenu',cmenusupra);
%     set(suprasubfig(:),'Ylim',[min(handles.bregmasupra(:,1)) max(handles.bregmasupra(:,2))]);
%     set(infrasubfig(:), 'Uicontextmenu',cmenuinfra);
%     set(infrasubfig(:),'Ylim',[min(handles.bregmainfra(:,1)) max(handles.bregmainfra(:,2))]);
end

function savetopview(src,evt,handles)
    %get real handles
    handles = get(handles.fig_ISH_setup,'UserData');
    handles.topview.savedate = clock;
    TOPVIEW = handles.topview;
    setuptable = handles.setuptable;
    fprintf('Saving...\n');
    if(isfield(handles,'ROI'))
        ROI = handles.ROI;
        save([handles.savepath char(handles.savename) '.mat'],'setuptable','ROI','TOPVIEW');
    else
        save([handles.savepath char(handles.savename) '.mat'],'setuptable','TOPVIEW');
    end
    fprintf('Project and Topview saved as %s\n',char(handles.savename));
end
        