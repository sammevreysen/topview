function varargout = managermice(varargin)
% MANAGERMICE MATLAB code for managermice.fig
%      MANAGERMICE, by itself, creates a new MANAGERMICE or raises the existing
%      singleton*.
%
%      H = MANAGERMICE returns the handle to a new MANAGERMICE or the handle to
%      the existing singleton*.
%
%      MANAGERMICE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MANAGERMICE.M with the given input arguments.
%
%      MANAGERMICE('Property','Value',...) creates a new MANAGERMICE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before managermice_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to managermice_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help managermice

% Last Modified by GUIDE v2.5 27-Mar-2015 18:08:58

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @managermice_OpeningFcn, ...
                   'gui_OutputFcn',  @managermice_OutputFcn, ...
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


% --- Executes just before managermice is made visible.
function managermice_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to managermice (see VARARGIN)
    
    %load files
    projectname = cell2mat(varargin{1});
    handles.projectname = projectname;
    fprintf('Loading project...');
    vars = openProject(projectname);
    varfields = fieldnames(vars);
    for i=1:size(varfields,1)
        handles.(varfields{i}) = vars.(varfields{i});
    end    
    
    if(nargin > 1)
        recreatetopview = varargin{2};
    else
        recreatetopview = false;
    end
    
    %savefolder
    handles.pdfsavefolder = ['saved_project' filesep projectname filesep 'pdf' filesep];
    
    handles.mice = unique(handles.setuptable(:,2));
    handles.conditions = arrayfun(@(x) cell2mat(unique(handles.setuptable(strcmp(handles.setuptable(:,2),x),1))),handles.mice,'UniformOutput',false);
    handles.aprange = arrayfun(@(x) [num2str(min(cell2mat(cellfun(@(y) y.bregma, handles.setuptable(strcmp(handles.setuptable(:,2),x),5),'UniformOutput',false)))) '-' num2str(max(cell2mat(cellfun(@(y) y.bregma, handles.setuptable(strcmp(handles.setuptable(:,2),x),5),'UniformOutput',false))))],handles.mice,'UniformOutput',false);
        
    if(~isfield(handles,'topview') || recreatetopview)
        handles.topview = createTopviewFile(handles.setuptable);
    end
        
    normalisation = arrayfun(@(x) isfield(handles.topview.mice.(x{:}),'normfactor_supra'),handles.mice,'UniformOutput',false);
    
    lr = {'left' 'right'};
    
    headers = {'Select','Mouse','Condition','A-P range','Hemisphere','Norm area'};
    colformat = {'logical','char','char','char',lr,'logical'};
    coledit = [true,false(1,3),true,true];
    
    hemisphere = cellfun(@(x) handles.topview.mice.(x).hemisphere,handles.mice,'UniformOutput',false);
    
    data = [num2cell(true(size(handles.mice,1),1)) handles.mice handles.conditions handles.aprange hemisphere normalisation];
    set(handles.uitable,'ColumnFormat',colformat,'ColumnEditable',coledit,'ColumnName',headers,'Data',data,'CellEditCallback',@selecttable);
    
    set(handles.popnormalize,'String',[{'None'}; handles.mice]);
    if(~isnan(handles.topview.normalizetomouse))
        set(handles.popnormalize,'Value',find(ismember([{'None'}; handles.mice],handles.topview.normalizetomouse)));
    end
    
    saveProject(handles,'topview');
    
    % Choose default command line output for managermice
    handles.output = hObject;
    
    % Update handles structure
    guidata(hObject, handles);
    
    % UIWAIT makes managermice wait for user response (see UIRESUME)
    %uiwait(handles.figmanagermice);

