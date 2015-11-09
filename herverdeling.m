function [pt,arealrel] = herverdeling(x,y,rasterxy,fixedrasterline,arealxy,pivot,arealrel)

    %crop curve
    [x y] = crop_curve(x,y,rasterxy(1,1),rasterxy(1,2),rasterxy(end,1),rasterxy(end,2));
    %build raster table with areal border
    rasterarealxy = unique(sortrows([rasterxy;arealxy(pivot,:)]),'rows');
    %build table with all discrete points xy combined with the raster
    %coordinates
    allxy = unique(sortrows([x y;rasterxy]),'rows');
    
    %calculate arc length between rasterline and areal border
    pidarea_allxy = find(all(ismember(allxy,arealxy(pivot,:)),2),1);
    if(isempty(pidarea_allxy))
        allxy = unique(sortrows([allxy;arealxy(pivot,:)]),'rows');
        pidarea_allxy = find(all(ismember(allxy,arealxy(pivot,:)),2),1);
    end
    pidrasterline_allxy = find(all(ismember(allxy,rasterxy(fixedrasterline+1,:)),2),1);
    
    if(pidarea_allxy == pidrasterline_allxy)
        %raster is already positioned on right place
        pt = rasterxy;
    else
        if(pidarea_allxy < pidrasterline_allxy)
            pids = pidarea_allxy:pidrasterline_allxy;
            diffsign = -1;
        else
            pids = pidrasterline_allxy:pidarea_allxy;
            diffsign = 1;
        end
        if(size(allxy(pids,:),1) == 0)
            error('wtf?');
        end
        arclen_area_pivot = arclength(allxy(pids,1),allxy(pids,2),'s');

        %calculate arc length between the two adjacent raster lines surrounding
        %the areal pivot border
        pidarea = find(all(ismember(rasterarealxy,arealxy(pivot,:)),2),1);
        pid1 = find(all(ismember(allxy,rasterarealxy(pidarea-1,:)),2),1);
        pid2 = find(all(ismember(allxy,rasterarealxy(pidarea+1,:)),2),1);
        arclen_raster = arclength(allxy(pid1:pid2,1),allxy(pid1:pid2,2),'s');

        %ratio of pivot
        ratpivot = diffsign * (arclen_area_pivot/arclen_raster);

        rastersegments = size(rasterxy,1)-1; %segments = rasterlines - 1

        t = linspace(0,1,rastersegments+1)+ratpivot/rastersegments; %equal spaced points between 0 and 1 shifted by pivot ratio in respect to distance between the equal spaced points
        arealrel = arealrel-ratpivot;
        pt = repmat(NaN,size(rasterxy));

        pt(t >= 0 & t <= 1,:) = interparc(t(t >= 0 & t <= 1),x,y);
    %     arccontrol = arclength(xy(pidarea_allxy:,1);
    
    end

end