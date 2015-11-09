function [areax, areay] = setarealborders_polynom(p,x,n)
    y = polyval(p,x);
    %plot(x,y);
    hold on;
    h = plot(x(1),y(1),'rd');
    userdata.h = h;
    userdata.xa = x(1);
    userdata.xb = x(end);
    userdata.y = y;
    userdata.p = p;
    userdata.list = [];
    userdata.n = n;
    set(gcf, 'UserData',userdata);
    set(gcf, 'WindowButtonMotionFcn', @mouseMove);
    set(gcf, 'WindowButtonDownFcn', @mouseClick);
    set(gcf, 'KeyPressFcn', @keyPress);
    uiwait(gcf);
    userdata = get(gcf, 'UserData');
    areax = userdata.list(:,1);
    areay = userdata.list(:,2);

function mouseMove (object, eventdata)
userdata = get(gcf,'UserData');
C = get (gca, 'CurrentPoint');
if(C(1,1) > userdata.xa && C(1,1) < userdata.xb)
    set(userdata.h,'XData',C(1,1),'YData',polyval(userdata.p,C(1,1)));
end

function mouseClick(object, eventdata)
    userdata = get(gcf,'UserData');    
    X = get(userdata.h,'XDATA');
    Y = get(userdata.h,'YDATA');
    userdata.list = [userdata.list; X Y userdata.h];
    set(userdata.h,'MarkerEdgeColor','b');
    if(size(userdata.list,1) < userdata.n) 
        userdata.h = plot(X,Y,'rd');
        set(gcf,'UserData',userdata);
    else
        set(gcf,'UserData',userdata);
        uiresume(gcf);
    end
    
function keyPress(src,event)
    if(strcmp(event.Key,'backspace'))
        userdata = get(gcf,'UserData');
        if(size(userdata.list,1) > 0)
            h = userdata.list(end,3);
            delete(h);
            userdata.list(end,:) = [];
            set(gcf,'UserData',userdata);
        end
    elseif(strcmp(event.Key,'escape'))
        userdata = get(gcf,'UserData');
        delete(userdata.h);
        uiresume(gcf);
    end