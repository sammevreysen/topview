function [x,y] = intersection(xs,ys,x1,y1,x2,y2,linespec)
    p = [(y2-y1)/(x2-x1) (x2*y1-x1*y2)/(x2-x1)];
    tri = delaunay(xs,ys);
    ints = 1000;
    xi = x1:(x2-x1)/ints:x2;
    
    Dind = zeros(1,length(xi));
    D = zeros(1,length(xi));
    for i=1:length(xi)
        Dind(i) = dsearch(xs,ys,tri,xi(i),polyval(p,xi(i)));
        D(i) = sqrt((xs(Dind(i))-xi(i))^2+(ys(Dind(i))-polyval(p,xi(i)))^2);
    end
    x = xs(Dind(find(min(D) == D,1)));
    y = ys(Dind(find(min(D) == D,1)));
    
    if(~strcmp(linespec,''))
        if(x1 < x2)
            plot(x1:0.1:x2,polyval(p,x1:0.1:x2),linespec);
        else
            plot(x2:0.1:x1,polyval(p,x2:0.1:x1),linespec);
        end
        plot(x,y,'bd');
    end