function handles = selecttable(hObject,callbackdata)
    handles = guidata(hObject);
    data = get(hObject,'Data');
    if(callbackdata.NewData == true & callbackdata.Indices(2) == 6)
        %load mice topview
        h = figure();
        mouse = handles.mice{callbackdata.Indices(1)};
        set(h,'Name',mouse);
        areas = size(handles.topview.mice.(mouse).arearelsupra,2);
        r = callbackdata.Indices(1);
        c = callbackdata.Indices(2);
        %supra
        ax(1) = subplot(1,2,1);
        suporinfra = 'supra';
        handles.topview = interpolate_mouse(handles.topview,mouse,suporinfra);
        imagesc(handles.topview.mice.(mouse).segmentsinterpol,handles.topview.mice.(mouse).bregmasinterpol,handles.topview.mice.(mouse).([suporinfra 'interpol']));
        hold on;
        plot(handles.topview.mice.(mouse).(['arearel' suporinfra 'interpol']),repmat(handles.topview.mice.(mouse).bregmasinterpol,1,areas),'k-');
        hold off;
        title('Supra');
        %infra
        ax(2) = subplot(1,2,2);
        suporinfra = 'infra';
        handles.topview = interpolate_mouse(handles.topview,mouse,suporinfra);
        imagesc(handles.topview.mice.(mouse).segmentsinterpol,handles.topview.mice.(mouse).bregmasinterpol,handles.topview.mice.(mouse).([suporinfra 'interpol']));
        hold on;
        plot(handles.topview.mice.(mouse).(['arearel' suporinfra 'interpol']),repmat(handles.topview.mice.(mouse).bregmasinterpol,1,5),'k-');
        hold off;
        title('Infra');
        %define normalisation factor based on normalisation area
        [handles.topview.mice.(mouse).normfactormask_supra, handles.topview.mice.(mouse).normfactor_supra] = definenormfactor(ax(1),handles.topview.mice.(mouse).suprainterpol);
        [handles.topview.mice.(mouse).normfactormask_infra, handles.topview.mice.(mouse).normfactor_infra] = definenormfactor(ax(2),handles.topview.mice.(mouse).infrainterpol);
        close(h);
        if(isnan(handles.topview.mice.(mouse).normfactor_supra) || isnan(handles.topview.mice.(mouse).normfactor_infra))
            data{r,c} = false;
        else
            data{r,c} = true;
            saveProject(handles,'topview');
        end
        set(hObject,'Data',data);
    elseif(callbackdata.Indices(2) == 5)
        handles.topview.mice.(data{callbackdata.Indices(1),2}).hemisphere = callbackdata.NewData;
       
    end
    
    guidata(hObject,handles);
    
    
function topview = interpolate_mouse(topview,mouse,suporinfra)
    %interpolate data
    [x y] = meshgrid(1:size(topview.mice.(mouse).(suporinfra),2),topview.mice.(mouse).bregmas);
    [xi yi] = meshgrid(1:0.1:size(x,2),y(1):1:y(end)); %for rat and mice: 120µm sections, 10µm interpolation = 1unit
    topview.mice.(mouse).([suporinfra 'interpol']) = interp2(x,y,topview.mice.(mouse).(suporinfra),xi,yi,'linear');
    topview.mice.(mouse).segmentsinterpol = xi(1,:);
    topview.mice.(mouse).bregmasinterpol = yi(:,1);
    topview.mice.(mouse).segments = x(1,:);
    %interpolate areas
    [xa ya] = meshgrid(1:size(topview.mice.(mouse).(['arearel' suporinfra]),2),topview.mice.(mouse).bregmas);
    [xai yai] = meshgrid(1:size(topview.mice.(mouse).(['arearel' suporinfra]),2),y(1):1:y(end));
    topview.mice.(mouse).(['arearel' suporinfra 'interpol']) = interp2(xa,ya,topview.mice.(mouse).(['arearel' suporinfra]),xai,yai,'linear');
    %extra smoothing
    topview.mice.(mouse).(['arearel' suporinfra 'interpolsmooth']) = topview.mice.(mouse).arearelsuprainterpol;
    
