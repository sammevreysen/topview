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

% Last Modified by GUIDE v2.5 18-Mar-2016 14:07:51

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
    fprintf('Loading project...\n');
    vars = openProject(projectname);
    varfields = fieldnames(vars);
    for i=1:size(varfields,1)
        handles.(varfields{i}) = vars.(varfields{i});
    end    
    
    if(nargin > 4)
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
        saveProject(handles,'topview');
    else
       if(~isfield(handles.topview,'suporinfra'))
           handles.topview.suporinfra = {'supra';'infra';'total'};
       end
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
%         handles.topview = interpolate_mouse(handles.topview,mouse,suporinfra);
        imagesc(handles.topview.mice.(mouse).segmentsinterpol,handles.topview.mice.(mouse).bregmasinterpol,handles.topview.mice.(mouse).([suporinfra 'interpol']));
        hold on;
        plot(handles.topview.mice.(mouse).(['arearel' suporinfra 'interpol']),repmat(handles.topview.mice.(mouse).bregmasinterpol,1,areas),'k-');
        hold off;
        title('Supra');
        %infra
        ax(2) = subplot(1,2,2);
        suporinfra = 'infra';
%         handles.topview = interpolate_mouse(handles.topview,mouse,suporinfra);
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
    suporinfra = handles.topview.suporinfra;    
    for j=1:length(suporinfra)
        fig(j) = figure('Visible','off');
        colormap jet;
        cmenu(j) = uicontextmenu;
        uimenu(cmenu(j), 'Label', 'Enlarge', 'Callback', @enlargesubplot);
        hMenu = uimenu(fig(j),'Label','Save');
        uimenu(hMenu,'Label','Save as PDF...','Callback',{@saveFigAsPDF,hObject});
    end
   
    for i=1:size(handles.topview.micenames,1)
        mouse = handles.topview.micenames{i};
        hemisphere = handles.topview.mice.(mouse).hemisphere;
        for j=1:length(suporinfra)
            figure(fig(j));
            figsub(j,i) = subplot(ceil(size(handles.topview.micenames,1)/4),min(size(handles.topview.micenames,1),4),i);
            if(~isfield(handles.topview.mice.(mouse),['normalizefactor_' suporinfra{j}]))
                handles = normalizemice(handles);
            end
            %         if(~isfield(handles.topview.mice.(mouse),'segmentsinterpol'))
            %             handles.topview = interpolate_mouse(handles.topview,mouse,'supra');
            %             handles.topview = interpolate_mouse(handles.topview,mouse,'infra');
            %         end
            switch view
                case 'flatmount'
                    imagesc(handles.topview.mice.(mouse).segmentsinterpol,handles.topview.mice.(mouse).bregmasinterpol/100,handles.topview.mice.(mouse).([suporinfra 'interpol']) .* handles.topview.mice.(mouse).(['normalizefactor_' suporinfra]));
                    hold on;
                    plot(handles.topview.mice.(mouse).(['arearel' suporinfra{j}]),handles.topview.mice.(mouse).bregmas/100,'k-');
                    plot(ones(1,size(handles.topview.mice.(mouse).bregmas,1)),handles.topview.mice.(mouse).bregmas/100,'k>');
                    hold off;
                case {'topview','topview_gm'}
                    if(strcmp(view,'topview'))
                        xs = handles.topview.mice.(mouse).([suporinfra{j} 'coxyprojected_smooth'])./handles.topview.pixpermm*100;
                        bregmas = handles.topview.mice.(mouse).bregmas;
                        v = handles.topview.mice.(mouse).(suporinfra{j}) .* handles.topview.mice.(mouse).(['normalizefactor_' suporinfra{j}]);
                        ys = repmat(handles.topview.mice.(mouse).bregmas,1,size(xs,2));
                        [xi,yi] = meshgrid(min(xs(:)):max(xs(:)),min(bregmas(:)):max(bregmas(:))); %abs(min(min(xsupra),0)-max(max(xsupra),0))/500
                        interpolprojected = concave_griddata(xs,ys,v,xi,yi);
                        interpolprojected  = smoothfct(handles.topview,interpolprojected);
                    else
                        xi = handles.topview.generalmodel.(handles.topview.mice.(mouse).hemisphere).(['xi_' suporinfra{j}]);
                        yi = handles.topview.generalmodel.(handles.topview.mice.(mouse).hemisphere).(['yi_' suporinfra{j}]);
                        interpolprojected = handles.topview.mice.(mouse).([suporinfra{j} 'interpol_gm_smooth']);
                    end
