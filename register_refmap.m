function h_borderline = register_refmap(r,fixborder,names)
    %distances
    userdata.r = r(:);

    %distances in percentage according to fixed borders
    userdata.fixborder = fixborder;
    fixborders = find(userdata.fixborder == 1);
    if(sum(fixborder) == 2)
        userdata.r_rel = (userdata.r-userdata.r(min(fixborders)))./diff(userdata.r(fixborder == 1));
    end
    
    hold on;
    userdata.click = 0;
    userdata.title = get(get(gca,'Title'),'String');
    userdata.xlim = xlim(gca);
    userdata.ylim = ylim(gca);
    
    title('Use left and right mouse button to draw the midline, confirm position with escape');
    
    userdata.midlinep = [NaN NaN];
    userdata.orthlinep = [NaN NaN];
    
    h_borderline = plot(1,nan(1,length(r)),':','DisplayName',names);
    if(sum(fixborder) == 2)
        set(h_borderline(fixborder == 1),'LineWidth',2);
        h_fixpoints = plot(1,nan(1,2),'rp');
        h_fixorthcrosspoints = plot(1,nan(1,2),'bp');
        userdata.h_fixpoints = h_fixpoints;
        userdata.h_fixorthcrosspoints = h_fixorthcrosspoints;
    end
    h_midline = plot(NaN,NaN,'r-');
    h_midlinep = plot(NaN,NaN,'ro');
    h_orthline = plot(NaN,NaN,'b-');
    h_orthlinep = plot(NaN,NaN,'rd');
    
    userdata.h_borderline = h_borderline(:);
    userdata.h_midline = h_midline;
    userdata.h_midlinep = h_midlinep;
    userdata.h_orthline = h_orthline;
    userdata.h_orthlinep = h_orthlinep;
    legend(h_borderline,'Location','EastOutside');
    
    set(gcf, 'UserData',userdata);
    set(gcf, 'WindowButtonMotionFcn', @mouseMovePositionMidline);
    set(gcf, 'WindowButtonDownFcn', @mouseDownClickPositionMidline);
    set(gcf, 'WindowButtonUpFcn', @mouseUpClick);
    set(gcf, 'WindowKeyPressFcn', @keyPress);
    
    uiwait(gcf);
    
    if(sum(fixborder) == 2)
        title('Position the 2 borders using the left and right mouse button, confirm with escape');
        set(gcf, 'WindowButtonMotionFcn', @mouseMoveFixBorder);
        set(gcf, 'WindowButtonDownFcn', @mouseDownClickFixBorder);
        set(gcf, 'WindowButtonUpFcn', @mouseUpClick);
        set(gcf, 'WindowKeyPressFcn', @keyPress);
        
        uiwait(gcf);
        
        fprintf('ended\n');
    end
    
    function keyPress(object, event)
        if(strcmp(event.Key,'escape'))
            uiresume(gcf);
        end
        
    end

    function mouseDownClickPositionMidline(object, eventdata)
        userdata = get(gcf,'UserData');
        C = get(gca, 'CurrentPoint');
        if(strcmp(get(gcf,'SelectionType'),'normal'))
            userdata.click = 1;
            set(userdata.h_midlinep,'XData',C(1,1),'YData',C(1,2));
            userdata.midlinep = C(1,1:2);
        elseif(strcmp(get(gcf,'SelectionType'),'alt'))
            userdata.click = 2;
            set(userdata.h_orthlinep,'XData',C(1,1),'YData',C(1,2));
            userdata.orthlinep = C(1,1:2);
        end
        
        set(gcf,'UserData',userdata);
        
    end

    function mouseDownClickFixBorder(object, eventdata)
        userdata = get(gcf,'UserData');
        if(strcmp(get(gcf,'SelectionType'),'normal'))
            userdata.click = 1;
        elseif(strcmp(get(gcf,'SelectionType'),'alt'))
            userdata.click = 2;
        end
        
        set(gcf,'UserData',userdata);
        
    end

    function mouseUpClick(object, eventdata)
        userdata = get(gcf,'UserData');
        userdata.click = 0;
        set(gcf,'UserData',userdata);
        %     set(gcf, 'WindowButtonMotionFcn', []);
        %     set(gcf, 'WindowButtonDownFcn', []);
        %     set(gcf, 'WindowButtonUpFcn', []);
        %     set(gcf, 'KeyPressFcn', @keyPress);
        %     uiresume(gcf);
        
    end

    function mouseMovePositionMidline(object, eventdata)
        C = get(gca,'CurrentPoint');
        userdata = get(gcf,'UserData');
        if(userdata.click == 1)
            set(userdata.h_midlinep,'XData',C(1,1),'YData',C(1,2));
            userdata.midlinep = C(1,1:2);
        elseif(userdata.click == 2)
            set(userdata.h_orthlinep,'XData',C(1,1),'YData',C(1,2));
            userdata.orthlinep = C(1,1:2);
        end
        
        if(~(any(isnan(userdata.midlinep))) && ~(any(isnan(userdata.orthlinep))) && userdata.click > 0)
            %midline and orthline
            A = userdata.midlinep;
            B = userdata.orthlinep;
            x = userdata.xlim(1):0.1:userdata.xlim(2);
            m1 = (A(2)-B(2))/(A(1)-B(1));
            c1 = -m1*B(1)+B(2);
            m2 = -1/m1;
            c2 = -m2*B(1)+B(2);
            midline = m1.*x+c1;
            orthline = m2.*x+c2;
            midlinemask = midline >= userdata.ylim(1) & midline <= userdata.ylim(2);
            orthlinemask = orthline >= userdata.ylim(1) & orthline <= userdata.ylim(2);
            userdata.midline_p = [m1 c1];
            userdata.orthline_p = [m2 c2];
            %arealborderlines
            r = userdata.r;
            a = m2^2+1;
            b = 2*(m2*c2-m2*B(2)-B(1));
            c = B(2)^2-r.^2+B(1)^2-2*c2*B(2)+c2^2;
            P = [(-b-sqrt(b^2-4*a*c))/(2*a) m2*((-b-sqrt(b^2-4*a*c))/(2*a))+c2];
            c3 = -m1.*P(:,1)+P(:,2);
            userdata.borderline_p = [repmat(m1,size(c3)) c3];
            userdata.borderorthcross = P;
            borderline = repmat(m1.*x,size(c3))+repmat(c3,size(x));
            borderlinemask = borderline >= userdata.ylim(1) & borderline <= userdata.ylim(2);
            
            set(userdata.h_midline,'XData',x(midlinemask),'YData',midline(midlinemask));
            set(userdata.h_orthline,'XData',x(orthlinemask),'YData',orthline(orthlinemask));
            arrayfun(@(i) set(userdata.h_borderline(i),'XData',x(borderlinemask(i,:)),'YData',borderline(i,borderlinemask(i,:))),1:length(r));
        end
        set(gcf,'UserData',userdata);
    end

    function mouseMoveFixBorder(object, eventdata)
        C = get(gca,'CurrentPoint');
        userdata = get(gcf,'UserData');
        if(userdata.click > 0)
            fixborders = find(userdata.fixborder == 1);
            c = C(1,2)-userdata.midline_p(1)*C(1,1);
            Px = (c-userdata.orthline_p(2))/(userdata.orthline_p(1)-userdata.midline_p(1));
            Py = userdata.midline_p(1)*Px+c;
            if(userdata.click == 1)
                userdata.borderorthcross(min(fixborders),:) = [Px Py];
                set(userdata.h_fixpoints(1),'XData',C(1,1),'YData',C(1,2));
                set(userdata.h_fixorthcrosspoints(1),'XData',Px,'YData',Py);
            elseif(userdata.click == 2)
                userdata.borderorthcross(max(fixborders),:) = [Px Py];
                set(userdata.h_fixpoints(2),'XData',C(1,1),'YData',C(1,2));
                set(userdata.h_fixorthcrosspoints(2),'XData',Px,'YData',Py);
            end
            %recalculate distances to fixed positions
            distfixborder = sqrt(sum(diff(userdata.borderorthcross(userdata.fixborder == 1,:),1).^2));
            userdata.r = userdata.r_rel.*distfixborder;
            
            %arealborderlines
            r = userdata.r;
            m1 = userdata.midline_p(1);
            m2 = userdata.orthline_p(1);
            c2 = userdata.orthline_p(2);
            B = userdata.borderorthcross(min(fixborders),:);
            x = userdata.xlim(1):0.1:userdata.xlim(2);
            a = m2^2+1;
            b = 2*(m2*c2-m2*B(2)-B(1));
            c = B(2)^2-r.^2+B(1)^2-2*c2*B(2)+c2^2;
            P = [(-b-sign(userdata.r_rel).*sqrt(b^2-4*a*c))/(2*a) m2*((-b-sign(userdata.r_rel).*sqrt(b^2-4*a*c))/(2*a))+c2];
            c3 = -m1.*P(:,1)+P(:,2);
            borderline = repmat(m1.*x,size(c3))+repmat(c3,size(x));
            borderlinemask = borderline >= userdata.ylim(1) & borderline <= userdata.ylim(2);
            
            arrayfun(@(i) set(userdata.h_borderline(i),'XData',x(borderlinemask(i,:)),'YData',borderline(i,borderlinemask(i,:))),1:length(r));
           
        end
        set(gcf,'UserData',userdata);
    end

end