function topview = interpolate_condition(topview,condition,suporinfra)
     micelist = topview.conditions.(condition).mice;
     arealborders = topview.arealborders;
     bregmalist = [];
     segments = 1:topview.segments;
     for jjj = 1:size(micelist,1)
         bregmalist = [bregmalist; topview.mice.(micelist{jjj}).bregmas];
     end
     bregmalist = unique(bregmalist);
     topview.conditions.(condition).bregmas = bregmalist;
     topview.conditions.(condition).segments = segments;
     %stack and align all animal in matrix (bregmas x segments x
     %animals)
     topview.conditions.(condition).(suporinfra) = nan(size(bregmalist,1),size(segments,2),size(micelist,1));
     topview.conditions.(condition).(['arearel' suporinfra]) = nan(size(bregmalist,1),arealborders,size(micelist,1));
     for jjj = 1:size(micelist,1)
         topview.conditions.(condition).(suporinfra)(ismember(bregmalist,topview.mice.(micelist{jjj}).bregmas),:,jjj) = topview.mice.(micelist{jjj}).(suporinfra).*topview.mice.(micelist{jjj}).(['normalizefactor_' suporinfra]);
         topview.conditions.(condition).(['arearel' suporinfra])(ismember(bregmalist,topview.mice.(micelist{jjj}).bregmas),:,jjj) = topview.mice.(micelist{jjj}).(['arearel' suporinfra]);
     end
     topview.conditions.(condition).([suporinfra '_mean']) = nanmean(topview.conditions.(condition).(suporinfra),3);
     topview.conditions.(condition).(['arearel' suporinfra '_mean']) = nanmean(topview.conditions.(condition).(['arearel' suporinfra]),3);
     
     %interpolate
     %flatmount
     [x y] = meshgrid(segments,topview.conditions.(condition).bregmas);
     [xi yi] = meshgrid(1:0.1:size(x,2),y(1):1:y(end));
     topview.conditions.(condition).([suporinfra '_mean_interpol']) = interp2(x,y,topview.conditions.(condition).([suporinfra '_mean']),xi,yi,'linear');
     topview.conditions.(condition).segmentsinterpol = xi(1,:);
     topview.conditions.(condition).bregmasinterpol = yi(:,1);
     [xa ya] = meshgrid(1:topview.arealborders,bregmalist);
     [xai yai] = meshgrid(1:topview.arealborders,ya(1):1:ya(end));
     topview.conditions.(condition).(['arearel' suporinfra '_mean_interpol']) = interp2(xa,ya,topview.conditions.(condition).(['arearel' suporinfra '_mean']),xai,yai,'linear');
     %topview
     lr = {'left' 'right'};
     xs = topview.generalmodel.(topview.conditions.(condition).hemisphere).(['mask_' suporinfra]);
     ys = repmat(topview.bregmas,1,size(xs,2));
     xi = topview.generalmodel.(topview.conditions.(condition).hemisphere).(['xi_' suporinfra]);
     yi = topview.generalmodel.(topview.conditions.(condition).hemisphere).(['yi_' suporinfra]);
     v = topview.conditions.(condition).([suporinfra '_mean']);
     vnnan = ismember(topview.bregmas,topview.conditions.(condition).bregmas);
     tmp = griddata(xs(vnnan,:),ys(vnnan,:),v,xi,yi,'linear');
     topview.conditions.(condition).(['topview_' suporinfra '_mean_interpol']) = tmp;
     topview.conditions.(condition).(['topview_' suporinfra '_xi']) = xi;
     topview.conditions.(condition).(['topview_' suporinfra '_yi']) = yi;
     [xa ya] = meshgrid(1:topview.arealborders,topview.bregmas);
     [xai yai] = meshgrid(1:topview.arealborders,min(ys(:)):max(ys(:)));
     va = topview.generalmodel.(topview.conditions.(condition).hemisphere).(['areas_' suporinfra]);
     topview.conditions.(condition).(['topview_area_' suporinfra '_mean_interpol']) = interp2(xa,ya,va,xai,yai,'linear');
     topview.conditions.(condition).(['topview_area_' suporinfra '_xi']) = xai;
     topview.conditions.(condition).(['topview_area_' suporinfra '_yi']) = yai;

function [mask, normfactor] = definenormfactor(ax,data)
    set(gcf,'CurrentAxes',ax(1));
    Imask = roipoly;
    if(~isempty(Imask))
        normfactor = nanmean(nanmean(data(Imask)));
        mask = Imask;
    else
        normfactor = NaN;
        mask = NaN;
        warndlg('Normalisation not set!');
    end

