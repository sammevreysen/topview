function varargout = managercondition(varargin)
% MANAGERCONDITION MATLAB code for managercondition.fig
%      MANAGERCONDITION, by itself, creates a new MANAGERCONDITION or raises the existing
%      singleton*.
%
%      H = MANAGERCONDITION returns the handle to a new MANAGERCONDITION or the handle to
%      the existing singleton*.
%
%      MANAGERCONDITION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MANAGERCONDITION.M with the given input arguments.
%
%      MANAGERCONDITION('Property','Value',...) creates a new MANAGERCONDITION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before managercondition_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to managercondition_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help managercondition

% Last Modified by GUIDE v2.5 07-May-2015 10:15:15

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @managercondition_OpeningFcn, ...
                   'gui_OutputFcn',  @managercondition_OutputFcn, ...
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
% End initialization code - DO NOT EDIT


% --- Executes just before managercondition is made visible.
function managercondition_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to managercondition (see VARARGIN)
    %load files
    projectname = cell2mat(varargin{1});    
    handles.projectname = projectname;
    vars = openProject(projectname,'topview');
    varfields = fieldnames(vars);
    for i=1:size(varfields,1)
        handles.(varfields{i}) = vars.(varfields{i});
    end    
    
    %savefolder
    handles.pdfsavefolder = ['saved_project' filesep projectname filesep 'pdf' filesep];
    
    handles.conditions = handles.topview.conditionnames;
       
    headers = {'Select','ConditionA','ConditionB','#A - #B','#Permutations','PT-t (=S²)','PT-t (~=S²'};
    colformat = {'logical',handles.conditions',handles.conditions','char','numeric','logical','logical'};
    coledit = [true,true,true,false,false,true,true];
    
    if(isfield(handles.topview,'interconditions'))
        selected = num2cell(false(size(fieldnames(handles.topview.interconditions),1),1));
        condA = struct2cell(structfun(@(x) x.conditions{1},handles.topview.interconditions,'UniformOutput',false));
        condB = struct2cell(structfun(@(x) x.conditions{2},handles.topview.interconditions,'UniformOutput',false));
        nomiceA = structfun(@(x) size(handles.topview.conditions.(x.conditions{1}).mice,1),handles.topview.interconditions);
        nomiceB = structfun(@(x) size(handles.topview.conditions.(x.conditions{2}).mice,1),handles.topview.interconditions);
        nomice = arrayfun(@(x,y) sprintf('%d - %d',x,y),nomiceA,nomiceB,'UniformOutput',false);
        noperm = num2cell(structfun(@(x) size(x.perms,1),handles.topview.interconditions));
        %pseudottesteqvar = structfun(@(x) x.equalvariances,handles.topview.interconditions);
        pseudottesteqvar = num2cell(false(size(fieldnames(handles.topview.interconditions),1),1));
        pseudottestneqvar = num2cell(true(size(fieldnames(handles.topview.interconditions),1),1));
        data = [selected condA condB nomice noperm pseudottesteqvar pseudottestneqvar];
    else
        data = [{false; false} {'';''} {'';''} {'';''} {'';''} {false; false} {false; false}];
    end
    set(handles.uitable,'ColumnFormat',colformat,'ColumnEditable',coledit,'ColumnName',headers,'Data',data,'CellEditCallback',@selecttable);
    
    % Choose default command line output for managercondition
    handles.output = hObject;
    
    % Update handles structure
    guidata(hObject, handles);
    
    % UIWAIT makes managercondition wait for user response (see UIRESUME)
    % uiwait(handles.figManagerConditions);

function selecttable(hObject,callbackdata)
    data = get(hObject,'Data');
    handles = guidata(hObject);
    if(callbackdata.Indices(1) == size(data,1))
        data = [data; {false} {''} {''} {''} {''} {false} {false}];
    end
    switch callbackdata.Indices(2)
        case {6,7}
            if(all(~strcmp(data(callbackdata.Indices(1),[2 3]),'')))
                if(callbackdata.Indices(2) == 6)
                    equalvariances = true;
                else
                    equalvariances = false;
                end
                conditioncombname = [data{callbackdata.Indices(1),2} '_' data{callbackdata.Indices(1),3}];
                if(isfield(handles.topview,'interconditions') && isfield(handles.topview.interconditions,conditioncombname))
                    handles.topview.interconditions = rmfield(handles.topview.interconditions,conditioncombname);
                end
                handles.topview.interconditions.(conditioncombname).conditions = {data{callbackdata.Indices(1),2} data{callbackdata.Indices(1),3}};
                for i = 1:size(handles.topview.suporinfra,1)
                    fprintf('Running pseudo T-test statistics \nfor %s\n',handles.topview.suporinfra{i});
                    handles.topview = runPseudoTteststepdown(handles.topview,data{callbackdata.Indices(1),2},data{callbackdata.Indices(1),3},handles.topview.suporinfra{i},equalvariances);
                end
                saveProject(handles,'topview');
                data{callbackdata.Indices(1),6} = callbackdata.Indices(2) == 6;
                data{callbackdata.Indices(1),7} = callbackdata.Indices(2) == 7;
                data{callbackdata.Indices(1),1} = true;
            end
        case {2,3}
            if(all(~strcmp(data(callbackdata.Indices(1),[2 3]),'')))
                nomiceA = size(handles.topview.conditions.(data{callbackdata.Indices(1),2}).mice,1);
                nomiceB = size(handles.topview.conditions.(data{callbackdata.Indices(1),3}).mice,1);
                data{callbackdata.Indices(1),4} = sprintf('%d - %d',nomiceA,nomiceB);
                data{callbackdata.Indices(1),5} = nchoosek(nomiceA+nomiceB,nomiceA);
            end
            
        case 1
            if(all(~strcmp(data(callbackdata.Indices(1),[2 3]),'')))
                conditioncombname = [data{callbackdata.Indices(1),2} '_' data{callbackdata.Indices(1),3}];
                handles.topview.interconditions.(conditioncombname).selected = callbackdata.NewData;
            end
                
    end
    set(hObject,'Data',data);
    guidata(hObject,handles);

