function addareamaskoverlay(hObject,callbackdata)
    if(strcmp(hObject.Label,'None'))
        delete(findobj('Tag','areamask'));
    else
        load(['visual_areas_mask' filesep hObject.Label '.mat']);
        childs = findobj(gcf,'Type','axes');
        areas = fieldnames(mask);
        for i=1:size(childs,1)
            set(gcf,'CurrentAxes',childs(i))
            hold on;
            for j=1:size(areas,1)
                plot(mask.(areas{j}).contour(1,:),mask.(areas{j}).contour(2,:),'Color',mask.(areas{j}).color,'LineWidth',mask.(areas{j}).linewidth,'LineStyle',mask.(areas{j}).linestyle,'Tag','areamask');
            end
            hold off;
        end
    end
    set(get(get(hObject,'Parent'),'Children'),'Checked','off');
    set(hObject,'Checked','on');