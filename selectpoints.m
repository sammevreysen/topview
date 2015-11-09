function [xs,ys] = selectpoints(N)
    if(nargin < 1)
        N = 1000;
    end
    button = 0;
    pointlist = [];
    ind = 1;
    while ind < N + 1
        [x,y,button] = ginput(1);
%         button
        if(button == 1)
            pointlist(ind,1:2) = [x,y];
            pointlist(ind,3) = plot(x,y,'gx');
            ind = ind + 1;
        elseif(button == 8)
            delete(pointlist(end));
            pointlist(end,:) = [];
            ind = ind - 1;
        elseif(button == 27)
            xs = pointlist(:,1);
            ys = pointlist(:,2);
            xi = xs(1):0.01:xs(end);
            %check unique xs
            if(size(xs,1) ~= size(unique(xs),1))
                eq = find(diff(xs)==0);
                for i=1:size(eq,1)
                    xs(eq(i)+1) = xs(eq(i)+1)+0.001;
                end
            end
            yi = spline(xs,ys,xi);
            plot(xi,yi,'r-');
            range = 0.05;
            title(sprintf('Current smooth range is %0.2f. Use up and down arrows to change and escape to confirm.',range));
            yiii = smooth(yi,range);
            h = plot(xi,yiii,'y-');
            userdata.yi = yi;
            userdata.yiii = yiii;
            userdata.h = h;
            userdata.range = range;
            set(gcf,'UserData',userdata);
            set(gcf, 'KeyPressFcn', @keyPress);
            uiwait(gcf);
            userdata = get(gcf,'UserData');
            yiii = userdata.yiii;
            break;
        end
    end
    xs = pointlist(:,1);
    ys = pointlist(:,2);
    delete(pointlist(:,3));
    
    function keyPress(src,event)
        if(strcmp(event.Key,'uparrow'))
            userdata = get(gcf,'UserData');
            if(userdata.range < 0.95)
                userdata.range = userdata.range + 0.05;
                userdata.yiii = smooth(userdata.yi,userdata.range);
                set(userdata.h,'YData',userdata.yiii);
                title(sprintf('Current smooth range is %0.2f. Use up and down arrows to change and escape to confirm.',userdata.range));
                set(gcf,'UserData',userdata);
            else
                title('Minimal smooth range is reached. Use up and down arrows to change and escape to confirm.');
            end
        elseif(strcmp(event.Key,'downarrow'))
            userdata = get(gcf,'UserData');
            if(userdata.range > 0.05)
                userdata.range = userdata.range - 0.05;
                userdata.yiii = smooth(userdata.yi,userdata.range);
                set(userdata.h,'YData',userdata.yiii);
                title(sprintf('Current smooth range is %0.2f. Use up and down arrows to change and escape to confirm.',userdata.range));
            else
                title('Minimal smooth range is reached. Use up and down arrows to change and escape to confirm.');
            end
            set(gcf,'UserData',userdata);
        elseif(strcmp(event.Key,'escape'))
            uiresume(gcf);
        end