% --- Outputs from this function are returned to the command line.
function varargout = managercondition_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in push_drawstats.
function push_drawstats_Callback(hObject, eventdata, handles)
% hObject    handle to push_drawstats (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    tails = get(handles.popup_tails,'String');
    tail = tails{get(handles.popup_tails,'Value')};
    handles = checked(handles);
    plotPseudoTteststepdown(handles.topview,tail);


% --------------------------------------------------------------------
function menu_extra_Callback(hObject, eventdata, handles)
% hObject    handle to menu_extra (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_calcpTtseqvar_Callback(hObject, eventdata, handles)
% hObject    handle to menu_calcpTtseqvar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    equalvariances = true;
    data = get(handles.uitable,'Data');
    fprintf('Running all pseudo T-test statistics assuming no equal variance \n');
    if(isfield(handles.topview,'interconditions'))
        handles.topview = rmfield(handles.topview,'interconditions');
    end
    for i=1:size(data,1)
        if(~strcmp(data{i,2},'') && ~strcmp(data{i,3},''))
            fprintf('%d/%d\n',i,size(data,1));
            for j = 1:size(handles.topview.suporinfra,1)
                fprintf('Running pseudo T-test statistics \nfor %s\n',handles.topview.suporinfra{j});
                handles.topview = runPseudoTteststepdown(handles.topview,data{i,2},data{i,3},handles.topview.suporinfra{j},equalvariances);
            end
            data{i,6} = true;
            data{i,7} = false;
            data{i,1} = true;
            set(handles.uitable,'Data',data);
        end
    end
    saveProject(handles,'topview');
    guidata(hObject,handles);

% --------------------------------------------------------------------
function menu_calcpTtsneqvar_Callback(hObject, eventdata, handles)
% hObject    handle to menu_calcpTtsneqvar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    equalvariances = false;
    data = get(handles.uitable,'Data');
    fprintf('Running all pseudo T-test statistics assuming no equal variance \n');
    if(isfield(handles.topview,'interconditions'))
        handles.topview = rmfield(handles.topview,'interconditions');
    end
    for i=1:size(data,1)
        if(~strcmp(data{i,2},'') && ~strcmp(data{i,3},''))
            fprintf('%d/%d\n',i,size(data,1));
            for j = 1:size(handles.topview.suporinfra,1)
                fprintf('Running pseudo T-test statistics \nfor %s\n',handles.topview.suporinfra{j});
                handles.topview = runPseudoTteststepdown(handles.topview,data{i,2},data{i,3},handles.topview.suporinfra{j},equalvariances);
            end
            data{i,6} = false;
            data{i,7} = true;
            data{i,1} = true;
            set(handles.uitable,'Data',data);
        end
    end
    saveProject(handles,'topview');
    guidata(hObject,handles);
    

% --------------------------------------------------------------------
function menu_cleantable_Callback(hObject, eventdata, handles)
% hObject    handle to menu_cleantable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    handles.topview = rmfield(handles.topview,'interconditions');
    saveProject(handles,'topview');
    data = [{false; false} {'';''} {'';''} {'';''} {'';''} {false; false} {false; false}];
    set(handles.uitable,'Data',data);
    guidata(hObject,handles);


% --- Executes on selection change in popup_tails.
function popup_tails_Callback(hObject, eventdata, handles)
% hObject    handle to popup_tails (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popup_tails contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popup_tails


% --- Executes during object creation, after setting all properties.
function popup_tails_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popup_tails (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function handles = checked(handles)
    data = get(handles.uitable,'Data');
    data(any(strcmp(data(:,2:3),''),2),:) = [];
    lst = [];
    for i=1:size(data,1)
        conditioncombname = [data{i,2} '_' data{i,3}];
        lst = [lst; {conditioncombname}];
        handles.topview.interconditions.(conditioncombname).selected = data{i,1};
    end
    savedlst = fieldnames(handles.topview.interconditions);
    trash = savedlst(~ismember(savedlst,lst));
    for i=1:size(trash,1)
        handles.topview.interconditions.(conditioncombname).selected = false;
    end