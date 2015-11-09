function [xs,ys]=crop_curve(x,y,xa,ya,xb,yb)
    [x ia ic] = unique(x);
    y = y(ia);
    xy = [x y];
    pida = find(all(ismember(xy,[xa ya]),2),1);
    pidb = find(all(ismember(xy,[xb yb]),2),1);
    if(isempty(pida) || isempty(pidb))
        warning('MATLAB:crop_curve','Outer borders not found, using nearest point.');
        if(strcmp(version('-release'),'2009b'))
            dt = delaunay(x,y);
        else
            dt = DelaunayTri(x,y);
        end
        if(isempty(pida))
            if(strcmp(version('-release'),'2009b'))
                pida = dsearch(x,y,dt,xa,ya);
            else
                [pida,d] = nearestNeighbor(dt,xa,ya);
            end
            
        end
        if(isempty(pidb))
            if(strcmp(version('-release'),'2009b'))
                pidb = dsearch(x,y,dt,xb,yb);
            else
                [pidb,d] = nearestNeighbor(dt,xb,yb);
            end
     
        end
    end
    xs = x(pida:pidb);
    ys = y(pida:pidb);
    [xs ia ic] = unique(xs);
    ys = ys(ia);