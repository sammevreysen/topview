function varargout = ISHtopviewColorscale(varargin)
% ISHTOPVIEWCOLORSCALE MATLAB code for ISHtopviewColorscale.fig
%      ISHTOPVIEWCOLORSCALE, by itself, creates a new ISHTOPVIEWCOLORSCALE or raises the existing
%      singleton*.
%
%      H = ISHTOPVIEWCOLORSCALE returns the handle to a new ISHTOPVIEWCOLORSCALE or the handle to
%      the existing singleton*.
%
%      ISHTOPVIEWCOLORSCALE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ISHTOPVIEWCOLORSCALE.M with the given input arguments.
%
%      ISHTOPVIEWCOLORSCALE('Property','Value',...) creates a new ISHTOPVIEWCOLORSCALE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ISHtopviewColorscale_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ISHtopviewColorscale_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ISHtopviewColorscale

% Last Modified by GUIDE v2.5 25-Mar-2014 12:20:43

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ISHtopviewColorscale_OpeningFcn, ...
                   'gui_OutputFcn',  @ISHtopviewColorscale_OutputFcn, ...
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


% --- Executes just before ISHtopviewColorscale is made visible.
function ISHtopviewColorscale_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ISHtopviewColorscale (see VARARGIN)

% Choose default command line output for ISHtopviewColorscale
handles.output = hObject;
handles.parenthandles = varargin{1,1};
climsupra = handles.parenthandles.climsupra;
climinfra = handles.parenthandles.climinfra;
set(handles.slidersupramin,'Min',climsupra(1)-20);
set(handles.slidersupramin,'Max',climsupra(2)+20);
set(handles.slidersupramin,'Value',climsupra(1));
set(handles.slidersupramax,'Min',climsupra(1)-20);
set(handles.slidersupramax,'Max',climsupra(2)+20);
set(handles.slidersupramax,'Value',climsupra(2));
set(handles.climsupramin,'String',num2str(climsupra(1)));
set(handles.climsupramax,'String',num2str(climsupra(2)));
set(handles.sliderinframin,'Min',climinfra(1)-20);
set(handles.sliderinframin,'Max',climinfra(2)+20);
set(handles.sliderinframin,'Value',climinfra(1));
set(handles.sliderinframax,'Min',climinfra(1)-20);
set(handles.sliderinframax,'Max',climinfra(2)+20);
set(handles.sliderinframax,'Value',climinfra(2));
set(handles.climinframin,'String',num2str(climinfra(1)));
set(handles.climinframax,'String',num2str(climinfra(2)));

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ISHtopviewColorscale wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ISHtopviewColorscale_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on slider movement.
function slidersupramin_Callback(hObject, eventdata, handles)
% hObject    handle to slidersupramin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
    handles.parenthandles.climsupra(1) = get(hObject,'Value');
    set(handles.climsupramin,'String',num2str(handles.parenthandles.climsupra(1)));
    if(get(hObject,'Value') == get(hObject,'Min'))
        set(hObject,'Min',handles.parenthandles.climsupra(1)-20);
    end
    guidata(hObject,handles);
    updatePlots(handles);

% --- Executes during object creation, after setting all properties.
function slidersupramin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slidersupramin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function climsupramin_Callback(hObject, eventdata, handles)
% hObject    handle to climsupramin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of climsupramin as text
%        str2double(get(hObject,'String')) returns contents of climsupramin as a double
    handles.parenthandles.climsupra(1) = str2num(get(hObject,'String'));
    set(handles.slidersupramax,'Value',handles.parenthandles.climsupra(1));
    set(handles.slidersupramax,'Min',handles.parenthandles.climsupra(1)-20);
    guidata(hObject,handles);
    updatePlots(handles);

% --- Executes during object creation, after setting all properties.
function climsupramin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to climsupramin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function climsupramax_Callback(hObject, eventdata, handles)
% hObject    handle to climsupramax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of climsupramax as text
%        str2double(get(hObject,'String')) returns contents of climsupramax as a double
    handles.parenthandles.climsupra(2) = str2num(get(hObject,'String'));
    set(handles.slidersupramax,'Value',handles.parenthandles.climsupra(2));
    set(handles.slidersupramax,'Max',handles.parenthandles.climsupra(2)+20);
    guidata(hObject,handles);
    updatePlots(handles);

% --- Executes during object creation, after setting all properties.
function climsupramax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to climsupramax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function slidersupramax_Callback(hObject, eventdata, handles)
% hObject    handle to slidersupramax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
    handles.parenthandles.climsupra(2) = get(hObject,'Value');
    set(handles.climsupramax,'String',num2str(handles.parenthandles.climsupra(2)));
    if(get(hObject,'Value') == get(hObject,'Max'))
        set(hObject,'Max',handles.parenthandles.climsupra(2)+20);
    end
    guidata(hObject,handles);
    updatePlots(handles);

% --- Executes during object creation, after setting all properties.
function slidersupramax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slidersupramax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function sliderinframin_Callback(hObject, eventdata, handles)
% hObject    handle to sliderinframin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
    handles.parenthandles.climinfra(1) = get(hObject,'Value');
    set(handles.climinframin,'String',num2str(handles.parenthandles.climinfra(1)));
    if(get(hObject,'Value') == get(hObject,'Min'))
        set(hObject,'Min',handles.parenthandles.climinfra(1)-20);
    end
    guidata(hObject,handles);
    updatePlots(handles);

