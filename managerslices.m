function varargout = managerslices(varargin)
% managerslices MATLAB code for managerslices.fig
%      managerslices, by itself, creates a new managerslices or raises the existing
%      singleton*.
%
%      H = managerslices returns the handle to a new managerslices or the handle to
%      the existing singleton*.
%
%      managerslices('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in managerslices.M with the given input arguments.
%
%      managerslices('Property','Value',...) creates a new managerslices or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before micemanager_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to micemanager_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help managerslices

% Last Modified by GUIDE v2.5 04-May-2015 14:42:31

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @micemanager_OpeningFcn, ...
                   'gui_OutputFcn',  @micemanager_OutputFcn, ...
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


% --- Executes just before managerslices is made visible.
function micemanager_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to managerslices (see VARARGIN)

% Choose default command line output for managerslices
handles.output = hObject;
if(ischar(varargin{1}))
    tmp = load(varargin{1});
    handles.setuptable = tmp.setuptable;
else
    handles.setuptable = varargin{1};
    handles.projectname = varargin{2};
end
if(~isfield(handles.setuptable{1,5},'bregma'))
    handles.setuptable = alignbregmas(handles.setuptable);
    fprintf('Bregmas aligned\n');
end
bregma = cellfun(@(x) x.bregma,handles.setuptable(:,5),'UniformOutput',false);
midline = cell(size(handles.setuptable,1),1);
for i=1:size(midline,1)
    if(isfield(handles.setuptable{i,5},'midlinep'))
        if(~any(isnan(handles.setuptable{i,5}.midlinep)))
            midline{i} = true;
        else
            midline{i} = false;
        end
    else
        midline{i} = false;
    end
end
background = arrayfun(@(x) isfield(x{:},'meanbg'),handles.setuptable(:,5),'UniformOutput',false);

headers = {'Select','Condition','Mouse','Slice','Bregma','Ortho projection','Background'};
colformat = {'logical','char','char','char','numeric','logical','logical'};
coledit = [true,false(1,3),true,true,true];

data = [num2cell(true(size(handles.setuptable,1),1)) handles.setuptable(:,1:3) bregma midline background];
set(handles.uitable,'ColumnFormat',colformat,'ColumnEditable',coledit,'ColumnName',headers,'Data',data,'CellEditCallback',@selecttable);

handles.hash = DataHash(handles.setuptable);
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes managerslices wait for user response (see UIRESUME)
% uiwait(handles.figure1);

function selecttable(hObject,callbackdata)
    switch callbackdata.Indices(2) 
        case 7
            warndlg('set background not implemented');
        case 6
            handles = guidata(hObject);
            row = callbackdata.Indices(1);
            hfig = figure();
            [handles.setuptable{row,5}.midlinep handles.setuptable{row,5}.midlinept] = reg_midline(handles.setuptable(row,:),hfig);
            if(any(isnan(handles.setuptable{row,5}.midlinep)))
                warndlg('This line was not registered correctly');
            else
                data = get(handles.uitable,'Data');
                data(callbackdata.Indices(1),callbackdata.Indices(2)) = {true};
                set(handles.uitable,'Data',data);
            end
            disp(handles.setuptable{row,5}.midlinep);
            disp(handles.setuptable{row,5}.midlinept);
            close(hfig);
            guidata(hObject,handles);
        case 5
            handles = guidata(hObject);
            handles.setuptable{callbackdata.Indices(1),5}.bregma = str2num(callbackdata.NewData);
            guidata(hObject,handles);
    end
    
function [midlinep, midlinept] = reg_midline(setuptablerow,hreffig)
    %open slice image
    if(~isfield(setuptablerow{6},'pivot'))
        setuptablerow{6}.pivot = 0;
    end
    
    pivot = setuptablerow{6}.pivot;
    
    if(pivot == 0)
        topcox = setuptablerow{6}.topcoxy(:,1);
        topcoy = setuptablerow{6}.topcoxy(:,2);
        midtcox = setuptablerow{6}.midcoxy(:,1);
        midtcoy = setuptablerow{6}.midcoxy(:,2);
        midbcox = midtcox;
        midbcoy = midtcoy;
        botcox = setuptablerow{6}.botcoxy(:,1);
        botcoy = setuptablerow{6}.botcoxy(:,2);
    else
        topcox = setuptablerow{6}.(['toppiv' num2str(pivot) 'coxy'])(:,1);
        topcoy = setuptablerow{6}.(['toppiv' num2str(pivot) 'coxy'])(:,2);
        midtcox = setuptablerow{6}.(['midtpiv' num2str(pivot) 'coxy'])(:,1);
        midtcoy = setuptablerow{6}.(['midtpiv' num2str(pivot) 'coxy'])(:,2);
        midbcox = setuptablerow{6}.(['midbpiv' num2str(pivot) 'coxy'])(:,1);
        midbcoy = setuptablerow{6}.(['midbpiv' num2str(pivot) 'coxy'])(:,2);
        botcox = setuptablerow{6}.(['botpiv' num2str(pivot) 'coxy'])(:,1);
        botcoy = setuptablerow{6}.(['botpiv' num2str(pivot) 'coxy'])(:,2);
    end
    topx = setuptablerow{5}.topx;
    topy = setuptablerow{5}.topy;
    botx = setuptablerow{5}.botx;
    boty = setuptablerow{5}.boty;
    
    topcoxy = [topcox topcoy];
    botcoxy = [botcox botcoy];
    
    figure(hreffig);
    clf;
    img = imread([setuptablerow{4} setuptablerow{3}]);
    imshow(img);
    set(hreffig,'Name',setuptablerow{3});
    
    %             if(isfield(setuptablerow{5},'midlinep'))
    %                 midlinep = setuptablerow{5}.midlinep;
    %                 midlinept = setuptablerow{5}.midlinept;
    %                 xlim = get(gca,'Xlim');
    %                 ylim = get(gca,'Ylim');
    %                 midlinex = xlim(1):0.1:xlim(2);
    %                 midliney = polyval(midlinep,midlinex);
    %                 window = midliney > ylim(1) & midliney < ylim(2);
    %                 midlinex = midlinex(window);
    %                 midliney = midliney(window);
    %             else
    midlinep = [];
    midlinept = [NaN NaN; NaN NaN];
    midlinex = NaN;
    midliney = NaN;
    %             end
    
    hold on;
    plot([topcox'; midtcox'],[topcoy'; midtcoy'],'b-');
    plot([midbcox'; botcox'],[midbcoy'; botcoy'],'c-');
    plot(setuptablerow{5}.topareaxy(:,1),setuptablerow{5}.topareaxy(:,2),'ro');
    plot(setuptablerow{5}.midareaxy(:,1),setuptablerow{5}.midareaxy(:,2),'ro');
    plot(setuptablerow{5}.botareaxy(:,1),setuptablerow{5}.botareaxy(:,2),'ro');
    plot(topx,topy,'r-');
    plot(botx,boty,'r-');
    hmidline = plot(midlinex,midliney,'g-');
    hmidlinept1 = plot(midlinept(1,1),midlinept(1,2),'gd');
    hmidlinept2 = plot(midlinept(2,1),midlinept(2,2),'gd');
    hold off;
    
    
    %register midline
    [midlinep midlinept] = register_midline(hmidline,hmidlinept1,hmidlinept2);
    

    
% --- Outputs from this function are returned to the command line.
function varargout = micemanager_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
    
    %check if fieldnames have same order
%     for i=2:size(handles.setuptable,1)
%         handles.setuptable{i,5} = orderfields(handles.setuptable{i,5},handles.setuptable{1,5});
%         handles.setuptable{i,6} = orderfields(handles.setuptable{i,6},handles.setuptable{1,6});
%     end
    %save project
    %handles = saveProject(handles);
    %output
    varargout{1} = handles.setuptable;
    guidata(hObject,handles);


% --- Executes on selection change in pop_normalize.
function pop_normalize_Callback(hObject, eventdata, handles)
% hObject    handle to pop_normalize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pop_normalize contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pop_normalize


% --- Executes during object creation, after setting all properties.
function pop_normalize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pop_normalize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushmice.
function pushmice_Callback(hObject, eventdata, handles)
% hObject    handle to pushmice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    %handles.projectname = 'Samme-M-Eve-Ctrl-ME';
%     handles = saveProject(handles);
    handles = checkselection(handles);
    if(~hasDoubleEntries(handles.setuptable))
%         newhash = DataHash(handles.setuptable);
%         if(~strcmp(handles.hash,newhash))
%             handles.hash = newhash;
        saveProject(handles,'setuptable');
%         end
        %check if all midlines were set
        checklist = ones(size(handles.setuptable,1),1);
        for i=1:size(handles.setuptable,1)
            if(~isfield(handles.setuptable{i,5},'midlinep'))
                checklist(i) = 0;
                fprintf('Midline not set for slice %d\n',i);
            end
        end
        if(all(checklist))
            managermice({handles.projectname},true);
        end
    end
    guidata(hObject,handles);


% --------------------------------------------------------------------
function menu_batch_Callback(hObject, eventdata, handles)
% hObject    handle to menu_batch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fprintf('');

% --------------------------------------------------------------------
function menu_regmidlineallslices_Callback(hObject, eventdata, handles)
% hObject    handle to menu_regmidlineallslices (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    hfig = figure();
    for i=1:size(handles.setuptable,1)
        [handles.setuptable{i,5}.midlinep handles.setuptable{i,5}.midlinept] = reg_midline(handles.setuptable(i,:),hfig);
    end
    close(hfig);
    guidata(hObject,handles);


% --------------------------------------------------------------------
function Untitled_1_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_save_Callback(hObject, eventdata, handles)
% hObject    handle to menu_save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    saveProject(handles,'setuptable');
    
    
function handles = checkselection(handles)
    data = get(handles.uitable,'data');
    sel = cell2mat(data(:,1));
    handles.setuptable(~sel,:) = [];
        