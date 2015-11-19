function [areax, areay] = setarealborders(x,y,n)
    xy = unique([x y],'rows');

    hold on;
    h = plot(x(1),y(1),'rd');
    userdata.h = h;
    userdata.x = xy(:,1);
    userdata.y = xy(:,2);
    
    userdata.list = {};
    userdata.n = n;
    %userdata.dt = delaunay(x,y);
    userdata.dt = DelaunayTri(x,y);
    set(gcf, 'UserData',userdata);
    set(gcf, 'WindowButtonMotionFcn', @mouseMove);
    set(gcf, 'WindowButtonDownFcn', @mouseClick);
    set(gcf, 'KeyPressFcn', @keyPress);
    uiwait(gcf);
    set(gcf, 'WindowButtonMotionFcn', []);
    set(gcf, 'WindowButtonDownFcn', []);
    set(gcf, 'KeyPressFcn', []);
    userdata = get(gcf, 'UserData');
    areax = cell2mat(userdata.list(:,1));
    areay = cell2mat(userdata.list(:,2));

function mouseMove (object, eventdata)
userdata = get(gcf,'UserData');
C = get (gca, 'CurrentPoint');
if(C(1,1) > min(userdata.x) && C(1,1) < max(userdata.x) && C(1,2) > min(userdata.y) && C(1,2) < max(userdata.y))
    %pid = dsearch(userdata.x,userdata.y,userdata.dt,C(1,1),C(1,2));
    [pid,d] = nearestNeighbor(userdata.dt,C(1,1),C(1,2));
    
    set(userdata.h,'XData',userdata.x(pid),'YData',userdata.y(pid));
end

function mouseClick(object, eventdata)
    userdata = get(gcf,'UserData');    
    X = get(userdata.h,'XDATA');
    Y = get(userdata.h,'YDATA');
    userdata.list = [userdata.list; {X} {Y} {userdata.h}];
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
            h = userdata.list{end,3};
            delete(h);
            userdata.list(end,:) = [];
            set(gcf,'UserData',userdata);
        end
    elseif(strcmp(event.Key,'escape'))
        userdata = get(gcf,'UserData');
        delete(userdata.h);
        uiresume(gcf);
    end