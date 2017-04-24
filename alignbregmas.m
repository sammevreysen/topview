function out = alignbregmas(in,gridsizevar)
    hmain = figure('Units','normalized','OuterPosition',[0 0 1 1],'MenuBar','none','ToolBar','none','DockControls','off');
%     hprev1 = figure('Units','normalized','OuterPosition',[0.5 0.5 0.5 0.5],'MenuBar','none','ToolBar','none','DockControls','off');
%     hprev2 = figure('Units','normalized','OuterPosition',[0.5 0 0.5 0.5],'MenuBar','none','ToolBar','none','DockControls','off');
    global cancel;
    global setuptable;
    global info;
    cancel = 0;
    setuptable = in;
    
    global gridsize
    gridsize = gridsizevar*100; %match precision of bregmas
    
    paintall();
    
    uiwait(hmain);
    
    out = setuptable;
    if(~cancel)
        for i=1:size(out,1)
            for j=1:size(info,1)
                if(strcmp(out{i,1},info{j,2}) && strcmp(out{i,2},info{j,3}))
                    out{i,5}.bregma = info{j,4}(info{j,1}==out{i,5}.bregma);
                end
            end
        end
    end
    try
        close(hmain);
    catch
        
    end
end

function paintall()
    global setuptable;
    global info;
    global gridsize;
    info = {};
    hold on;
    setuptable = sortrows(setuptable,[1 2 3]);
    if(~isfield(setuptable{1,5},'bregma'))
        for i=1:size(setuptable,1)
            tmp = regexp(setuptable{i,3},'[_-]\d{3}.','match','once');
            setuptable{i,5}.bregma = str2num(tmp(2:end-1));
        end
    end
    %check for duplicates
    files = arrayfun(@(x,y,z) [x{:} '-' y{:} '-' z{:}],setuptable(:,1),setuptable(:,2),setuptable(:,3),'UniformOutput',false);
    if(length(unique(files)) ~= length(files))
        warning('%d duplicates has been removed.',length(files)-length(unique(files)))
        [~,id] = unique(files);
        setuptable = setuptable(id,:);
    end
    
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
            %check duplicates
            [~,id]=unique(info{a,1});
            dbs = ~ismember(1:length(info{a,1}),id);
            if(any(dbs))
                warning('Duplicates found for animal %s:',mouse)
                dbsid = find(dbs);
                for k=dbsid
                    fprintf('bregma %d found in lines %s\n',info{a,1}(k),num2str(find(info{a,1}==info{a,1}(k))'));
                end
                
            end
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
        hp{b+1} = hist(rawbregmas,min(rawbregmas)+b-10:gridsize:max(rawbregmas)+10);
        hp{b+1} = hp{b+1}./numel(rawbregmas);
        %        bar(hp{b});
    end
    stds = cellfun(@std,hp);
    %    figure(hprev2)
    %    plot(stds);
    offset = find(min(stds)==stds,1,'first')-2;
    fixedbregmas = (min(rawbregmas)+offset-10:gridsize:max(rawbregmas)+10)';
    fixededges = (min(rawbregmas)+offset-15:gridsize:max(rawbregmas)+15)';
    plot(xlim,repmat(fixedbregmas',2,1),'k:','LineWidth',0.25);
    set(gcf,'UserData',fixedbregmas);
    
    for i=1:size(info,1)
        [N,~,bin] = histcounts(info{i,1},fixededges);
        if(any(N>1))
            for j=1:length(N)
                if(N(j)>1)
                    ids = find(bin==j);
                    dist = info{i,1}(bin==j)-fixedbregmas(j);
                    [~,maxid] = max(abs(dist));
                    bin(ids(maxid)) = bin(ids(maxid))+sign(dist(maxid));
                end
            end
        end
        info{i,4} = fixedbregmas(bin);
        
        marker = markers{mod(find(strcmp(conditions,info{i,2}))-1,length(markers))+1};
        color = 'k';%get(hplot(i),'Color');
        info{i,6} = plot(repmat(i,1,length(info{i,4})),info{i,4},'Marker',marker,'Color',color,'MarkerFaceColor',color,'LineStyle','none','PickableParts','all','ButtonDownFcn',@selline);
        set(info{i,6},'UserData',i);
        
    end
    xlabel('Animals');
    ylabel('Bregma (x10^{-2} mm)');
    title('Alignment of the slices across all animals');
    set(gcf,'UserData',info);
    hm = uimenu(gcf,'Label','Save');
    hm2 = uimenu(hm,'Label','Save corrected Bregma levels','Callback',@gotoend);
    hm3 = uimenu(hm,'Label','Cancel','Callback',@gotocancel);
    hm4 = uimenu(gcf,'Label','Reset');
    hm5 = uimenu(hm4,'Label','Reset using filenames','Callback',@reset);
    hm6 = uimenu(gcf,'Label','Print');
    hm7 = uimenu(hm6,'Label','Save as PDF...','Callback',@saveFigAsPDF);
end
    
function gotoend(object,event)
    global cancel;
    cancel = 0;
    uiresume(gcf);
end

function gotocancel(object,event)
    global cancel;
    cancel = 1;
    uiresume(gcf);
end

function reset(object,event)
    %get bregma from filename
    global setuptable;
    for i=1:size(setuptable,1)
        tmp = regexp(setuptable{i,3},'[_-]\d{3}.','match','once');
        setuptable{i,5}.bregma = str2num(tmp(2:end-1));
    end
    clf;
    paintall();
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
    global gridsize;
    info = get(gcf,'UserData');
    if(strcmp(event.Key,'uparrow'))
        info{id,4} = info{id,4}+gridsize;
    elseif(strcmp(event.Key,'downarrow'))
        info{id,4} = info{id,4}-gridsize;
    end
    set(info{id,6},'YData',info{id,4});
    set(gcf,'Userdata',info);
end

        
       
       
       
       
       
       
       
       
       