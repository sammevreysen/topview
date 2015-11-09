function [midlinep midlinept] = register_midline(hmidline,hmidlinept1,hmidlinept2)
    %distances
    userdata.hmidline = hmidline;
    userdata.hmidlinept1 = hmidlinept1;
    userdata.hmidlinept2 = hmidlinept2;
    userdata.midlinept1 = [get(hmidlinept1,'XData') get(hmidlinept1,'YData')];
    userdata.midlinept2 = [get(hmidlinept2,'XData') get(hmidlinept2,'YData')];

    hold on;
    userdata.click = 0;
    userdata.title = get(get(gca,'Title'),'String');
    userdata.xlim = xlim(gca);
    userdata.ylim = ylim(gca);
    
    title('Use left and right mouse button to draw the midline, confirm position with escape');
          
    set(gcf, 'UserData',userdata);
    set(gcf, 'WindowButtonMotionFcn', @mouseMovePositionMidline);
    set(gcf, 'WindowButtonDownFcn', @mouseDownClickPositionMidline);
    set(gcf, 'WindowButtonUpFcn', @mouseUpClick);
    set(gcf, 'WindowKeyPressFcn', @keyPress);
    
    uiwait(gcf);
    set(gcf, 'WindowButtonMotionFcn', []);
    set(gcf, 'WindowButtonDownFcn', []);
    set(gcf, 'WindowButtonUpFcn', []);
    set(gcf, 'WindowKeyPressFcn', []);
    midlinep = polyfit(get(hmidline,'XData'),get(hmidline,'YData'),1);
    midlinept = [get(hmidlinept1,'XData') get(hmidlinept1,'YData'); get(hmidlinept2,'XData') get(hmidlinept2,'YData')];
       
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
            set(userdata.hmidlinept1,'XData',C(1,1),'YData',C(1,2));
            userdata.midlinept1 = C(1,1:2);
        elseif(strcmp(get(gcf,'SelectionType'),'alt'))
            userdata.click = 2;
            set(userdata.hmidlinept2,'XData',C(1,1),'YData',C(1,2));
            userdata.midlinept2 = C(1,1:2);
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
            set(userdata.hmidlinept1,'XData',C(1,1),'YData',C(1,2));
            userdata.midlinept1 = C(1,1:2);
        elseif(userdata.click == 2)
            set(userdata.hmidlinept2,'XData',C(1,1),'YData',C(1,2));
            userdata.midlinept2 = C(1,1:2);
        end
        
        if(~(any(isnan(userdata.midlinept1))) && ~(any(isnan(userdata.midlinept2))) && userdata.click > 0)
            %midline and orthline
            A = userdata.midlinept1;
            B = userdata.midlinept2;
            x = userdata.xlim(1):0.1:userdata.xlim(2);
            m1 = (A(2)-B(2))/(A(1)-B(1));
            c1 = -m1*B(1)+B(2);
            midline = m1.*x+c1;
            midlinemask = midline >= userdata.ylim(1) & midline <= userdata.ylim(2);
            userdata.midlinep = [m1 c1];
            
            set(userdata.hmidline,'XData',x(midlinemask),'YData',midline(midlinemask));
        end
        set(gcf,'UserData',userdata);
    end