%                     pcolor_rgb(xi/100,-yi/100,interpolprojected);
                    image(xi(1,:)/100,-yi(:,1)/100,scaleRGB(interpolprojected));
                    hold on;
                    if(strcmp(view,'topview'))
                        plot(handles.topview.mice.(mouse).([suporinfra{j} 'areaxyprojected_smooth'])./handles.topview.pixpermm,-handles.topview.mice.(mouse).bregmas/100,'k-');
                    else
                        plot(handles.topview.generalmodel.(hemisphere).(['areas_' suporinfra{j}])./100,-handles.topview.bregmas/100,'k-');
                    end
                    if(all(xi < 0))
                        ls = 'k<';
                    else
                        ls = 'k>';
                    end
                    plot(-3.7*ones(1,size(handles.topview.mice.(mouse).bregmas,1)),-handles.topview.mice.(mouse).bregmas/100,ls);
                    hold off;
            end
            
            set(figsub(j,i), 'Uicontextmenu',cmenu(j));
            set(figsub(j,i),'Tag','jet');
            if(strcmp(mouse,handles.topview.normalizetomouse))
                title([mouse ' - ' suporinfra{j} ' (*)']);
            else
                title([mouse ' - ' suporinfra{j}]);
            end
            ylims{j,i} = ylim;
            xlims{j,i} = xlim;
            clims{j,i} = caxis;
        end
        
    end
    ylims = cell2mat(ylims(:));
    xlims = cell2mat(xlims(:));
    clims = cell2mat(clims(:));
    figsub(1:2,:) = [];
    set(figsub,'Clim',[0 100]);
    set(figsub,'Ylim',[min(ylims(:,1)) max(ylims(:,2))]);
%     set(figsub,'Xlim',[min(xlims(:,1)) max(xlims(:,2))]);
    set(figsub,'Xlim',[min(xlims(:,1))*(1 - (sign(min(xlims(:,1)))*0.03)) max(xlims(:,2))*(1 + (sign(min(xlims(:,1)))*0.03))]);
    set(fig,'Visible','on');
    axis ij equal tight;
    guidata(hObject,handles);
%     saveProject(handles,'topview');
        
