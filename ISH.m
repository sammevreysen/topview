%-x-x-x- INITIATION GUI -x-x-x-%
function varargout = ISH(varargin)
% ISH M-file for ISH.fig
%      ISH, by itself, creates a new ISH or raises the existing
%      singleton*.
%
%      H = ISH returns the handle to a new ISH or the handle to
%      the existing singleton*.
%
%      ISH('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ISH.M with the given input arguments.
%
%      ISH('Property','Value',...) creates a new ISH or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ISH_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ISH_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ISH

% Last Modified by GUIDE v2.5 14-Apr-2016 11:00:43

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ISH_OpeningFcn, ...
                   'gui_OutputFcn',  @ISH_OutputFcn, ...
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

function ISH_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ISH (see VARARGIN)

% Choose default command line output for ISH
handles.output = hObject;

%mac compatibility
handles.mac = 'off';

%debug option
handles.debug = 0;

%show raster
handles.showraster = 0;

%option don't prepare to pivot
handles.dontpivot = 'on';

%Initiate setuptable and load listboxes
handles.setuptable = initiate_setuptable();
reload_listbox(handles,[1 1 1]);

%set save path and create if it not exists
if(~isdir('saved_analysis'))
    mkdir('saved_analysis');
end
if(strfind(system_dependent('getos'),'Microsoft Windows'))
    handles.savepath = 'saved_analysis\';
else
    handles.savepath = 'saved_analysis/';
end
handles.savename = '';
%path to slices
handles.path = '';

%areas initialisation
handles.areas = get(handles.edit_areas,'String');
handles.arealborders = size(strfind(handles.areas,','),2) + size(strfind(handles.areas,'|'),2)*2 +2;
set(handles.text_arealborders,'String',['-> ' num2str(handles.arealborders) ' areal borders']);
areassplit = regexp(handles.areas,',|\|','split');
areas_pivot{1} = 'None';
for i=1:size(areassplit,2)-1
    areas_pivot{i+1} =sprintf('%s | %s',areassplit{i},areassplit{i+1});
end
set(handles.popup_pivot,'String',areas_pivot);

%segments
handles.rastersegments = str2double(get(handles.edit_segments,'String'));

%graph clear
axis off;

% Update handles structure
guidata(hObject, handles);

function varargout = ISH_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


%-x-x-x- WORKFLOW ROUTINES -x-x-x-%
function handles = addCond(handles)
    cond = char(inputdlg('Enter a condition (must begin with letters and can contain letters and digits [a-zA-Z0-9_])','ISH Project Setup'));
    if(~isempty(cond))
        if(size(regexp(cond,'^[0-9]+|[^a-zA-Z0-9_]+|(_vs_)','match'),1) > 0)
            errordlg('Name contains characters that are not allowed!');
            return;
        end
        borders.arealborder = [];
        borders.topp = [];
        borders.midp = [];
        borders.botp = [];
        rastervalues.meansupra_raw = [];
        rastervalues.meaninfra_raw = [];
        if(size(handles.setuptable,2) > 6)
            handles.setuptable = [handles.setuptable(:,1:6); {char(cond),'-','-','-',borders,rastervalues}];
        else
            handles.setuptable = [handles.setuptable; {char(cond),'-','-','-',borders,rastervalues}];
        end
        handles.setuptable = handles.setuptable(~strcmp(handles.setuptable(:,1),'-'),:);
        reload_listbox(handles,[length(cellstr(get(handles.list_cond,'String'))) 1 1]);
        %update setuptable
    end

function handles = delCond(handles)
    conditions = get(handles.list_cond,'String');
    if(size(conditions,1) == 1)
        borders.arealborder = [];
        borders.topp = [];
        borders.midp = [];
        borders.botp = [];
        rastervalues.meansupra_raw = [];
        rastervalues.meaninfra_raw = [];
        handles.setuptable = {'-','-','-','-',borders,rastervalues};
        reload_listbox(handles,[1 1 1]);
        %update setuptable
    elseif ~isempty(conditions)
        %update setuptable
        handles.setuptable = handles.setuptable(~strcmp(handles.setuptable(:,1),conditions(get(handles.list_cond,'Value'))),:);
        reload_listbox(handles,[1 1 1]);
    end

function handles = addMouse(handles)
    mouse = char(inputdlg('Enter a mouse (must begin with letters and can contain letters and digits [a-zA-Z0-9_])','ISH Project Setup'));
    if(~isempty(mouse))
        if(size(regexp(mouse,'^[0-9]+|[^a-zA-Z0-9_]+','match'),1) > 0)
            errordlg('Name contains characters that are not allowed!');
            return;
        end
        conditions = cellstr(get(handles.list_cond,'String'));
        selcond = char(conditions(get(handles.list_cond,'Value')));
        borders.arealborder = [];
        borders.topp = [];
        borders.midp = [];
        borders.botp = [];
        rastervalues.meansupra_raw = [];
        rastervalues.meaninfra_raw = [];
        if(size(handles.setuptable,2) > 6)
            handles.setuptable = handles.setuptable(:,1:6);
        end
        if(sum(strcmp(handles.setuptable(:,1),selcond) & strcmp(handles.setuptable(:,2),'-')))
            handles.setuptable(strcmp(handles.setuptable(:,1),selcond) & strcmp(handles.setuptable(:,2),'-'),2) = cellstr(mouse);
        else
            handles.setuptable = [handles.setuptable; {selcond, mouse, '-','-',borders,rastervalues}];
        end
        reload_listbox(handles,[get(handles.list_cond,'Value') sum(strcmp(handles.setuptable(:,1),selcond)) 1]);
        disp(handles.setuptable);
    end

function handles = delMouse(handles)
        mice = get(handles.list_mice,'String');
    conditions = get(handles.list_cond,'String');
    cond = conditions(get(handles.list_cond,'Value'));
    if(size(mice,1) == 1)
        borders.arealborder = [];
        borders.topp = [];
        borders.midp = [];
        borders.botp = [];
        rastervalues.meansupra_raw = [];
        rastervalues.meaninfra_raw = [];
        handles.setuptable = handles.setuptable(~strcmp(handles.setuptable(:,1),conditions(get(handles.list_cond,'Value'))),:);
        handles.setuptable = [handles.setuptable; {char(cond), '-', '-','-',borders,rastervalues}];
        reload_listbox(handles,[get(handles.list_cond,'Value') 1  1]);
        %update setuptable
    elseif ~isempty(mice)
        %update setuptable
        handles.setuptable = handles.setuptable(~(strcmp(handles.setuptable(:,1),conditions(get(handles.list_cond,'Value'))) & strcmp(handles.setuptable(:,2),mice(get(handles.list_mice,'Value')))),:);
        reload_listbox(handles,[get(handles.list_cond,'Value') 1 1]);
    end

function handles = addSlice(handles)
    if(size(handles.setuptable,1) > 1 | ~strcmp(handles.setuptable(1,1),'-'))
        if(~isempty(find(~strcmp(handles.setuptable(:,4),'-'),1,'last')))
            filepath = handles.setuptable{find(~strcmp(handles.setuptable(:,4),'-'),1,'last'),4};
        else
            filepath = '';
        end
    else
        filepath = '';
    end
    [handles.filenames handles.path] = uigetfile('*.tif;*.jpg','Select all slices of same experiment',filepath,'MultiSelect','on');
    if(~isnumeric(handles.filenames))
        handles.filenames = cellstr(handles.filenames);
        handles.path = cellstr(handles.path);
        conditions = cellstr(get(handles.list_cond,'String'));
        selcond = conditions(get(handles.list_cond,'Value'));
        mice = cellstr(get(handles.list_mice,'String'));
        selmouse = mice(get(handles.list_mice,'Value'));
        if(size(handles.setuptable,2) > 6)
            handles.setuptable = handles.setuptable(:,1:6);
        end
        %delete row with '-'
        handles.setuptable = handles.setuptable(~(strcmp(handles.setuptable(:,1),selcond) & strcmp(handles.setuptable(:,2),selmouse) & strcmp(handles.setuptable(:,3),'-')),:);
        %empty var for rastervalues
        rastervalues.meansupra_raw = [];
        rastervalues.meaninfra_raw = [];
        %add slices to setuptable
        for i=1:length(handles.filenames)
            %set borders and areas
            borders = setBordersSlice(handles.filenames(i), handles.path, handles);
            %if succesfull store in setuptable
            handles.setuptable = [handles.setuptable; {char(selcond), char(selmouse), char(handles.filenames(i)),char(handles.path),borders,rastervalues}];
            reload_listbox(handles,[get(handles.list_cond,'Value') get(handles.list_mice,'Value') 1]);
        end
        disp(handles.setuptable);
        
    end

function handles = delSlice(handles) 
    slices = get(handles.list_slices,'String');
    slice = slices(get(handles.list_slices,'Value'));
    mice = get(handles.list_mice,'String');
    mouse = mice(get(handles.list_mice,'Value'));
    conditions = get(handles.list_cond,'String');
    cond = conditions(get(handles.list_cond,'Value'));
    if(size(slices,1) == 1)
        borders.arealborder = [];
        borders.topp = [];
        borders.midp = [];
        borders.botp = [];
        rastervalues.meansupra_raw = [];
        rastervalues.meaninfra_raw = [];
        handles.setuptable = handles.setuptable(~strcmp(handles.setuptable(:,2),mouse),:);
        handles.setuptable = [handles.setuptable; {char(cond), char(mouse), '-','-',borders,rastervalues}];
        reload_listbox(handles,[get(handles.list_cond,'Value') get(handles.list_mice,'Value')  1]);
        %update setuptable
    elseif ~isempty(mice)
        %update setuptable
        handles.setuptable = handles.setuptable(max([~strcmp(handles.setuptable(:,1),conditions(get(handles.list_cond,'Value'))) ~strcmp(handles.setuptable(:,2),mice(get(handles.list_mice,'Value'))) ~strcmp(handles.setuptable(:,3),slices(get(handles.list_slices,'Value')))],[],2),:);
        reload_listbox(handles,[get(handles.list_cond,'Value') 1 1]);
    end

function borders = setBordersSlice(filename,path, handles)
    if(~isfield(handles,'hfigselslice'))
        handles.hfigselslice = figure();
    elseif(ishandle(handles.hfigselslice))
        handles.hfigselslice = figure(handles.hfigselslice);
    else
        handles.hfigselslice = figure();
    end
    img = imread([char(path) char(filename)]);
    if(size(img,3) > 1)
        imshow(img(:,:,1));
    else
        imshow(img);
    end
    hold on;
    xlabel(char(filename));
    
    %Top border
    title('Draw the top border of the cortex');
    [topx,topy] = draw_curve(handles.hfigselslice); %selectpoints(); 
%     tmp = sortrows([topx topy]);
%     topx = tmp(:,1);
%     topy = tmp(:,2);
%     topy = round(topy);
%     topp = polyfit(topx,topy,2);
%     topf = polyval(topp,topx(1):topx(end));
%     plot(topx(1):topx(end),topf,'g-');

    %supra-infra border
    title('Draw the supra-infragranular border of the cortex');
    [midx,midy] = draw_curve(handles.hfigselslice); %selectpoints();
%     tmp = sortrows([midx,midy]);
%     midx = tmp(:,1);
%     midy = tmp(:,2);
%     midp = polyfit(midx,midy,2);
%     midf = polyval(midp,midx(1):midx(end));
%     plot(midx(1):midx(end),midf,'g-');
    
    
    %bottom border
    title('Draw the bottom border of the cortex');
    [botx,boty] = draw_curve(handles.hfigselslice); %selectpoints();
%     tmp = sortrows([botx,boty]);
%     botx = tmp(:,1);
%     boty = tmp(:,2);
%     botp = polyfit(botx,boty,2);
%     botf = polyval(botp,botx(1):botx(end));
%     plot(botx(1):botx(end),botf,'g-');
    
    %areal borders
    title(sprintf('Select points at the top of the cortex corresponding to the areas %s',handles.areas));
    [topareax,topareay] = setarealborders(topx,topy,handles.arealborders);
    title(sprintf('Select points at the bottom of the cortex corresponding to the areas %s',handles.areas));
    [botareax,botareay] = setarealborders(botx,boty,handles.arealborders);
    
    %calculate intersection areal borders with supra-infra border and plot
    %areal borders
    midareax = zeros(handles.arealborders,1);
    midareay = zeros(handles.arealborders,1);
    for i=1:handles.arealborders
        arealxi = topareax(i):(botareax(i)-topareax(i))/1000:botareax(i);
        arealp = [(botareay(i)-topareay(i))/(botareax(i)-topareax(i)) (botareax(i)*topareay(i)-topareax(i)*botareay(i))/(botareax(i)-topareax(i))];
        arealyi = polyval(arealp,arealxi);
        [midareax(i) midareay(i)] = intersections(midx,midy,arealxi,arealyi);
        if(~any(all(ismember([midx midy],[midareax(i) midareay(i)]),2)))
            %dt = delaunay(midx,midy);
            dt = DelaunayTri(midx,midy);
            %pid = dsearch(midx,midy,dt,midareax(i),midareay(i));
            [pid,d] = nearestNeighbor(dt,midareax(i),midareay(i));
            xywindow = sortrows([midx(pid-1) midy(pid-1);midx(pid) midy(pid);midx(pid+1) midy(pid+1);midareax(i) midareay(i)]);
            if(handles.debug)
                figure();
                plot(xywindow(:,1),xywindow(:,2),'bx-',midareax(i),midareay(i),'ro');
                figure(handles.hfigselslice);
            end
            midx = [midx(1:pid-2); xywindow(:,1); midx(pid+2:end)];
            midy = [midy(1:pid-2); xywindow(:,2); midy(pid+2:end)];
        end
        plot(arealxi,arealyi,'b-',midareax(i), midareay(i),'bo');
%         own intersection version
%         intersection(midx,midy,topareax(i),topareay(i),botareax(i),botareay(i),'b-');
%         Polynomial approach
%         [midareax(i) midareay(i)] = intersection(topareax(i),topareay(i),botareax(i),botareay(i),midp,'b-');
    end
    

    %Interactive normalization actions
    
    %background square
    title('Select 2 points to form a square to calculate the background');
    [bgx,bgy]=selectpoints(2);
    segmentmask = roipoly(img,[bgx(1) bgx(1) bgx(2) bgx(2)],[bgy(1) bgy(2) bgy(2) bgy(1)]);
    plot([bgx(1) bgx(1) bgx(2) bgx(2) bgx(1)],[bgy(1) bgy(2) bgy(2) bgy(1) bgy(1)],'m:');
    %calculate mean grayvalue of segment
    borders.meanbg = mean(mean(img(segmentmask)));
    borders.meanbgcoordinates = [bgx bgy];
     
    hold off;
    
    %close image
    close(handles.hfigselslice);
    
    %return border values
    borders.topareaxy = [topareax topareay];
    borders.midareaxy = [midareax midareay];
    borders.botareaxy = [botareax botareay];
    borders.areas = handles.areas;
    borders.arealborders = handles.arealborders;
%     borders.topp = topp;
%     borders.midp = midp;
%     borders.botp = botp;
    borders.topx = topx;
    borders.topy = topy;
    borders.midx = midx;
    borders.midy = midy;
    borders.botx = botx;
    borders.boty = boty;
  
function handles = rasterize(handles)
    %segments
    handles.rastersegments = str2num(get(handles.edit_segments,'String'));
    
    %check all slices are rasterized and ask user to rasterize all slices
    %again or only the new slices
    notsliced = 0;
    list = [];
    listpiv = [];
    for i=1:size(handles.setuptable,1)
        ntslcd = 0;
        if(~isempty(handles.setuptable{i,6}))
            if((~isfield(handles.setuptable{i,6},'segments') || handles.setuptable{i,6}.segments == 0) && ~isnan(mean(handles.setuptable{i,6}.meansupra_raw)) )
                handles.setuptable{i,6}.segments = size(handles.setuptable{i,6}.meansupra,2);
            elseif(~isfield(handles.setuptable{i,6},'segments') || handles.setuptable{i,6}.segments == 0)
                ntslcd = ntslcd + 1;
                list = [list i];
            end
%             if(isempty(handles.setuptable{i,6}.meansupra_raw))
%                 ntslcd = ntslcd + 1;
%                 list = [list i];                
%             end
        else
            ntslcd = ntslcd + 1;
            list = [list i];
        end
        if(~isfield(handles.setuptable{i,6},'pivotpointtop'))
            listpiv = [listpiv i];
        end
        if ntslcd > 0
            notsliced = notsliced + 1;
        end
    end
    if(notsliced == size(handles.setuptable,1))
        segmentall = 1;
    else
        choice = questdlg(sprintf('There are %d new slices detected.\nDo you want to segmentize all slices again or only the new slices?',notsliced),'Segmentize slices','All slices','Only new slices','Only new slices');
        switch choice
            case 'All slices'
                segmentall = 1;
            case 'Only new slices'
                segmentall = 0;
            otherwise
                return;
        end
    end
    fprintf('Rasterizing slices...\n');
    setuptable = handles.setuptable;
      
    emptyrow = strcmp(setuptable(:,3),'-');
    
    if(max(emptyrow))
        choice = questdlg('There are mice listed without assigned slices. Do you want to assign slices to this mice? Or do you want to exclude (remove) these mice from the analysis?','Mice without slices detected','Assign slices to mice','Exclude from analysis','Exclude from analysis');
        switch choice
            case 'Assign slices to mice'
                emptylist = find(emptyrow,1);
                reload_listbox(handles,[find(strcmp(unique(handles.setuptable(:,1)),handles.setuptable{emptylist(1),1}),1) find(strcmp(unique(handles.setuptable(:,2)),handles.setuptable{emptylist(1),2}),1) 1]);
                return;
            case 'Exclude from analysis'
                %remove empty rows from setuptable
                setuptable = setuptable(~strcmp(setuptable(:,3),'-'),:);
        end
    end
    if(segmentall)
        list = 1:size(setuptable,1);        
    end
    
    tempsetuptable = setuptable;
    errs = 0;
    parfor_progress(length(list));
    for i=list
        try
            %         second degree polynomial version
            %         [topcox,topcoy] = verdeling(setuptable{i,5}.topp(1),setuptable{i,5}.topp(2),setuptable{i,5}.topp(3),setuptable{i,5}.topareaxy(1,1), setuptable{i,5}.topareaxy(end,1),1000,handles.rastersegments);
            %         [midcox,midcoy] = verdeling(setuptable{i,5}.midp(1),setuptable{i,5}.midp(2),setuptable{i,5}.midp(3),setuptable{i,5}.midareaxy(1,1), setuptable{i,5}.midareaxy(end,1),1000,handles.rastersegments);
            %         [botcox,botcoy] = verdeling(setuptable{i,5}.botp(1),setuptable{i,5}.botp(2),setuptable{i,5}.botp(3),setuptable{i,5}.botareaxy(1,1), setuptable{i,5}.botareaxy(end,1),1000,handles.rastersegments);
            
            %         own version *failed*
            %         [topcox,topcoy] = divide_drawed_curve(setuptable{i,5}.topx,setuptable{i,5}.topy,setuptable{i,5}.topareaxy(1,1),setuptable{i,5}.topareaxy(1,2), setuptable{i,5}.topareaxy(end,1),setuptable{i,5}.topareaxy(end,2),1,handles.rastersegments);
            %         [midcox,midcoy] = divide_drawed_curve(setuptable{i,5}.midp(1),setuptable{i,5}.midp(2),setuptable{i,5}.midp(3),setuptable{i,5}.midareaxy(1,1), setuptable{i,5}.midareaxy(end,1),1000,handles.rastersegments);
            %         [botcox,botcoy] = divide_drawed_curve(setuptable{i,5}.botp(1),setuptable{i,5}.botp(2),setuptable{i,5}.botp(3),setuptable{i,5}.botareaxy(1,1), setuptable{i,5}.botareaxy(end,1),1000,handles.rastersegments);
            
            %crop the curve to the outer areal borders
            [topx,topy] = crop_curve(setuptable{i,5}.topx,setuptable{i,5}.topy,setuptable{i,5}.topareaxy(1,1),setuptable{i,5}.topareaxy(1,2), setuptable{i,5}.topareaxy(end,1),setuptable{i,5}.topareaxy(end,2));
            [midx,midy] = crop_curve(setuptable{i,5}.midx,setuptable{i,5}.midy,setuptable{i,5}.midareaxy(1,1),setuptable{i,5}.midareaxy(1,2), setuptable{i,5}.midareaxy(end,1),setuptable{i,5}.midareaxy(end,2));
            [botx,boty] = crop_curve(setuptable{i,5}.botx,setuptable{i,5}.boty,setuptable{i,5}.botareaxy(1,1),setuptable{i,5}.botareaxy(1,2), setuptable{i,5}.botareaxy(end,1),setuptable{i,5}.botareaxy(end,2));
            
            %segmentize the curve into x segments with x+1 lines with 1/20
            %resolution
            topcoxy = interparc(handles.rastersegments+1,topx(1:20:end),topy(1:20:end));
            midcoxy = interparc(handles.rastersegments+1,midx(1:20:end),midy(1:20:end));
            botcoxy = interparc(handles.rastersegments+1,botx(1:20:end),boty(1:20:end));
            
            tempsetuptable{i,6}.segments =  handles.rastersegments;
            tempsetuptable{i,6}.topcoxy = topcoxy;
            tempsetuptable{i,6}.midcoxy = midcoxy;
            tempsetuptable{i,6}.botcoxy = botcoxy;
            slicename = setuptable{i,3};
            tempsetuptable{i,6}.toparealrel = relativearealborders(topx,topy,setuptable{i,5}.topareaxy(:,1),setuptable{i,5}.topareaxy(:,2),topcoxy,handles.rastersegments,slicename);
            tempsetuptable{i,6}.midarealrel = relativearealborders(midx,midy,setuptable{i,5}.midareaxy(:,1),setuptable{i,5}.midareaxy(:,2),midcoxy,handles.rastersegments,slicename);
            tempsetuptable{i,6}.botarealrel = relativearealborders(botx,boty,setuptable{i,5}.botareaxy(:,1),setuptable{i,5}.botareaxy(:,2),botcoxy,handles.rastersegments,slicename);
            
            if(handles.debug)
                figure();
                img = imread([setuptable{i,4} setuptable{i,3}]);
                imshow(img);
                hold on;
                plot(topx,topy,'g-');
                plot(midx,midy,'g-');
                plot(botx,boty,'g-');
                plot(topcoxy(:,1),topcoxy(:,2),'rx');
                plot(midcoxy(:,1),midcoxy(:,2),'rx');
                plot(botcoxy(:,1),botcoxy(:,2),'rx');
                plot([topcoxy(:,1)'; midcoxy(:,1)'],[topcoxy(:,2)'; midcoxy(:,2)'],'b-');
                plot([midcoxy(:,1)'; botcoxy(:,1)'],[midcoxy(:,2)'; botcoxy(:,2)'],'c-');
                plot(setuptable{i,5}.topareaxy(:,1),setuptable{i,5}.topareaxy(:,2),'ro');
                plot(setuptable{i,5}.midareaxy(:,1),setuptable{i,5}.midareaxy(:,2),'ro');
                plot(setuptable{i,5}.botareaxy(:,1),setuptable{i,5}.botareaxy(:,2),'ro');
                hold off;
                figure(handles.fig_ISH_setup)
            end
        catch
            fprintf('Error during slice %d/%d\n',i,size(setuptable,1));
            errs = errs + 1;
        end
        parfor_progress;
    end
    parfor_progress(0);
    fprintf('End parfor loop, %d errors\nSaving...',errs);
    setuptable = tempsetuptable;
    save([handles.savepath char(handles.savename) '.mat'],'setuptable');
    handles.setuptable = setuptable;
    guidata(handles.fig_ISH_setup,handles);
    fprintf('saved.\n');
    
    handles.setuptable = setuptable;
    
    handles = verificate_segmentation(handles);
    fprintf('Slices rasterized.\n\n');
    
    idx = hasIntersectingSegments(handles.setuptable);
    if(isempty(idx))
        fprintf('All slices are segmented correctly.\n');
    else
        fprintf('%d/%d slices are not segmented correctly:\n',numel(idx),size(setuptable,1));
        for i=1:length(idx)
            fprintf('%s - %s - %s\n',handles.setuptable{idx(i),1},handles.setuptable{idx(i),2},handles.setuptable{idx(i),3});
        end
        msgbox(sprintf('%d slices are not segmented correctly. Please check the Command Window.',numel(idx)));
    end
    fprintf('\n');
    
    if(strcmp(handles.dontpivot,'off'))
        fprintf('Prepairing raster for pivoting...\n');
        setuptable = handles.setuptable;
        
        if(handles.debug)
            pivotdebugfig = figure();
            pivindex = 1;
        end
        for i=listpiv
            fprintf('Slice %d/%d\n',i,size(setuptable,1));
            for pivotborder = 2:handles.arealborders - 1
                pivotpointtop = round(mean(handles.allrelarealborderstop(:,pivotborder)));
                pivotpointmid = round(mean(handles.allrelarealbordersmid(:,pivotborder)));
                pivotpointbot = round(mean(handles.allrelarealbordersbot(:,pivotborder)));
                [topcoxy,toparealrel] = herverdeling(setuptable{i,5}.topx,setuptable{i,5}.topy,setuptable{i,6}.topcoxy,pivotpointtop,setuptable{i,5}.topareaxy,pivotborder,setuptable{i,6}.toparealrel);
                %             midcoxy = herverdeling(setuptable{i,5}.midx,setuptable{i,5}.midy,setuptable{i,6}.midcoxy, pivotpointmid,setuptable{i,5}.midareaxy, pivotborder);
                [midtcoxy,midtarealrel] = herverdeling(setuptable{i,5}.midx,setuptable{i,5}.midy,setuptable{i,6}.midcoxy, pivotpointtop,setuptable{i,5}.midareaxy, pivotborder,setuptable{i,6}.toparealrel);
                [midbcoxy,midbarealrel] = herverdeling(setuptable{i,5}.midx,setuptable{i,5}.midy,setuptable{i,6}.midcoxy, pivotpointbot,setuptable{i,5}.midareaxy, pivotborder,setuptable{i,6}.botarealrel);
                [botcoxy,botarealrel] = herverdeling(setuptable{i,5}.botx,setuptable{i,5}.boty,setuptable{i,6}.botcoxy, pivotpointbot,setuptable{i,5}.botareaxy, pivotborder,setuptable{i,6}.botarealrel);
                
                setuptable{i,6}.pivotpointtop(pivotborder-1) = pivotpointtop;
                setuptable{i,6}.pivotpointbot(pivotborder-1) = pivotpointbot;
                setuptable{i,6}.(['toppiv' num2str(pivotborder-1) 'coxy']) = topcoxy;
                setuptable{i,6}.(['toppiv' num2str(pivotborder-1) 'arealrel']) = toparealrel;
                setuptable{i,6}.(['midtpiv' num2str(pivotborder-1) 'coxy']) = midtcoxy;
                setuptable{i,6}.(['midbpiv' num2str(pivotborder-1) 'coxy']) = midbcoxy;
                setuptable{i,6}.(['botpiv' num2str(pivotborder-1) 'coxy']) = botcoxy;
                setuptable{i,6}.(['botpiv' num2str(pivotborder-1) 'arealrel']) = botarealrel;
                
                
                if(handles.debug)
                    figure(pivotdebugfig);
                    subplot(size(setuptable,1),handles.arealborders-2,pivindex);
                    pivindex = pivindex + 1;
                    img = imread([handles.setuptable{i,4} handles.setuptable{i,3}]);
                    imshow(img);
                    hold on;
                    %plot([setuptable{i,6}.topcoxy(:,1)'; setuptable{i,6}.midcoxy(:,1)'; setuptable{i,6}.botcoxy(:,1)'],[setuptable{i,6}.topcoxy(:,2)';setuptable{i,6}.midcoxy(:,2)'; setuptable{i,6}.botcoxy(:,2)'],'g-');
                    plot([topcoxy(:,1)'; midtcoxy(:,1)'],[topcoxy(:,2)'; midtcoxy(:,2)'],'b-');
                    plot([midbcoxy(:,1)'; botcoxy(:,1)'],[midbcoxy(:,2)'; botcoxy(:,2)'],'c-');
                    %                 plot([topcoxy(:,1)'; midcoxy(:,1)'],[topcoxy(:,2)'; midcoxy(:,2)'],'b-');
                    %                 plot([midcoxy(:,1)'; botcoxy(:,1)'],[midcoxy(:,2)'; botcoxy(:,2)'],'c-');
                    plot(setuptable{i,5}.topareaxy(:,1),setuptable{i,5}.topareaxy(:,2),'ro');
                    plot(setuptable{i,5}.midareaxy(:,1),setuptable{i,5}.midareaxy(:,2),'ro');
                    plot(setuptable{i,5}.botareaxy(:,1),setuptable{i,5}.botareaxy(:,2),'ro');
                    hold off;
                end
            end
            save([handles.savepath char(handles.savename) '.mat'],'setuptable');
        end
    else
        fprintf('Prepairing raster for pivoting skipped!\n');
    end
    
    handles.setuptable = setuptable;
    
    fprintf('Raster prepaired for pivoting.\n');
        
function handles = verificate_segmentation(handles)
    %plot boxplots of arealborders
    
    handles = calc_allarealborders(handles);
    if(size(handles.allrelarealborderstop,2)>2)
        if(~strcmp(version,'7.7.0.471 (R2008b)'))
            figure();
        end
        cla;
        n = 1;
        for i=2:size(handles.allrelarealborderstop,2)-1
            h = subplot(3,size(handles.allrelarealborderstop,2)-2,n);
            set(gcf,'CurrentAxes',gca);
            boxplot(handles.allrelarealborderstop(:,i));
            set(gca,'XTickLabel',{''});
            areas = regexp(handles.areas,',','split');
            title(sprintf('%s/%s',areas{i-1},areas{i}));
            n = n + 1;
        end
        for i=2:size(handles.allrelarealbordersmid,2)-1
            h = subplot(3,size(handles.allrelarealbordersmid,2)-2,n);
            boxplot(handles.allrelarealbordersmid(:,i));
            set(gca,'XTickLabel',{''});
            n = n + 1;
        end
        for i=2:size(handles.allrelarealbordersbot,2)-1
            h = subplot(3,size(handles.allrelarealbordersbot,2)-2,n);
            boxplot(handles.allrelarealbordersbot(:,i));
            set(gca,'XTickLabel',{''});
            n = n + 1;
        end
        
        if(size(handles.allrelarealborderstop,1)> 2)
            h = findobj(gcf,'tag','Outliers');
            yc = get(h,'YData');
            y = horzcat(yc{:});
            ynan = y(~isnan(y));
            if(size(ynan,2) > 0)
                outlind = zeros(size(handles.allrelarealborderstop,1),1);
                for i=1:size(ynan,2)
                    outltop = max(ynan(i) == handles.allrelarealborderstop,[],2);
                    outlmid = max(ynan(i) == handles.allrelarealbordersmid,[],2);
                    outlbot = max(ynan(i) == handles.allrelarealbordersbot,[],2);
                    outlind = max([outlind outltop outlmid outlbot],[],2);
                end
                set(handles.list_verif,'Value',1);
                set(handles.list_verif,'String',handles.setuptable(find(outlind),3));
            else
                set(handles.list_verif,'String','');
            end
        end
    end

function handles = calc_allarealborders(handles)
    allrelarealborderstop = zeros(size(handles.setuptable,1),handles.arealborders);
    allrelarealbordersmid = zeros(size(handles.setuptable,1),handles.arealborders);
    allrelarealbordersbot = zeros(size(handles.setuptable,1),handles.arealborders);
    for i=1:size(handles.setuptable,1)
        
        allrelarealborderstop(i,:) = handles.setuptable{i,6}.toparealrel;
        allrelarealbordersmid(i,:) = handles.setuptable{i,6}.midarealrel;
        allrelarealbordersbot(i,:) = handles.setuptable{i,6}.botarealrel;
    end
    handles.allrelarealborderstop = allrelarealborderstop;
    handles.allrelarealbordersmid = allrelarealbordersmid;
    handles.allrelarealbordersbot = allrelarealbordersbot;

function handles = calc_OD(handles)
    pivot = get(handles.popup_pivot,'Value')-1;
    pivot_strings = get(handles.popup_pivot,'String');
    for i=1:size(handles.setuptable,1)
        fprintf('Calculating OD of slice %d/%d\n',i,size(handles.setuptable,1));
        img = imread([handles.setuptable{i,4} handles.setuptable{i,3}]);
        if(pivot == 0)
            topcox = handles.setuptable{i,6}.topcoxy(:,1);
            topcoy = handles.setuptable{i,6}.topcoxy(:,2);
            midtcox = handles.setuptable{i,6}.midcoxy(:,1);
            midtcoy = handles.setuptable{i,6}.midcoxy(:,2);
            midbcox = midtcox;
            midbcoy = midtcoy;
            botcox = handles.setuptable{i,6}.botcoxy(:,1);
            botcoy = handles.setuptable{i,6}.botcoxy(:,2);
        else
            topcox = handles.setuptable{i,6}.(['toppiv' num2str(pivot) 'coxy'])(:,1);
            topcoy = handles.setuptable{i,6}.(['toppiv' num2str(pivot) 'coxy'])(:,2);
            midtcox = handles.setuptable{i,6}.(['midtpiv' num2str(pivot) 'coxy'])(:,1);
            midtcoy = handles.setuptable{i,6}.(['midtpiv' num2str(pivot) 'coxy'])(:,2);
            midbcox = handles.setuptable{i,6}.(['midbpiv' num2str(pivot) 'coxy'])(:,1);
            midbcoy = handles.setuptable{i,6}.(['midbpiv' num2str(pivot) 'coxy'])(:,2);
            botcox = handles.setuptable{i,6}.(['botpiv' num2str(pivot) 'coxy'])(:,1);
            botcoy = handles.setuptable{i,6}.(['botpiv' num2str(pivot) 'coxy'])(:,2);
        end
        
        handles.setuptable{i,6}.pivot = pivot;
        if(pivot == 0)
            handles.setuptable{i,6}.pivot_string = 'none';
        else
            handles.setuptable{i,6}.pivot_string = pivot_strings(pivot+1);
        end
        
        if(handles.showraster == i)
            rasfig = figure();
            imshow(img);
            title(handles.setuptable{i,3});
            hold on;
            plot(handles.setuptable{i,5}.topareaxy(:,1),handles.setuptable{i,5}.topareaxy(:,2),'ro');
            plot(handles.setuptable{i,5}.botareaxy(:,1),handles.setuptable{i,5}.botareaxy(:,2),'go');
        end
        %calc OD supra
        for j=1:size(topcox,1)-1
            if(~isnan(topcox(j)) && ~isnan(midtcox(j)) && ~isnan(topcox(j+1)) && ~isnan(midtcox(j+1)))
                if(handles.showraster == i)
                    plot([topcox(j) topcox(j+1) midtcox(j+1) midtcox(j) topcox(j)],[topcoy(j) topcoy(j+1) midtcoy(j+1) midtcoy(j) topcoy(j)],'w-');
                    
                end
                segmentmask = roipoly(img,[topcox(j) topcox(j+1) midtcox(j+1) midtcox(j)],[topcoy(j) topcoy(j+1) midtcoy(j+1) midtcoy(j)]);
                handles.setuptable{i,6}.meansupra_raw(j) = mean(mean(img(segmentmask)));
            else
                handles.setuptable{i,6}.meansupra_raw(j) = NaN;
            end
        end
        %calc OD infra
        for j=1:size(botcox,1)-1
            if(~isnan(botcox(j)) && ~isnan(midbcox(j)) && ~isnan(botcox(j+1)) && ~isnan(midbcox(j+1)))
                if(handles.showraster == i)
                    plot([midbcox(j) midbcox(j+1) botcox(j+1) botcox(j) midbcox(j)],[midbcoy(j) midbcoy(j+1) botcoy(j+1) botcoy(j) midbcoy(j)],'w-');
                end
                segmentmask = roipoly(img,[midbcox(j) midbcox(j+1) botcox(j+1) botcox(j)],[midbcoy(j) midbcoy(j+1) botcoy(j+1) botcoy(j)]);
                handles.setuptable{i,6}.meaninfra_raw(j) = mean(mean(img(segmentmask)));
            else
                handles.setuptable{i,6}.meaninfra_raw(j) = NaN;
            end
        end       
        %calc OD total
        for j=1:size(botcox,1)-1
            if(~isnan(botcox(j)) && ~isnan(topcox(j)) && ~isnan(botcox(j+1)) && ~isnan(topcox(j+1)))
                
                segmentmask = roipoly(img,[topcox(j) topcox(j+1) botcox(j+1) botcox(j)],[topcoy(j) topcoy(j+1) botcoy(j+1) botcoy(j)]);
                handles.setuptable{i,6}.meantotal_raw(j) = mean(mean(img(segmentmask)));
            else
                handles.setuptable{i,6}.meantotal_raw(j) = NaN;
            end
        end  
        
        %normalize against background in thalamus (%%TODO change here for
        %use with c-13 ladder
        handles.setuptable{i,6}.meansupra = (1-(handles.setuptable{i,6}.meansupra_raw./handles.setuptable{i,5}.meanbg))*100;
        handles.setuptable{i,6}.meaninfra = (1-(handles.setuptable{i,6}.meaninfra_raw./handles.setuptable{i,5}.meanbg))*100;
        handles.setuptable{i,6}.meantotal = (1-(handles.setuptable{i,6}.meantotal_raw./handles.setuptable{i,5}.meanbg))*100;
    end
    
function handles = extractdata(handles)
    
    %open log file
    flogid = fopen([handles.savepath handles.savename '_log.txt'],'w');
    fprintf(flogid,'ISH Analysis Logbook for experiment %s\n',handles.savename);
    fprintf(flogid,'_______________________________________________________\n\n');
    fprintf(flogid,'Setup\n------\n');
    setuptabletr = handles.setuptable(:,1:3)';
    fprintf(flogid,'%s\t%s\t%s\n',setuptabletr{:});
    fprintf(flogid,'\nAnalysis\n--------\n');
    
    %Calculate OD's
    pivot = get(handles.popup_pivot,'Value')-1;
%     pivot_strings = get(handles.popup_pivot,'String');
%     pivot_string = pivot_strings(pivot);
    
    if(~isfield(handles,'skipod'))
        handles.skipod = 'off';
    end
    if(strcmp(handles.skipod,'off'))
        fprintf(flogid,'Calculating OD of %d segments in %d slices\n\n',size(handles.setuptable,1),handles.rastersegments);
        fprintf('Calculating OD of %d segments in %d slices\n\n',handles.rastersegments,size(handles.setuptable,1));
        handles = calc_OD(handles);
    else
        fprintf(flogid,'Calculating OD skipped');
        fprintf('Calculating OD skipped');
    end
    
    %start resultstruct
    projectresults.name = handles.savename;
    projectresults.amountslices = size(handles.setuptable,1);
    projectresults.segments = handles.rastersegments;
    projectresults.areas = get(handles.edit_areas,'String');
    projectresults.mice = {};
    projectresults.conditions = {};
    projectresults.intraconditions = {};
    projectresults.interconditions = {};
    
    
    %fprintf('Verificating segmentation\n');
    %handles = rasterize(handles);
    
    fprintf('Sorting data\n');
    
    %area and regions
    areas = regexp(handles.areas,',','split');
    projectresults.regions.areas = areas;
    if(isfield(handles,'ROI'))
        for k=1:size(handles.ROI,1)
            projectresults.regions.(['region' num2str(k)]) = unique(handles.ROI(k,~strcmp(handles.ROI(k,:),'')));
        end
    end
    
    %Raw data table
    setuptable = handles.setuptable;
    
    mice = unique(setuptable(:,2));
    for i=1:size(mice,1)
        %build table for slices x segments for one mouse
        slicesxsegments_supra = [];
        slicesxsegments_infra = [];
        %areal borders for one mouse
        toparearel = [];
        botarearel = [];
        %regions
        
        regions_areas = struct([]);
        regions_regions = struct([]);
        for j=1:size(setuptable,1)
            if(strcmp(setuptable(j,2),mice(i)))
                slicesxsegments_supra = [slicesxsegments_supra; setuptable{j,6}.meansupra];
                slicesxsegments_infra = [slicesxsegments_infra; setuptable{j,6}.meaninfra];
                cond = setuptable{j,1};
                %borders = setuptable{j,5}.arealborder(:,1)';
                if(pivot == 0)
                    toparearel = [toparearel; setuptable{j,6}.toparealrel];
                    botarearel = [botarearel; setuptable{j,6}.botarealrel];
                        
                else
                    toparearel = [toparearel; setuptable{j,6}.(['toppiv' num2str(pivot) 'arealrel'])];
                    botarearel = [botarearel; setuptable{j,6}.(['botpiv' num2str(pivot) 'arealrel'])];
                end
                %build areas by clustering segments
                for k=1:size(areas,2)
                   tempval_supra = setuptable{j,6}.meansupra(:,1:size(setuptable{j,6}.meansupra,2) >= toparearel(end,k) & 1:size(setuptable{j,6}.meansupra,2) < toparearel(end,k+1));
                   tempval_infra = setuptable{j,6}.meaninfra(:,1:size(setuptable{j,6}.meaninfra,2) >= botarearel(end,k) & 1:size(setuptable{j,6}.meaninfra,2) < botarearel(end,k+1));
                   if(~isfield(regions_areas,areas{k}))
                       regions_areas(1).(areas{k}).segments_supra = tempval_supra';
                       regions_areas(1).(areas{k}).segments_supra_mean = nanmean(tempval_supra);
                       regions_areas(1).(areas{k}).segments_infra = tempval_infra';
                       regions_areas(1).(areas{k}).segments_infra_mean = nanmean(tempval_infra);
                   else
                       regions_areas.(areas{k}).segments_supra = [regions_areas.(areas{k}).segments_supra; tempval_supra'];
                       regions_areas.(areas{k}).segments_infra = [regions_areas.(areas{k}).segments_infra; tempval_infra'];
                       regions_areas.(areas{k}).segments_supra_mean = [regions_areas.(areas{k}).segments_supra_mean; nanmean(tempval_supra)];
                       regions_areas.(areas{k}).segments_infra_mean = [regions_areas.(areas{k}).segments_infra_mean; nanmean(tempval_infra)];
                   end
                end
                for l=1:size(areas,2)
                    regions_areas(1).(areas{l}).segments_supra_mean_mean = nanmean(regions_areas.(areas{l}).segments_supra);
                    regions_areas(1).(areas{l}).segments_infra_mean_mean = nanmean(regions_areas.(areas{l}).segments_infra);
                end
            end
        end
        
        %build regions by clustering areas
        if(isfield(handles,'ROI'))
            for k=1:size(handles.ROI,1)
                for l=1:size(handles.ROI,2)
                    if(~strcmp(handles.ROI{k,l},''))
                        if(~isfield(regions_regions,['region' num2str(k)]) || ~isfield(regions_regions(1).(['region' num2str(k)]),handles.ROI{k,l}))
                            regions_regions(1).(['region' num2str(k)]).(handles.ROI{k,l}).segments_supra = regions_areas.(areas{l}).segments_supra;
                            regions_regions(1).(['region' num2str(k)]).(handles.ROI{k,l}).segments_infra = regions_areas.(areas{l}).segments_infra;
                            regions_regions(1).(['region' num2str(k)]).(handles.ROI{k,l}).segments_supra_mean = regions_areas.(areas{l}).segments_supra_mean;
                            regions_regions(1).(['region' num2str(k)]).(handles.ROI{k,l}).segments_infra_mean = regions_areas.(areas{l}).segments_infra_mean;
                        else
                            regions_regions(1).(['region' num2str(k)]).(handles.ROI{k,l}).segments_supra = [regions_regions(1).(['region' num2str(k)]).(handles.ROI{k,l}).segments_supra; regions_areas.(areas{l}).segments_supra];
                            regions_regions(1).(['region' num2str(k)]).(handles.ROI{k,l}).segments_infra = [regions_regions(1).(['region' num2str(k)]).(handles.ROI{k,l}).segments_infra; regions_areas.(areas{l}).segments_infra];
                            regions_regions(1).(['region' num2str(k)]).(handles.ROI{k,l}).segments_supra_mean = [regions_regions(1).(['region' num2str(k)]).(handles.ROI{k,l}).segments_supra_mean; regions_areas.(areas{l}).segments_supra_mean];
                            regions_regions(1).(['region' num2str(k)]).(handles.ROI{k,l}).segments_infra_mean = [regions_regions(1).(['region' num2str(k)]).(handles.ROI{k,l}).segments_infra_mean; regions_areas.(areas{l}).segments_infra_mean];
                        end
                    end
                end
                region = fieldnames(regions_regions(1).(['region' num2str(k)]));
                for l=1:size(region,1)
                    regions_regions(1).(['region' num2str(k)]).(region{l}).segments_supra_mean_mean = nanmean(regions_regions(1).(['region' num2str(k)]).(region{l}).segments_supra);
                    regions_regions(1).(['region' num2str(k)]).(region{l}).segments_infra_mean_mean = nanmean(regions_regions(1).(['region' num2str(k)]).(region{l}).segments_infra);
                end
            end
        end
                
        
        fprintf(flogid,'\n\n*********** Mouse %s ***********\n',char(mice(i)));
        fprintf(flogid,'Mouse %s - Supra: Slices x Segments\n',char(mice(i)));
        fprintf(flogid,[repmat('%6.2f\t',1,size(slicesxsegments_supra,2)) '\n'],slicesxsegments_supra');
        fprintf(flogid,'Mouse %s - Supra: Mean Areal Borders\n',char(mice(i)));
        fprintf(flogid,[repmat('%6.2f\t',1,size(mean(toparearel),2)) '\n'],mean(toparearel)');
        fprintf(flogid,'Mouse %s - Infra: Slices x Segments\n',char(mice(i)));
        fprintf(flogid,[repmat('%6.2f\t',1,size(slicesxsegments_infra,2)) '\n'],slicesxsegments_infra');
        fprintf(flogid,'Mouse %s - Infra: Mean Areal Borders\n',char(mice(i)));
        fprintf(flogid,[repmat('%6.2f\t',1,size(mean(botarearel),2)) '\n'],mean(botarearel)');
        
        %save results in struct mouseresults
        mouseresults.(genvarname(mice{i})).condition = cond;
        mouseresults.(genvarname(mice{i})).slicesxsegments_supra = slicesxsegments_supra;
        mouseresults.(genvarname(mice{i})).slicesxsegments_infra = slicesxsegments_infra;
        mouseresults.(genvarname(mice{i})).slicesxsegments_supra_mean = nanmean(slicesxsegments_supra,1);
        mouseresults.(genvarname(mice{i})).slicesxsegments_supra_sterr = nanstd(slicesxsegments_supra,0,1)./sqrt(size(slicesxsegments_supra,1));
        mouseresults.(genvarname(mice{i})).slicesxsegments_supra_std = nanstd(slicesxsegments_supra,0,1);
        mouseresults.(genvarname(mice{i})).slicesxsegments_infra_mean = nanmean(slicesxsegments_infra,1);
        mouseresults.(genvarname(mice{i})).slicesxsegments_infra_sterr = nanstd(slicesxsegments_infra,0,1)./sqrt(size(slicesxsegments_infra,1));
        mouseresults.(genvarname(mice{i})).slicesxsegments_infra_std = nanstd(slicesxsegments_infra,0,1);
        mouseresults.(genvarname(mice{i})).toparearel = toparearel;
        mouseresults.(genvarname(mice{i})).toparearel_mean = mean(toparearel);
        mouseresults.(genvarname(mice{i})).botarearel = botarearel;
        mouseresults.(genvarname(mice{i})).botarearel_mean = mean(botarearel);
        mouseresults.(genvarname(mice{i})).regions.areas = regions_areas;
        mouseresults.(genvarname(mice{i})).regions = catstruct(mouseresults.(genvarname(mice{i})).regions,regions_regions);
        
    end
    
    %save results per mice in struct projectresults
    projectresults.mice = mouseresults;
    
    %build table slices x segments for each condition  MEAN OVER ALL SLICES
    %PER MICE
    conditions = {};
    for i=1:size(setuptable,1)
        if(~isfield(conditions,setuptable(i,1)))
            conditions.(setuptable{i,1}).slicesxsegments_supra = setuptable{i,6}.meansupra;
            conditions.(setuptable{i,1}).slicesxsegments_infra = setuptable{i,6}.meaninfra;
%             conditions.(setuptable{i,1}).arealborder = setuptable{i,5}.arealborder;
            conditions.(setuptable{i,1}).mice = cellstr(setuptable{i,2});
            conditions.(setuptable{i,1}).slicesxsegments_supra_mousemean = [];
            conditions.(setuptable{i,1}).slicesxsegments_infra_mousemean = [];
        else
            conditions.(setuptable{i,1}).slicesxsegments_supra = [conditions.(setuptable{i,1}).slicesxsegments_supra; setuptable{i,6}.meansupra];
            conditions.(setuptable{i,1}).slicesxsegments_infra = [conditions.(setuptable{i,1}).slicesxsegments_infra; setuptable{i,6}.meaninfra;];
%             conditions.(setuptable{i,1}).arealborder = [conditions.(setuptable{i,1}).arealborder; setuptable{i,5}.arealborder];
            if(size(conditions.(setuptable{i,1}).mice,1) == 1)
                if(~strcmp(conditions.(setuptable{i,1}).mice,setuptable{i,2}))
                    conditions.(setuptable{i,1}).mice = [cellstr(conditions.(setuptable{i,1}).mice); setuptable{i,2}];
                end
            else
                if(ismember(conditions.(setuptable{i,1}).mice,setuptable{i,2}) == 0)
                    conditions.(setuptable{i,1}).mice = [cellstr(conditions.(setuptable{i,1}).mice); setuptable{i,2}];
                end
            end
        end
    end
    
    %build table slices x segments for each condition WITH MEAN PER MICE
    for i=1:size(mice,1)
        conditions.(projectresults.mice.(mice{i}).condition).slicesxsegments_supra_mousemean = [conditions.(projectresults.mice.(mice{i}).condition).slicesxsegments_supra_mousemean; projectresults.mice.(mice{i}).slicesxsegments_supra_mean];
        conditions.(projectresults.mice.(mice{i}).condition).slicesxsegments_infra_mousemean = [conditions.(projectresults.mice.(mice{i}).condition).slicesxsegments_infra_mousemean; projectresults.mice.(mice{i}).slicesxsegments_infra_mean];
    end
    
    conditionnames = fieldnames(conditions);
       
    %compute mean and standard error for each condition
    
    alltoparearel = [];
    allbotarearel = [];
    for i=1:size(conditionnames,1)
        %over all slices per mouse
        conditions.(conditionnames{i}).slicesxsegments_supra_mean = nanmean(conditions.(conditionnames{i}).slicesxsegments_supra,1);
        conditions.(conditionnames{i}).slicesxsegments_supra_sterr = nanstd(conditions.(conditionnames{i}).slicesxsegments_supra,0,1)./sqrt(sum(~isnan(conditions.(conditionnames{i}).slicesxsegments_supra)));
        conditions.(conditionnames{i}).slicesxsegments_supra_std = nanstd(conditions.(conditionnames{i}).slicesxsegments_supra,0,1);
        conditions.(conditionnames{i}).slicesxsegments_infra_mean = nanmean(conditions.(conditionnames{i}).slicesxsegments_infra,1);
        conditions.(conditionnames{i}).slicesxsegments_infra_sterr = nanstd(conditions.(conditionnames{i}).slicesxsegments_infra,0,1)./sqrt(sum(~isnan(conditions.(conditionnames{i}).slicesxsegments_infra)));
        conditions.(conditionnames{i}).slicesxsegments_infra_std = nanstd(conditions.(conditionnames{i}).slicesxsegments_infra,0,1);
        %over mean of slices per mouse
        conditions.(conditionnames{i}).slicesxsegments_supra_mousemean_mean = nanmean(conditions.(conditionnames{i}).slicesxsegments_supra_mousemean,1);
        conditions.(conditionnames{i}).slicesxsegments_supra_mousemean_sterr = nanstd(conditions.(conditionnames{i}).slicesxsegments_supra_mousemean,0,1)./sqrt(sum(~isnan(conditions.(conditionnames{i}).slicesxsegments_supra_mousemean)));
        conditions.(conditionnames{i}).slicesxsegments_supra_mousemean_std = nanstd(conditions.(conditionnames{i}).slicesxsegments_supra_mousemean,0,1);
        conditions.(conditionnames{i}).slicesxsegments_infra_mousemean_mean = nanmean(conditions.(conditionnames{i}).slicesxsegments_infra_mousemean,1);
        conditions.(conditionnames{i}).slicesxsegments_infra_mousemean_sterr = nanstd(conditions.(conditionnames{i}).slicesxsegments_infra_mousemean,0,1)./sqrt(sum(~isnan(conditions.(conditionnames{i}).slicesxsegments_infra_mousemean)));
        conditions.(conditionnames{i}).slicesxsegments_infra_mousemean_std = nanstd(conditions.(conditionnames{i}).slicesxsegments_infra_mousemean,0,1);
        
        conditions.(conditionnames{i}).toparearel = [];
        conditions.(conditionnames{i}).botarearel = [];
        conditions.(conditionnames{i}).regions = struct([]);
        for j=1:size(conditions.(conditionnames{i}).mice,1)
            conditions.(conditionnames{i}).toparearel = [conditions.(conditionnames{i}).toparearel; projectresults.mice.(conditions.(conditionnames{i}).mice{j}).toparearel];
            conditions.(conditionnames{i}).botarearel = [conditions.(conditionnames{i}).botarearel; projectresults.mice.(conditions.(conditionnames{i}).mice{j}).botarearel];
            %combine data regions per condition
            regions = fieldnames(projectresults.mice.(conditions.(conditionnames{i}).mice{j}).regions);
            for k=1:size(regions,1)
                region = fieldnames(projectresults.mice.(conditions.(conditionnames{i}).mice{j}).regions.(regions{k}));
                for l=1:size(region,1)
                    if(~isfield(conditions.(conditionnames{i}).regions,regions{k}) || ~isfield(conditions.(conditionnames{i}).regions.(regions{k}),region{l}))
                        conditions.(conditionnames{i}).regions(1).(regions{k}).(region{l}).segments_supra = projectresults.mice.(conditions.(conditionnames{i}).mice{j}).regions.(regions{k}).(region{l}).segments_supra_mean;
                        conditions.(conditionnames{i}).regions(1).(regions{k}).(region{l}).segments_infra = projectresults.mice.(conditions.(conditionnames{i}).mice{j}).regions.(regions{k}).(region{l}).segments_infra_mean;
                    else
                        conditions.(conditionnames{i}).regions.(regions{k}).(region{l}).segments_supra = [conditions.(conditionnames{i}).regions.(regions{k}).(region{l}).segments_supra; projectresults.mice.(conditions.(conditionnames{i}).mice{j}).regions.(regions{k}).(region{l}).segments_supra_mean];
                        conditions.(conditionnames{i}).regions.(regions{k}).(region{l}).segments_infra = [conditions.(conditionnames{i}).regions.(regions{k}).(region{l}).segments_infra; projectresults.mice.(conditions.(conditionnames{i}).mice{j}).regions.(regions{k}).(region{l}).segments_infra_mean];
                    end
                end
            end
        end
        
        alltoparearel = [alltoparearel; conditions.(conditionnames{i}).toparearel];
        allbotarearel = [allbotarearel; conditions.(conditionnames{i}).botarearel];
        
    end
    


    %save table in struct projectresults
    projectresults.conditions = conditions;
    projectresults.alltoparearel = alltoparearel;
    projectresults.allbotarearel = allbotarearel;
    
    fclose(flogid);
    
%     fprintf('Saving data in Excel file...\n');
%     if(strfind(system_dependent('getos'),'Microsoft Windows'))
%         exportToExcel(projectresults,[pwd '\' handles.savepath handles.savename '_results.xlsx']);
%     else
%         fprintf('Skipped because of non-Windows machine');
%     end
%     
    fprintf('Saving data in Matlab file...\n');
    %save setuptable and resultfile
    if(isfield(handles,'ROI'))
        ROI = handles.ROI;
        save([handles.savepath char(handles.savename) '.mat'],'setuptable','ROI');
    else
        save([handles.savepath char(handles.savename) '.mat'],'setuptable');
    end
    save([handles.savepath handles.savename '_results.mat'],'projectresults');
    fprintf('Project saved as %s\n',handles.savename);
    fprintf('Results saved as %s\n',[handles.savename '_results.mat']);
    %store handles
    handles.setuptable = setuptable;
    handles.projectresults = projectresults;
    fprintf('Data sorted\n');
    
function handles = runstatistics(handles)
    setuptable = handles.setuptable;
    projectresults = handles.projectresults;
   
%     ROI = handles.ROI;
    
    
    %logfile
    flogid = fopen([handles.savepath handles.savename '_log.txt'],'w');
    fprintf(flogid,'\n\n----------Statistics----------');
    
    %test normality and equal variance for all slices per condition (per
    %segment)
    conditionnames = fieldnames(projectresults.conditions);
    for i=1:size(conditionnames,1)
        slicesxsegments_supra = projectresults.conditions.(conditionnames{i}).slicesxsegments_supra;
        slicesxsegments_infra = projectresults.conditions.(conditionnames{i}).slicesxsegments_infra;
        normalitypassed = 0;
        normalitypersegment_supra = zeros(1,size(slicesxsegments_supra,2));
        normalitypersegment_infra = zeros(1,size(slicesxsegments_infra,2));
        npersegment_supra = zeros(1,size(slicesxsegments_supra,2));
        npersegment_infra = zeros(1,size(slicesxsegments_supra,2));
        strpassed = {'passed' 'not passed'};
        for j=1:size(slicesxsegments_supra,2)
            if(all(isnan(slicesxsegments_supra(:,j))))
                normalitypersegment_supra(j) = NaN;
            else
                [h,p,k] = kstest(slicesxsegments_supra(:,j));
                fprintf(flogid,'Condition %s segment %d supra %s normality test with p = %d\n',char(conditionnames(i)), j,char(strpassed(h+1)),p);
                normalitypassed = normalitypassed | h;
                normalitypersegment_supra(j) = p;
                npersegment_supra(j) = sum(~isnan(slicesxsegments_supra(:,j)));
            end
            if(all(isnan(slicesxsegments_infra(:,j))))
                normalitypersegment_infra(j) = NaN;
            else
                [h,p,k] = kstest(slicesxsegments_infra(:,j));
                fprintf(flogid,'Condition %s segment %d infra %s normality test with p = %d\n',char(conditionnames(i)), j,char(strpassed(h+1)),p);
                normalitypassed = normalitypassed | h;
                normalitypersegment_infra(j) = p;
                npersegment_infra(j) = sum(~isnan(slicesxsegments_infra(:,j)));
            end
        end
        fprintf('Normality test for all segments of condition %s %s\n',char(conditionnames(i)),char(strpassed(normalitypassed+1)));
        fprintf(flogid,'Normality test for all segments of condition %s %s\n',char(conditionnames(i)),char(strpassed(normalitypassed+1)));
        
        %save normality results in struct mouseresults
        projectresults.conditions.(conditionnames{i}).normalitypersegment_supra = normalitypersegment_supra;
        projectresults.conditions.(conditionnames{i}).normalitypersegment_infra = normalitypersegment_infra;
        projectresults.conditions.(conditionnames{i}).normalitypersegment_supra = npersegment_supra;
        projectresults.conditions.(conditionnames{i}).normalitypersegment_infra = npersegment_infra;
        
        %test equal variance
        %Two-sampled F-test (vartestn) (0 passes null hypothesis, 1 rejects it)
        %'robust' if not normal (Levene) or 'classical' if normal
        %(Bartlett)
        
        %supra
        segmentODlist = reshape(slicesxsegments_supra,numel(slicesxsegments_supra),1);
        slicelist = reshape(repmat(1:size(slicesxsegments_supra,2),size(slicesxsegments_supra,1),1),numel(slicesxsegments_supra),1);
        
        normalitytest = {'Bartlett','Levene'};
        if(normalitypassed) %1: reject (niet-normaal), 0: accept (normaal)
            [p,stat] = vartestn(segmentODlist,slicelist,'off','robust');
        else
            [p,stat] = vartestn(segmentlist,slicelist,'off','classical');
        end
        equalvarpassed = (p < 0.05);
        statfields = fieldnames(stat);
        
        fprintf(flogid,'Equal variance test (%s) for condition %s supra %s with\n',normalitytest{normalitypassed+1},char(conditionnames(i)),char(strpassed(equalvarpassed+1)));
        fprintf(flogid,'p=%d\n%s: %d\ndf: %s\n',p,statfields{1},stat.(statfields{1}),num2str(stat.df));
        fprintf('Equal variance test for condition %s supra %s with p=%d\n',char(conditionnames(i)),char(strpassed(equalvarpassed+1)),p);
        
        %save equal variance results in struct mouseresults
        projectresults.conditions.(conditionnames{i}).equalvar_segments_supra_p = p;
        projectresults.conditions.(conditionnames{i}).equalvar_segments_supra_h = h;
        projectresults.conditions.(conditionnames{i}).equalvar_segments_supra_stat = stat;
        
        %infra
        segmentODlist = reshape(slicesxsegments_infra,numel(slicesxsegments_infra),1);
        slicelist = reshape(repmat(1:size(slicesxsegments_infra,2),size(slicesxsegments_infra,1),1),numel(slicesxsegments_infra),1);
        
        if(normalitypassed) %1: reject (niet-normaal), 0: accept (normaal)
            [p,stat] = vartestn(segmentODlist,slicelist,'off','robust');
        else
            [p,stat] = vartestn(segmentlist,slicelist,'off','classical');
        end
        equalvarpassed = (p < 0.05);
        statfields = fieldnames(stat);
        
        fprintf(flogid,'Equal variance test (%s) for condition %s infra %s with\n',normalitytest{normalitypassed+1},char(conditionnames(i)),char(strpassed(equalvarpassed+1)));
        fprintf(flogid,'p=%d\n%s: %d\ndf: %s\n',p,statfields{1},stat.(statfields{1}),num2str(stat.df));
        fprintf('Equal variance test for condition %s infra %s with p=%d\n',char(conditionnames(i)),char(strpassed(equalvarpassed+1)),p);
        
        
        %save equal variance results in struct mouseresults
        projectresults.conditions.(conditionnames{i}).equalvar_segments_infra_p = p;
        projectresults.conditions.(conditionnames{i}).equalvar_segments_infra_h = p;
        projectresults.conditions.(conditionnames{i}).equalvar_segments_infra_stat = stat;
        
        
        %INTRACONDITION TESTS (segments)
        if(~(normalitypassed || equalvarpassed))  %if both 0, so normal and equalvar
            %parametric tests
            %TODO
            error('Warning: parametric test');
        else
            %non-parametric matched tests
            %Friedmann test combined with multcompare with Dunn post-hoc
            
            %supra
            nonparam_matched_supra_h = repmat({''},size(slicesxsegments_supra,2),size(slicesxsegments_supra,2)); %0: not significant diffent with alpha 0.05, 1: otherwise
            nonparam_matched_supra_diff = zeros(size(slicesxsegments_supra,2));
            
            table = slicesxsegments_supra(:,~any(isnan(slicesxsegments_supra),1));
            table_names = 1:size(slicesxsegments_supra,2);
            table_names = table_names(:,~any(isnan(slicesxsegments_supra),1));
            nonparam_matched_supra_h(:,any(isnan(slicesxsegments_supra),1)) = {'#'};
            [nonparam_matched_supra_p,table,stats] = friedman(table,1,'off');
            %alpha 0.001, 0.01 and 0.05
            [c1,m1,h1,gnames] = multcompare(stats,'alpha',0.001,'display','off','ctype','dunn-sidak');
            [c2,m2,h2,gnames] = multcompare(stats,'alpha',0.01,'display','off','ctype','dunn-sidak');
            [c3,m3,h3,gnames] = multcompare(stats,'alpha',0.05,'display','off','ctype','dunn-sidak');
            
%             nonparam_matched_supra_table_0001 = c1;
%             nonparam_matched_supra_table_001 = c2;
%             nonparam_matched_supra_table_005 = c3;
%             nonparam_matched_supra_table_names = table_names;
            for j=1:size(c1,1)
                if(c1(j,3) < 0 && c1(j,5) < 0) || (c1(j,3) > 0 && c1(j,5) > 0)
                    if(m1(c1(j,1),1) > m1(c1(j,2),1))
                        nonparam_matched_supra_diff(c1(j,1),table_names(c1(j,2))) = 1;
                    else
                        nonparam_matched_supra_diff(c1(j,1),table_names(c1(j,2))) = -1;
                    end
                    nonparam_matched_supra_h{c1(j,1),table_names(c1(j,2))} = '***';
                elseif(c2(j,3) < 0 && c2(j,5) < 0) || (c2(j,3) > 0 && c2(j,5) > 0)
                    if(m1(c2(j,1),1) > m1(c2(j,2),1))
                        nonparam_matched_supra_diff(c1(j,1),table_names(c1(j,2))) = 1;
                    else
                        nonparam_matched_supra_diff(c1(j,1),table_names(c1(j,2))) = -1;
                    end
                    nonparam_matched_supra_h{c1(j,1),table_names(c1(j,2))} = '**';
                    
                elseif(c3(j,3) < 0 && c3(j,5) < 0) || (c3(j,3) > 0 && c3(j,5) > 0)
                    if(m1(c3(j,1),1) > m1(c3(j,2),1))
                        nonparam_matched_supra_diff(c1(j,1),table_names(c1(j,2))) = 1;
                    else
                        nonparam_matched_supra_diff(c1(j,1),table_names(c1(j,2))) = -1;
                    end
                    nonparam_matched_supra_h{c1(j,1),table_names(c1(j,2))} = '*';
                    
                else
                    nonparam_matched_supra_h{c1(j,1),table_names(c1(j,2))} = '=';
                end
            end
            
            %infra     
            nonparam_matched_infra_h = repmat({''},size(slicesxsegments_infra,2),size(slicesxsegments_infra,2)); %0: not significant diffent with alpha 0.05, 1: otherwise
            nonparam_matched_infra_diff = zeros(size(slicesxsegments_infra,2));
            
            table = slicesxsegments_infra(:,~any(isnan(slicesxsegments_infra),1));
            table_names = 1:size(slicesxsegments_infra,2);
            table_names = table_names(:,~any(isnan(slicesxsegments_infra),1));
            nonparam_matched_infra_h(:,any(isnan(slicesxsegments_infra),1)) = {'#'};
            [nonparam_matched_infra_p,table,stats] = friedman(table,1,'off');
            %alpha 0.001, 0.01 and 0.05
            [c1,m1,h1,gnames] = multcompare(stats,'alpha',0.001,'display','off','ctype','dunn-sidak');
            [c2,m2,h2,gnames] = multcompare(stats,'alpha',0.01,'display','off','ctype','dunn-sidak');
            [c3,m3,h3,gnames] = multcompare(stats,'alpha',0.05,'display','off','ctype','dunn-sidak');
            
%             nonparam_matched_infra_table_0001 = c1;
%             nonparam_matched_infra_table_001 = c2;
%             nonparam_matched_infra_table_005 = c3;
%             nonparam_matched_infra_table_names = table_names;
            for j=1:size(c1,1)
                if(c1(j,3) < 0 && c1(j,5) < 0) || (c1(j,3) > 0 && c1(j,5) > 0)
                    if(m1(c1(j,1),1) > m1(c1(j,2),1))
                        nonparam_matched_infra_diff(c1(j,1),table_names(c1(j,2))) = 1;
                    else
                        nonparam_matched_infra_diff(c1(j,1),table_names(c1(j,2))) = -1;
                    end
                    nonparam_matched_infra_h{c1(j,1),table_names(c1(j,2))} = '***';
                elseif(c2(j,3) < 0 && c2(j,5) < 0) || (c2(j,3) > 0 && c2(j,5) > 0)
                    if(m1(c2(j,1),1) > m1(c2(j,2),1))
                        nonparam_matched_infra_diff(c1(j,1),table_names(c1(j,2))) = 1;
                    else
                        nonparam_matched_infra_diff(c1(j,1),table_names(c1(j,2))) = -1;
                    end
                    nonparam_matched_infra_h{c1(j,1),table_names(c1(j,2))} = '**';
                    
                elseif(c3(j,3) < 0 && c3(j,5) < 0) || (c3(j,3) > 0 && c3(j,5) > 0)
                    if(m1(c3(j,1),1) > m1(c3(j,2),1))
                        nonparam_matched_infra_diff(c1(j,1),table_names(c1(j,2))) = 1;
                    else
                        nonparam_matched_infra_diff(c1(j,1),table_names(c1(j,2))) = -1;
                    end
                    nonparam_matched_infra_h{c1(j,1),table_names(c1(j,2))} = '*';
                    
                else
                    nonparam_matched_infra_h{c1(j,1),table_names(c1(j,2))} = '=';
                end
            end
            
            
            fprintf(flogid,'Non-parametric matched test (Friedman with Dunn post-hoc) for condition %s supra:\n',char(conditionnames{i}));
            temp = nonparam_matched_supra_h';
            fprintf(flogid,[repmat('%s\t',1,size(nonparam_matched_supra_h,2)) '\n'],temp{:,:});
            
            fprintf(flogid,'Non-parametric matched test (Friedman with Dunn post-hoc) for condition %s infra:\n',char(conditionnames{i}));
            temp = nonparam_matched_infra_h';
            fprintf(flogid,[repmat('%s\t',1,size(nonparam_matched_supra_h,2)) '\n'],temp{:,:});
            
            fprintf('Non-parametric matched test (Friedman with Dunn post-hoc) for condition %s run\n',char(conditionnames{i}));
            
            
            %save paired difference test results in struct mouseresults
            projectresults.intraconditions.(conditionnames{i}).nonparam_matched_supra_h = nonparam_matched_supra_h;
            projectresults.intraconditions.(conditionnames{i}).nonparam_matched_supra_p = nonparam_matched_supra_p;
            projectresults.intraconditions.(conditionnames{i}).nonparam_matched_supra_diff = nonparam_matched_supra_diff;
            projectresults.intraconditions.(conditionnames{i}).nonparam_matched_infra_h = nonparam_matched_infra_h;
            projectresults.intraconditions.(conditionnames{i}).nonparam_matched_infra_p = nonparam_matched_infra_p;
            projectresults.intraconditions.(conditionnames{i}).nonparam_matched_infra_diff = nonparam_matched_infra_diff;
            
            
            
            %non-parametric Wilcoxon test (segment by segment, not in 1
            %test)
            wilcoxon_supra_h = repmat('-',size(slicesxsegments_supra,2),size(slicesxsegments_supra,2));
            wilcoxon_infra_h = repmat('-',size(slicesxsegments_infra,2),size(slicesxsegments_supra,2));
            wilcoxon_supra_p = zeros(size(slicesxsegments_supra,2));
            wilcoxon_infra_p = zeros(size(slicesxsegments_supra,2));
            wilcoxon_supra_diff = zeros(size(slicesxsegments_supra,2));
            wilcoxon_infra_diff = zeros(size(slicesxsegments_supra,2));
            
            %supra and infra
            for j=1:size(slicesxsegments_supra,2)-1
                for l = j+1:size(slicesxsegments_supra,2)
                    if(all(isnan(slicesxsegments_supra(:,j))) || all(isnan(slicesxsegments_supra(:,l))) || all(isnan(slicesxsegments_supra(:,j)-slicesxsegments_supra(:,l))))
                        wilcoxon_supra_p(j,l) = NaN;
                        wilcoxon_supra_h(j,l) = NaN;
                        wilcoxon_supra_diff(j,l) = NaN;
                    else
                        [p,h,stats] = signrank(slicesxsegments_supra(:,j),slicesxsegments_supra(:,l));
                        wilcoxon_supra_h(j,l) = sprintf('%d',h);
                        wilcoxon_supra_p(j,l) = p;
                        %wilcoxon_supra_stats(j,l) = stats;
                        wilcoxon_supra_diff(j,l) = mean(slicesxsegments_supra(:,j)) - mean(slicesxsegments_supra(:,l));
                    end
                    if(all(isnan(slicesxsegments_infra(:,j))) || all(isnan(slicesxsegments_infra(:,l))) || all(isnan(slicesxsegments_infra(:,j)-slicesxsegments_infra(:,l))))
                        wilcoxon_infra_p(j,l) = NaN;
                        wilcoxon_infra_h(j,l) = NaN;
                        wilcoxon_infra_diff(j,l) = NaN;
                    else
                        [p,h,stats] = signrank(slicesxsegments_infra(:,j),slicesxsegments_infra(:,l));
                        wilcoxon_infra_h(j,l) = sprintf('%d',h);
                        wilcoxon_infra_p(j,l) = p;
                        %wilcoxon_infra_stats(j,l) = stats;
                        wilcoxon_infra_diff(j,l) = mean(slicesxsegments_infra(:,j)) - mean(slicesxsegments_infra(:,l));
                    end
                end
            end
            
            fprintf('Non-parametric paired test segment by segment (Wilcoxon signed-rank test) for condition %s run\n',char(conditionnames{i}));
            
            
            %save paired difference test results in struct mouseresults
            projectresults.intraconditions.(conditionnames{i}).wilcoxon_supra_h = wilcoxon_supra_h;
            projectresults.intraconditions.(conditionnames{i}).wilcoxon_supra_p = wilcoxon_supra_p;
            projectresults.intraconditions.(conditionnames{i}).wilcoxon_supra_diff = wilcoxon_supra_diff;
            projectresults.intraconditions.(conditionnames{i}).wilcoxon_infra_h = wilcoxon_infra_h;
            projectresults.intraconditions.(conditionnames{i}).wilcoxon_infra_p = wilcoxon_infra_p;
            projectresults.intraconditions.(conditionnames{i}).wilcoxon_infra_diff = wilcoxon_infra_diff;
            
        end
    end
    
    if(size(conditionnames,1)>1)
        %INTERCONDITION TESTS (segments)
        if(~(normalitypassed || equalvarpassed))  %if both 0, so normal and equalvar
            %parametric tests
            %TODO
            error('Warning: parametric test');
        else
            conditionnames = fieldnames(projectresults.conditions);
            
            for i=1:projectresults.segments
                table_supra = [];
                table_supra_group = [];
                table_infra = [];
                table_infra_group = [];
                for j=1:length(conditionnames)
                    table_supra = [table_supra; projectresults.conditions.(conditionnames{j}).slicesxsegments_supra(:,i)];
                    table_supra_group = [table_supra_group; repmat(conditionnames(j),length(projectresults.conditions.(conditionnames{j}).slicesxsegments_supra(:,i)),1)];
                    table_infra = [table_infra; projectresults.conditions.(conditionnames{j}).slicesxsegments_infra(:,i)];
                    table_infra_group = [table_infra_group; repmat(conditionnames(j),length(projectresults.conditions.(conditionnames{j}).slicesxsegments_infra(:,i)),1)];
                    
                end
                %supra
                allnan = false;
                uniquegroup = unique(table_supra_group);
                for j=1:size(uniquegroup,1)
                    if(all(isnan(table_supra(strcmp(table_supra_group,uniquegroup{j})))))
                        allnan = true;
                    end
                end
                if(~allnan & size(~isnan(table_supra(strcmp(table_supra_group,uniquegroup{j}))))>2)
                    [nonparam_unmatched_supra_p,table,stats] = kruskalwallis(table_supra,table_supra_group,'off');
                    %alpha 0.001, 0.01 and 0.05
                    [c1,m1,h1,gnames] = multcompare(stats,'alpha',0.001,'display','off','ctype','tukey-kramer');
                    [c2,m2,h2,gnames] = multcompare(stats,'alpha',0.01,'display','off','ctype','tukey-kramer');
                    [c3,m3,h3,gnames] = multcompare(stats,'alpha',0.05,'display','off','ctype','tukey-kramer');
                    
                    %             projectresults.interconditions.([conditionnames{c1(j,1)} '_vs_' conditionnames{c1(j,2)}]).nonparam_unmatched_supra_table_0001 = c1;
                    %             projectresults.interconditions.([conditionnames{c1(j,1)} '_vs_' conditionnames{c1(j,2)}]).nonparam_unmatched_supra_table_001 = c2;
                    %             projectresults.interconditions.([conditionnames{c1(j,1)} '_vs_' conditionnames{c1(j,2)}]).nonparam_unmatched_supra_table_005 = c3;
                    %             projectresults.interconditions.([conditionnames{c1(j,1)} '_vs_' conditionnames{c1(j,2)}]).nonparam_unmatched_supra_p = nonparam_unmatched_supra_p;
                    
                    
                    for j=1:size(c1,1)
                        if(c1(j,3) < 0 && c1(j,5) < 0) || (c1(j,3) > 0 && c1(j,5) > 0)
                            if(m1(c1(j,1),1) > m1(c1(j,2),1))
                                projectresults.interconditions.([conditionnames{c1(j,1)} '_vs_' conditionnames{c1(j,2)}]).nonparam_unmatched_supra_diff(i) = 1;
                            else
                                projectresults.interconditions.([conditionnames{c1(j,1)} '_vs_' conditionnames{c1(j,2)}]).nonparam_unmatched_supra_diff(i) = -1;
                            end
                            projectresults.interconditions.([conditionnames{c1(j,1)} '_vs_' conditionnames{c1(j,2)}]).nonparam_unmatched_supra_h{i} = '***';
                        elseif(c2(j,3) < 0 && c2(j,5) < 0) || (c2(j,3) > 0 && c2(j,5) > 0)
                            if(m1(c2(j,1),1) > m1(c2(j,2),1))
                                projectresults.interconditions.([conditionnames{c1(j,1)} '_vs_' conditionnames{c1(j,2)}]).nonparam_unmatched_supra_diff(i) = 1;
                            else
                                projectresults.interconditions.([conditionnames{c1(j,1)} '_vs_' conditionnames{c1(j,2)}]).nonparam_unmatched_supra_diff(i) = -1;
                            end
                            projectresults.interconditions.([conditionnames{c1(j,1)} '_vs_' conditionnames{c1(j,2)}]).nonparam_unmatched_supra_h{i} = '**';
                            
                        elseif(c3(j,3) < 0 && c3(j,5) < 0) || (c3(j,3) > 0 && c3(j,5) > 0)
                            if(m1(c3(j,1),1) > m1(c3(j,2),1))
                                projectresults.interconditions.([conditionnames{c1(j,1)} '_vs_' conditionnames{c1(j,2)}]).nonparam_unmatched_supra_diff(i) = 1;
                            else
                                projectresults.interconditions.([conditionnames{c1(j,1)} '_vs_' conditionnames{c1(j,2)}]).nonparam_unmatched_supra_diff(i) = -1;
                            end
                            projectresults.interconditions.([conditionnames{c1(j,1)} '_vs_' conditionnames{c1(j,2)}]).nonparam_unmatched_supra_h{i} = '*';
                            
                        else
                            projectresults.interconditions.([conditionnames{c1(j,1)} '_vs_' conditionnames{c1(j,2)}]).nonparam_unmatched_supra_diff(i) = 0;
                            projectresults.interconditions.([conditionnames{c1(j,1)} '_vs_' conditionnames{c1(j,2)}]).nonparam_unmatched_supra_h{i} = '=';
                        end
                    end
                else
                    for j=1:size(uniquegroup,1)-1
                        for k=j+1:size(uniquegroup,1)
                            projectresults.interconditions.([uniquegroup{j} '_vs_' uniquegroup{k}]).nonparam_unmatched_supra_diff(i) = 0;
                            projectresults.interconditions.([uniquegroup{j} '_vs_' uniquegroup{k}]).nonparam_unmatched_supra_h{i} = '-';
                        end
                    end
                end
                
                %infra
                allnan = false;
                uniquegroup = unique(table_infra_group);
                for j=1:size(uniquegroup,1)
                    if(all(isnan(table_infra(strcmp(table_infra_group,uniquegroup{j})))))
                        allnan = true;
                    end
                end
                if(~allnan & size(~isnan(table_infra(strcmp(table_infra_group,uniquegroup{j}))))>2)
                    [nonparam_unmatched_infra_p,table,stats] = kruskalwallis(table_infra,table_infra_group,'off');
                    %alpha 0.001, 0.01 and 0.05
                    [c1,m1,h1,gnames] = multcompare(stats,'alpha',0.001,'display','off','ctype','tukey-kramer');
                    [c2,m2,h2,gnames] = multcompare(stats,'alpha',0.01,'display','off','ctype','tukey-kramer');
                    [c3,m3,h3,gnames] = multcompare(stats,'alpha',0.05,'display','off','ctype','tukey-kramer');
                    
                    %             projectresults.interconditions.([conditionnames{c1(j,1)} '_vs_' conditionnames{c1(j,2)}]).nonparam_unmatched_infra_table_0001 = c1;
                    %             projectresults.interconditions.([conditionnames{c1(j,1)} '_vs_' conditionnames{c1(j,2)}]).nonparam_unmatched_infra_table_001 = c2;
                    %             projectresults.interconditions.([conditionnames{c1(j,1)} '_vs_' conditionnames{c1(j,2)}]).nonparam_unmatched_infra_table_005 = c3;
                    %             projectresults.interconditions.([conditionnames{c1(j,1)} '_vs_' conditionnames{c1(j,2)}]).nonparam_unmatched_infra_p = nonparam_unmatched_infra_p;
                    
                    
                    for j=1:size(c1,1)
                        if(c1(j,3) < 0 && c1(j,5) < 0) || (c1(j,3) > 0 && c1(j,5) > 0)
                            if(m1(c1(j,1),1) > m1(c1(j,2),1))
                                projectresults.interconditions.([conditionnames{c1(j,1)} '_vs_' conditionnames{c1(j,2)}]).nonparam_unmatched_infra_diff(i) = 1;
                            else
                                projectresults.interconditions.([conditionnames{c1(j,1)} '_vs_' conditionnames{c1(j,2)}]).nonparam_unmatched_infra_diff(i) = -1;
                            end
                            projectresults.interconditions.([conditionnames{c1(j,1)} '_vs_' conditionnames{c1(j,2)}]).nonparam_unmatched_infra_h{i} = '***';
                        elseif(c2(j,3) < 0 && c2(j,5) < 0) || (c2(j,3) > 0 && c2(j,5) > 0)
                            if(m1(c2(j,1),1) > m1(c2(j,2),1))
                                projectresults.interconditions.([conditionnames{c1(j,1)} '_vs_' conditionnames{c1(j,2)}]).nonparam_unmatched_infra_diff(i) = 1;
                            else
                                projectresults.interconditions.([conditionnames{c1(j,1)} '_vs_' conditionnames{c1(j,2)}]).nonparam_unmatched_infra_diff(i) = -1;
                            end
                            projectresults.interconditions.([conditionnames{c1(j,1)} '_vs_' conditionnames{c1(j,2)}]).nonparam_unmatched_infra_h{i} = '**';
                            
                        elseif(c3(j,3) < 0 && c3(j,5) < 0) || (c3(j,3) > 0 && c3(j,5) > 0)
                            if(m1(c3(j,1),1) > m1(c3(j,2),1))
                                projectresults.interconditions.([conditionnames{c1(j,1)} '_vs_' conditionnames{c1(j,2)}]).nonparam_unmatched_infra_diff(i) = 1;
                            else
                                projectresults.interconditions.([conditionnames{c1(j,1)} '_vs_' conditionnames{c1(j,2)}]).nonparam_unmatched_infra_diff(i) = -1;
                            end
                            projectresults.interconditions.([conditionnames{c1(j,1)} '_vs_' conditionnames{c1(j,2)}]).nonparam_unmatched_infra_h{i} = '*';
                            
                        else
                            projectresults.interconditions.([conditionnames{c1(j,1)} '_vs_' conditionnames{c1(j,2)}]).nonparam_unmatched_infra_diff(i) = 0;
                            projectresults.interconditions.([conditionnames{c1(j,1)} '_vs_' conditionnames{c1(j,2)}]).nonparam_unmatched_infra_h{i} = '=';
                        end
                    end
                else
                    for j=1:size(uniquegroup,1)-1
                        for k=j+1:size(uniquegroup,1)
                            projectresults.interconditions.([uniquegroup{j} '_vs_' uniquegroup{k}]).nonparam_unmatched_infra_diff(i) = 0;
                            projectresults.interconditions.([uniquegroup{j} '_vs_' uniquegroup{k}]).nonparam_unmatched_infra_h{i} = '-';
                        end
                    end
                end
            end
            
            
            interconditionnames = fieldnames(projectresults.interconditions);
            for i=1:size(interconditionnames,1)
                cond = regexp(interconditionnames{i},'_vs_','split');
                fprintf(flogid,'Non-parametric unmatched test (Kruskal-Wallis with Tuckey post-hoc) between conditions %s and %s supra:\n',cond{1},cond{2});
                fprintf(flogid,[repmat('%s\t',1,size(temp,2)) '\n'],projectresults.interconditions.(interconditionnames{i}).nonparam_unmatched_supra_h{:});
                fprintf(flogid,'Non-parametric unmatched test (Kruskal-Wallis with Tuckey post-hoc) between conditions %s and %s infra:\n',cond{1},cond{2});
                fprintf(flogid,[repmat('%s\t',1,size(temp,2)) '\n'],projectresults.interconditions.(interconditionnames{i}).nonparam_unmatched_infra_h{:});
                
                fprintf('Non-parametric unmatched test (Kruskal-Wallis with Tuckey post-hoc) between conditions %s and %s run:\n',cond{1},cond{2});
            end
            
            
        end
        
        %test normality and equal variance for all slices per condition (per
        %region)
        for i=1:size(conditionnames,1)
            regions = fieldnames(projectresults.conditions.(conditionnames{i}).regions);
            normalitypassed = 0;
            for j=1:size(regions,1)
                region = fieldnames(projectresults.conditions.(conditionnames{i}).regions.(regions{j}));
                strpassed = {'passed' 'not passed'};
                for k=1:size(region,1)
                    if(all(isnan(projectresults.conditions.(conditionnames{i}).regions.(regions{j}).(region{k}).segments_supra)))
                        projectresults.conditions.(conditionnames{i}).regions.(regions{j}).(region{k}).normality_supra = NaN;
                        
                    else
                        [h,p,q] = kstest(projectresults.conditions.(conditionnames{i}).regions.(regions{j}).(region{k}).segments_supra);
                        fprintf(flogid,'Condition %s segment %d supra %s normality test with p = %d\n',char(conditionnames(i)), j,char(strpassed(h+1)),p);
                        normalitypassed = normalitypassed | h;
                        projectresults.conditions.(conditionnames{i}).regions.(regions{j}).(region{k}).normality_supra = p;
                    end
                    if(all(isnan(projectresults.conditions.(conditionnames{i}).regions.(regions{j}).(region{k}).segments_infra)))
                        projectresults.conditions.(conditionnames{i}).regions.(regions{j}).(region{k}).normality_infra = NaN;
                    else
                        [h,p,q] = kstest(projectresults.conditions.(conditionnames{i}).regions.(regions{j}).(region{k}).segments_infra);
                        fprintf(flogid,'Condition %s segment %d infra %s normality test with p = %d\n',char(conditionnames(i)), j,char(strpassed(h+1)),p);
                        normalitypassed = normalitypassed | h;
                        projectresults.conditions.(conditionnames{i}).regions.(regions{j}).(region{k}).normality_infra = p;
                    end
                end
                fprintf('Normality test for all regions (%s) of condition %s %s\n',char(regions{j}),char(conditionnames(i)),char(strpassed(normalitypassed+1)));
                fprintf(flogid,'Normality test for all regions (%s) of condition %s %s\n',char(regions{j}),char(conditionnames(i)),char(strpassed(normalitypassed+1)));
            end
            
            %test equal variance
            %Two-sampled F-test (vartest2) (0 passes null hypothesis, 1 rejects
            %it)
            equalvarpassed = 0;
            regions = fieldnames(projectresults.conditions.(conditionnames{i}).regions);
            for j=1:size(regions,1)
                region = fieldnames(projectresults.conditions.(conditionnames{i}).regions.(regions{j}));
                strpassed = {'passed' 'not passed'};
                equalvar_supra = repmat('-',size(region,1),size(region,1));
                equalvar_infra = repmat('-',size(region,1),size(region,1));
                for k=1:size(region,1)-1
                    for l=1+k:size(region,1)
                        [h,p] = vartest2(projectresults.conditions.(conditionnames{i}).regions.(regions{j}).(region{k}).segments_supra,projectresults.conditions.(conditionnames{i}).regions.(regions{j}).(region{l}).segments_supra);
                        if(isnan(h))
                            equalvar_supra(k,l) = sprintf('%d',9);
                        else
                            equalvar_supra(k,l) = sprintf('%d',h);
                            equalvarpassed = equalvarpassed | h;
                        end
                        [h,p] = vartest2(projectresults.conditions.(conditionnames{i}).regions.(regions{j}).(region{k}).segments_infra,projectresults.conditions.(conditionnames{i}).regions.(regions{j}).(region{l}).segments_infra);
                        if(isnan(h))
                            equalvar_infra(k,l) = sprintf('%d',9);
                        else
                            equalvar_infra(k,l) = sprintf('%d',h);
                            equalvarpassed = equalvarpassed | h;
                        end
                    end
                end
                fprintf(flogid,'Equal variance test for condition %s supra (regions %s):  (0 passes null hypothesis, 1 rejects it)\n',char(conditionnames(i)),char(regions{j}));
                fprintf(flogid,[repmat('%c\t',1,size(equalvar_supra,2)) '\n'],equalvar_supra');
                fprintf(flogid,'Equal variance test for condition %s infra (regions %s):  (0 passes null hypothesis, 1 rejects it)\n',char(conditionnames(i)),char(regions{j}));
                fprintf(flogid,[repmat('%c\t',1,size(equalvar_infra,2)) '\n'],equalvar_infra');
                fprintf('Equal variance test for all segments of condition %s %s\n',char(conditionnames(i)),char(strpassed(equalvarpassed+1)));
                fprintf(flogid,'Equal variance test for all segments of condition %s %s\n',char(conditionnames(i)),char(strpassed(equalvarpassed+1)));
                %save equal variance results in struct mouseresults
                projectresults.conditions.(conditionnames{i}).(['equalvar_' regions{j} '_supra']) = equalvar_supra;
                projectresults.conditions.(conditionnames{i}).(['equalvar_' regions{j} '_infra']) = equalvar_infra;
            end
            
            
            
            
            if(~(normalitypassed || equalvarpassed))  %if both 0, so normal and equalvar
                %parametric tests
                warning('Warning: parametric test');
            else
                
                %intracondition tests
                
                %non-parametric tests
                %Compare within one condition each segment to find differences
                %Unpaired difference test: Mann Whintey-U test (ranksum)
                %(0 passes null hypothesis, 1 rejects it)
                regions = fieldnames(projectresults.conditions.(conditionnames{i}).regions);
                for j=1:size(regions,1)
                    region = fieldnames(projectresults.conditions.(conditionnames{i}).regions.(regions{j}));
                    paireddiff_supra_h = repmat('-',size(region,1),size(region,1));
                    paireddiff_infra_h = repmat('-',size(region,1),size(region,1));
                    paireddiff_supra_p = zeros(size(region,1));
                    paireddiff_infra_p = zeros(size(region,1));
                    difference_supra = zeros(size(region,1));
                    difference_infra = zeros(size(region,1));
                    for k=1:size(region,1)-1
                        for l = k+1:size(region,1)
                            [p,h] = ranksum(projectresults.conditions.(conditionnames{i}).regions.(regions{j}).(region{k}).segments_supra,projectresults.conditions.(conditionnames{i}).regions.(regions{j}).(region{l}).segments_supra);
                            paireddiff_supra_h(k,l) = sprintf('%d',h);
                            paireddiff_supra_p(k,l) = p;
                            difference_supra(k,l) = mean(projectresults.conditions.(conditionnames{i}).regions.(regions{j}).(region{k}).segments_supra) - mean(projectresults.conditions.(conditionnames{i}).regions.(regions{j}).(region{l}).segments_supra);
                            [p,h] = ranksum(projectresults.conditions.(conditionnames{i}).regions.(regions{j}).(region{k}).segments_infra,projectresults.conditions.(conditionnames{i}).regions.(regions{j}).(region{l}).segments_infra);
                            paireddiff_infra_h(k,l) = sprintf('%d',h);
                            paireddiff_infra_p(k,l) = p;
                            difference_infra(k,l) = mean(projectresults.conditions.(conditionnames{i}).regions.(regions{j}).(region{k}).segments_infra) - mean(projectresults.conditions.(conditionnames{i}).regions.(regions{j}).(region{l}).segments_infra);
                        end
                    end
                    fprintf(flogid,'Paired difference test (Wilcoxon signed rank) for condition %s supra (region %s):  (0 passes null hypothesis, 1 rejects it)\n',char(conditionnames{i}),char(regions{j}));
                    fprintf(flogid,[repmat('%c\t',1,size(paireddiff_supra_h,2)) '\n'],paireddiff_supra_h');
                    fprintf(flogid,'p-values of paired difference test (Wilcoxon signed rank) for mouse %s supra (region %s):  \n',char(conditionnames{i}),char(regions{j}));
                    fprintf(flogid,[repmat('%d\t',1,size(paireddiff_supra_p,2)) '\n'],paireddiff_supra_p');
                    fprintf(flogid,'Paired difference test (Wilcoxon signed rank) for mouse %s infra (region %s):  (0 passes null hypothesis, 1 rejects it)\n',char(conditionnames{i}),char(regions{j}));
                    fprintf(flogid,[repmat('%c\t',1,size(paireddiff_infra_h,2)) '\n'],paireddiff_infra_h');
                    fprintf(flogid,'p-values of paired difference test (Wilcoxon signed rank) for mouse %s infra (region %s):  \n',char(conditionnames{i}),char(regions{j}));
                    fprintf(flogid,[repmat('%d\t',1,size(paireddiff_infra_p,2)) '\n'],paireddiff_infra_p');
                    fprintf('Paired difference test (Wilcoxon signed rank) for all segments of condition %s tested for region %s\n',char(conditionnames{i}),char(regions{j}));
                    fprintf(flogid,'Paired difference test (Wilcoxon signed rank) for all segments of condition %s tested for region %s\n',char(conditionnames{i}),char(regions{j}));
                    
                    %save paired difference test results in struct mouseresults
                    projectresults.intraconditions.(conditionnames{i}).regions.(regions{j}).paireddiff_supra_h = paireddiff_supra_h;
                    projectresults.intraconditions.(conditionnames{i}).regions.(regions{j}).paireddiff_supra_p = paireddiff_supra_p;
                    projectresults.intraconditions.(conditionnames{i}).regions.(regions{j}).difference_supra = difference_supra;
                    projectresults.intraconditions.(conditionnames{i}).regions.(regions{j}).paireddiff_infra_h = paireddiff_infra_h;
                    projectresults.intraconditions.(conditionnames{i}).regions.(regions{j}).paireddiff_infra_p = paireddiff_infra_p;
                    projectresults.intraconditions.(conditionnames{i}).regions.(regions{j}).difference_infra = difference_infra;
                end
                
            end
        end
        
        if(~(normalitypassed || equalvarpassed))  %if both 0, so normal and equalvar
            %parametric tests
            %TODO
            warning('Warning: parametric test');
        else
            conditionslist = sort(fieldnames(projectresults.conditions));
            
            
            %intercondition tests
            
            %non-parametric tests
            %Compare between conditions each segment to find differences
            %Unpaired difference test: Mann Whintey-U test (ranksum)
            %(0 passes null hypothesis, 1 rejects it)
            
            for i=1:size(conditionslist,1)-1
                for j=i+1:size(conditionslist,1)
                    regions = fieldnames(projectresults.conditions.(conditionnames{i}).regions);
                    for k=1:size(regions,1)
                        region = fieldnames(projectresults.conditions.(conditionnames{i}).regions.(regions{k}));
                        unpaireddiff_supra_h = zeros(1,size(region,1));
                        unpaireddiff_supra_p = zeros(1,size(region,1));
                        unpaireddiff_infra_h = zeros(1,size(region,1));
                        unpaireddiff_infra_p = zeros(1,size(region,1));
                        difference_supra = zeros(1,size(region,1));
                        difference_infra = zeros(1,size(region,1));
                        for l=1:size(region,1)
                            [p,h] = ranksum(projectresults.conditions.(conditionnames{i}).regions.(regions{k}).(region{l}).segments_supra,projectresults.conditions.(conditionnames{j}).regions.(regions{k}).(region{l}).segments_supra);
                            unpaireddiff_supra_h(l) = h;
                            unpaireddiff_supra_p(l) = p;
                            difference_supra(l) = mean(projectresults.conditions.(conditionnames{i}).regions.(regions{k}).(region{l}).segments_supra) - mean(projectresults.conditions.(conditionnames{j}).regions.(regions{k}).(region{l}).segments_supra);
                            [p,h] = ranksum(projectresults.conditions.(conditionnames{i}).regions.(regions{k}).(region{l}).segments_infra,projectresults.conditions.(conditionnames{j}).regions.(regions{k}).(region{l}).segments_infra);
                            unpaireddiff_infra_h(l) = h;
                            unpaireddiff_infra_p(l) = p;
                            difference_infra(l) = mean(projectresults.conditions.(conditionnames{i}).regions.(regions{k}).(region{l}).segments_infra) - mean(projectresults.conditions.(conditionnames{j}).regions.(regions{k}).(region{l}).segments_infra);
                        end
                        fprintf(flogid,'Unpaired difference test (Wilcoxon rank sum test) between conditions %s and %s supra (region %s):  (0 passes null hypothesis, 1 rejects it)\n',conditionslist{i},conditionslist{j},char(regions{k}));
                        fprintf(flogid,[repmat('%c\t',1,size(unpaireddiff_supra_h,2)) '\n'],unpaireddiff_supra_h');
                        fprintf(flogid,'p-values of unpaired difference test (Wilcoxon signed rank) between condtions %s and %s supra (region %s):  \n',conditionslist{i},conditionslist{j},char(regions{k}));
                        fprintf(flogid,[repmat('%d\t',1,size(unpaireddiff_supra_p,2)) '\n'],unpaireddiff_supra_p');
                        fprintf(flogid,'Unpaired difference test (Wilcoxon rank sum test) between conditions %s and %s infra (region %s):  (0 passes null hypothesis, 1 rejects it)\n',conditionslist{i},conditionslist{j},char(regions{k}));
                        fprintf(flogid,[repmat('%c\t',1,size(unpaireddiff_infra_h,2)) '\n'],unpaireddiff_infra_h');
                        fprintf(flogid,'p-values of unpaired difference test (Wilcoxon signed rank) between conditions %s and %s infra (region %s):  \n',conditionslist{i},conditionslist{j},char(regions{k}));
                        fprintf(flogid,[repmat('%d\t',1,size(unpaireddiff_infra_p,2)) '\n'],unpaireddiff_infra_p');
                        fprintf('Unpaired difference test (Wilcoxon rank sum test) for all segments between conditions %s and %s tested for region %s\n',conditionslist{i},conditionslist{j},char(regions{k}));
                        fprintf(flogid,'Unpaired difference test (Wilcoxon rank sum test) for all segments between conditions %s and %s tested for region %s\n',conditionslist{i},conditionslist{j},char(regions{k}));
                        
                        %save in conditions variable
                        projectresults.interconditions.([conditionslist{i} '_vs_' conditionslist{j}]).regions.(regions{k}).region = region;
                        projectresults.interconditions.([conditionslist{i} '_vs_' conditionslist{j}]).regions.(regions{k}).unpaireddiff_supra_h = unpaireddiff_supra_h;
                        projectresults.interconditions.([conditionslist{i} '_vs_' conditionslist{j}]).regions.(regions{k}).unpaireddiff_supra_p = unpaireddiff_supra_p;
                        projectresults.interconditions.([conditionslist{i} '_vs_' conditionslist{j}]).regions.(regions{k}).difference_supra = difference_supra;
                        projectresults.interconditions.([conditionslist{i} '_vs_' conditionslist{j}]).regions.(regions{k}).unpaireddiff_infra_h = unpaireddiff_infra_h;
                        projectresults.interconditions.([conditionslist{i} '_vs_' conditionslist{j}]).regions.(regions{k}).unpaireddiff_infra_p = unpaireddiff_infra_p;
                        projectresults.interconditions.([conditionslist{i} '_vs_' conditionslist{j}]).regions.(regions{k}).difference_infra = difference_infra;
                    end
                    
                end
            end
            
        end
    end
    
    fclose(flogid);
    
    fprintf('Analysis ended\n');
    
    %save setuptable and resultfile
    if(isfield(handles,'ROI'))
        ROI = handles.ROI;
        save([handles.savepath char(handles.savename) '.mat'],'setuptable','ROI');
    else
        save([handles.savepath char(handles.savename) '.mat'],'setuptable');
    end
    save([handles.savepath handles.savename '_results.mat'],'projectresults');
    fprintf('Project saved as %s\n',handles.savename);
    fprintf('Results saved as %s\n',[handles.savename '_results.mat']);
    %store handles
    handles.setuptable = setuptable;
    handles.projectresults = projectresults;
    

%-x-x-x- WORKFLOW ADDITIONAL ROUTINES -x-x-x-%
function reload_listbox(handles,select)
    cond =unique(handles.setuptable(:,1));
    if(select(1) > size(cond,1))
        select = [1 1 1];
    else
        mice =unique(handles.setuptable(strcmp(handles.setuptable(:,1),cond(select(1))),2));
        if(select(2) > size(mice,1))
            select = [select(1) 1 1];
        else
            slices = handles.setuptable(strcmp(handles.setuptable(:,1),cond(select(1))) & strcmp(handles.setuptable(:,2),mice(select(2))),3);
            if(select(3) > size(slices,1))
                select = [select(1) select(2) 1];
            end
        end
    end
   
    set(handles.list_cond,'String',unique(handles.setuptable(:,1)));
    set(handles.list_cond,'Value',select(1));
    
    set(handles.list_mice,'String',unique(handles.setuptable(strcmp(handles.setuptable(:,1),cond(select(1))),2)));
    set(handles.list_mice,'Value',select(2));
    
    set(handles.list_slices,'String',handles.setuptable(strcmp(handles.setuptable(:,1),cond(select(1))) & strcmp(handles.setuptable(:,2),mice(select(2))),3));
    set(handles.list_slices,'Value',select(3));
    if(handles.debug)
        disp(handles.setuptable);
    end

function setuptable = initiate_setuptable()
    borders.arealborder = [];
    borders.topp = [];
    borders.midp = [];
    borders.botp = [];
    rastervalues.meansupra_raw = [];
    rastervalues.meaninfra_raw = [];
    setuptable = {'-','-','-','-',borders,rastervalues};


%-x-x-x- GUI EDITED CALLBACKS -x-x-x-%
%Menu
function menu_Callback(hObject, eventdata, handles)

function new_Callback(hObject, eventdata, handles)
% hObject    handle to new (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    handles.setuptable = initiate_setuptable();
    reload_listbox(handles,[1 1 1]);
    set(handles.fig_ISH_setup,'Name','ISH - <not-saved>');
    handles.savename = '';
    guidata(hObject,handles);
    disp('New project created');

function load_Callback(hObject, eventdata, handles)
% hObject    handle to load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    [filename path] = uigetfile('saved_analysis/*.mat','Select project');
    if(~isnumeric(filename))
        temp = load([path filename]);
        handles.setuptable = temp.setuptable;
        if(isfield(temp,'ROI'))
            handles.ROI = temp.ROI;
        end
        %check existence slice folder
        folders = unique(handles.setuptable(:,4));
        for i=1:size(folders,1)
            if(~strcmp(folders{i},'-') && exist(folders{i},'dir') ~= 7)
                cond = handles.setuptable(strcmp(handles.setuptable(:,4),folders{i}),1);
                mouse = handles.setuptable(strcmp(handles.setuptable(:,4),folders{i}),2);
                slices = handles.setuptable(strcmp(handles.setuptable(:,4),folders{i}),3);
                path = uigetdir('',sprintf(['Select folder that contains condition %s, mouse %s, and slice %s' repmat(', %s',1,size(slices,2)-1) ' for this experiment.'],cond{1}, mouse{1}, slices{1}));
                if(strcmp(path,'') | ~path)
                    break;
                else
                    for j=1:size(handles.setuptable,1)
                        if(~strcmp(handles.setuptable{j,4},'-') && strcmp(handles.setuptable{j,4},folders{i}))
                            if(strcmp(handles.mac,'on'))
                                handles.setuptable{j,4} = [path '/'];
                            else
                                handles.setuptable{j,4} = [path '\'];
                            end
                        end
                    end
                end
            end
        end
        reload_listbox(handles,[1 1 1]);
        if(isfield(handles.setuptable{1,5},'areas'))
            handles.areas = handles.setuptable{1,5}.areas;
            handles.arealborders = size(strfind(handles.areas,','),2) + size(strfind(handles.areas,'|'),2)*2 +2;
        end
        set(handles.edit_areas,'String',handles.areas);
        if(isfield(handles.setuptable{1,6},'segments'))
           set(handles.edit_segments,'String',handles.setuptable{1,6}.segments);
           handles.rastersegments = handles.setuptable{1,6}.segments;
        end
        
        if(exist([path filename(1:end-4) '_results.mat'],'file'))
            temp = load([path filename(1:end-4) '_results.mat']);
            handles.projectresults = temp.projectresults;
            set(handles.push_runstatistics,'Enable','On');
        end
        set(handles.fig_ISH_setup,'Name',['ISH - ' filename]);
        handles.savename = filename(1:end-4);
        str = sprintf('Project %s loaded',char(filename(1:end-4)));
        disp(str);
    end
    guidata(hObject,handles);

function handles = save_Callback(hObject, eventdata, handles)
% hObject    handle to save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    if(strcmp(handles.savename,''))
        handles.savename = char(inputdlg('Save analysis as...','ISH Project Setup'));
    end
    if(~isempty(handles.savename))
        setuptable = handles.setuptable;
        if(size(setuptable,2) > 6)
            setuptable = setuptable(:,1:6);
        end
        if(isfield(handles,'ROI'))
            ROI = handles.ROI;
            save([handles.savepath char(handles.savename) '.mat'],'setuptable','ROI');
        else
            save([handles.savepath char(handles.savename) '.mat'],'setuptable');
        end
        set(handles.fig_ISH_setup,'Name',['ISH - ' handles.savename '.mat']);
        str = sprintf('Project saved as %s',handles.savename);
        disp(str);
    end
    
    guidata(hObject,handles);
    
function close_Callback(hObject, eventdata, handles)

function exit_Callback(hObject, eventdata, handles)

function append_Callback(hObject, eventdata, handles)
    [filename path] = uigetfile('saved_analysis/*.mat','Select project to append to current project.');
    if(~isnumeric(filename))
        temp = load([path filename]);
        if(temp.setuptable{1,5}.arealborders == handles.setuptable{1,5}.arealborders)
            handles.setuptable = [handles.setuptable; temp.setuptable];
            if(isfield(temp,'ROI'))
                handles.ROI = [handles.ROI; temp.ROI];
            end
        else
            errordlg('The project you want to append to the current project does not have the same amount of areal boundries as the current project.','ISH Analysis - Setup dimension mismatch');
        end
    end
    %check existence slice folder
        folders = unique(handles.setuptable(:,4));
        for i=1:size(folders,1)
            if(~strcmp(folders{i},'-') && exist(folders{i},'dir') ~= 7)
                slices = handles.setuptable(strcmp(handles.setuptable(:,4),folders{i}),3);
                path = uigetdir('',sprintf(['Select folder that contains slices %s' repmat(', %s',1,size(slices,2)-1) ' for this experiment.'],slices{:}));
                if(strcmp(path,''))
                    break;
                else
                    for j=1:size(handles.setuptable,1)
                        if(~strcmp(handles.setuptable{j,4},'-') && strcmp(handles.setuptable{j,4},folders{i}))
                            handles.setuptable{j,4} = [path '\'];
                        end
                    end
                end
            end
        end
    reload_listbox(handles,[1 1 1]);
    guidata(hObject,handles);
    
function menu_raster_Callback(hObject, eventdata, handles)
    handles.showraster = str2num(char(inputdlg('Raster to show (0 to disable)','Show raster')));
    set(handles.menu_raster,'Label',sprintf('Show raster: %d',handles.showraster));
    guidata(hObject,handles);

function menu_mac_Callback(hObject, eventdata, handles)
    if(strcmp(get(hObject,'Checked'),'on'))
        handles.mac = 'off';
    else
        handles.mac = 'on';
    end
    set(hObject,'Checked',handles.mac);
    fprintf('Mac compatibility %s\n',handles.debug);
    guidata(hObject,handles);
    
function menu_fixmac_Callback(hObject, eventdata, handles)
    fixed = 0;
    for i=1:size(handles.setuptable)
        if(strfind(handles.setuptable{i,4},'\'))
            fixed = fixed + 1;
        end
        handles.setuptable{i,4} = regexprep(handles.setuptable{i,4},'\','/');
    end
    guidata(hObject,handles);
    warndlg(sprintf('Fixed %d filenames for Mac compatibility. Save your project now.',fixed),'Mac compatibility');
    
function menu_fixwin_Callback(hObject, eventdata, handles)
    fixed = 0;
    for i=1:size(handles.setuptable)
        if(strfind(handles.setuptable{i,4},'/'))
            fixed = fixed + 1;
        end
        handles.setuptable{i,4} = regexprep(handles.setuptable{i,4},'/','\');
    end
    guidata(hObject,handles);
    warndlg(sprintf('Fixed %d filenames for Mac compatibility. Save your project now.',fixed),'Mac compatibility');
   
function menu_showselslice_Callback(hObject, eventdata, handles)
    setuptable = handles.setuptable;
    slices = get(handles.list_slices,'String');
    slice = slices{get(handles.list_slices,'Value')};
    mice = get(handles.list_mice,'String');
    mouse = mice(get(handles.list_mice,'Value'));
    conditions = get(handles.list_cond,'String');
    cond = conditions(get(handles.list_cond,'Value'));
    imgid = strcmp(setuptable(:,1),cond) & strcmp(setuptable(:,2),mouse) & strcmp(setuptable(:,3),slice);
    if(isfield(handles,'hfigselslice'))
        handles.hfigselslice = showSlice(setuptable(imgid,:),handles.hfigselslice);
    else
        handles.hfigselslice = showSlice(setuptable(imgid,:));
    end
    guidata(hObject,handles);

function menu_topview_Callback(hObject, eventdata, handles)
    handles = ISHtopview(handles,'conditions');
    guidata(hObject,handles);
 
function menu_topview_mouse_Callback(hObject, eventdata, handles)
% hObject    handle to menu_topview_mouse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    handles = ISHtopview(handles,'flatmount');
    guidata(hObject,handles);
    
function skipcalcod_Callback(hObject, eventdata, handles)
% hObject    handle to skipcalcod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    if(~isfield(handles,'skipod'))
        handles.skipod = 'off';
    end
    if(strcmp(handles.skipod,'on'))
        handles.skipod = 'off';
    else
        handles.skipod = 'on';
    end
    set(hObject,'Checked',handles.skipod);
    
    fprintf('Skip OD %s\n',handles.skipod);
    guidata(hObject,handles);

%GUI
function push_addCond_Callback(hObject, eventdata, handles)
% hObject    handle to push_addCond (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    handles = addCond(handles);
    guidata(hObject,handles);

function list_cond_Callback(hObject, eventdata, handles)
% hObject    handle to list_cond (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns list_cond contents as cell array
%        contents{get(hObject,'Value')} returns selected item from list_cond
    reload_listbox(handles,[get(hObject,'Value') 1 1]);

function push_delCond_Callback(hObject, eventdata, handles)
% hObject    handle to push_delCond (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    handles = delCond(handles);
    guidata(hObject,handles);

function push_addMouse_Callback(hObject, eventdata, handles)
% hObject    handle to push_addMouse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    handles = addMouse(handles);
    guidata(hObject,handles);

function push_delMouse_Callback(hObject, eventdata, handles)
% hObject    handle to push_delMouse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    handles = delMouse(handles);
    guidata(hObject,handles);
    
function list_mice_Callback(hObject, eventdata, handles)
% hObject    handle to list_mice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns list_mice contents as cell array
%        contents{get(hObject,'Value')} returns selected item from list_mice
reload_listbox(handles,[get(handles.list_cond,'Value') get(hObject,'Value') 1]);

function push_addSlices_Callback(hObject, eventdata, handles)
% hObject    handle to push_addSlices (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    handles = addSlice(handles);
    guidata(hObject,handles);

function push_delSlices_Callback(hObject, eventdata, handles)
% hObject    handle to push_delSlices (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    handles = delSlice(handles);
    guidata(hObject,handles);

function list_slices_Callback(hObject, eventdata, handles)
% hObject    handle to list_slices (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns list_slices contents as cell array
%        contents{get(hObject,'Value')} returns selected item from list_slices
if(strcmp(get(handles.fig_ISH_setup,'SelectionType'),'open'))
   slices = get(hObject,'String');
   filename = slices(get(hObject,'Value'));
   conditions = get(handles.list_cond,'String');
   cond = conditions(get(handles.list_cond,'Value'));
   mice = get(handles.list_mice,'String');
   mouse = mice(get(handles.list_mice,'Value'));
   id = strcmp(handles.setuptable(:,1),cond) & strcmp(handles.setuptable(:,2),mouse) & strcmp(handles.setuptable(:,3),filename);
   setuptablerow = handles.setuptable(id,:);
   path = setuptablerow(4);
   %show stored information
   if(isfield(handles,'hfigselslice'))
       handles.hfigselslice = showSlice(setuptablerow,handles.hfigselslice);
   else
       handles.hfigselslice = showSlice(setuptablerow);
   end
   title('Retrace this slice? Press Enter to continue, Escape to cancel.');
   set(handles.hfigselslice,'KeyPressFcn', @escapekeypress);
   uiwait;
   if(ishandle(handles.hfigselslice))
       borders = setBordersSlice(filename, path,handles);
       %if succesfull store in setuptable
       %store midline if set
       if(isfield(handles.setuptable{id,5},'midlinep'))
           midlinep = handles.setuptable{id,5}.midlinep;
           midlinept = handles.setuptable{id,5}.midlinept;
           handles.setuptable{id,5} = borders;
           handles.setuptable{id,5}.midlinep = midlinep;
           handles.setuptable{id,5}.midlinept = midlinept;
       else
           handles.setuptable{id,5} = borders;
       end
       handles.setuptable{id,6} = [];
   end
    
end
guidata(hObject,handles);

function edit_areas_Callback(hObject, eventdata, handles)
% hObject    handle to edit_areas (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_areas as text
%        str2double(get(hObject,'String')) returns contents of edit_areas as a double
handles.areas = get(handles.edit_areas,'String');

handles.arealborders = size(findstr(',',handles.areas),2) + size(findstr('|',handles.areas),2)*2 +2;
set(handles.text_arealborders,'String',['-> ' num2str(handles.arealborders) ' areal borders']);
areassplit = regexp(handles.areas,',|\|','split');
areas_pivot{1} = 'None';
for i=1:size(areassplit,2)-1
    areas_pivot{i+1} =sprintf('%s | %s',areassplit{i},areassplit{i+1});
end
set(handles.popup_pivot,'String',areas_pivot);

guidata(hObject,handles);

function saveas_Callback(hObject, eventdata, handles)
% hObject    handle to saveas (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    handles.savename = char(inputdlg('Save analysis as...','ISH Project Setup'));
    if(~isempty(handles.savename))
        setuptable = handles.setuptable;
        if(isfield(handles,'ROI'))
            ROI = handles.ROI;
            save([handles.savepath char(handles.savename) '.mat'],'setuptable','ROI');
        else
            save([handles.savepath char(handles.savename) '.mat'],'setuptable');
        end
        set(handles.fig_ISH_setup,'Name',['ISH - ' handles.savename '.mat']);
        str = sprintf('Project saved as %s',handles.savename);
        disp(str);
    end
    
    guidata(hObject,handles);

function push_segmentize_Callback(hObject, eventdata, handles)
% hObject    handle to push_segmentize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    handles = rasterize(handles);
    fprintf('End segmentation protocol\n');
    
    guidata(hObject,handles);

function list_verif_Callback(hObject, eventdata, handles)
% hObject    handle to list_verif (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns list_verif contents as cell array
%        contents{get(hObject,'Value')} returns selected item from list_verif
if(strcmp(get(handles.fig_ISH_setup,'SelectionType'),'open'))
   slices = get(hObject,'String');
   filename = slices(get(hObject,'Value'));
   path = handles.setuptable(strcmp(handles.setuptable(:,3),filename),4);
   borders = setBordersSlice(filename, path,handles);
   %if succesfull store in setuptable
   handles.setuptable{strcmp(handles.setuptable(:,3),filename),5} = borders;
   handles.setuptable{strcmp(handles.setuptable(:,3),filename),6} = [];
end
guidata(hObject,handles);

function checkbox_pivot_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_pivot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_pivot
if(get(hObject,'Value'))
    set(handles.popup_pivot,'Enable','On');
else
    set(handles.popup_pivot,'Enable','Off');
end

function push_results_Callback(hObject, eventdata, handles)
% hObject    handle to push_results (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    ISHresults({[handles.savepath handles.savename '_results.mat']});
    
function push_extractdata_Callback(hObject, eventdata, handles)
% hObject    handle to push_results (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    %check if setup is saved
    if(strcmp(handles.savename,''))
        handles = save_Callback(hObject, eventdata, handles);
    end
    handles = extractdata(handles);
    
     
    %set push_statistics enabled
    set(handles.push_runstatistics,'Enable','On');
    guidata(hObject,handles);

function push_runstatistics_Callback(hObject, eventdata, handles)
    if(strcmp(handles.savename,''))
        handles = save_Callback(hObject, eventdata, handles);
    end
    handles = runstatistics(handles);
    
    ISHresults({[handles.savepath handles.savename '_results.mat']});
    
    %set push_results enabled
    set(handles.push_results,'Enable','On');
    guidata(hObject,handles);
    
function edit_segments_Callback(hObject, eventdata, handles)
    handles.rastersegments = str2double(get(handles.edit_segments,'String'));
    guidata(hObject,handles);

function menu_debug_Callback(hObject, eventdata, handles)
    if(strcmp(get(hObject,'Checked'),'on'))
        handles.debug = 0;
        tmp = 'off';
    else
        handles.debug = 1;
        tmp = 'on';
    end
    set(hObject,'Checked',tmp);
    fprintf('Debug mode %s\n',handles.debug);
    guidata(hObject,handles);

function push_ROI_Callback(hObject, eventdata, handles)
    if(isfield(handles,'ROI'))
        roi = areapicker({handles.areas},handles.ROI);
    else
        roi =  areapicker({handles.areas});
    end
    if(iscell(roi))
        handles.ROI = roi;
    end
    guidata(hObject,handles);
 
function list_slices_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to list_slices (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
if(strcmp(eventdata.Key,'f1'))
    menu_showselslice_Callback(hObject, eventdata, handles);
end
    
%-x-x-x- GUI TRASH CALLBACKS -x-x-x-%
function edit_segments_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_segments (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function radiobutton1_Callback(hObject, eventdata, handles)

function radiobutton2_Callback(hObject, eventdata, handles)

function list_cond_CreateFcn(hObject, eventdata, handles)
% hObject    handle to list_cond (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function list_mice_CreateFcn(hObject, eventdata, handles)
% hObject    handle to list_mice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function list_slices_CreateFcn(hObject, eventdata, handles)
% hObject    handle to list_slices (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit_areas_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_areas (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit7_Callback(hObject, eventdata, handles)

function edit7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_segments (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function radiobutton7_Callback(hObject, eventdata, handles)

function radiobutton8_Callback(hObject, eventdata, handles)

function pushbutton15_Callback(hObject, eventdata, handles)

function radiobutton9_Callback(hObject, eventdata, handles)

function radiobutton10_Callback(hObject, eventdata, handles)

function edit8_Callback(hObject, eventdata, handles)

function edit8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_segments (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function list_verif_CreateFcn(hObject, eventdata, handles)
% hObject    handle to list_verif (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function popup_pivot_Callback(hObject, eventdata, handles)

function popup_pivot_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popup_pivot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function listbox7_Callback(hObject, eventdata, handles)

function listbox7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to list_verif (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Untitled_1_Callback(hObject, eventdata, handles)

function Untitled_2_Callback(hObject, eventdata, handles)


function menu_verifsegment_Callback(hObject, eventdata, handles)
    handles = verificate_segmentation(handles);
    guidata(hObject,handles);


function menu_images_Callback(hObject, eventdata, handles)
function Untitled_3_Callback(hObject, eventdata, handles)


% --------------------------------------------------------------------
function menu_reregBackground_Callback(hObject, eventdata, handles)
% hObject    handle to menu_reregBackground (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    if(~isfield(handles,'hfigselslice'))
        handles.hfigselslice = figure();
    end
    setuptable = handles.setuptable;
    slices = get(handles.list_slices,'String');
    slice = slices(get(handles.list_slices,'Value'));
    mice = get(handles.list_mice,'String');
    mouse = mice(get(handles.list_mice,'Value'));
    conditions = get(handles.list_cond,'String');
    cond = conditions(get(handles.list_cond,'Value'));
    imgid = find(strcmp(setuptable(:,1),cond) & strcmp(setuptable(:,2),mouse) & strcmp(setuptable(:,3),slice));
    if(isfield(setuptable{imgid,6},'pivot'))
        pivot = setuptable{imgid,6}.pivot;
        
        if(pivot == 0)
            topcox = handles.setuptable{imgid,6}.topcoxy(:,1);
            topcoy = handles.setuptable{imgid,6}.topcoxy(:,2);
            midtcox = handles.setuptable{imgid,6}.midcoxy(:,1);
            midtcoy = handles.setuptable{imgid,6}.midcoxy(:,2);
            midbcox = midtcox;
            midbcoy = midtcoy;
            botcox = handles.setuptable{imgid,6}.botcoxy(:,1);
            botcoy = handles.setuptable{imgid,6}.botcoxy(:,2);
        else
            topcox = handles.setuptable{imgid,6}.(['toppiv' num2str(pivot) 'coxy'])(:,1);
            topcoy = handles.setuptable{imgid,6}.(['toppiv' num2str(pivot) 'coxy'])(:,2);
            midtcox = handles.setuptable{imgid,6}.(['midtpiv' num2str(pivot) 'coxy'])(:,1);
            midtcoy = handles.setuptable{imgid,6}.(['midtpiv' num2str(pivot) 'coxy'])(:,2);
            midbcox = handles.setuptable{imgid,6}.(['midbpiv' num2str(pivot) 'coxy'])(:,1);
            midbcoy = handles.setuptable{imgid,6}.(['midbpiv' num2str(pivot) 'coxy'])(:,2);
            botcox = handles.setuptable{imgid,6}.(['botpiv' num2str(pivot) 'coxy'])(:,1);
            botcoy = handles.setuptable{imgid,6}.(['botpiv' num2str(pivot) 'coxy'])(:,2);
        end
        
        handles.hfigselslice = figure(handles.hfigselslice);
        img = imread([setuptable{imgid,4} setuptable{imgid,3}]);
        imshow(img);
        hold on;
        plot([topcox'; midtcox'],[topcoy'; midtcoy'],'b-');
        plot([midbcox'; botcox'],[midbcoy'; botcoy'],'c-');
        plot(setuptable{imgid,5}.topareaxy(:,1),setuptable{imgid,5}.topareaxy(:,2),'ro');
        plot(setuptable{imgid,5}.midareaxy(:,1),setuptable{imgid,5}.midareaxy(:,2),'ro');
        plot(setuptable{imgid,5}.botareaxy(:,1),setuptable{imgid,5}.botareaxy(:,2),'ro');
        hold off;
    else
        handles.hfigselslice = figure(handles.hfigselslice);
        img = imread([setuptable{imgid,4} setuptable{imgid,3}]);
        imshow(img);
        hold on;
        plot(setuptable{imgid,5}.topx(1:100:end),setuptable{imgid,5}.topy(1:100:end),'b-');
        plot(setuptable{imgid,5}.midx(1:100:end),setuptable{imgid,5}.midy(1:100:end),'b-');
        plot(setuptable{imgid,5}.botx(1:100:end),setuptable{imgid,5}.boty(1:100:end),'b-');
        plot(setuptable{imgid,5}.topareaxy(:,1),setuptable{imgid,5}.topareaxy(:,2),'ro');
        plot(setuptable{imgid,5}.midareaxy(:,1),setuptable{imgid,5}.midareaxy(:,2),'ro');
        plot(setuptable{imgid,5}.botareaxy(:,1),setuptable{imgid,5}.botareaxy(:,2),'ro');
        hold off;
    end
    hold on;
    title('Select 2 points to form a square to calculate the background');
    [bgx,bgy]=selectpoints(2);
    segmentmask = roipoly(img,[bgx(1) bgx(1) bgx(2) bgx(2)],[bgy(1) bgy(2) bgy(2) bgy(1)]);
    plot([bgx(1) bgx(1) bgx(2) bgx(2) bgx(1)],[bgy(1) bgy(2) bgy(2) bgy(1) bgy(1)],'m:');
    %calculate mean grayvalue of segment
    handles.setuptable{imgid,5}.meanbg = mean(mean(img(segmentmask)));
    handles.setuptable{imgid,5}.meanbgcoordinates = [bgx bgy];
    hold off;
    close(handles.hfigselslice);
    guidata(hObject,handles);


% --------------------------------------------------------------------
function menu_dontpivot_Callback(hObject, eventdata, handles)
if(strcmp(handles.dontpivot,'off'))
    handles.dontpivot = 'on';
else
    handles.dontpivot = 'off';
end
set(hObject,'Checked',handles.dontpivot);
guidata(hObject,handles);


function menu_regrefmap_Callback(hObject, eventdata, handles)
    [filename path] = uigetfile('Reference_maps/*.mat','Select the data file of the reference map');
    if(~isnumeric(filename))
        temp = load([path filename]);
        ref_names = temp.ref_names;
        ref_bregmas = temp.ref_bregmas;
        ref_map = temp.ref_map;
        ref_fixborder = temp.ref_fixborder;
        ref_mmtopixel = temp.ref_mmtopixel;
        if(size(ref_bregmas) ~= size(ref_map))
            ref_bregmas = repmat(ref_bregmas,1,size(ref_map,2));
        end
        
        mice = unique(handles.setuptable(:,2));
        [sel ok] = listdlg('PromptString','Choose a mouse to register the reference map to','ListString',mice,'SelectionMode','single');
        if(ok && sel~=0)
            hreffig = figure();
            mouse = mice(sel);
            slices = find(strcmp(handles.setuptable(:,2),mouse));
            
            %interpolate refmap to current bregma levels and convert to
            %pixel dimension
            tmp = char(handles.setuptable(slices,3));
            bregmas = str2num(tmp(:,end-6:end-4));
            ref_map_interp = interp1(ref_bregmas(:,1),ref_map.*ref_mmtopixel,bregmas);
            
            
            refmap_toprel = nan(size(ref_map_interp));
            refmap_botrel = nan(size(ref_map_interp));
            
            for i=1:size(slices,1)
                %open slice image
                imgid = slices(i);
                if(isfield(handles.setuptable{imgid,6},'pivot'))
                    pivot = handles.setuptable{imgid,6}.pivot;
                    
                    if(pivot == 0)
                        topcox = handles.setuptable{imgid,6}.topcoxy(:,1);
                        topcoy = handles.setuptable{imgid,6}.topcoxy(:,2);
                        midtcox = handles.setuptable{imgid,6}.midcoxy(:,1);
                        midtcoy = handles.setuptable{imgid,6}.midcoxy(:,2);
                        midbcox = midtcox;
                        midbcoy = midtcoy;
                        botcox = handles.setuptable{imgid,6}.botcoxy(:,1);
                        botcoy = handles.setuptable{imgid,6}.botcoxy(:,2);
                    else
                        topcox = handles.setuptable{imgid,6}.(['toppiv' num2str(pivot) 'coxy'])(:,1);
                        topcoy = handles.setuptable{imgid,6}.(['toppiv' num2str(pivot) 'coxy'])(:,2);
                        midtcox = handles.setuptable{imgid,6}.(['midtpiv' num2str(pivot) 'coxy'])(:,1);
                        midtcoy = handles.setuptable{imgid,6}.(['midtpiv' num2str(pivot) 'coxy'])(:,2);
                        midbcox = handles.setuptable{imgid,6}.(['midbpiv' num2str(pivot) 'coxy'])(:,1);
                        midbcoy = handles.setuptable{imgid,6}.(['midbpiv' num2str(pivot) 'coxy'])(:,2);
                        botcox = handles.setuptable{imgid,6}.(['botpiv' num2str(pivot) 'coxy'])(:,1);
                        botcoy = handles.setuptable{imgid,6}.(['botpiv' num2str(pivot) 'coxy'])(:,2);
                    end
                    topx = handles.setuptable{imgid,5}.topx;
                    topy = handles.setuptable{imgid,5}.topy;
                    botx = handles.setuptable{imgid,5}.botx;
                    boty = handles.setuptable{imgid,5}.boty;
                    
                    topcoxy = [topcox topcoy];
                    botcoxy = [botcox botcoy];
                    
                    figure(hreffig);
                    img = imread([handles.setuptable{imgid,4} handles.setuptable{imgid,3}]);
                    imshow(img);
                    set(hreffig,'Name',handles.setuptable{imgid,3});
                    hold on;
                    plot([topcox'; midtcox'],[topcoy'; midtcoy'],'b-');
                    plot([midbcox'; botcox'],[midbcoy'; botcoy'],'c-');
                    plot(handles.setuptable{imgid,5}.topareaxy(:,1),handles.setuptable{imgid,5}.topareaxy(:,2),'ro');
                    plot(handles.setuptable{imgid,5}.midareaxy(:,1),handles.setuptable{imgid,5}.midareaxy(:,2),'ro');
                    plot(handles.setuptable{imgid,5}.botareaxy(:,1),handles.setuptable{imgid,5}.botareaxy(:,2),'ro');
                    plot(topx,topy,'r-');
                    plot(botx,boty,'r-');
                    hold off;
                end
                %assign corresponding bregma level
                tmp = regexp(handles.setuptable{slices(i),3},'_\d{3}','match','once');
                bregma = str2num(tmp(2:end));
                
                %register refmap
                hborders = register_refmap(ref_map_interp(bregmas == bregma,:),ref_fixborder(bregmas == bregma,:),ref_names);
                %find intersection with top border
                refmap_top = zeros(size(hborders,1),2);
                refmap_bot = zeros(size(hborders,1),2);
                for j=1:size(hborders,1)
                    xdata = get(hborders(j),'XData');
                    ydata = get(hborders(j),'YData');
                    if(~isempty(xdata))
                        [refmap_top(j,1) refmap_top(j,2)] = intersection2curves(topx,topy,xdata,ydata);
                        [refmap_bot(j,1) refmap_bot(j,2)] = intersection2curves(botx,boty,xdata,ydata);
                    else
                        [refmap_top(j,:)] = [NaN NaN];
                        [refmap_bot(j,:)] = [NaN NaN];
                    end
                    hold on;
                    plot([refmap_top(j,1);refmap_bot(j,1)],[refmap_top(j,2);refmap_bot(j,2)],'gd:');                    
                    hold off;
                end
                refmap_toprel(i,:) = relativearealborders(topx,topy,refmap_top(:,1),refmap_top(:,2),topcoxy,handles.rastersegments,handles.setuptable{imgid,3});
                refmap_botrel(i,:) = relativearealborders(botx,boty,refmap_bot(:,1),refmap_bot(:,2),botcoxy,handles.rastersegments,handles.setuptable{imgid,3});
                refmap_bregma(i) = bregma;
            end
            handles.refmap_toprel = refmap_toprel;
            handles.refmap_botrel = refmap_botrel;
            save([path filename],'ref_names','ref_bregmas','ref_map','refmap_toprel','refmap_botrel','refmap_bregma');
            fprintf('Reference map %s registered to mouse %s',filename,mouse);
        end
    end
    
function menu_regmidline_Callback(hObject, eventdata, handles)
    hreffig = figure();    
       
    for i=1:size(handles.setuptable,1)
        %open slice image
        if(~isfield(handles.setuptable{i,5},'midlinep'))
            if(isfield(handles.setuptable{i,6},'pivot'))
            
                pivot = handles.setuptable{i,6}.pivot;
                
                if(pivot == 0)
                    topcox = handles.setuptable{i,6}.topcoxy(:,1);
                    topcoy = handles.setuptable{i,6}.topcoxy(:,2);
                    midtcox = handles.setuptable{i,6}.midcoxy(:,1);
                    midtcoy = handles.setuptable{i,6}.midcoxy(:,2);
                    midbcox = midtcox;
                    midbcoy = midtcoy;
                    botcox = handles.setuptable{i,6}.botcoxy(:,1);
                    botcoy = handles.setuptable{i,6}.botcoxy(:,2);
                else
                    topcox = handles.setuptable{i,6}.(['toppiv' num2str(pivot) 'coxy'])(:,1);
                    topcoy = handles.setuptable{i,6}.(['toppiv' num2str(pivot) 'coxy'])(:,2);
                    midtcox = handles.setuptable{i,6}.(['midtpiv' num2str(pivot) 'coxy'])(:,1);
                    midtcoy = handles.setuptable{i,6}.(['midtpiv' num2str(pivot) 'coxy'])(:,2);
                    midbcox = handles.setuptable{i,6}.(['midbpiv' num2str(pivot) 'coxy'])(:,1);
                    midbcoy = handles.setuptable{i,6}.(['midbpiv' num2str(pivot) 'coxy'])(:,2);
                    botcox = handles.setuptable{i,6}.(['botpiv' num2str(pivot) 'coxy'])(:,1);
                    botcoy = handles.setuptable{i,6}.(['botpiv' num2str(pivot) 'coxy'])(:,2);
                end
                topx = handles.setuptable{i,5}.topx;
                topy = handles.setuptable{i,5}.topy;
                botx = handles.setuptable{i,5}.botx;
                boty = handles.setuptable{i,5}.boty;
                
                topcoxy = [topcox topcoy];
                botcoxy = [botcox botcoy];
                
                figure(hreffig);
                clf;
                img = imread([handles.setuptable{i,4} handles.setuptable{i,3}]);
                imshow(img);
                set(hreffig,'Name',handles.setuptable{i,3});
                
                if(isfield(handles.setuptable{i,5},'midlinep'))
                    midlinep = handles.setuptable{i,5}.midlinep;
                    midlinept = handles.setuptable{i,5}.midlinept;
                    xlim = get(gca,'Xlim');
                    ylim = get(gca,'Ylim');
                    midlinex = xlim(1):0.1:xlim(2);
                    midliney = polyval(midlinep,midlinex);
                    window = midliney > ylim(1) & midliney < ylim(2);
                    midlinex = midlinex(window);
                    midliney = midliney(window);
                else
                    midlinep = [];
                    midlinept = [NaN NaN; NaN NaN];
                    midlinex = NaN;
                    midliney = NaN;
                end
                
                hold on;
                plot([topcox'; midtcox'],[topcoy'; midtcoy'],'b-');
                plot([midbcox'; botcox'],[midbcoy'; botcoy'],'c-');
                plot(handles.setuptable{i,5}.topareaxy(:,1),handles.setuptable{i,5}.topareaxy(:,2),'ro');
                plot(handles.setuptable{i,5}.midareaxy(:,1),handles.setuptable{i,5}.midareaxy(:,2),'ro');
                plot(handles.setuptable{i,5}.botareaxy(:,1),handles.setuptable{i,5}.botareaxy(:,2),'ro');
                plot(topx,topy,'r-');
                plot(botx,boty,'r-');
                hmidline = plot(midlinex,midliney,'g-');
                hmidlinept1 = plot(midlinept(1,1),midlinept(1,2),'gd');
                hmidlinept2 = plot(midlinept(2,1),midlinept(2,2),'gd');
                hold off;
            
            
                %register midline
                [midlinep midlinept] = register_midline(hmidline,hmidlinept1,hmidlinept2);
                handles.setuptable{i,5}.midlinep = midlinep;
                handles.setuptable{i,6}.topcoxyprojected = projectToTopview(handles.setuptable{i,6}.topcoxy,handles.setuptable{i,5}.midlinep);
                handles.setuptable{i,6}.botcoxyprojected = projectToTopview(handles.setuptable{i,6}.botcoxy,handles.setuptable{i,5}.midlinep);
                handles.setuptable{i,5}.topareaxyprojected = projectToTopview(handles.setuptable{i,5}.topareaxy,handles.setuptable{i,5}.midlinep);
                handles.setuptable{i,5}.botareaxyprojected = projectToTopview(handles.setuptable{i,5}.botareaxy,handles.setuptable{i,5}.midlinep);
                handles.setuptable{i,5}.midlinept = midlinept;
                
            end
        end
    end
    close(hreffig);
    handles = save_Callback(hObject, eventdata, handles);
    guidata(hObject,handles);

function menu_topview_mouse_top_Callback(hObject, eventdata, handles)
    handles = ISHtopview(handles,'top');
    guidata(hObject,handles);


% --------------------------------------------------------------------
function Untitled_4_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_topviewGUI_Callback(hObject, eventdata, handles)
% hObject    handle to menu_topviewGUI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    handles.setuptable = managerslices(handles.setuptable,handles.savename);
    guidata(hObject,handles);
    
    


% --------------------------------------------------------------------
function menu_validatesegmentation_Callback(hObject, eventdata, handles)
% hObject    handle to menu_validatesegmentation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    segmented = cellfun(@(x) isfield(x,'topcoxy'),handles.setuptable(:,6));
    fprintf('No of segmented slices: %d/%d\n',sum(segmented), size(handles.setuptable,1));
    idx = hasIntersectingSegments(handles.setuptable(segmented,:));
    if(isempty(idx))
        fprintf('All slices are correctly segmented.\n');
    else
        fprintf('%d/%d slices are not correctly segmented:\n',numel(idx),sum(segmented));
        for i=1:length(idx)
            fprintf('%s - %s - %s\n',handles.setuptable{idx(i),1},handles.setuptable{idx(i),2},handles.setuptable{idx(i),3});
        end
    end
    fprintf('\n');
    
function escapekeypress(object, event)
    if(strcmp(event.Key,'escape'))
        close(gcf);
    elseif(strcmp(event.Key,'return'))
        uiresume();
    end


% --------------------------------------------------------------------
function menu_projectinformation_Callback(hObject, eventdata, handles)
% hObject    handle to menu_projectinformation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    getProjectInfo(handles.setuptable);


% --------------------------------------------------------------------
function menu_alignbregmas_Callback(hObject, eventdata, handles)
% hObject    handle to menu_alignbregmas (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    handles.setuptable = alignbregmas(handles.setuptable);
    fprintf('Bregmas aligned\n');
    guidata(hObject,handles);


% --------------------------------------------------------------------
function menu_resetbregma_Callback(hObject, eventdata, handles)
% hObject    handle to menu_resetbregma (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    setuptable = handles.setuptable;
    bregma = arrayfun(@(y) str2mat(y{:}(2:end)),arrayfun(@(x) regexp(x{:}(end-8:end),'[_-]\d{3}','match','once'),setuptable(:,3),'UniformOutput',false),'UniformOutput',false);
    for i=1:size(setuptable,1)
        setuptable{i,5}.bregma = str2num(bregma{i});
    end
    handles.setuptable = setuptable;
    guidata(hObject,handles);