
% by Tolga Birdal
%{
    This file contains both the implementation and the test function for
    contour smoothing. So to test, just press F5.
    The contour smoothing is done by projecting all the contour points 
    onto the local regression line. The radius defines the number of points
    on each side of the contour, which will contribute to the computation
    of the local regression line. The higher the number of points, the
    smoother the curve. 
    
    Because of the linear nature of fitting, when too much smoothing is 
    desired,  the algorithm loses important features such as corners, and
    confuses in such critical regions.

    Actually, the algorithm is fully parallelizable. If a parallel
    implemtation is desired the main loop in smooth_contours function can
    easily be parallelized.

    You can check further details in the comments.
%}
function [xsout,ysout] = draw_curve(h,pixpermm)
hold on;
userdata.click = 0;
userdata.range = 21;
userdata.alpha = 5;
userdata.title = get(get(gca,'Title'),'String');
set(gcf, 'UserData',userdata);
set(gcf, 'WindowButtonMotionFcn', @mouseMove);
set(gcf, 'WindowButtonDownFcn', @mouseDownClick);
set(gcf, 'WindowButtonUpFcn', @mouseUpClick);
uiwait(gcf);
set(gcf, 'KeyPressFcn', []);
userdata = get(gcf,'UserData');
xs = userdata.xs;
ys = userdata.ys;
xsout = [];
ysout = [];
% %interpolate with spline
% [xs,ia,ic] = unique(xs);
% ys = ys(ia);
% for i=1:size(xs,1)-1
%    xis = xs(i):(xs(i+1)-xs(i))/50:xs(i+1);
%    yis = interp1([xs(i) xs(i+1)],[ys(i) ys(i+1)],xis);
%    xsout = [xsout;xis'];
%    ysout = [ysout;yis'];
% end

%interpolation at 5µm resolution
xys = interparc(ceil(sum(sqrt(sum(diff([xs ys],1,1).^2,2)))/pixpermm/0.005),xs,ys);
xsout = xys(:,1);
ysout = xys(:,2);
set(userdata.hsmooth,'XData',xys(:,1),'YData',xys(:,2));
end

function keyPress(object, event)
    if(strcmp(event.Key,'backspace'))
        userdata = get(gcf,'UserData');
        delete(userdata.h);
        delete(userdata.hsmooth);
        userdata.xs = [];
        userdata.ys = [];
        userdata.click = 0;
        userdata.firstclick = 0;
        set(gcf,'UserData',userdata);
        set(gcf, 'WindowButtonMotionFcn', @mouseMove);
        set(gcf, 'WindowButtonDownFcn', @mouseDownClick);
        set(gcf, 'WindowButtonUpFcn', @mouseUpClick);
        set(gcf, 'KeyPressFcn', []);
        title(userdata.title);
    elseif(strcmp(event.Key,'uparrow'))
        userdata = get(gcf,'UserData');
        if(userdata.range < 200)
            userdata.range = userdata.range + 1;
            xdata = get(userdata.h,'XData');
            ydata = get(userdata.h,'YData');
            [xs ys] = smooth_contours(xdata,ydata,userdata.range,userdata.alpha);
            userdata.xs = xs;
            userdata.ys = ys;
            set(userdata.hsmooth,'XData',userdata.xs,'YData',userdata.ys);
            title(sprintf('Current smooth range is %d and \alpha is %0.1f. Use up and down arrows to change range, left and right arrows to change alpha. Use escape to confirm.',userdata.range,userdata.alpha));
            set(gcf,'UserData',userdata);
        else
            title('Maximal smooth range is reached. Use up and down arrows to change range, left and right arrows to change alpha. Use escape to confirm.');
        end
    elseif(strcmp(event.Key,'downarrow'))
        userdata = get(gcf,'UserData');
        if(userdata.range > 0.05)
            userdata.range = userdata.range - 1;
            xdata = get(userdata.h,'XData');
            ydata = get(userdata.h,'YData');
            [xs ys] = smooth_contours(xdata,ydata,userdata.range,userdata.alpha);
            userdata.xs = xs;
            userdata.ys = ys;
            set(userdata.hsmooth,'XData',userdata.xs,'YData',userdata.ys);
            title(sprintf('Current smooth range is %d and \alpha is %0.1f. Use up and down arrows to change range, left and right arrows to change alpha. Use escape to confirm.',userdata.range,userdata.alpha));
            set(gcf,'UserData',userdata);
        else
            title('Minimal smooth range is reached. Use up and down arrows to change range, left and right arrows to change alpha. Use escape to confirm.');
        end
    elseif(strcmp(event.Key,'leftarrow'))
        userdata = get(gcf,'UserData');
        if(userdata.alpha > 0.5)
            userdata.alpha = userdata.alpha - 0.5;
            xdata = get(userdata.h,'XData');
            ydata = get(userdata.h,'YData');
            [xs ys] = smooth_contours(xdata,ydata,userdata.range,userdata.alpha);
            userdata.xs = xs;
            userdata.ys = ys;
            set(userdata.hsmooth,'XData',userdata.xs,'YData',userdata.ys);
            title(sprintf('Current smooth range is %d and \alpha is %0.1f. Use up and down arrows to change range, left and right arrows to change alpha. Use escape to confirm.',userdata.range,userdata.alpha));
            set(gcf,'UserData',userdata);
        else
            title('Minimal alpha is reached. Use up and down arrows to change range, left and right arrows to change alpha. Use escape to confirm.');
        end
    elseif(strcmp(event.Key,'rightarrow'))
        userdata = get(gcf,'UserData');
        if(userdata.alpha < 20)
            userdata.alpha = userdata.alpha + 0.5;
            xdata = get(userdata.h,'XData');
            ydata = get(userdata.h,'YData');
            [xs ys] = smooth_contours(xdata,ydata,userdata.range,userdata.alpha);
            userdata.xs = xs;
            userdata.ys = ys;
            set(userdata.hsmooth,'XData',userdata.xs,'YData',userdata.ys);
            title(sprintf('Current smooth range is %d and \alpha is %0.1f. Use up and down arrows to change range, left and right arrows to change alpha. Use escape to confirm.',userdata.range,userdata.alpha));
            set(gcf,'UserData',userdata);
        else
            title('Maximal alpha is reached. Use up and down arrows to change range, left and right arrows to change alpha. Use escape to confirm.');
        end
    elseif(strcmp(event.Key,'escape'))
        uiresume(gcf);
    end
    

end

function mouseDownClick(object, eventdata)
    userdata = get(gcf,'UserData');
    userdata.click = 1;
    C = get(gca, 'CurrentPoint');
    h = plot(C(1,1),C(1,2),'r-');
    userdata.h = h;
    userdata.firstclick = 1;
    set(gcf,'UserData',userdata);
    
end

function mouseUpClick(object, eventdata)
    userdata = get(gcf,'UserData');
    userdata.click = 0;
    set(gcf,'UserData',userdata);
    xdata = get(userdata.h,'XData');
    ydata = get(userdata.h,'YData');
    [xs ys] = smooth_contours(xdata,ydata,userdata.range,userdata.alpha);
    userdata.xs = xs;
    userdata.ys = ys;
    set(userdata.h,'Visible','off');
    userdata.hsmooth = plot(xs,ys,'b-');
    set(gcf,'UserData',userdata);
    set(gcf, 'WindowButtonMotionFcn', []);
    set(gcf, 'WindowButtonDownFcn', []);
    set(gcf, 'WindowButtonUpFcn', []);
    set(gcf, 'KeyPressFcn', @keyPress);
    title(sprintf('Current smooth range is %d. Use up and down arrows to change and escape to confirm.',userdata.range));
end

function mouseMove(object, eventdata)
    C = get (gca, 'CurrentPoint');    
    userdata = get(gcf,'UserData');
    if(userdata.click == 1)
        xdata = get(userdata.h,'XData');
        ydata = get(userdata.h,'YData');
        if(userdata.firstclick == 1)
            set(userdata.h,'XData',C(1,1),'YData',C(1,2));
            userdata.firstclick = 0;
            set(gcf,'Userdata',userdata);
        else
            set(userdata.h,'XData',[xdata C(1,1)],'YData',[ydata C(1,2)]);
        end
    end
end

% The actual computation
function [Xs Ys]=smooth_contours(X, Y, Radius, alpha)

Xs=zeros(length(X),1);
Ys=zeros(length(X),1);

%limit radius to size X
%Radius = min(21,size(X,1));

% copy out-of-bound points as they are
Xs(1:Radius)=X(1:Radius);
Ys(1:Radius)=Y(1:Radius);
Xs(length(X)-Radius:end)=X(length(X)-Radius:end);
Ys(length(X)-Radius:end)=Y(length(X)-Radius:end);

% obtain the bounding box
maxX=max(max(X));
minX=min(min(X));
maxY=max(max(Y));
minY=min(min(Y));

% smooth now
for i=Radius+1:length(X)-Radius
    ind=(i-Radius:i+Radius);
    xLocal=X(ind);
    yLocal=Y(ind);
    
    % local regression line
    %p=polyfit(xLocal,yLocal,1);
    [a b c] = wols(xLocal,yLocal,gausswin(length(xLocal),alpha));
    p(1)=-a/b;
    p(2)=-c/b;
    
    % project point on local regression line
    [x2, y2]=project_point_on_line(p(1), p(2), X(i), Y(i));
    
    % check erronous smoothing
    % points should stay inside the bounding box
    if (x2>=minX && y2>minY && x2<=maxX && y2<=maxY)
        Xs(i)=x2;
        Ys(i)=y2;
    else
        Xs(i)=X(i);
        Ys(i)=Y(i);
    end
end

end

% Projects the point (x1, y1) onto the line defined as y=m1*x+b1
function [x2, y2]=project_point_on_line(m1, b1, x1, y1)

m2=-1./m1;
b2=-m2*x1+y1;
x2=(b2-b1)./(m1-m2);
y2=m2.*x2+b2;

end

function [a b c] = wols(x,y,w)
% Weighted orthogonal least squares fit of line a*x+b*y+c=0 to a set of 2D points with coordiantes given by x and y and weights w
n = sum(w);
meanx = sum(w.*x)/n;
meany = sum(w.*y)/n;
x = x - meanx;
y = y - meany;
y2x2 = sum(w.*(y.^2 - x.^2));
xy = sum(w.*x.*y);
alpha = 0.5 * acot(0.5 * y2x2 / xy) + pi/2*(y2x2 > 0);
%if y2x2 > 0, alpha = alpha + pi/2; end
a = sin(alpha);
b = cos(alpha);
c = -(a*meanx + b*meany);
end