% --- Executes during object creation, after setting all properties.
function sliderinframin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderinframin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function climinframin_Callback(hObject, eventdata, handles)
% hObject    handle to climinframin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of climinframin as text
%        str2double(get(hObject,'String')) returns contents of climinframin as a double
    handles.parenthandles.climinfra(1) = str2num(get(hObject,'String'));
    set(handles.sliderinframax,'Value',handles.parenthandles.climinfra(1));
    set(handles.sliderinframax,'Max',handles.parenthandles.climinfra(1)-20);
    guidata(hObject,handles);
    updatePlots(handles);

% --- Executes during object creation, after setting all properties.
function climinframin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to climinframin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function climinframax_Callback(hObject, eventdata, handles)
% hObject    handle to climinframax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of climinframax as text
%        str2double(get(hObject,'String')) returns contents of climinframax as a double
    handles.parenthandles.climinfra(2) = str2num(get(hObject,'String'));
    set(handles.sliderinframax,'Value',handles.parenthandles.climinfra(2));
    set(handles.sliderinframax,'Max',handles.parenthandles.climinfra(2)+20);
    guidata(hObject,handles);
    updatePlots(handles);

% --- Executes during object creation, after setting all properties.
function climinframax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to climinframax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function sliderinframax_Callback(hObject, eventdata, handles)
% hObject    handle to sliderinframax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
    handles.parenthandles.climinfra(2) = get(hObject,'Value');
    set(handles.climinframax,'String',num2str(handles.parenthandles.climinfra(2)));
    if(get(hObject,'Value') == get(hObject,'Max'))
        set(hObject,'Max',handles.parenthandles.climinfra(2)+20);
    end
    guidata(hObject,handles);
    updatePlots(handles);

% --- Executes during object creation, after setting all properties.
function sliderinframax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderinframax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function updatePlots(handles)
    hsubplots = handles.parenthandles.figsubsupra;
    for i=1:size(hsubplots,2)
        set(hsubplots(i),'CLim',handles.parenthandles.climsupra); 
    end
    hsubplots = handles.parenthandles.figsubinfra;
    for i=1:size(hsubplots,2)
        set(hsubplots(i),'CLim',handles.parenthandles.climinfra);
    end
    

% --- Executes on button press in resetsupramin.
function resetsupramin_Callback(hObject, eventdata, handles)
% hObject    handle to resetsupramin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    handles.parenthandles.climsupra(1) = handles.parenthandles.climsupra_original(1);
    set(handles.climsupramin,'String',num2str(handles.parenthandles.climsupra_original(1)));
    set(handles.slidersupramin,'Min',handles.parenthandles.climsupra_original(1)-20);
    set(handles.slidersupramin,'Max',handles.parenthandles.climsupra_original(2)+20);
    set(handles.slidersupramin,'Value',handles.parenthandles.climsupra_original(1));
    guidata(hObject,handles);
    updatePlots(handles);
    
% --- Executes on button press in resetsupramax.
function resetsupramax_Callback(hObject, eventdata, handles)
% hObject    handle to resetsupramax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    handles.parenthandles.climsupra(2) = handles.parenthandles.climsupra_original(2);
    set(handles.climsupramax,'String',num2str(handles.parenthandles.climsupra_original(2)));
    set(handles.slidersupramax,'Min',handles.parenthandles.climsupra_original(1)-20);
    set(handles.slidersupramax,'Max',handles.parenthandles.climsupra_original(2)+20);
    set(handles.slidersupramax,'Value',handles.parenthandles.climsupra_original(2));
    guidata(hObject,handles);
    updatePlots(handles);

% --- Executes on button press in resetinframin.
function resetinframin_Callback(hObject, eventdata, handles)
% hObject    handle to resetinframin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    handles.parenthandles.climinfra(1) = handles.parenthandles.climinfra_original(1);
    set(handles.climinframin,'String',num2str(handles.parenthandles.climinfra_original(1)));
    set(handles.sliderinframin,'Min',handles.parenthandles.climinfra_original(1)-20);
    set(handles.sliderinframin,'Max',handles.parenthandles.climinfra_original(2)+20);
    set(handles.sliderinframin,'Value',handles.parenthandles.climinfra_original(1));
    guidata(hObject,handles);
    updatePlots(handles);

% --- Executes on button press in resetinframax.
function resetinframax_Callback(hObject, eventdata, handles)
% hObject    handle to resetinframax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    handles.parenthandles.climinfra(2) = handles.parenthandles.climinfra_original(2);
    set(handles.climinframax,'String',num2str(handles.parenthandles.climinfra_original(2)));
    set(handles.sliderinframax,'Min',handles.parenthandles.climinfra_original(1)-20);
    set(handles.sliderinframax,'Max',handles.parenthandles.climinfra_original(2)+20);
    set(handles.sliderinframax,'Value',handles.parenthandles.climinfra_original(2));
    guidata(hObject,handles);
    updatePlots(handles);