function drawpercondition(hObject,handles,view)
    suporinfra = handles.topview.suporinfra;    
    for j=1:length(suporinfra)
        fig(j) = figure('Visible','off');
        colormap jet;
        cmenu(j) = uicontextmenu;
        uimenu(cmenu(j), 'Label', 'Enlarge', 'Callback', @enlargesubplot);
        hMenu = uimenu(fig(j),'Label','Save');
        uimenu(hMenu,'Label','Save as PDF...','Callback',@saveFigAsPDF);
        hMenu2 = uimenu(fig(j),'Label','Areamask');
        hsubmenu = uimenu(hMenu2,'Label','Add area mask');
        uimenu(hsubmenu,'Label','None','Callback',@addareamaskoverlay,'Checked','on');
        files = dir(['visual_areas_mask' filesep '*.mat']);
        for i=1:size(files,1)
            uimenu(hsubmenu,'Label',strrep(files(i).name,'.mat',''),'Callback',@addareamaskoverlay);
        end
        hsubmenu2 = uimenu(hMenu2,'Label','Change layout...');
        for i=1:size(files,1)
            uimenu(hsubmenu2,'Label',strrep(files(i).name,'.mat',''),'Callback',@changeareamaskoverlay);
        end
    end
    if 1
        for i=1:size(handles.topview.conditionnames,1)
            condition = handles.topview.conditionnames{i};
            marg = [0.05 0.05];
            for j=1:length(suporinfra)
                switch view
                    case 'flatmount'
                        figure(fig(j));
                        figsub(j,i) = subplot_tight(ceil(size(handles.topview.conditionnames,1)/4),min(size(handles.topview.conditionnames,1),4),i,marg);
                        imagesc(handles.topview.conditions.(condition).segmentsinterpol,handles.topview.conditions.(condition).bregmasinterpol,handles.topview.conditions.(condition).([suporinfra{j} '_mean_interpol']));
                        hold on;
                        plot(handles.topview.conditions.(condition).(['arearel' suporinfra{j} '_mean_interpol']),handles.topview.conditions.(condition).bregmasinterpol,'k-');
                        plot(ones(size(handles.topview.conditions.(condition).bregmas,1),1),handles.topview.conditions.(condition).bregmas,'k>');
                        hold off;
                    case 'topview'
                        figure(fig(j));
                        figsub(j,i) = subplot_tight(ceil(size(handles.topview.conditionnames,1)/4),min(size(handles.topview.conditionnames,1),4),i,marg);
                        image(handles.topview.conditions.(condition).(['topview_' suporinfra{j} '_xi'])(1,:)/100,-handles.topview.conditions.(condition).(['topview_' suporinfra{j} '_yi'])(:,1)/100,scaleRGB(handles.topview.conditions.(condition).(['topview_' suporinfra{j} '_mean_interpol_smooth'])));
                        hold on;
                        plot(handles.topview.conditions.(condition).(['topview_area_' suporinfra{j} '_mean_interpol'])/100,-handles.topview.conditions.(condition).(['topview_area_' suporinfra{j} '_yi'])/100,'k-');
                        hold off;
                        axis xy equal tight;
                end
                set(figsub(j,i), 'Uicontextmenu',cmenu(j));
                set(figsub(j,i),'Tag','jet');
                title([condition ' - ' suporinfra{j}]);
                xlims(j,i,:) = xlim;
                ylims(j,i,:) = ylim;
                clims(j,i,:) = caxis;
            end
            
        end
        ylims = reshape(ylims,[],2);
        xlims = reshape(xlims,[],2);
        clims = reshape(clims,[],2);
        set(figsub,'Clim',[0 100]);
        set(figsub,'Ylim',[min(ylims(:,1)) max(ylims(:,2))]);
        %     set(figsub,'Xlim',[min(xlims(:,1)) max(xlims(:,2))]);
        set(figsub,'Xlim',[min(xlims(:,1))*(1 - (sign(min(xlims(:,1)))*0.03)) max(xlims(:,2))*(1 + (sign(min(xlims(:,1)))*0.03))]);
    elseif 0
        figure(fig(1));
        a = 1;
        for j=1:length(suporinfra)
            i=2;
            condition = handles.topview.conditionnames{i};
            marg = [0.05 0.05];
            figsub(j,1) = subplot_tight(2,3,a,marg);
            pcolor_rgb(handles.topview.conditions.(condition).(['topview_' suporinfra{j} '_xi'])/100,-handles.topview.conditions.(condition).(['topview_' suporinfra{j} '_yi'])/100,handles.topview.conditions.(condition).(['topview_' suporinfra{j} '_mean_interpol_smooth']));
            hold on;
            plot(handles.topview.conditions.(condition).(['topview_area_' suporinfra{j} '_mean_interpol'])/100,-handles.topview.conditions.(condition).(['topview_area_' suporinfra{j} '_yi'])/100,'k-');
            hold off;
            axis xy equal tight;
            title(condition);
            xlims(j,i,:) = xlim;
            ylims(j,i,:) = ylim;
            clims(j,i,:) = caxis;
            a = a + 1;
            
            
            figsub(j,2) = subplot_tight(2,3,a,marg);
            axis xy equal tight;
            a = a + 1;
            
            i=1;
            condition = handles.topview.conditionnames{i};
            marg = [0.05 0.05];           
            figsub(j,3) = subplot_tight(2,3,a,marg);
            pcolor_rgb(handles.topview.conditions.(condition).(['topview_' suporinfra{j} '_xi'])/100,-handles.topview.conditions.(condition).(['topview_' suporinfra{j} '_yi'])/100,handles.topview.conditions.(condition).(['topview_' suporinfra{j} '_mean_interpol_smooth']));
            hold on;
            plot(handles.topview.conditions.(condition).(['topview_area_' suporinfra{j} '_mean_interpol'])/100,-handles.topview.conditions.(condition).(['topview_area_' suporinfra{j} '_yi'])/100,'k-');
            hold off;
            axis xy equal tight;
            title(condition);
            xlims(j,i,:) = xlim;
            ylims(j,i,:) = ylim;
            clims(j,i,:) = caxis;
            a = a + 1;
            
        end
        ylims = reshape(ylims,[],2);
        xlims = reshape(xlims,[],2);
        clims = reshape(clims,[],2);
        set(figsub,'Clim',[0 100]);
        set(figsub,'Ylim',[min(ylims(:,1)) max(ylims(:,2))]);
        %     set(figsub,'Xlim',[min(xlims(:,1)) max(xlims(:,2))]);
        set(figsub,'Xlim',[min(xlims(:,1))*(1 - (sign(min(xlims(:,1)))*0.03)) max(xlims(:,2))*(1 + (sign(min(xlims(:,1)))*0.03))]);
    end
        
    set(fig,'Visible','on');
    guidata(hObject,handles);

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


% --------------------------------------------------------------------
function Untitled_1_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_recal_topviewmice_Callback(hObject, eventdata, handles)
% hObject    handle to menu_recal_topviewmice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    handles.topview = interpolate_mice_gm(handles.topview);
    fprintf('Topview per animal recalculated\n');
    guidata(hObject,handles);

% --------------------------------------------------------------------
function menu_recal_topviewconditions_Callback(hObject, eventdata, handles)
% hObject    handle to menu_recal_topviewconditions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    handles.topview = interpolate_conditions_gm(handles.topview);
    fprintf('Topview per condition recalculated\n');
    guidata(hObject,handles);


% --- Executes on button press in push_drawpermouse_gm.
function push_drawpermouse_gm_Callback(hObject, eventdata, handles)
% hObject    handle to push_drawpermouse_gm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    drawpermouse(hObject,handles,'topview_gm');


% --------------------------------------------------------------------
function Untitled_2_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_smoothwindow_Callback(hObject, eventdata, handles)
% hObject    handle to menu_smoothwindow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    val = str2num(cell2mat(inputdlg('Size of smoothing window in mm, 0 to disable','Smoothing window',1)));
    set(hObject,'Label',sprintf('Smooth window: %0.3f mm',val));
    handles.topview.smoothwindow = val;
    fprintf('Recalculating topview per animal\n');
    handles.topview = interpolate_mice_gm(handles.topview);
    fprintf('Recalculating topview per condition\n');
    handles.topview = interpolate_conditions_gm(handles.topview);
    fprintf('Finished\n');
    guidata(hObject,handles);
