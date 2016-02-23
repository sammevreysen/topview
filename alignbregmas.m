function out = alignbregmas(setuptable)
    hmain = figure('Units','normalized','OuterPosition',[0 0 1 1],'MenuBar','none','ToolBar','none','DockControls','off');
%     hprev1 = figure('Units','normalized','OuterPosition',[0.5 0.5 0.5 0.5],'MenuBar','none','ToolBar','none','DockControls','off');
%     hprev2 = figure('Units','normalized','OuterPosition',[0.5 0 0.5 0.5],'MenuBar','none','ToolBar','none','DockControls','off');
    
    figure(hmain);
    hold on;
    setuptable = sortrows(setuptable,[1 2 3]);
    conditions = unique(setuptable(:,1));
    markers = {'s','o','d','p','h','x','*'};
    a = 1;
    for i = 1:length(conditions)
        condition = conditions{i};
        mice = unique(setuptable(strcmp(setuptable(:,1),condition),2));
        for j = 1:length(mice)
            mouse = mice{j};
            marker = markers{mod(find(strcmp(conditions,condition))-1,length(markers))+1};
            info{a,1} = cell2mat(cellfun(@(x) x.bregma,setuptable(strcmp(setuptable(:,2),mouse),5),'UniformOutput',false));
            info{a,2} = condition;
            info{a,3} = mouse;
            info{a,5} = plot(repmat(a,1,length(info{a,1})),info{a,1},'-','Marker',marker,'HitTest','off');
            a = a + 1;
        end
    end
    xlim([0 a+1]);
%    figure(hprev1)
   rawbregmas = cell2mat(info(:,1));
%    hs = histcounts(rawbregmas,min(rawbregmas):max(rawbregmas));
%    hs = hs./numel(rawbregmas);
%    bar(hs);
   
   
%    figure(hprev2)
   for b=0:9
%        subplot(5,5,b)
       hp{b+1} = hist(rawbregmas,min(rawbregmas)+b-10:10:max(rawbregmas)+10);
       hp{b+1} = hp{b+1}./numel(rawbregmas);
%        bar(hp{b});
   end
   stds = cellfun(@std,hp);
%    figure(hprev2)
%    plot(stds);
   offset = find(min(stds)==stds,1,'first')-1;
   fixedbregmas = (min(rawbregmas)+offset-10:10:max(rawbregmas)+10)';
   figure(hmain)
   plot(xlim,repmat(fixedbregmas',2,1),'k:');
   set(hmain,'UserData',fixedbregmas);
   
   for i=1:size(info,1)
       info{i,4} = fixedbregmas(logical(hist(info{i,1},fixedbregmas)));
       marker = markers{mod(find(strcmp(conditions,info{i,2}))-1,length(markers))+1};
       color = 'k';%get(hplot(i),'Color');
       info{i,6} = plot(repmat(i,1,length(info{i,4})),info{i,4},'Marker',marker,'Color',color,'MarkerFaceColor',color,'LineStyle','none','PickableParts','all','ButtonDownFcn',@selline);
       set(info{i,6},'UserData',i);
       
   end
   set(hmain,'UserData',info);
   hm = uimenu(hmain,'Label','Save');
   hm2 = uimenu(hm,'Label','Save corrected Bregma levels','Callback',@gotoend);
   uiwait(hmain);
   out = setuptable;
   for i=1:size(out,1)
       for j=1:size(info,1)
           if(strcmp(out{i,1},info{j,2}) && strcmp(out{i,2},info{j,3}))
               out{i,5}.bregma = info{j,4}(info{j,1}==out{i,5}.bregma);
           end
       end
   end
   close(hmain);
end
    
function gotoend(object,event)
    uiresume(gcf);
end
    
function selline(object,event)
    info = get(gcf,'UserData');
    id = get(gco,'UserData');
    lw = get(info{id,5},'LineWidth');
    if(lw == 2)
        set(info{id,5},'LineWidth',1);
        set(gcf, 'WindowKeyPressFcn', []);
    else
        set(info{id,5},'LineWidth',2);
        set(gcf, 'WindowKeyPressFcn', {@keyPress,id});
    end
end

function keyPress(object,event,id)
    info = get(gcf,'UserData');
    if(strcmp(event.Key,'uparrow'))
        info{id,4} = info{id,4}+10;
    elseif(strcmp(event.Key,'downarrow'))
        info{id,4} = info{id,4}-10;
    end
    set(info{id,6},'YData',info{id,4});
    set(gcf,'Userdata',info);
end

        
       
       
       
       
       
       
       
       
       