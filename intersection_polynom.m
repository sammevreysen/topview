function [x,y] = intersection_polynom(x1,y1,x2,y2,secp,linespec)
    p = [(y2-y1)/(x2-x1) (x2*y1-x1*y2)/(x2-x1)];
    pintersec = secp - [0 p];
    root = roots(pintersec);
    x = root(2);
    y = polyval(secp,x);
    
    if(~strcmp(linespec,''))
        if(x1 < x2)
            plot(x1:0.1:x2,polyval(p,x1:0.1:x2),'b-');
        else
            plot(x2:0.1:x1,polyval(p,x2:0.1:x1),'b-');
        end
        plot(x,y,'bd');
    end