function handles = normalizemice(handles)
    list = cellstr(get(handles.popnormalize,'String'));
    sel = list{get(handles.popnormalize,'Value')};
    if(strcmp(sel,'None'))
        for i=1:size(handles.topview.micenames,1)
            handles.topview.mice.(handles.topview.micenames{i}).normalizefactor_supra = 1;
            handles.topview.mice.(handles.topview.micenames{i}).normalizefactor_infra = 1;
        end
        handles.topview.normalizetomouse = NaN;
    else
        %check if all mice have a normalisation area defined
        data = get(handles.uitable,'Data');
        ok = all(cell2mat(data(:,end)));
        if(ok)
            for i=1:size(handles.topview.micenames,1)
                handles.topview.mice.(handles.topview.micenames{i}).normalizefactor_supra = handles.topview.mice.(sel).normfactor_supra/handles.topview.mice.(handles.topview.micenames{i}).normfactor_supra;
                handles.topview.mice.(handles.topview.micenames{i}).normalizefactor_infra = handles.topview.mice.(sel).normfactor_infra/handles.topview.mice.(handles.topview.micenames{i}).normfactor_infra;
                switch get(get(handles.uipanel1,'SelectedObject'),'UserData')
                    case 'supra'
                        handles.topview.mice.(handles.topview.micenames{i}).normalizefactor_infra = handles.topview.mice.(handles.topview.micenames{i}).normalizefactor_supra;
                    case 'infra'
                        handles.topview.mice.(handles.topview.micenames{i}).normalizefactor_supra = handles.topview.mice.(handles.topview.micenames{i}).normalizefactor_infra;
                end
            end
            handles.topview.normalizetomouse = sel;
        else
            warndlg('Not all mice have a normalization area defined, please correct.');
        end
                
    end
    
% --- Outputs from this function are returned to the command line.
function varargout = managermice_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in popnormalize.
function popnormalize_Callback(hObject, eventdata, handles)
% hObject    handle to popnormalize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popnormalize contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popnormalize
    handles = normalizemice(handles);
    handles = saveProject(handles,'topview');
    guidata(hObject,handles);



