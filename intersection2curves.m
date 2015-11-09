function [xout,yout] = intersection2curves(xs,ys,x,y)
    xi = max(xs(1),x(1)):0.01:min(xs(end),x(end));          % 1:n
    [xssorted, index] = sort(xs);
    yssorted = ys(index);
    uniq = [true, diff(xssorted)' ~= 0];
    yis = interp1(xssorted(uniq), yssorted(uniq), xi);
    yi = interp1(x,y,xi);
    substract = abs(yis-yi);
    zerocrossing = substract < 0.1;                       % 1:n
    %split out for different crossings
    zerodiff = diff(zerocrossing);                          % 1:n-1
    zeroboundries = [find(zerodiff > 0)' find(zerodiff < 0)'];
    [xsidx ~] = meshgrid(1:size(xi,2),1:size(zeroboundries,1)); %1:n
    zerowindow = double(bsxfun(@(a,b) a > b,xsidx,zeroboundries(:,1)) & bsxfun(@(a,b) a <= b,xsidx,zeroboundries(:,2)));
    zerowindow(zerowindow == 0) = NaN;
    
    tri = delaunay(xs,ys);
    if(yi(1)<yi(end))
        [zerop zeropxid] = min(substract.*zerowindow(end,:));
    else
        [zerop zeropxid] = min(substract.*zerowindow(1,:));
    end
    Dind = dsearch(xs,ys,tri,xi(zeropxid),yis(zeropxid));
    
    xout = xs(Dind);
    yout = ys(Dind);
    

%     Dind = arrayfun(@(x,y) dsearch(xs,ys,tri,x,y),x(:),y(:));
%     D = sqrt((xs(Dind)-x)^2+(ys(Dind)-y)^2);
%     x = xs(Dind(find(min(D) == D,1)));
%     y = ys(Dind(find(min(D) == D,1)));
    
  