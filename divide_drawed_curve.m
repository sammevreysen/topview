function [Zx,Zy] = divide_drawed_curve(x,y,xa,ya,xb,yb,step,ints2)
    % A,B,C coeffs van integraal; xa en xb = grenzen waarbinnen je wil werken;
    % ints = # intervallen integratie (zoveel
    % mogelijk als haalbaar, ordegrootte 1000), ints2 = # gelijke lengte
    % parabool intervallen (25 of 26-tal)
    xy = [x y];
    pida = find(all(ismember(xy,[xa ya]),2));
    pidb = find(all(ismember(xy,[xb yb]),2));
    xs = x(pida:step:pidb);
    ys = y(pida:step:pidb);
    
    M = zeros(1,size(xs,1)-1);
%     T = zeros(1,size(xs,1)-1);
    for i = 1:size(xs,1)-1
        M(i) = sqrt((ys(i+1)-ys(i))^2+(xs(i+1)-xs(i))^2);
%         T(i) = xs(i)-xs(1);
    end
    T = 1:size(xs,1)-1;
    I = zeros(1,size(xs,1)-1);
    I(1) = M(1);
    for i = 2:size(xs,1)-1
        I(i) = M(i) + I(i-1);
    end
    J = transpose(I);
    D = transpose(T);
    
    jj(1,1)=0;
    for i = 1:1:ints2
        jj(i+1,1) = jj(i,1) + J(end)/ints2;
    end
    Zind = spline(J,D,jj);
    
    %apply second spline to window around Zind to get Zy
    for i=1:length(Zind)
        Zy = spline(xs(floor(Zind(i))-5:ceil(Zind(i)+5)),ys,Zx);
    
        
    end
    %control plots
%     figure();
%     plot(D,J,'b-');
%     hold on;
%     plot(Zindex,0,'ro');

end