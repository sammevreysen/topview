function relborders = relativearealborders(x,y,xarealborders,yarealborders,allrasterxy,rastersegments,slicename)
    rasterxy = allrasterxy(any(~isnan(allrasterxy),2),:);
    pxy = unique(sortrows([x y;rasterxy]),'rows');
    pxy = pxy([diff(pxy(:,1)); 1] ~= 0,:);
    len_area = zeros(size(xarealborders,1),1);
    pidrasta = find(all(ismember(pxy,rasterxy(1,:)),2),1);
    if(isempty(pidrasta))
        tmp = max(abs(pxy - repmat(rasterxy(1,:),size(pxy,1),1)),[],2);
        pidrasta = find(min(tmp) == tmp);
        warning('Relativearealborders: approximation of areal border');
    end
    pidrastb = find(all(ismember(pxy,rasterxy(2,:)),2),1);
    if(isempty(pidrastb))
        tmp = max(abs(pxy - repmat(rasterxy(2,:),size(pxy,1),1)),[],2);
        pidrastb = find(min(tmp) == tmp);
        warning('Relativearealborders: approximation of areal border');
    end
    pidraste = find(all(ismember(pxy,rasterxy(end,:)),2),1);
    if(isempty(pidraste))
        tmp = max(abs(pxy - repmat(rasterxy(end,:),size(pxy,1),1)),[],2);
        pidraste = find(min(tmp) == tmp);
        warning('Relativearealborders: approximation of areal border');
    end
    %total length
    pxy_area = pxy(pidrasta:pidraste,:);
    rastot = arclength(pxy_area(:,1),pxy_area(:,2));
    
    for i=1:size(xarealborders,1)
        pidb = find(all(ismember(pxy,[xarealborders(i) yarealborders(i)]),2),1);
        if(isempty(pidb))
            warning('MATLAB:crop_curve','pidb not found, using nearest point.');
%             dt = delaunay(pxy(:,1),pxy(:,2));
            dt = DelaunayTri(x,y);
            [pidb,d] = nearestNeighbor(dt,xarealborders(i),yarealborders(i));
            %pidb = dsearch(pxy(:,1),pxy(:,2),dt,xarealborders(i),yarealborders(i));
        end
        if(pidrasta == pidb)
            len_area(i) = 0;
        else
            if(pidrasta < pidb)
                pxy_area = pxy(pidrasta:pidb,:);
                sig = 1;
            else
                pxy_area = pxy(pidb:pidrasta,:);
                sig = -1;
            end
            if(isempty(pxy_area))
                error(['pxy_area is empty in slice: ' slicename]);
            end
            tic;
            len_area(i) = sig * arclength(pxy_area(:,1),pxy_area(:,2));
            tics(i) = toc;
            
        end
        pidrasta = pidb;
    end
    %fprintf('%d\n',tics(:));
    if(pidrasta == pidrastb)
        error('wtf?');
    end
    if(size(pxy(pidrasta:pidrastb,1)) == [0 1])
        %removed the rasterx in pxy instead of a x: substitute
        pxy(ismember(pxy(:,1),rasterxy(end,1)),:) = rasterxy(end,:);
        pidrastb = find(all(ismember(pxy,rasterxy(end,:)),2),1);
    end
    %pidrasta = find(all(ismember(pxy,rasterxy(1,:)),2),1);
    %raslen = arclength(pxy(pidrasta:pidrastb,1),pxy(pidrasta:pidrastb,2),'s');
    raslen = sum(len_area);
    
    
    %first valid segment
    firstvalidsegment = find(~isnan(allrasterxy(:,1)),1,'first')-1;
    if(firstvalidsegment > 0)
        warning('First valid segment greater than 0');
        relborders = ((cumsum(len_area)./raslen)+firstvalidsegment)'.*rastersegments;
    else
        relborders = (cumsum(len_area)./rastot)'.*rastersegments;
    end
    
    