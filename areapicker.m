function varargout = areapicker(varargin)

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @areapicker_OpeningFcn, ...
                   'gui_OutputFcn',  @areapicker_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
     gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end


function areapicker_OpeningFcn(hObject, eventdata, handles, varargin)
if(~strcmp(varargin,''))
    handles.cancel = false;
    handles.areastr = varargin{1};
    handles.areas = regexp(handles.areastr{:},',','split');
    format = [{'logical'} repmat({'char'},1,size(handles.areas,2))];
    edit = repmat([true],1,size(handles.areas,2)+1);
    if(max(size(varargin)) > 1)
        data = [repmat({true},size(varargin{2},1),1) varargin{2}];
        data = [data; [{false} repmat({''},1,size(data,2)-1)]];
    else
        data = repmat([{false} repmat({''},1,size(handles.areas,2))],2,1);
    end
    set(handles.uitable_areas,'Data',data,'ColumnName',[' ' handles.areas],'ColumnFormat',format,'ColumnEditable',edit,'CellEditCallback',@uitable_areas_Callback);
    guidata(hObject, handles);
    uiwait();
end


function varargout = areapicker_OutputFcn(hObject, eventdata, handles) 
    if(size(handles,1) > 0)    
        if(~handles.cancel)
            data = get(handles.uitable_areas,'Data');
            varargout{1} = data(cellfun(@any,data(:,1)),2:end);
        else
            varargout{1} = false;
        end
        close();
    else
        varargout{1} = false;
    end

function uitable_areas_Callback(source,eventdata)
    data = get(source,'Data');
    if(eventdata.Indices(2) == 1)
        if(eventdata.Indices(1) == size(data,1) && eventdata.NewData)
            %add new row
            data = [data; [{false} repmat({''},1,size(data,2)-1)]];
        elseif(~eventdata.NewData)
            %delete row
            logicals = true(size(data));
            logicals(eventdata.Indices(1),:) = false;
            data = reshape(data(logicals),size(data,1)-1,size(data,2));
            if(size(data,1) == 1)
                data = [data; [{false} repmat({''},1,size(data,2)-1)]];
            end
        end
    else
        %check row
        data{eventdata.Indices(1),1} = true;
        if(eventdata.Indices(1) == size(data,1))
            %add new row
            data = [data; [{false} repmat({''},1,size(data,2)-1)]];
        end
    end
    set(source,'Data',data);

function push_done_Callback(hObject, eventdata, handles)
    %check if any row is checked
    data = get(handles.uitable_areas,'Data');
    if(~any(cellfun(@any,data(:,1))))
        button = questdlg('No rows were selected in the region setup. Do you wish to add regions?','Region setup - Warning','Yes, add regions','No, just cancel','Yes, add regions');
        switch button
            case 'Yes, add regions'
                return;
            case 'No, just cancel'
                handles.cancel = true;
                uiresume();
        end
    else
        %if rows are selected, check if there is more than 1 region created
        region = true;
        ind = find(cellfun(@any,data(:,1)) == true);
        for i=1:size(ind,1)
            region = region && (size(unique(data(ind(i),2:end)),2) > 1);
        end
        if(~region)
            button = questdlg('The region setup contains rows with only one region. Do you wish to correct this?','Region setup - Warning','Yes, correct regions','No, just cancel','Yes, correct regions');
            switch button
                case 'Yes, correct regions'
                    return;
                case 'No, just cancel'
                    handles.cancel = true;
                    uiresume();
            end
        else
            uiresume();
        end
    end
        
function push_cancel_Callback(hObject, eventdata, handles)
    handles.cancel = true;
    guidata(hObject,handles);
    uiresume();