% --- Executes during object creation, after setting all properties.
function popnormalize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popnormalize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in push_comparecondition.
function push_comparecondition_Callback(hObject, eventdata, handles)
% hObject    handle to push_comparecondition (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    managercondition({handles.projectname});


% --- Executes when selected object is changed in uipanel1.
function uipanel1_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uipanel1 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
    handles = normalizemice(handles);
    handles = saveProject(handles,'topview');
    guidata(hObject,handles);

function drawpermouse(hObject,handles,view)
    figsupra = figure('Visible','off');
    cmenusupra = uicontextmenu;
    uimenu(cmenusupra, 'Label', 'Enlarge', 'Callback', @enlargesubplot);
    hMenu = uimenu(figsupra,'Label','Save');
    uimenu(hMenu,'Label','Save as PDF...','Callback',{@saveFigAsPDF,hObject});
    figinfra = figure('Visible','off');
    cmenuinfra = uicontextmenu;
    uimenu(cmenuinfra, 'Label', 'Enlarge', 'Callback', @enlargesubplot);
    hMenu = uimenu(figinfra,'Label','Save');
    uimenu(hMenu,'Label','Save as PDF...','Callback',{@saveFigAsPDF,hObject})
    for i=1:size(handles.topview.micenames,1)
        %supra
        figure(figsupra);
        figsubsupra(i) = subplot(ceil(size(handles.topview.micenames,1)/4),min(size(handles.topview.micenames,1),4),i);
        if(~isfield(handles.topview.mice.(handles.topview.micenames{i}),'normalizefactor_supra'))
            handles = normalizemice(handles);
        end
        if(~isfield(handles.topview.mice.(handles.topview.micenames{i}),'segmentsinterpol'))
            handles.topview = interpolate_mouse(handles.topview,handles.topview.micenames{i},'supra');
            handles.topview = interpolate_mouse(handles.topview,handles.topview.micenames{i},'infra');
        end
        switch view
            case 'flatmount'
                imagesc(handles.topview.mice.(handles.topview.micenames{i}).segmentsinterpol,handles.topview.mice.(handles.topview.micenames{i}).bregmasinterpol/100,handles.topview.mice.(handles.topview.micenames{i}).suprainterpol.*handles.topview.mice.(handles.topview.micenames{i}).normalizefactor_supra);
                hold on;
                plot(handles.topview.mice.(handles.topview.micenames{i}).arearelsupra,handles.topview.mice.(handles.topview.micenames{i}).bregmas/100,'k-');
                plot(ones(1,size(handles.topview.mice.(handles.topview.micenames{i}).bregmas,1)),handles.topview.mice.(handles.topview.micenames{i}).bregmas/100,'k>');
                hold off;
            case 'topview'
                xs = handles.topview.mice.(handles.topview.micenames{i}).topcoxyprojected_smooth./handles.topview.pixpermm*100;
                bregmas = handles.topview.mice.(handles.topview.micenames{i}).bregmas;
                v = handles.topview.mice.(handles.topview.micenames{i}).supra.*handles.topview.mice.(handles.topview.micenames{i}).normalizefactor_supra;
                ys = repmat(handles.topview.mice.(handles.topview.micenames{i}).bregmas,1,size(xs,2));
                [xi yi] = meshgrid(min(xs(:)):max(xs(:)),min(bregmas(:)):max(bregmas(:))); %abs(min(min(xsupra),0)-max(max(xsupra),0))/500
                suprainterpolprojected = griddata(xs,ys,v,xi,yi,'linear');
                pcolor(xi/100,yi/100,suprainterpolprojected);
                shading flat;
                axis equal;
                axis ij;
                hold on;
                plot(handles.topview.mice.(handles.topview.micenames{i}).topareaxyprojected_smooth/handles.topview.pixpermm,handles.topview.mice.(handles.topview.micenames{i}).bregmas/100,'k-');
                if(xs < 0)
                    ls = 'k<';
                else
                    ls = 'k>';
                end
                plot(zeros(1,size(handles.topview.mice.(handles.topview.micenames{i}).bregmas,1)),handles.topview.mice.(handles.topview.micenames{i}).bregmas/100,ls);
                hold off;
        end
        colormap jet;
        set(figsubsupra(i), 'Uicontextmenu',cmenusupra);
        set(figsubsupra(i),'Tag','jet');
        if(strcmp(handles.topview.micenames{i},handles.topview.normalizetomouse))
            title([handles.topview.micenames{i} ' - Supra (*)']);
        else
            title([handles.topview.micenames{i} ' - Supra']);
        end
        lims = ylim;
        bregmasupra(i,:) = lims;
        xlimsupra(i,:) = xlim;
        climsupra(i,:) = caxis;
        
        %infra
        figure(figinfra);
        figsubinfra(i) = subplot(ceil(size(handles.topview.micenames,1)/4),min(size(handles.topview.micenames,1),4),i);
        switch view
            case 'flatmount'
                imagesc(handles.topview.mice.(handles.topview.micenames{i}).segmentsinterpol,handles.topview.mice.(handles.topview.micenames{i}).bregmasinterpol,handles.topview.mice.(handles.topview.micenames{i}).infrainterpol.*handles.topview.mice.(handles.topview.micenames{i}).normalizefactor_infra);
                hold on;
                plot(handles.topview.mice.(handles.topview.micenames{i}).arearelinfra,handles.topview.mice.(handles.topview.micenames{i}).bregmas/100,'k-');
                plot(ones(1,size(handles.topview.mice.(handles.topview.micenames{i}).bregmas,1)),handles.topview.mice.(handles.topview.micenames{i}).bregmas/100,'k>');
                hold off;
            case 'topview'
                xs = handles.topview.mice.(handles.topview.micenames{i}).botcoxyprojected_smooth./handles.topview.pixpermm*100;
                bregmas = handles.topview.mice.(handles.topview.micenames{i}).bregmas;
                v = handles.topview.mice.(handles.topview.micenames{i}).infra.*handles.topview.mice.(handles.topview.micenames{i}).normalizefactor_infra;
                ys = repmat(handles.topview.mice.(handles.topview.micenames{i}).bregmas,1,size(xs,2));
                [xi yi] = meshgrid(min(xs(:)):max(xs(:)),min(bregmas(:)):max(bregmas(:))); %abs(min(min(xsupra),0)-max(max(xsupra),0))/500
                suprainterpolprojected = griddata(xs,ys,v,xi,yi,'linear');
                pcolor(xi/100,yi/100,suprainterpolprojected);
                shading flat;
                axis equal;
                axis ij;
                hold on;
                plot(handles.topview.mice.(handles.topview.micenames{i}).botareaxyprojected_smooth/handles.topview.pixpermm,handles.topview.mice.(handles.topview.micenames{i}).bregmas/100,'k-');
                if(xs < 0)
                    ls = 'k<';
                else
                    ls = 'k>';
                end
                plot(zeros(1,size(handles.topview.mice.(handles.topview.micenames{i}).bregmas,1)),handles.topview.mice.(handles.topview.micenames{i}).bregmas/100,ls);
                hold off;
        end
        colormap jet;
        set(figsubinfra(i), 'Uicontextmenu',cmenuinfra);
        set(figsubinfra(i),'Tag','jet');
        if(strcmp(handles.topview.micenames{i},handles.topview.normalizetomouse))
            title([handles.topview.micenames{i} ' - Infra (*)']);
        else
            title([handles.topview.micenames{i} ' - Infra']);
        end
        lims = ylim;
        bregmainfra(i,:) = lims;
        xliminfra(i,:) = xlim;
        climinfra(i,:) = caxis;
    end
    set(figsubsupra,'Clim',[0 100]);
    set(figsubinfra,'Clim',[0 100]);
    set(figsubsupra,'Ylim',[min(bregmasupra(:,1)) max(bregmasupra(:,2))]);
    set(figsubinfra,'Ylim',[min(bregmainfra(:,1)) max(bregmainfra(:,2))]);
    set(figsubsupra,'Xlim',[min(xlimsupra(:,1)) max(xlimsupra(:,2))]);
    set(figsubsupra,'Xlim',[min(xlimsupra(:,1))*(1 - (sign(min(xlimsupra(:,1)))*0.03)) max(xlimsupra(:,2))*(1 + (sign(min(xlimsupra(:,1)))*0.03))]);
    set(figsubinfra,'Xlim',[min(xliminfra(:,1))*(1 - (sign(min(xliminfra(:,1)))*0.03)) max(xliminfra(:,2))*(1 + (sign(min(xliminfra(:,1)))*0.03))]);
    set(figsupra,'Visible','on');
    set(figinfra,'Visible','on');
    guidata(hObject,handles);
    saveProject(handles,'topview');
        
function drawpercondition(hObject,handles,view)
    figsupra = figure('Visible','off');
    cmenusupra = uicontextmenu;
    uimenu(cmenusupra, 'Label', 'Enlarge', 'Callback', @enlargesubplot);
    hMenu = uimenu(figsupra,'Label','Save');
    uimenu(hMenu,'Label','Save as PDF...','Callback',{@saveFigAsPDF,hObject});
    figinfra = figure('Visible','off');
    cmenuinfra = uicontextmenu;
    uimenu(cmenuinfra, 'Label', 'Enlarge', 'Callback', @enlargesubplot);
    hMenu = uimenu(figinfra,'Label','Save');
    uimenu(hMenu,'Label','Save as PDF...','Callback',{@saveFigAsPDF,hObject})
    for i=1:size(handles.topview.conditionnames,1)
        condition = handles.topview.conditionnames{i};
        handles.topview = interpolate_condition(handles.topview,condition,'supra');
        handles.topview = interpolate_condition(handles.topview,condition,'infra');
        marg = [0.05 0.05];
        switch view
            case 'flatmount'
                figure(figsupra);
                figsubsupra(i) = subplot_tight(ceil(size(handles.topview.conditionnames,1)/4),min(size(handles.topview.conditionnames,1),4),i,marg);
                imagesc(handles.topview.conditions.(condition).segmentsinterpol,handles.topview.conditions.(condition).bregmasinterpol,handles.topview.conditions.(condition).supra_mean_interpol);
                hold on;
                plot(handles.topview.conditions.(condition).arearelsupra_mean_interpol,handles.topview.conditions.(condition).bregmasinterpol,'k-');
                plot(ones(size(handles.topview.conditions.(condition).bregmas,1),1),handles.topview.conditions.(condition).bregmas,'k>');
                hold off;
                set(figsubsupra(i), 'Uicontextmenu',cmenusupra);
                set(figsubsupra(i),'Tag','jet');
                title([condition ' - Supra']);
                lims = ylim;
                bregmasupra(i,:) = lims;
                climsupra(i,:) = caxis;
                
                figure(figinfra);
                figsubinfra(i) = subplot_tight(ceil(size(handles.topview.conditionnames,1)/4),min(size(handles.topview.conditionnames,1),4),i,marg);
                imagesc(handles.topview.conditions.(condition).segmentsinterpol,handles.topview.conditions.(condition).bregmasinterpol,handles.topview.conditions.(condition).infra_mean_interpol);
                hold on;
                plot(handles.topview.conditions.(condition).arearelinfra_mean_interpol,handles.topview.conditions.(condition).bregmasinterpol,'k-');
                plot(ones(size(handles.topview.conditions.(condition).bregmas,1),1),handles.topview.conditions.(condition).bregmas,'k>');
                hold off;
                set(figsubinfra(i), 'Uicontextmenu',cmenuinfra);
                set(figsubinfra(i),'Tag','jet');
                title([condition ' - Infra']);
                lims = ylim;
                bregmainfra(i,:) = lims;
                climinfra(i,:) = caxis;
            case 'topview'
                figure(figsupra);
                figsubsupra(i) = subplot_tight(ceil(size(handles.topview.conditionnames,1)/4),min(size(handles.topview.conditionnames,1),4),i,marg);
                pcolor(handles.topview.conditions.(condition).topview_supra_xi/100,handles.topview.conditions.(condition).topview_supra_yi/100,handles.topview.conditions.(condition).topview_supra_mean_interpol);
                shading flat;
                axis equal;
                axis ij;
                hold on;
                plot(handles.topview.conditions.(condition).topview_area_supra_mean_interpol/100,handles.topview.conditions.(condition).topview_area_supra_yi/100,'k-');
                hold off;
                set(figsubsupra(i), 'Uicontextmenu',cmenusupra);
                set(figsubsupra(i),'Tag','jet');
                title([condition ' - Supra']);
                lims = ylim;
                bregmasupra(i,:) = lims;
                climsupra(i,:) = caxis;
                
                figure(figinfra);
                figsubinfra(i) = subplot_tight(ceil(size(handles.topview.conditionnames,1)/4),min(size(handles.topview.conditionnames,1),4),i,marg);
                pcolor(handles.topview.conditions.(condition).topview_infra_xi/100,handles.topview.conditions.(condition).topview_infra_yi/100,handles.topview.conditions.(condition).topview_infra_mean_interpol);
                shading flat;
                axis equal;
                axis ij;
                hold on;
                plot(handles.topview.conditions.(condition).topview_area_infra_mean_interpol/100,handles.topview.conditions.(condition).topview_area_infra_yi/100,'k-');
                hold off;
                set(figsubinfra(i), 'Uicontextmenu',cmenuinfra);
                set(figsubinfra(i),'Tag','jet');
                title([condition ' - Infra']);
                lims = ylim;
                bregmainfra(i,:) = lims;
                climinfra(i,:) = caxis;
                
        end
    end
%     set(figsubsupra,'Clim',[min(min(climsupra(:)),min(climinfra(:))) max(max(climsupra(:)),max(climinfra(:)))]);
%     set(figsubinfra,'Clim',[min(min(climsupra(:)),min(climinfra(:))) max(max(climsupra(:)),max(climinfra(:)))]);
    set(figsubsupra,'Clim',[0 100]);
    set(figsubinfra,'Clim',[0 100]);
%     set(figsubsupra,'Ylim',[min(bregmasupra(:,1)) max(bregmasupra(:,2))]);
%     set(figsubinfra,'Ylim',[min(bregmainfra(:,1)) max(bregmainfra(:,2))]);
    colormap(figsupra,jet);
    colormap(figinfra,jet);
    set(figsupra,'Visible','on');
    set(figinfra,'Visible','on');
    guidata(hObject,handles);
    saveProject(handles,'topview');

% --- Executes on button press in push_drawpermouse_topview.
function push_drawpermouse_topview_Callback(hObject, eventdata, handles)
% hObject    handle to push_drawpermouse_topview (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    drawpermouse(hObject,handles,'topview');

% --- Executes on button press in push_drawpercondition_topview.
function push_drawpercondition_topview_Callback(hObject, eventdata, handles)
% hObject    handle to push_drawpercondition_topview (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    drawpercondition(hObject,handles,'topview');

% --- Executes on button press in push_drawpermouse_flat.
function push_drawpermouse_flat_Callback(hObject, eventdata, handles)
% hObject    handle to push_drawpermouse_flat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    drawpermouse(hObject,handles,'flatmount');

% --- Executes on button press in push_drawpercondition_flat.
function push_drawpercondition_flat_Callback(hObject, eventdata, handles)
% hObject    handle to push_drawpercondition_flat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    drawpercondition(hObject,handles,'flatmount');