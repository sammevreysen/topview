function changeareamaskoverlay(hObject,callbackdata)
    filename = ['visual_areas_mask' filesep hObject.Label '.mat'];
    load(filename);
    areas = fieldnames(mask);
    for i=1:size(areas,1)
        if(~isfield(mask.(areas{i}),'color'))
            tab{i,1} = 'ff0000';
        else
            tab{i,1} = reshape(sprintf('%02X',mask.(areas{i}).color.*255),6,[]).';
        end
        if(~isfield(mask.(areas{i}),'linewidth'))
            tab{i,2} = 1;
        else
            tab{i,2} = mask.(areas{i}).linewidth;
        end
        if(~isfield(mask.(areas{i}),'linestyle'))
            tab{i,3} = '-';
        else
            tab{i,3} = mask.(areas{i}).linestyle;
        end
    end
    colname = {'Color (hex)','Linewidth','Linestyle'};
    colformat = {'numeric','numeric',{'-','--',':'}};
    
    h = figure();
    t = uitable('Data',tab,'ColumnName',colname,'ColumnFormat',colformat,'ColumnEditable',[true true true],'RowName',areas);
    
    uimenu(h,'Label','Save','Callback',@savetable);
    uimenu(h,'Label','Cancel','Callback',{@close,gcf});
    
    function savetable(hO,cbd)
        tab = t.Data;
        for j=1:size(tab,1)
            mask.(areas{j}).color = reshape(sscanf(tab{j,1}.','%2x'),3,[]).'/255;
            mask.(areas{j}).linewidth = tab{j,2};
            mask.(areas{j}).linestyle = tab{j,3};
        end
        save(filename,'mask');
        close(gcf);
    end

end