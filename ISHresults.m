%-x-x-x- INITIATION GUI -x-x-x-%
function varargout = ISHresults(varargin)
% ISHRESULTS M-file for ISHresults.fig
%      ISHRESULTS, by itself, creates a new ISHRESULTS or raises the existing
%      singleton*.
%
%      H = ISHRESULTS returns the handle to a new ISHRESULTS or the handle to
%      the existing singleton*.
%
%      ISHRESULTS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ISHRESULTS.M with the given input arguments.
%
%      ISHRESULTS('Property','Value',...) creates a new ISHRESULTS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ISHresults_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ISHresults_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ISHresults

% Last Modified by GUIDE v2.5 23-Apr-2014 15:13:15

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ISHresults_OpeningFcn, ...
                   'gui_OutputFcn',  @ISHresults_OutputFcn, ...
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

function ISHresults_OpeningFcn(hObject, eventdata, handles, varargin)

handles.output = hObject;
graphtypes = get(handles.pop_graphtype,'String');
handles.graphtype = graphtypes(get(handles.pop_graphtype,'Value'));

set(handles.uitable_legend_intra,'Data',{'Significant greater than','','';'<html><div align="center"><font bgcolor=yellow>&lt;0,05</font></html>', '<html><font bgcolor=#FF9900>&lt;0,01</font></html>', '<html><font bgcolor=red>&lt;0,001</font></div></html>';'Significant smaller than','','';'<html><div align="center"><font bgcolor=#00FFFF>&lt;0,05</font></html>', '<html><font bgcolor=#0099FF>&lt;0,01</font></html>', '<html><font bgcolor=blue>&lt;0,001</font></div></html>'},'ColumnWidth',{70});
set(handles.uitable_legend_inter,'Data',{'Significant greater than','','';'<html><div align="center"><font bgcolor=yellow>&lt;0,05</font></html>', '<html><font bgcolor=#FF9900>&lt;0,01</font></html>', '<html><font bgcolor=red>&lt;0,001</font></div></html>';'Significant smaller than','','';'<html><div align="center"><font bgcolor=#00FFFF>&lt;0,05</font></html>', '<html><font bgcolor=#0099FF>&lt;0,01</font></html>', '<html><font bgcolor=blue>&lt;0,001</font></div></html>'},'ColumnWidth',{70});

handles.ymin = 0;
handles.ymax = 100;
handles.ste = false;
handles.ticks = false;
handles.median = false;
handles.ste = false;
handles.meanmouse = 'on';
handles.limitviewsupra = NaN;
handles.limitviewinfra = NaN;
handles.highlightsupra = NaN;
handles.highlightinfra = NaN;
handles.bw = 'off';
handles.removeouterarealborders = 'off';
handles.highlightgrayband = 'off';

if ~strcmp(varargin,'')
    temp = load(char(varargin{1}),'projectresults');
    handles.projectresults = temp.projectresults;
    
    filename = char(regexp(char(varargin{1}),'/.*_results.mat','match'));
    set(handles.fig_ISH_results,'Name',['Results ISH Analysis - ' filename(2:end-11)]);
    handles.savename = filename(1:end-4);
    fprintf('Results from project %s loaded\n',char(filename(2:end-11)));
    
    handles = load_results(handles);
    
end
guidata(hObject, handles);

function varargout = ISHresults_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;


%-x-x-x- WORKFLOW ROUTINES -x-x-x-%
function handles = chooseGraph(handles)
    mice = get(handles.pop_graph,'String');
    valind = get(handles.pop_graph,'Value');
    value = mice{valind};
    if(valind > find(ismember(mice, '-----Mice-----')==1) && valind < find(ismember(mice, '--Conditions--')==1))
        handles = draw_axes_mouse(handles,value);
    elseif(valind > find(ismember(mice, '--Conditions--')==1) && valind < find(ismember(mice, '---Intercond---')==1))
        handles = draw_axes_condition(handles,value);
    elseif(valind > find(ismember(mice, '---Intercond---')==1))
        handles = draw_axes_intercond(handles,value);
    end

function handles = load_results(handles)
    projectresults = handles.projectresults;
    %load popup lists
    if(size(fieldnames(projectresults.mice),1) > 0)
        graph = ['-----Mice-----'; fieldnames(projectresults.mice)];
    end
    if(size(fieldnames(projectresults.conditions),1)>0)
        graph = [graph; '--Conditions--'; fieldnames(projectresults.conditions)];
    else
        graph = [graph; '--No conditions present in setup--'];
    end
    if(length(projectresults.interconditions))
        if(size(fieldnames(projectresults.interconditions),1)>0)
            conditions = fieldnames(projectresults.conditions);
            graph = [graph; '---Intercond---'; fieldnames(projectresults.interconditions)];
            if(size(conditions,1) > 2)
                graph = [graph; [sprintf('%s_vs_',conditions{1:end-1}),conditions{end}]];
            end
        else
            graph = [graph; '---Intercond---';'--Only 1 condition present in setup--'];
        end
    end
    set(handles.pop_graph,'String',graph);
    set(handles.pop_graph,'Value',2);
    regions = fieldnames(projectresults.regions);
    for i=1:size(regions,1)
        graphregions{i} = sprintf('Bar graph for %s',regions{i});
    end
    set(handles.pop_graphtype,'String',['Line graph per segment';'Bar graph per segment';graphregions';'Histogram']);
    
    %draw mouse axes
    handles = draw_axes_mouse(handles,graph{2});
    
    %load intracondition tests
    conditions = fieldnames(projectresults.conditions);
    set(handles.pop_cond,'String',conditions);
    set(handles.pop_cond,'Value',1);
    set(handles.popup_intracond_region,'String',['Segments';regions]);
    draw_table_intracondition(handles,conditions{1});
    
    
    %load interconditions tests
    set(handles.popup_intercond_region,'String',['Segments';regions]);
    draw_table_intercondition(handles);

function res_out = colorizecells(result,difference)
     res_out = repmat('',size(result,1),size(result,2));   
     for i=1:size(result,1)
        for j=1:size(result,2)
            if(strcmp(result{i,j},''))
                res_out{i,j} = sprintf('<html><font bgcolor=#FFFFFF>-</font></html>');
            elseif(strcmp(result{i,j},'#'))
                res_out{i,j} = sprintf('<html><font bgcolor=#999999>-</font></html>');
            elseif(strcmp(result{i,j},'***'))
                if(difference(i,j) > 0)
                    res_out{i,j} = sprintf('<html><font bgcolor=red>%s</font></html>',result{i,j});
                else
                    res_out{i,j} = sprintf('<html><font bgcolor=blue>%s</font></html>',result{i,j});
                end
            elseif(strcmp(result{i,j},'**'))
                if(difference(i,j) > 0)
                    res_out{i,j} = sprintf('<html><font bgcolor=#FF9900>%s</font></html>',result{i,j});
                else
                    res_out{i,j} = sprintf('<html><font bgcolor=#0099FF>%s</font></html>',result{i,j});
                end
            elseif(strcmp(result{i,j},'*'))
                if(difference(i,j) > 0)
                    res_out{i,j} = sprintf('<html><font bgcolor=yellow>%s</font></html>',result{i,j});
                else
                    res_out{i,j} = sprintf('<html><font bgcolor=#00FFFF>%s</font></html>',result{i,j});
                end
            else
                res_out{i,j} = sprintf('<html><font bgcolor=#FFFFFF>%s</font></html>',result{i,j});
            end
        end
     end
     
     
    
function handles = draw_axes_mouse(handles,mouse)
     projectresults = handles.projectresults;
     xval = 1:projectresults.segments;
     hbar = 0;
     graphtypestr = get(handles.pop_graphtype,'String');
     handles.graphtype = graphtypestr(get(handles.pop_graphtype,'Value'));
     colors = get(gca,'ColorOrder');
     if(~isnan(handles.limitviewsupra))
        limitviewsupra = handles.limitviewsupra(1):handles.limitviewsupra(2);
     else
        limitviewsupra = xval;
     end
     if(~isnan(handles.limitviewinfra))
        limitviewinfra = handles.limitviewinfra(1):handles.limitviewinfra(2);
     else
        limitviewinfra = xval;
     end
     
     
     switch char(handles.graphtype)
         case 'Line graph per segment'
             %plot supra
             axes(handles.axes_mouse_supra);
             cla;
             hold on;
             hplot = zeros(size(projectresults.mice.(mouse).slicesxsegments_supra,1),1);
             for i=1:size(projectresults.mice.(mouse).slicesxsegments_supra,1)
                 hplot(i) = plot(xval(limitviewsupra),projectresults.mice.(mouse).slicesxsegments_supra(i,limitviewsupra),'Tag',sprintf('%s_%d',mouse,i),'DisplayName',num2str(i),'Color',colors(mod(i-1,size(colors,1)-1)+1,:));
             end
             if(size(projectresults.mice.(mouse).slicesxsegments_supra,1)>1)
                 if(handles.ste)
                     hbar = errorbar(xval,mean(projectresults.mice.(mouse).slicesxsegments_supra(:,limitviewsupra)),std(projectresults.mice.(mouse).slicesxsegments_supra(:,limitviewsupra))./size(projectresults.mice.(mouse).slicesxsegments_supra,2),'k-','LineWidth',2,'Tag',mouse,'DisplayName',mouse);
                 else
                     hbar = errorbar(xval,mean(projectresults.mice.(mouse).slicesxsegments_supra(:,limitviewsupra)),std(projectresults.mice.(mouse).slicesxsegments_supra(:,limitviewsupra)),'k-','LineWidth',2,'Tag',mouse,'DisplayName',mouse);
                 end
                 plot(mean(projectresults.mice.(mouse).toparearel),repmat(100,1,size(projectresults.mice.(mouse).toparearel,2)),'rv','Tag','Arealborders');
             else
                 plot(projectresults.mice.(mouse).toparearel,repmat(max(ylim(handles.axes_mouse_supra)),1,size(projectresults.mice.(mouse).toparearel,2)),'rv','Tag','Arealborders');
             end
             ylim([handles.ymin handles.ymax]);
             if(~isnan(handles.limitviewsupra))
                 xlim(handles.limitviewsupra + [-1 1]);
             else
                 xlim([0 projectresults.segments+1]);
             end
             set(gca,'XTick',limitviewsupra);
             set(gca,'XTickLabelMode','auto');
             ylabel('Relative Optical Density');
             hold off;
             %legend
             handles.legend = [mouse; cellstr(num2str((1:size(projectresults.mice.(mouse).slicesxsegments_supra,1))'))];
%              set(hbar,'DisplayName',mouse);
             
             if(hbar > 0)
                 handles.legend_supra = legend([hbar,hplot'],'Location','Best');
             else
                 handles.legend_supra = legend(hplot','Location','Best');
             end
             
             %plot infra
             axes(handles.axes_mouse_infra);
             cla;
             hold on;
             hplot = zeros(size(projectresults.mice.(mouse).slicesxsegments_infra,1),1);
             for i=1:size(projectresults.mice.(mouse).slicesxsegments_infra,1)
                hplot(i) = plot(xval,projectresults.mice.(mouse).slicesxsegments_infra(i,:),'Tag',sprintf('%s_%d',mouse,i),'DisplayName',num2str(i),'Color',colors(mod(i-1,size(colors,1)-1)+1,:));
             end
             if(size(projectresults.mice.(mouse).slicesxsegments_infra,1)>1)
                 if(handles.ste)
                     hbar = errorbar(xval,mean(projectresults.mice.(mouse).slicesxsegments_infra(:,limitviewinfra)),std(projectresults.mice.(mouse).slicesxsegments_infra(:,limitviewinfra))./size(projectresults.mice.(mouse).slicesxsegments_infra,2),'k-','LineWidth',2,'Tag',mouse,'DisplayName',mouse);
                 else
                     hbar = errorbar(xval,mean(projectresults.mice.(mouse).slicesxsegments_infra(:,limitviewinfra)),std(projectresults.mice.(mouse).slicesxsegments_infra(:,limitviewinfra)),'k-','LineWidth',2,'Tag',mouse,'DisplayName',mouse);
                 end
                 plot(mean(projectresults.mice.(mouse).botarearel),repmat(max(ylim(handles.axes_mouse_infra)),1,size(projectresults.mice.(mouse).botarearel,2)),'rv','Tag','Arealborders');
             else
                 plot(projectresults.mice.(mouse).botarearel,repmat(max(ylim(handles.axes_mouse_infra)),1,size(projectresults.mice.(mouse).botarearel,2)),'rv','Tag','Arealborders');
             end
             ylim([handles.ymin handles.ymax]);
             if(~isnan(handles.limitviewinfra))
                 xlim(handles.limitviewinfra + [-1 1]);
                 set(gca,'XTick',limitviewinfra);
             else
                 xlim([0 projectresults.segments+1]);
                 set(gca,'XTick',1:projectresults.segments);
             end
             
             set(gca,'XTickLabelMode','auto');
             ylabel('Relative Optical Density');
             hold off;
             %legend
             if(hbar > 0)
                 handles.legend_infra = legend([hbar,hplot'],'Location','Best');
             else
                 handles.legend_infra = legend(hplot','Location','Best');
             end
             
         case 'Bar graph per segment'
             markertype = {'o','s','d','p','h','*'};
             %plot supra
             axes(handles.axes_mouse_supra);
             cla;
             hold on;
             hbar = bar(xval,projectresults.mice.(mouse).slicesxsegments_supra_mean,'FaceColor',[0.6,0.6,0.6],'Tag',mouse,'DisplayName',mouse);
             hplot = zeros(1,size(projectresults.mice.(mouse).slicesxsegments_supra,1));
             for i=1:size(projectresults.mice.(mouse).slicesxsegments_supra,1)
                hplot(i) = plot(xval,projectresults.mice.(mouse).slicesxsegments_supra(i,:),[markertype{i} 'k'],'LineStyle','none','Tag',sprintf('%s_%d',mouse,i),'DisplayName',num2str(i));
             end
             if(handles.ste)
                 errorbar(xval,projectresults.mice.(mouse).slicesxsegments_supra_mean,projectresults.mice.(mouse).slicesxsegments_supra_sterr,'Linestyle','none','Color',[0.3,0.3,0.3]);
             else
                 errorbar(xval,projectresults.mice.(mouse).slicesxsegments_supra_mean,projectresults.mice.(mouse).slicesxsegments_supra_std,'Linestyle','none','Color',[0.3,0.3,0.3]);
             end
             plot(mean(projectresults.mice.(mouse).toparearel),repmat(max(ylim(handles.axes_mouse_supra)),1,size(projectresults.mice.(mouse).toparearel,2)),'rv','Tag','Arealborders');
             if(~isnan(handles.limitviewsupra))
                 xlim(handles.limitviewsupra + [-1 1]);
             else
                 xlim([0 projectresults.segments+1]);
             end
             set(gca,'XTick',1:projectresults.segments);
             set(gca,'XTickLabelMode','auto');
             ylabel('Relative Optical Density');
             hold off;
             %legend
             handles.legend = [mouse; cellstr(num2str((1:size(projectresults.mice.(mouse).slicesxsegments_supra,1))'))];
             handles.legend_supra = legend([hbar,hplot],'Location','Best');
             
             %plot infra
             axes(handles.axes_mouse_infra);
             cla;
             hold on;
             hbar = bar(xval,projectresults.mice.(mouse).slicesxsegments_infra_mean,'FaceColor',[0.6,0.6,0.6],'Tag',mouse,'DisplayName',mouse);
             hplot = zeros(1,size(projectresults.mice.(mouse).slicesxsegments_infra,1));
             for i=1:size(projectresults.mice.(mouse).slicesxsegments_infra,1)
                hplot(i) = plot(xval,projectresults.mice.(mouse).slicesxsegments_infra(i,:),[markertype{i} 'k'],'LineStyle','none','Tag',sprintf('%s_%d',mouse,i),'DisplayName',num2str(i));
             end
             if(handles.ste)
                 errorbar(xval,projectresults.mice.(mouse).slicesxsegments_infra_mean,projectresults.mice.(mouse).slicesxsegments_infra_sterr,'Linestyle','none','Color',[0.3,0.3,0.3]);
             else
                errorbar(xval,projectresults.mice.(mouse).slicesxsegments_infra_mean,projectresults.mice.(mouse).slicesxsegments_infra_std,'Linestyle','none','Color',[0.3,0.3,0.3]);
             end
             plot(mean(projectresults.mice.(mouse).botarearel),repmat(max(ylim(handles.axes_mouse_infra)),1,size(projectresults.mice.(mouse).botarearel,2)),'rv','Tag','Arealborders');
             if(~isnan(handles.limitviewinfra))
                 xlim(handles.limitviewinfra + [-1 1]);
             else
                 xlim([0 projectresults.segments+1]);
             end
             set(gca,'XTick',1:projectresults.segments);
             set(gca,'XTickLabelMode','auto');
             ylabel('Relative Optical Density');
             hold off;
             
             %legend
             handles.legend = [mouse; cellstr(num2str((1:size(projectresults.mice.(mouse).slicesxsegments_supra,1))'))];
             handles.legend_infra = legend([hbar,hplot],'Location','Best');
             
         case 'Histogram'
             axes(handles.axes_mouse_supra);
             cla;
             bar(1:size(projectresults.mice.(mouse).slicesxsegments_supra,2),sum(~isnan(projectresults.mice.(mouse).slicesxsegments_supra),1));
             ylim([0 max(sum(~isnan(projectresults.mice.(mouse).slicesxsegments_supra),1))+1]);
             axes(handles.axes_mouse_infra);
             cla;
             bar(1:size(projectresults.mice.(mouse).slicesxsegments_infra,2),sum(~isnan(projectresults.mice.(mouse).slicesxsegments_infra),1));
             ylim([0 max(sum(~isnan(projectresults.mice.(mouse).slicesxsegments_infra),1))+1]);
             
         otherwise
             regionsstr = regexp(handles.graphtype{:},' ','split');
             regions = regionsstr{4};
             %markertype = {'o','s','d','p','h','*'};
             %build data table
             region_data = projectresults.mice.(mouse).regions.(regions);
             regnames = fieldnames(region_data);
             region_supra_mean = zeros(1,size(regnames,1));
             region_infra_mean = zeros(1,size(regnames,1));
             region_supra_ste = zeros(1,size(regnames,1));
             region_infra_ste = zeros(1,size(regnames,1));
             region_supra_std = zeros(1,size(regnames,1));
             region_infra_std = zeros(1,size(regnames,1));
             region_supra_cnt = zeros(1,size(regnames,1));
             region_infra_cnt = zeros(1,size(regnames,1));
             for i=1:size(regnames,1)
                 region_supra_mean(i) = mean(region_data.(regnames{i}).segments_supra);
                 region_infra_mean(i) = mean(region_data.(regnames{i}).segments_infra);
                 region_supra_ste(i) = std(region_data.(regnames{i}).segments_supra)/size(region_data.(regnames{i}).segments_supra,1);
                 region_infra_ste(i) = std(region_data.(regnames{i}).segments_infra)/size(region_data.(regnames{i}).segments_infra,1);
                 region_supra_std(i) = std(region_data.(regnames{i}).segments_supra);
                 region_infra_std(i) = std(region_data.(regnames{i}).segments_infra);
                 region_supra_cnt(i) = size(region_data.(regnames{i}).segments_supra,1);
                 region_infra_cnt(i) = size(region_data.(regnames{i}).segments_infra,1);
             end
             
             %plot supra
             axes(handles.axes_mouse_supra);
             areas = regexp(projectresults.areas,',','split');
             cla;
             if(handles.ste)
                 hbar = barweb(region_supra_mean', region_supra_ste', 0.6, regnames, [], [], 'Relative Optical Density', [0.6,0.6,0.6], [], mouse);
             else
                 hbar = barweb(region_supra_mean', region_supra_std', 0.6, regnames, [], [], 'Relative Optical Density', [0.6,0.6,0.6], [], mouse);
             end
             hold on;
%              hplot = zeros(1,sum(region_supra_cnt));
%              for i=1:size(regnames,1)
%                  hplot(i) = plot(j,mean(projectresults.mice.(mouse).slicesxsegments_supra(i,1:projectresults.segments >= arealborder(j) & 1:projectresults.segments <= arealborder(j+1))),[markertype{i} 'k'],'LineStyle','none','Tag',num2str(i),'DisplayName',num2str(i));
%              end
             %errorbar(1:size(findstr(',',projectresults.areas),2)+1,valueperarea,sterrperarea,'Linestyle','none','Color',[0.3,0.3,0.3]);
             
             xlim([0 size(regnames,1)+1]);
             ylabel('Relative Optical Density');
             hold off;
             %legend
             handles.legend_supra = legend([hbar.bars],'Location','Best');
             
             %plot infra
             axes(handles.axes_mouse_infra);
             cla;
             if(handles.ste)
                hbar = barweb(region_infra_mean', region_infra_ste', 0.6, regnames, [], [], 'Relative Optical Density', [0.6,0.6,0.6], [], mouse);
             else
                 hbar = barweb(region_infra_mean', region_infra_std', 0.6, regnames, [], [], 'Relative Optical Density', [0.6,0.6,0.6], [], mouse);
             end
             hold on;
%              hplot = zeros(1,size(projectresults.mice.(mouse).slicesxsegments_infra,1));
%              for i=1:size(projectresults.mice.(mouse).slicesxsegments_infra,1)
%                  for j=1:size(findstr(',',projectresults.areas),2)+1
%                      hplot(i) = plot(j,mean(projectresults.mice.(mouse).slicesxsegments_infra(i,1:projectresults.segments >= arealborder(j) & 1:projectresults.segments <= arealborder(j+1))),[markertype{i} 'k'],'LineStyle','none','Tag',num2str(i),'DisplayName',num2str(i));
%                  end
%              end
%              %errorbar(1:size(findstr(',',projectresults.areas),2)+1,valueperarea,sterrperarea,'Linestyle','none','Color',[0.3,0.3,0.3]);
             
             xlim([0 size(regnames,1)+1]);
             ylabel('Relative Optical Density');
             hold off;
             
             %legend
             handles.legend_infra = legend([hbar.bars],'Location','Best');
             
     end
     
function handles = draw_axes_condition(handles,cond)
     projectresults = handles.projectresults;
     xval = 1:projectresults.segments;
     mice = projectresults.conditions.(cond).mice;
     hbar = 0;
     colors = get(gca,'ColorOrder');
     if(~isnan(handles.limitviewsupra))
        limitviewsupra = handles.limitviewsupra(1):handles.limitviewsupra(2);
     else
        limitviewsupra = xval;
     end
     if(~isnan(handles.limitviewinfra))
        limitviewinfra = handles.limitviewinfra(1):handles.limitviewinfra(2);
     else
        limitviewinfra = xval;
     end
      
     switch char(handles.graphtype)
         case 'Line graph per segment'
             %plot supra
             axes(handles.axes_mouse_supra);
             cla;
             hold on;
             values = zeros(size(mice,1),size(projectresults.mice.(mice{1}).slicesxsegments_supra_mean(limitviewsupra),2));
             hplot = zeros(size(values,1),1);
             for i=1:size(mice,1)
                 values(i,:) = projectresults.mice.(mice{i}).slicesxsegments_supra_mean(limitviewsupra);
                 hplot(i) = plot(xval(limitviewsupra),values(i,:),'Tag',sprintf('%s_%s',cond,mice{i}),'DisplayName',mice{i},'Color',colors(mod(i-1,size(colors,1)-1)+1,:));
             end
                          
             if(size(values,1)>1)
                 if(handles.ste)
                     if(strcmp(handles.meanmouse,'on'))
                        hbar = errorbar(xval(limitviewsupra),projectresults.conditions.(cond).slicesxsegments_supra_mousemean_mean(limitviewsupra),projectresults.conditions.(cond).slicesxsegments_supra_mousemean_sterr(limitviewsupra),'k-','LineWidth',2,'Tag',cond,'DisplayName',cond);
                     else
                        hbar = errorbar(xval(limitviewsupra),projectresults.conditions.(cond).slicesxsegments_supra_mean(limitviewsupra),projectresults.conditions.(cond).slicesxsegments_supra_sterr(limitviewsupra),'k-','LineWidth',2,'Tag',cond,'DisplayName',cond);
                     end
                 else
                     if(strcmp(handles.meanmouse,'on'))
                        hbar = errorbar(xval(limitviewsupra),projectresults.conditions.(cond).slicesxsegments_supra_mousemean_mean(limitviewsupra),projectresults.conditions.(cond).slicesxsegments_supra_mousemean_std(limitviewsupra),'k-','LineWidth',2,'Tag',cond,'DisplayName',cond);
                     else
                        hbar = errorbar(xval(limitviewsupra),projectresults.conditions.(cond).slicesxsegments_supra_mean(limitviewsupra),projectresults.conditions.(cond).slicesxsegments_supra_std(limitviewsupra),'k-','LineWidth',2,'Tag',cond,'DisplayName',cond);
                     end
                 end
             end
             arearel = mean(projectresults.conditions.(cond).toparearel);
             if(~isnan(handles.limitviewsupra))
                 arearel = arearel(arearel > handles.limitviewsupra(1) - 1 & arearel < handles.limitviewsupra(2) + 1);
             end
             plot(arearel,repmat(max(ylim(handles.axes_mouse_supra)),1,size(arearel,2)),'rv','Tag','Arealborders');
             if(~isnan(handles.limitviewsupra))
                 xlim(handles.limitviewsupra + [-1 1]);
                 set(gca,'XTick',limitviewsupra);
             else
                 xlim([0 projectresults.segments+1]);
                 set(gca,'XTick',1:projectresults.segments);
             end
             
             set(gca,'XTickLabelMode','auto');
             ylabel('Relative Optical Density');
             hold off;
             %legend
             if(hbar > 0)
                 handles.legend_supra = legend([hbar,hplot'],'Location','Best');
             else
                 handles.legend_supra = legend(hplot','Location','Best');
             end
             
             %plot infra
             axes(handles.axes_mouse_infra);
             cla;
             hold on;
             values = zeros(size(mice,1),size(projectresults.mice.(mice{1}).slicesxsegments_infra_mean(limitviewinfra),2));
             hplot = zeros(size(values,1),1);
             for i=1:size(mice,1)
                 values(i,:) = projectresults.mice.(mice{i}).slicesxsegments_infra_mean(limitviewinfra);
                 hplot(i) = plot(xval(limitviewinfra),values(i,:),'Tag',sprintf('%s_%s',cond,mice{i}),'DisplayName',mice{i},'Color',colors(mod(i-1,size(colors,1)-1)+1,:));
             end
             if(size(values,1)>1)
                 if(handles.ste)
                     if(strcmp(handles.meanmouse,'on'))
                        hbar = errorbar(xval(limitviewinfra),projectresults.conditions.(cond).slicesxsegments_infra_mousemean_mean(limitviewinfra),projectresults.conditions.(cond).slicesxsegments_infra_mousemean_sterr(limitviewinfra),'k-','LineWidth',2,'Tag',cond,'DisplayName',cond);
                     else
                        hbar = errorbar(xval(limitviewinfra),projectresults.conditions.(cond).slicesxsegments_infra_mean(limitviewinfra),projectresults.conditions.(cond).slicesxsegments_infra_sterr(limitviewinfra),'k-','LineWidth',2,'Tag',cond,'DisplayName',cond);
                     end
                 else
                     if(strcmp(handles.meanmouse,'on'))
                        hbar = errorbar(xval(limitviewinfra),projectresults.conditions.(cond).slicesxsegments_infra_mousemean_mean(limitviewinfra),projectresults.conditions.(cond).slicesxsegments_infra_mousemean_std(limitviewinfra),'k-','LineWidth',2,'Tag',cond,'DisplayName',cond);
                     else
                        hbar = errorbar(xval(limitviewinfra),projectresults.conditions.(cond).slicesxsegments_infra_mean(limitviewinfra),projectresults.conditions.(cond).slicesxsegments_infra_std(limitviewinfra),'k-','LineWidth',2,'Tag',cond,'DisplayName',cond);
                     end
                 end
             end
             arearel = mean(projectresults.conditions.(cond).botarearel);
             if(~isnan(handles.limitviewinfra))
                 arearel = arearel(arearel > handles.limitviewinfra(1) - 1 & arearel < handles.limitviewinfra(2) + 1);
             end
             plot(arearel,repmat(max(ylim(handles.axes_mouse_infra)),1,size(arearel,2)),'rv','Tag','Arealborders');
             if(~isnan(handles.limitviewinfra))
                 xlim(handles.limitviewinfra + [-1 1]);
                 set(gca,'XTick',limitviewinfra);
             else
                 xlim([0 projectresults.segments+1]);
                 set(gca,'XTick',1:projectresults.segments);
             end
             
             set(gca,'XTickLabelMode','auto');
             ylabel('Relative Optical Density');
             hold off;
             %legend
             if(hbar > 0)
                 handles.legend_infra = legend([hbar,hplot'],'Location','Best');
             else
                 handles.legend_infra = legend(hplot','Location','Best');
             end
             
         case 'Bar graph per segment'
             markertype = {'o','s','d','p','h','*'};
             %plot supra
             axes(handles.axes_mouse_supra);
             cla;
             hold on;
             values = zeros(size(mice,1),size(projectresults.mice.(mice{1}).slicesxsegments_supra_mean,2));
             for i=1:size(mice,1)
                 values(i,:) = projectresults.mice.(mice{i}).slicesxsegments_supra_mean;
             end
             if(size(values,1)>1)
                 hbar = bar(xval,mean(values),'FaceColor',[0.6,0.6,0.6],'Tag',cond,'DisplayName',cond);
                 if(handles.ste)
                     if(strcmp(handles.meanmouse,'on'))
                        errorbar(xval,projectresults.conditions.(cond).slicesxsegments_supra_mousemean_mean,projectresults.conditions.(cond).slicesxsegments_supra_mousemean_sterr,'LineStyle','none','Color',[0.3,0.3,0.3]);
                     else
                         errorbar(xval,projectresults.conditions.(cond).slicesxsegments_supra_mean,projectresults.conditions.(cond).slicesxsegments_supra_sterr,'LineStyle','none','Color',[0.3,0.3,0.3]);
                     end
                 else
                     if(strcmp(handles.meanmouse,'on'))
                        errorbar(xval,projectresults.conditions.(cond).slicesxsegments_supra_mousemean_mean,projectresults.conditions.(cond).slicesxsegments_supra_mousemean_std,'LineStyle','none','Color',[0.3,0.3,0.3]);
                     else
                         errorbar(xval,projectresults.conditions.(cond).slicesxsegments_supra_mean,projectresults.conditions.(cond).slicesxsegments_supra_std,'LineStyle','none','Color',[0.3,0.3,0.3]);
                     end
                 end
             else
                 hbar = bar(xval,values,'FaceColor',[0.6,0.6,0.6],'Tag',cond,'DisplayName',cond);
             end
             hplot = zeros(1,size(mice,1));
             for i=1:size(mice,1)
                 hplot(i) = plot(xval,values(i,:),[markertype{i} 'k'],'LineStyle','none');
             end
                 
             plot(mean(projectresults.conditions.(cond).toparearel),max(ylim(handles.axes_mouse_supra)):max(ylim(handles.axes_mouse_supra)),'rv','Tag','Arealborders');
             if(~isnan(handles.limitviewsupra))
                 xlim(handles.limitviewsupra + [-1 1]);
             else
                 xlim([0 projectresults.segments+1]);
             end
             set(gca,'XTick',1:projectresults.segments);
             set(gca,'XTickLabelMode','auto');
             ylabel('Relative Optical Density');
             hold off;
             %legend
             for i=1:size(hplot,1)
                set(hplot(i),'DisplayName',mice{i});
             end
             if(hbar > 0)
                 handles.legend_supra = legend([hbar,hplot],'Location','Best');
             else
                 handles.legend_supra = legend(hplot','Location','Best');
             end
             
             
             %plot infra
             axes(handles.axes_mouse_infra);
             cla;
             hold on;
             values = zeros(size(mice,1),size(projectresults.mice.(mice{1}).slicesxsegments_infra_mean,2));
             for i=1:size(mice,1)
                 values(i,:) = projectresults.mice.(mice{i}).slicesxsegments_infra_mean;
             end
             if(size(values,1)>1)
                 hbar = bar(xval,mean(values),'FaceColor',[0.6,0.6,0.6],'Tag',cond,'DisplayName',cond);
                  if(handles.ste)
                     if(strcmp(handles.meanmouse,'on'))
                        errorbar(xval,projectresults.conditions.(cond).slicesxsegments_infra_mousemean_mean,projectresults.conditions.(cond).slicesxsegments_infra_mousemean_sterr,'LineStyle','none','Color',[0.3,0.3,0.3]);
                     else
                         errorbar(xval,projectresults.conditions.(cond).slicesxsegments_infra_mean,projectresults.conditions.(cond).slicesxsegments_infra_sterr,'LineStyle','none','Color',[0.3,0.3,0.3]);
                     end
                 else
                     if(strcmp(handles.meanmouse,'on'))
                        errorbar(xval,projectresults.conditions.(cond).slicesxsegments_infra_mousemean_mean,projectresults.conditions.(cond).slicesxsegments_infra_mousemean_std,'LineStyle','none','Color',[0.3,0.3,0.3]);
                     else
                         errorbar(xval,projectresults.conditions.(cond).slicesxsegments_infra_mean,projectresults.conditions.(cond).slicesxsegments_infra_std,'LineStyle','none','Color',[0.3,0.3,0.3]);
                     end
                 end
             else
                 hbar = bar(xval,values,'FaceColor',[0.6,0.6,0.6],'Tag',cond,'DisplayName',cond);
             end
             hplot = zeros(1,size(mice,1));
             for i=1:size(mice,1)
                 hplot(i) = plot(xval,values(i,:),[markertype{i} 'k'],'LineStyle','none');            
             end
             plot(mean(projectresults.conditions.(cond).botarearel),max(ylim(handles.axes_mouse_infra)):max(ylim(handles.axes_mouse_infra)),'rv','Tag','Arealborders');
             if(~isnan(handles.limitviewinfra))
                 xlim(handles.limitviewinfra + [-1 1]);
             else
                 xlim([0 projectresults.segments+1]);
             end
             set(gca,'XTick',1:projectresults.segments);
             set(gca,'XTickLabelMode','auto');
             ylabel('Relative Optical Density');
             hold off;
             %legend
             for i=1:size(hplot,1)
                set(hplot(i),'DisplayName',mice{i});
             end
             if(hbar > 0)
                 handles.legend_infra = legend([hbar,hplot],'Location','Best');
             else
                 handles.legend_infra = legend(hplot','Location','Best');
             end
         case 'Histogram'
             axes(handles.axes_mouse_supra);
             cla;
             values = zeros(size(mice,1),size(projectresults.mice.(mice{1}).slicesxsegments_supra_mean,2));
             for i=1:size(mice,1)
                 values(i,:) = sum(~isnan(projectresults.mice.(mice{i}).slicesxsegments_supra),1);
             end
             bar(1:size(values,2),sum(values,1));
             ylim([0 max(sum(values,1))+1]);
             ylabel('Number of data points');
             set(gca,'XTick',1:size(values,2));
             set(gca,'XTickLabelMode','auto');
             axes(handles.axes_mouse_infra);
             cla;
             values = zeros(size(mice,1),size(projectresults.mice.(mice{1}).slicesxsegments_infra_mean,2));
             for i=1:size(mice,1)
                 values(i,:) = sum(~isnan(projectresults.mice.(mice{i}).slicesxsegments_infra),1);
             end
             bar(1:size(values,2),sum(values,1));
             ylim([0 max(sum(values,1))+1]);
             ylabel('Number of data points');
             set(gca,'XTick',1:size(values,2));
             set(gca,'XTickLabelMode','auto');
             
         otherwise
             regions = regexp(handles.graphtype{:},'Bar graph per .*','match');
             regionsstr = regexp(handles.graphtype{:},' ','split');
             regions = regionsstr{4};
             markertype = {'o','s','d','p','h','*'};
             %build data table
             region_data = projectresults.conditions.(cond).regions.(regions);
             regnames = fieldnames(region_data);
             region_supra_mean = zeros(1,size(regnames,1));
             region_infra_mean = zeros(1,size(regnames,1));
             region_supra_ste = zeros(1,size(regnames,1));
             region_infra_ste = zeros(1,size(regnames,1));
             region_supra_std = zeros(1,size(regnames,1));
             region_infra_std = zeros(1,size(regnames,1));
             region_supra_cnt = zeros(1,size(regnames,1));
             region_infra_cnt = zeros(1,size(regnames,1));
             region_supra_median = zeros(1,size(regnames,1));
             region_infra_median = zeros(1,size(regnames,1));
             region_supra_q1 = zeros(1,size(regnames,1));
             region_infra_q1 = zeros(1,size(regnames,1));
             region_supra_q3 = zeros(1,size(regnames,1));
             region_infra_q3 = zeros(1,size(regnames,1));
             
             for i=1:size(regnames,1)
                 region_supra_mean(i) = nanmean(region_data.(regnames{i}).segments_supra);
                 region_infra_mean(i) = nanmean(region_data.(regnames{i}).segments_infra);
                 region_supra_ste(i) = nanstd(region_data.(regnames{i}).segments_supra)/size(region_data.(regnames{i}).segments_supra,1);
                 region_infra_ste(i) = nanstd(region_data.(regnames{i}).segments_infra)/size(region_data.(regnames{i}).segments_infra,1);
                 region_supra_std(i) = nanstd(region_data.(regnames{i}).segments_supra);
                 region_infra_std(i) = nanstd(region_data.(regnames{i}).segments_infra);
                 region_supra_cnt(i) = size(region_data.(regnames{i}).segments_supra,1);
                 region_infra_cnt(i) = size(region_data.(regnames{i}).segments_infra,1);
                 region_supra_median(i) = nanmedian(region_data.(regnames{i}).segments_supra);
                 region_infra_median(i) = nanmedian(region_data.(regnames{i}).segments_infra);
                 region_supra_q1(i) = quantile(region_data.(regnames{i}).segments_supra,0.25);
                 region_infra_q1(i) = quantile(region_data.(regnames{i}).segments_infra,0.25);
                 region_supra_q3(i) = quantile(region_data.(regnames{i}).segments_supra,0.75);
                 region_infra_q3(i) = quantile(region_data.(regnames{i}).segments_infra,0.75);
             end
             %plot supra
             axes(handles.axes_mouse_supra);             
             cla;
             if(handles.median)
                 hbar.bars = bar(1:size(region_supra_mean,2),region_supra_median,'FaceColor',[0.6,0.6,0.6],'Tag',cond);
                 hold on;
                 hbar.err = errorbar(1:size(region_supra_mean,2),region_supra_median,(region_supra_median-region_supra_q1),(region_supra_q3-region_supra_median),'k','LineStyle','none');
                 plot(1:size(region_supra_mean,2),region_supra_mean,'rd');
             else
                 if(handles.ste)
                     hbar = barweb(region_supra_mean', region_supra_ste', 0.6, regnames, [], [], 'Relative Optical Density', [0.6,0.6,0.6], [], cond);
                 else
                     hbar = barweb(region_supra_mean', region_supra_std', 0.6, regnames, [], [], 'Relative Optical Density', [0.6,0.6,0.6], [], cond);
                 end
             end
             hold on;
             hplot = zeros(1,size(mice,1));
             for i=1:size(mice,1)
                 for j=1:size(regnames,1)
                     hplot(i) = plot(j,mean(projectresults.mice.(mice{i}).regions.(regions).(regnames{j}).segments_supra),[markertype{i} 'k'],'LineStyle','none','Tag',mice{i},'DisplayName',mice{i});
                 end
             end 
             xlim([0.5 size(regnames,1)+0.5]);
             ylabel('Relative Optical Density');
             hold off;
             %legend
             handles.legend = [cond; mice];
             handles.legend_supra = legend([hbar.bars,hplot],'Location','Best');
             
             %plot infra
             axes(handles.axes_mouse_infra);
             cla;
             if(handles.median)
                 hbar.bars = bar(1:size(region_supra_mean,2),region_supra_median,'FaceColor',[0.6,0.6,0.6],'Tag',cond);
                 hold on;
                 hbar.err = errorbar(1:size(region_supra_mean,2),region_supra_median,(region_supra_median-region_supra_q1),(region_supra_q3-region_supra_median),'k','LineStyle','none');
                 plot(1:size(region_supra_mean,2),region_supra_mean,'rd');
             else
                 if(handles.ste)
                     hbar = barweb(region_infra_mean', region_infra_ste', 0.6, regnames, [], [], 'Relative Optical Density', [0.6,0.6,0.6], [], cond);
                 else
                     hbar = barweb(region_infra_mean', region_infra_std', 0.6, regnames, [], [], 'Relative Optical Density', [0.6,0.6,0.6], [], cond);
                 end
             end
             hold on;
             hplot = zeros(1,size(mice,1));
             for i=1:size(mice,1)
                 for j=1:size(regnames,1)
                     hplot(i) = plot(j,mean(projectresults.mice.(mice{i}).regions.(regions).(regnames{j}).segments_infra),[markertype{i} 'k'],'LineStyle','none','Tag',mice{i},'DisplayName',mice{i});
                 end
             end 
             xlim([0.5 size(regnames,1)+0.5]);             
             ylabel('Relative Optical Density');
             hold off;
             
             %legend
             handles.legend = [cond; mice];
             handles.legend_infra = legend([hbar.bars,hplot],'Location','Best');
             
     end
             
function handles = draw_axes_intercond(handles,value)
    conditions = regexp(value,'_vs_','split');
    projectresults = handles.projectresults;
    xval = 1:projectresults.segments;
    if(~isnan(handles.limitviewsupra))
        limitviewsupra = handles.limitviewsupra(1):handles.limitviewsupra(2);
    else
        limitviewsupra = xval;
    end
    if(~isnan(handles.limitviewinfra))
        limitviewinfra = handles.limitviewinfra(1):handles.limitviewinfra(2);
    else
        limitviewinfra = xval;
    end
             
    switch char(handles.graphtype)
        case 'Line graph per segment'
            %plot supra
            axes(handles.axes_mouse_supra);
            cla;
            hold on;
            if(strcmp(handles.bw,'on'))
                if(size(conditions,2)==2)
                    colors = [40 40 40;128 128 128]./255;
                    lines = {'-','-',':',':','-.','-.'};
                else
                    colors = [40 40 40;90 90 90;128 128 128;150 150 150]./255;
                    lines = {'-','-','-','-'};
                end
            else
                colormap('default');
                colors = get(gca,'ColorOrder');
                lines = repmat({'-'},1,size(colors,1));
            end
            
            hbar = zeros(1,size(conditions,2));
            if(~isnan(handles.highlightsupra) & strcmp(handles.highlightgrayband,'on'))
                hgrayband = area(xval(handles.highlightsupra(1):handles.highlightsupra(2)),repmat(max(ylim(handles.axes_mouse_supra)),1,handles.highlightsupra(2)-handles.highlightsupra(1)+1),'FaceColor',[0.8 0.8 0.8],'LineStyle','none','DisplayName','Lesion');
                set(gca,'Layer','top');
            end
                                    
            for i=1:size(conditions,2)
                limitviewsupraflag = zeros(size(projectresults.conditions.(conditions{i}).slicesxsegments_supra_mean));
                limitviewsupraflag(limitviewsupra) = 1;
                
                if(~isnan(handles.highlightsupra) & strcmp(handles.highlightgrayband,'off'))
                    highlight = handles.highlightsupra(1)+1:handles.highlightsupra(2)-1;
                    limitviewsupraflag(highlight) = 2;
                    slicesxsegments_supra_mean_limitview = nan(size(projectresults.conditions.(conditions{i}).slicesxsegments_supra_mean));
                    xval_limitview = nan(size(xval));
                    slicesxsegments_supra_mean_limitview(limitviewsupraflag > 0) = projectresults.conditions.(conditions{i}).slicesxsegments_supra_mean(limitviewsupraflag > 0);
                    xval_limitview(limitviewsupraflag > 0) = xval(limitviewsupraflag > 0);
                    slicesxsegments_supra_mean_limitview(handles.highlightsupra(1)+1:handles.highlightsupra(2)-1) = NaN;
                    hbar(i) = plot(xval,slicesxsegments_supra_mean_limitview,lines{i},'LineWidth',2,'Color',colors(mod(i-1,size(colors,1))+1,:),'Tag',conditions{i},'DisplayName',conditions{i});
                    plot(xval(handles.highlightsupra(1):handles.highlightsupra(2)),projectresults.conditions.(conditions{i}).slicesxsegments_supra_mean(handles.highlightsupra(1):handles.highlightsupra(2)),lines{i},'LineWidth',3,'Color',colors(mod(i-1,size(colors,1))+1,:),'Tag',[conditions{i} '_highlight'],'DisplayName',[conditions{i} '_highlight']);
                else
                    hbar(i) = plot(xval(limitviewsupraflag>0),projectresults.conditions.(conditions{i}).slicesxsegments_supra_mean(limitviewsupraflag>0),lines{i},'LineWidth',2,'Color',colors(mod(i-1,size(colors,1))+1,:),'Tag',conditions{i},'DisplayName',conditions{i});
                end
                
                if(handles.ste)
                    errorbar(xval(limitviewsupraflag>0),projectresults.conditions.(conditions{i}).slicesxsegments_supra_mean(limitviewsupraflag>0),projectresults.conditions.(conditions{i}).slicesxsegments_supra_sterr(limitviewsupraflag>0),'LineStyle','none','LineWidth',1,'Color',colors(mod(i-1,size(colors,1))+1,:),'Tag',conditions{i},'DisplayName',conditions{i});
                else
                    errorbar(xval(limitviewsupraflag>0),projectresults.conditions.(conditions{i}).slicesxsegments_supra_mean(limitviewsupraflag>0),projectresults.conditions.(conditions{i}).slicesxsegments_supra_std(limitviewsupraflag>0),'LineStyle','none','LineWidth',1,'Color',colors(mod(i-1,size(colors,1))+1,:),'Tag',conditions{i},'DisplayName',conditions{i});
                end
                
            end
            arearel = mean(projectresults.alltoparearel);
            if(strcmp(handles.removeouterarealborders,'on'))
                arearel = arearel(2:end-1);
            end
            if(strcmp(handles.bw,'on'))
                plot(arearel,repmat(max(ylim(handles.axes_mouse_supra)),1,size(arearel,2)),'kv','Tag','Arealborders');
            else
                plot(arearel,repmat(max(ylim(handles.axes_mouse_supra)),1,size(arearel,2)),'rv','Tag','Arealborders');
            end
            plot([arearel; arearel], repmat([0.001;max(ylim(handles.axes_mouse_supra))*0.98],1,size(arearel,2)),':','Color',[0.5 0.5 0.5],'Tag','Arealbordersdottedlines','LineWidth',0.25);
            
            if(~isnan(handles.limitviewsupra))
                xlim(handles.limitviewsupra + [-1 1]);
                set(gca,'XTick',limitviewsupra);
            else
                xlim([0 projectresults.segments+1]);
                set(gca,'XTick',1:projectresults.segments);
            end
            
            set(gca,'XTickLabelMode','auto');
            ylabel('Relative Optical Density');
            hold off;
            %legend
            handles.legend = conditions;
            handles.legend_supra = legend(hbar,'Location','Best');
            
            %axes userdata
            userdata.errorbars = hbar;
            userdata.legend = handles.legend_supra;
            set(gca,'UserData',userdata);
            
            %plot infra
            axes(handles.axes_mouse_infra);
            cla;
            hold on;
            hbar = zeros(1,size(conditions,2));
            if(~isnan(handles.highlightinfra) & strcmp(handles.highlightgrayband,'on'))
                hgrayband = area(xval(handles.highlightinfra(1):handles.highlightinfra(2)),repmat(max(ylim(handles.axes_mouse_infra)),1,handles.highlightinfra(2)-handles.highlightinfra(1)+1),'FaceColor',[0.8 0.8 0.8],'LineStyle','none','DisplayName','Lesion');
                set(gca,'Layer','top');
            end
                                    
            for i=1:size(conditions,2)
                limitviewinfraflag = zeros(size(projectresults.conditions.(conditions{i}).slicesxsegments_infra_mean));
                limitviewinfraflag(limitviewinfra) = 1;
                
                if(~isnan(handles.highlightinfra) & strcmp(handles.highlightgrayband,'off'))
                    highlight = handles.highlightinfra(1)+1:handles.highlightinfra(2)-1;
                    limitviewinfraflag(highlight) = 2;
                    slicesxsegments_infra_mean_limitview = nan(size(projectresults.conditions.(conditions{i}).slicesxsegments_infra_mean));
                    xval_limitview = nan(size(xval));
                    slicesxsegments_infra_mean_limitview(limitviewinfraflag > 0) = projectresults.conditions.(conditions{i}).slicesxsegments_infra_mean(limitviewinfraflag > 0);
                    xval_limitview(limitviewinfraflag > 0) = xval(limitviewinfraflag > 0);
                    slicesxsegments_infra_mean_limitview(handles.highlightinfra(1)+1:handles.highlightinfra(2)-1) = NaN;
                    hbar(i) = plot(xval,slicesxsegments_infra_mean_limitview,lines{i},'LineWidth',2,'Color',colors(mod(i-1,size(colors,1))+1,:),'Tag',conditions{i},'DisplayName',conditions{i});
                    plot(xval(handles.highlightinfra(1):handles.highlightinfra(2)),projectresults.conditions.(conditions{i}).slicesxsegments_infra_mean(handles.highlightinfra(1):handles.highlightinfra(2)),lines{i},'LineWidth',3,'Color',colors(mod(i-1,size(colors,1))+1,:),'Tag',[conditions{i} '_highlight'],'DisplayName',[conditions{i} '_highlight']);
                else
                    hbar(i) = plot(xval(limitviewinfraflag>0),projectresults.conditions.(conditions{i}).slicesxsegments_infra_mean(limitviewinfraflag>0),lines{i},'LineWidth',2,'Color',colors(mod(i-1,size(colors,1))+1,:),'Tag',conditions{i},'DisplayName',conditions{i});
                end
                
                if(handles.ste)
                    errorbar(xval(limitviewinfraflag>0),projectresults.conditions.(conditions{i}).slicesxsegments_infra_mean(limitviewinfraflag>0),projectresults.conditions.(conditions{i}).slicesxsegments_infra_sterr(limitviewinfraflag>0),'LineStyle','none','LineWidth',1,'Color',colors(mod(i-1,size(colors,1))+1,:),'Tag',conditions{i},'DisplayName',conditions{i});
                else
                    errorbar(xval(limitviewinfraflag>0),projectresults.conditions.(conditions{i}).slicesxsegments_infra_mean(limitviewinfraflag>0),projectresults.conditions.(conditions{i}).slicesxsegments_infra_std(limitviewinfraflag>0),'LineStyle','none','LineWidth',1,'Color',colors(mod(i-1,size(colors,1))+1,:),'Tag',conditions{i},'DisplayName',conditions{i});
                end
                
            end
            arearel = mean(projectresults.allbotarearel);
            if(strcmp(handles.removeouterarealborders,'on'))
                arearel = arearel(2:end-1);
            end
            if(strcmp(handles.bw,'on'))
                plot(arearel,repmat(max(ylim(handles.axes_mouse_infra)),1,size(arearel,2)),'kv','Tag','Arealborders');
            else
                plot(arearel,repmat(max(ylim(handles.axes_mouse_infra)),1,size(arearel,2)),'rv','Tag','Arealborders');
            end
            plot([arearel; arearel], repmat([0.001;max(ylim(handles.axes_mouse_infra))*0.98],1,size(arearel,2)),':','Color',[0.5 0.5 0.5],'Tag','Arealbordersdottedlines','LineWidth',0.25);
            
            if(~isnan(handles.limitviewinfra))
                xlim(handles.limitviewinfra + [-1 1]);
                set(gca,'XTick',limitviewinfra);
            else
                xlim([0 projectresults.segments+1]);
                set(gca,'XTick',1:projectresults.segments);
            end
            
            set(gca,'XTickLabelMode','auto');
            ylabel('Relative Optical Density');
            hold off;
            %legend
            handles.legend = conditions;
            handles.legend_infra = legend(hbar,'Location','Best');
             
        case 'Bar graph per segment'
            %plot supra
            axes(handles.axes_mouse_supra);
            cla;
            
            colors = [0.3 0.3 0.3; 0.4 0.4 0.4; 0.5 0.5 0.5; 0.6 0.6 0.6; 0.7 0.7 0.7];
            values = zeros(size(conditions,2),size(projectresults.conditions.(conditions{1}).slicesxsegments_supra_mean,2));
            valste = zeros(size(conditions,2),size(projectresults.conditions.(conditions{1}).slicesxsegments_supra_sterr,2));
            valstd = zeros(size(conditions,2),size(projectresults.conditions.(conditions{1}).slicesxsegments_supra_std,2));
            for i=1:size(conditions,2)
                values(i,:) = projectresults.conditions.(conditions{i}).slicesxsegments_supra_mean;
                valste(i,:) = projectresults.conditions.(conditions{i}).slicesxsegments_supra_sterr;
                valstd(i,:) = projectresults.conditions.(conditions{i}).slicesxsegments_supra_std;
            end
            if(handles.ste)
                hbar = barweb(values', valste', 1, conditions, [], [], 'Relative Optical Density', colors, [], conditions);
            else
                hbar = barweb(values', valstd', 1, conditions, [], [], 'Relative Optical Density', colors, [], conditions);
            end
            
            hold on;
            plot(mean(projectresults.alltoparearel),max(ylim(handles.axes_mouse_supra)):max(ylim(handles.axes_mouse_supra)),'rv','Tag','Arealborders');
            if(~isnan(handles.limitviewsupra))
                xlim(handles.limitviewsupra + [-1 1]);
            else
                xlim([0 projectresults.segments+1]);
            end
            set(gca,'XTick',1:projectresults.segments);
            set(gca,'XTickLabelMode','auto');
            ylabel('Relative Optical Density');
            hold off;
            %legend
            handles.legend = conditions;
            handles.legend_supra = legend(hbar.bars,'Location','Best');
            
            %plot infra
            axes(handles.axes_mouse_infra);
            cla;
            hold on;
            values = zeros(size(conditions,2),size(projectresults.conditions.(conditions{1}).slicesxsegments_supra_mean,2));
            valste = zeros(size(conditions,2),size(projectresults.conditions.(conditions{1}).slicesxsegments_supra_sterr,2));
            valstd = zeros(size(conditions,2),size(projectresults.conditions.(conditions{1}).slicesxsegments_supra_std,2));
            for i=1:size(conditions,2)
                values(i,:) = projectresults.conditions.(conditions{i}).slicesxsegments_infra_mean;
                valste(i,:) = projectresults.conditions.(conditions{i}).slicesxsegments_infra_sterr;
                valstd(i,:) = projectresults.conditions.(conditions{i}).slicesxsegments_infra_std;
            end
            if(handles.ste)
                hbar = barweb(values', valste', 1, conditions, [], [], 'Relative Optical Density', colors, [], conditions);
            else
                hbar = barweb(values', valstd', 1, conditions, [], [], 'Relative Optical Density', colors, [], conditions);
            end
            hold on;
            
            plot(mean(projectresults.allbotarearel),max(ylim(handles.axes_mouse_infra)):max(ylim(handles.axes_mouse_infra)),'rv','Tag','Arealborders');
            if(~isnan(handles.limitviewinfra))
                xlim(handles.limitviewinfra + [-1 1]);
            else
                xlim([0 projectresults.segments+1]);
            end
            set(gca,'XTick',1:projectresults.segments);
            set(gca,'XTickLabelMode','auto');
            ylabel('Relative Optical Density');
            hold off;
            
            %legend
            handles.legend = conditions;
            handles.legend_infra = legend(hbar.bars,'Location','Best');
            
        case 'Histogram'
             axes(handles.axes_mouse_supra);
             cla;
             values = zeros(size(conditions,2),size(projectresults.conditions.(conditions{1}).slicesxsegments_supra_mean,2));
             for i=1:size(conditions,2)
                 values(i,:) = sum(~isnan(projectresults.conditions.(conditions{i}).slicesxsegments_supra),1);
             end
             hbar = bar(1:size(values,2),values');
             ylim([0 max(sum(values,1))+1]);
             ylabel('Number of data points');
             set(gca,'XTick',1:size(values,2));
             set(gca,'XTickLabelMode','auto');
             handles.legend = conditions;
             handles.legend_supra = legend(hbar,handles.legend,'Location','Best');
             
             axes(handles.axes_mouse_infra);
             cla;
             values = zeros(size(conditions,2),size(projectresults.conditions.(conditions{1}).slicesxsegments_supra_mean,2));
             for i=1:size(conditions,2)
                 values(i,:) = sum(~isnan(projectresults.conditions.(conditions{i}).slicesxsegments_infra),1);
             end
             hbar = bar(1:size(values,2),values');
             ylim([0 max(sum(values,1))+1]);
             ylabel('Number of data points');
             set(gca,'XTick',1:size(values,2));
             set(gca,'XTickLabelMode','auto');
             handles.legend = conditions;
             handles.legend_infra = legend(hbar,handles.legend,'Location','Best');
             
        otherwise
            regionsstr = regexp(handles.graphtype{:},' ','split');
            regions = regionsstr{4};
            %build data table
            region_data = projectresults.conditions.(conditions{1}).regions.(regions);
            regnames = fieldnames(region_data);
            region_supra_mean = zeros(size(conditions,2),size(regnames,1));
            region_infra_mean = zeros(size(conditions,2),size(regnames,1));
            region_supra_ste = zeros(size(conditions,2),size(regnames,1));
            region_infra_ste = zeros(size(conditions,2),size(regnames,1));
            region_supra_std = zeros(size(conditions,2),size(regnames,1));
            region_infra_std = zeros(size(conditions,2),size(regnames,1));
            region_supra_cnt = zeros(size(conditions,2),size(regnames,1));
            region_infra_cnt = zeros(size(conditions,2),size(regnames,1));
            region_supra_median = zeros(size(conditions,2),size(regnames,1));
             region_infra_median = zeros(size(conditions,2),size(regnames,1));
             region_supra_q1 = zeros(size(conditions,2),size(regnames,1));
             region_infra_q1 = zeros(size(conditions,2),size(regnames,1));
             region_supra_q3 = zeros(size(conditions,2),size(regnames,1));
             region_infra_q3 = zeros(size(conditions,2),size(regnames,1));
            
            for i=1:size(conditions,2)
                region_data = projectresults.conditions.(conditions{i}).regions.(regions);
                for j=1:size(regnames,1)
                    region_supra_mean(i,j) = nanmean(region_data.(regnames{j}).segments_supra);
                    region_infra_mean(i,j) = nanmean(region_data.(regnames{j}).segments_infra);
                    region_supra_ste(i,j) = nanstd(region_data.(regnames{j}).segments_supra)/size(region_data.(regnames{j}).segments_supra,1);
                    region_supra_std(i,j) = nanstd(region_data.(regnames{j}).segments_supra);
                    region_infra_ste(i,j) = nanstd(region_data.(regnames{j}).segments_infra)/size(region_data.(regnames{j}).segments_infra,1);
                    region_infra_std(i,j) = nanstd(region_data.(regnames{j}).segments_infra);
                    region_supra_cnt(i,j) = size(region_data.(regnames{j}).segments_supra,1);
                    region_infra_cnt(i,j) = size(region_data.(regnames{j}).segments_infra,1);
                    region_supra_median(i,j) = nanmedian(region_data.(regnames{j}).segments_supra);
                    region_infra_median(i,j) = nanmedian(region_data.(regnames{j}).segments_infra);
                    region_supra_q1(i,j) = quantile(region_data.(regnames{j}).segments_supra,0.25);
                    region_infra_q1(i,j) = quantile(region_data.(regnames{j}).segments_infra,0.25);
                    region_supra_q3(i,j) = quantile(region_data.(regnames{j}).segments_supra,0.75);
                    region_infra_q3(i,j) = quantile(region_data.(regnames{j}).segments_infra,0.75);
                end
            end
            fprintf('\nCounts supra\n');
            fprintf([repmat('%6.2f\t',1,size(region_supra_cnt,2)) '\n'],region_supra_cnt');
            fprintf('\nCounts infra\n');
            fprintf([repmat('%6.2f\t',1,size(region_infra_cnt,2)) '\n'],region_infra_cnt');
            
            %plot supra
            axes(handles.axes_mouse_supra);
            cla;
            colors = [0.3 0.3 0.3; 0.4 0.4 0.4; 0.5 0.5 0.5; 0.6 0.6 0.6; 0.7 0.7 0.7];
            if(handles.median)
                hbar = barweb2(region_supra_median',region_supra_mean',(region_supra_median-region_supra_q1)',(region_supra_q3-region_supra_median)', 1, regnames, [], [], 'Relative Optical Density', colors, [], conditions);
             else
                 if(handles.ste)
                     hbar = barweb(region_supra_mean', region_supra_ste', 1, regnames, [], [], 'Relative Optical Density', colors, [], conditions);
                 else
                     hbar = barweb(region_supra_mean', region_supra_std', 1, regnames, [], [], 'Relative Optical Density', colors, [], conditions);
                 end
            end
            xlim([0 size(findstr(',',projectresults.areas),2)+2]);
            ylabel('Relative Optical Density');
            %legend
            handles.legend = conditions;
            handles.legend_supra = legend(hbar.bars,'Location','Best');
            
            %plot infra
            axes(handles.axes_mouse_infra);
            cla;
            if(handles.median)
                 hbar = barweb2(region_infra_median',region_supra_mean',(region_infra_median-region_infra_q1)',(region_infra_q3-region_infra_median)', 1, regnames, [], [], 'Relative Optical Density', colors, [], conditions);
            else
                if(handles.ste)
                    hbar = barweb(region_infra_mean', region_infra_ste', 1, regnames, [], [], 'Relative Optical Density', colors, [], conditions);
                else
                    hbar = barweb(region_infra_mean', region_infra_std', 1, regnames, [], [], 'Relative Optical Density', colors, [], conditions);
                end
            end
            
            xlim([0 size(findstr(',',projectresults.areas),2)+2]);
            ylabel('Relative Optical Density');
            %legend
            handles.legend = conditions;
            handles.legend_infra = legend(hbar.bars,'Location','Best');
            
    end  
  
function draw_table_intracondition(handles,cond)
    regionstr = get(handles.popup_intracond_region,'String');
    regions = regionstr(get(handles.popup_intracond_region,'Value'));
    projectresults = handles.projectresults;
    
    
    if(strcmp(regions,'Segments'))
        res_supra = colorizecells(projectresults.intraconditions.(cond).nonparam_matched_supra_h,projectresults.intraconditions.(cond).nonparam_matched_supra_diff);
        res_infra = colorizecells(projectresults.intraconditions.(cond).nonparam_matched_infra_h,projectresults.intraconditions.(cond).nonparam_matched_infra_diff);
        set(handles.uitable_intracond_supra,'Data',res_supra,'ColumnName',{1:projectresults.segments},'RowName',{1:projectresults.segments},'ColumnWidth',{30});
        set(handles.uitable_intracond_infra,'Data',res_infra,'ColumnName',{1:projectresults.segments},'RowName',{1:projectresults.segments},'ColumnWidth',{30});
    else
        region = fieldnames(projectresults.conditions.(cond).regions.(regions{:}));
        res_supra = colorizecells(projectresults.intraconditions.(cond).regions.(regions{:}).paireddiff_supra_p,projectresults.intraconditions.(cond).regions.(regions{:}).difference_supra);
        res_infra = colorizecells(projectresults.intraconditions.(cond).regions.(regions{:}).paireddiff_infra_p,projectresults.intraconditions.(cond).regions.(regions{:}).difference_infra);
        set(handles.uitable_intracond_supra,'Data',res_supra,'ColumnName',region','RowName',region','ColumnWidth',{30});
        set(handles.uitable_intracond_infra,'Data',res_infra,'ColumnName',region','RowName',region','ColumnWidth',{30});
    end
    
%     set(handles.uitable_legend_intra,'Data',{'Significant greater than','','';['<html><div align="center"><font bgcolor=yellow>&lt;' num2str(sidak_alpha(1)) '</font></html>'], ['<html><font bgcolor=#FF9900>&lt;' num2str(sidak_alpha(2)) '</font></html>'], ['<html><font bgcolor=red>&lt;' num2str(sidak_alpha(3)) '</font></div></html>'];'Significant smaller than','','';['<html><div align="center"><font bgcolor=#00FFFF>&lt;' num2str(sidak_alpha(1)) '</font></html>'], ['<html><font bgcolor=#0099FF>&lt;' num2str(sidak_alpha(2)) '</font></html>'], ['<html><font bgcolor=blue>&lt;' num2str(sidak_alpha(3)) '</font></div></html>']},'ColumnWidth',{80});
     

function draw_table_intercondition(handles)
    regionstr = get(handles.popup_intercond_region,'String');
    regions = regionstr(get(handles.popup_intercond_region,'Value'));    
    projectresults = handles.projectresults;
    
    if(size(projectresults.interconditions,1) > 0)
        if(strcmp(regions,'Segments'))
            intercond = fieldnames(projectresults.interconditions);
            
            for i=1:size(intercond,1)
                res_supra(i,:) = projectresults.interconditions.(intercond{i}).nonparam_unmatched_supra_h(:);
                diff_supra(i,:) = projectresults.interconditions.(intercond{i}).nonparam_unmatched_supra_diff(:);
                res_infra(i,:) = projectresults.interconditions.(intercond{i}).nonparam_unmatched_infra_h(:);
                diff_infra(i,:) = projectresults.interconditions.(intercond{i}).nonparam_unmatched_infra_diff(:);
            end
%             sidak_alpha = projectresults.interconditions.(intercond{1}).sidak_alpha;
            %colorize table cells according to p-value
            res_supra_out = colorizecells(res_supra,diff_supra);
            res_infra_out = colorizecells(res_infra,diff_infra);
            
            set(handles.uitable_intercond_supra,'Data',res_supra_out,'ColumnName',{1:projectresults.segments},'RowName',intercond','ColumnWidth',{45});
            set(handles.uitable_intercond_infra,'Data',res_infra_out,'ColumnName',{1:projectresults.segments},'RowName',intercond','ColumnWidth',{45});
        else
            intercond = fieldnames(projectresults.interconditions);
            sidak_alpha = [0.05 0.01 0.001];
            regio = projectresults.interconditions.(intercond{1}).regions.(regions{:}).region;
            res_supra = zeros(size(intercond,1),size(regio,1));
            res_infra = zeros(size(intercond,1),size(regio,1));
            diff_supra = zeros(size(intercond,1),size(regio,1));
            diff_infra = zeros(size(intercond,1),size(regio,1));
            for i=1:size(intercond,1)
                res_supra(i,:) = projectresults.interconditions.(intercond{i}).regions.(regions{:}).unpaireddiff_supra_p;
                diff_supra(i,:) = projectresults.interconditions.(intercond{i}).regions.(regions{:}).difference_supra;
                res_infra(i,:) = projectresults.interconditions.(intercond{i}).regions.(regions{:}).unpaireddiff_infra_p;
                diff_infra(i,:) = projectresults.interconditions.(intercond{i}).regions.(regions{:}).difference_infra;
            end
            
            %colorize table cells according to p-value
            res_supra_out = colorizecells(res_supra,diff_supra);
            res_infra_out = colorizecells(res_infra,diff_infra);
            
            set(handles.uitable_intercond_supra,'Data',res_supra_out,'ColumnName',regio','RowName',intercond','ColumnWidth',{45});
            set(handles.uitable_intercond_infra,'Data',res_infra_out,'ColumnName',regio','RowName',intercond','ColumnWidth',{45});
        end
%        set(handles.uitable_legend_inter,'Data',{'Significant greater than','','';['<html><div align="center"><font bgcolor=yellow>&lt;' num2str(sidak_alpha(1)) '</font></html>'], ['<html><font bgcolor=#FF9900>&lt;' num2str(sidak_alpha(2)) '</font></html>'], ['<html><font bgcolor=red>&lt;' num2str(sidak_alpha(3)) '</font></div></html>'];'Significant smaller than','','';['<html><div align="center"><font bgcolor=#00FFFF>&lt;' num2str(sidak_alpha(1)) '</font></html>'], ['<html><font bgcolor=#0099FF>&lt;' num2str(sidak_alpha(2)) '</font></html>'], ['<html><font bgcolor=blue>&lt;' num2str(sidak_alpha(3)) '</font></div></html>']},'ColumnWidth',{80});
    else
        set(handles.uitable_intercond_supra,'Data',{'Only 1 condition present in setup'},'ColumnWidth',{200});
        set(handles.uitable_intercond_infra,'Data',{'Only 1 condition present in setup'},'ColumnWidth',{200});
    end
    


%-x-x-x- GUI EDITED CALLBACKS -x-x-x-%
%Menu
function menu_load_Callback(hObject, eventdata, handles)
    [filename path] = uigetfile('saved_analysis/*.mat','Select result file');
    if(~isnumeric(filename))
        temp = load([path filename],'projectresults');
        handles.projectresults = temp.projectresults;
        
        set(handles.fig_ISH_results,'Name',['Results ISH Analysis - ' filename]);
        handles.savename = filename(1:end-4);
        fprintf('Results from project %s loaded\n',char(filename(1:end-4)));
        handles = load_results(handles);
    end
    
    guidata(hObject,handles);
    
function menu_ymin_Callback(hObject, eventdata, handles)
    handles.ymin = str2num(char(inputdlg('Minimum value on Y axes','Graph properties')));
    set(handles.menu_ymin,'Label',sprintf('Ymin: %d',handles.ymin));
    guidata(hObject,handles);

function menu_ymax_Callback(hObject, eventdata, handles)
    handles.ymax = str2num(char(inputdlg('Maximum value on Y axes','Graph properties')));
    set(handles.menu_ymax,'Label',sprintf('Ymax: %d',handles.ymax));
    guidata(hObject,handles);

function menu_ste_Callback(hObject, eventdata, handles)
    if strcmp(get(gcbo, 'Checked'),'on')
        set(gcbo, 'Checked', 'off');
        handles.ste = false;
    else
        set(gcbo, 'Checked', 'on');
        handles.ste = true;
    end
    guidata(hObject,handles);

function menu_ticks_Callback(hObject, eventdata, handles)
    if strcmp(get(gcbo, 'Checked'),'on')
        set(gcbo, 'Checked', 'off');
        handles.ticks = false;
    else
        set(gcbo, 'Checked', 'on');
        handles.ticks = true;
    end
    guidata(hObject,handles);

function menu_median_Callback(hObject, eventdata, handles)
    if strcmp(get(gcbo, 'Checked'),'on')
        set(gcbo, 'Checked', 'off');
        handles.median = false;
    else
        set(gcbo, 'Checked', 'on');
        handles.median = true;
    end
    guidata(hObject,handles);
    
function saveasvar_Callback(hObject, eventdata, handles)
    graph = get(handles.pop_graph,'String');
    item = graph(get(handles.pop_graph,'Value'));    
    
    if(exist(['saved_variables/' char(handles.projectresults.name) '_' char(item) '.mat'],'file'))
        delete(['saved_variables/' char(handles.projectresults.name) '_' char(item) '.mat']);
    end
    
    child = get(handles.axes_mouse_supra,'Children');
    for i=1:size(child,1)
        eval([get(child(i),'Tag') '_supra_x=[' mat2str(get(child(i),'XData')) '];']);
        eval([get(child(i),'Tag') '_supra_y=[' mat2str(get(child(i),'YData')) '];']);
        if(~exist(['saved_variables/' char(handles.projectresults.name) '_' char(item) '.mat'],'file'))
            save(['saved_variables/' char(handles.projectresults.name) '_' char(item) '.mat'],[get(child(i),'Tag') '_supra_x'],[get(child(i),'Tag') '_supra_y']);
        else
            save(['saved_variables/' char(handles.projectresults.name) '_' char(item) '.mat'],[get(child(i),'Tag') '_supra_x'],[get(child(i),'Tag') '_supra_y'],'-append');
        end
        if(strcmp(get(child(i),'Type'),'hggroup'))
            eval([get(child(i),'Tag') '_supra_error=[' mat2str(get(child(i),'UData')) '];']);
            save(['saved_variables/' char(handles.projectresults.name) '_' char(item) '.mat'],[get(child(i),'Tag') '_supra_error'],'-append');
        end
    end
    child = get(handles.axes_mouse_infra,'Children');
    for i=1:size(child,1)
        eval([get(child(i),'Tag') '_infra_x=[' mat2str(get(child(i),'XData')) '];']);
        eval([get(child(i),'Tag') '_infra_y=[' mat2str(get(child(i),'YData')) '];']);
        save(['saved_variables/' char(handles.projectresults.name) '_' char(item) '.mat'],[get(child(i),'Tag') '_infra_x'],[get(child(i),'Tag') '_infra_y'],'-append');
        if(strcmp(get(child(i),'Type'),'hggroup'))
            eval([get(child(i),'Tag') '_infra_error=[' mat2str(get(child(i),'UData')) '];']);
            save(['saved_variables/' char(handles.projectresults.name) '_' char(item) '.mat'],[get(child(i),'Tag') '_infra_error'],'-append');
        end
    end
    fprintf('Current graphs saved as mat file in saved_variables.\n');

function menu_excel_Callback(hObject, eventdata, handles)
    [file,path] = uiputfile('*.xlsx','Save Results As');
    exportToExcel(handles.projectresults,fullfile(path,file));
    
%GUI
function pop_graph_Callback(hObject, eventdata, handles)
    handles = chooseGraph(handles);
    guidata(hObject,handles);

function pushbutton1_Callback(hObject, eventdata, handles)
load_results(handles)

function pop_cond_Callback(hObject, eventdata, handles)
conds = get(hObject,'String');
draw_table_intracondition(handles,conds{get(hObject,'Value')});

function savegraphs_Callback(hObject, eventdata, handles)
    list = get(handles.pop_graph,'String');
    listitem = list{get(handles.pop_graph,'Value')};
    fig = figure();
    figsubplot(1) = subplot(2,1,1);
    set(figsubplot(1),'Visible','off');
    if(isfield(handles,'savegraphpath'))
        path = handles.savegraphpath;
    else
        path = '';
    end
    path = uigetdir(path,'Save Current Graphs to this directory');
    if(ischar(path))
        handles.savegraphpath = path;
        newax = copyobj(handles.axes_mouse_supra,fig);
        axes(newax);
        set(newax,'OuterPosition',[0 0.5 1 0.5])
        set(newax,'Box','off');
        if(~strcmp(handles.graphtype{:},'Histogram'))
            ylabel(newax,'Relative \textit{zif268} expression','Interpreter','latex');
            newleg = copyobj(handles.legend_supra,fig);
            set(newleg,'Position',[0.9 0.6 0.09 0.09])
        end
        if(handles.ticks)
            set(gca,'TickLength',[0.005 0]);
            set(gca,'TickDir','out');
        else
            set(gca,'TickLength',[0 0]);
        end
        title([listitem ' Supra']);
        %set(newax, 'units', 'pixels', 'position', [60 60 680 300]);
        %     saveas(fig,[path '\' listitem '_supra_' strrep(handles.graphtype{:},' ','-') '.jpg']);
        
        figsubplot(2) = subplot(2,1,2);
        set(figsubplot(2),'Visible','off');
        newax = copyobj(handles.axes_mouse_infra,fig);
        axes(newax);
        set(newax,'OuterPosition',[0 0 1 0.5])
        set(newax, 'Box','off');
        if(~strcmp(handles.graphtype{:},'Histogram'))
            ylabel(newax,'Relative \textit{zif268} expression','Interpreter','latex');
            newleg = copyobj(handles.legend_infra,fig);
            set(newleg,'Position',[0.9 0.1 0.09 0.09])
        end
        if(handles.ticks)
            set(gca,'TickLength',[0.005 0]);
            set(gca,'TickDir','out');
        else
            set(gca,'TickLength',[0 0]);
        end
        title([listitem ' Infra']);
        
        set(fig,'Position',[477 56 997 937]);
        saveas(fig,[path '\' datestr(date,'yyyymmdd') '_' listitem '_' strrep(handles.graphtype{:},' ','-') '.tiff']);
        close(fig)
        guidata(hObject, handles);
    end

function saveasfig_Callback(hObject, eventdata, handles)
    list = get(handles.pop_graph,'String');
    listitem = list{get(handles.pop_graph,'Value')};
    fig = figure();
    if(isfield(handles,'savegraphpath'))
        path = handles.savegraphpath;
    else
        path = '';
    end
    path = uigetdir(path,'Save Current Graphs to this directory');
    handles.savegraphpath = path;
    newax = copyobj(handles.axes_mouse_supra,fig);
    axes(newax);
    
    %fonts
    set(0,'DefaultTextFontname', 'CMU Sans Serif');
    set(0,'DefaultAxesFontName', 'CMU Sans Serif');
    set(0,'defaulttextinterpreter','latex');
    
    
    newleg = copyobj(handles.legend_supra,fig);
    set(newleg,'Position',[0.7082 0.1460 0.1786 0.1048]);
    set(gca,'YLim',[handles.ymin handles.ymax]);
    
    set(gca,'Units','Normalized');
    set(gca,'OuterPosition',[0 0 1 1]);
    set(gca,'Position',[0.1300 0.1100 0.7750 0.8150]);
    xtick = get(gca,'XTick');
    newtick = 0:5:handles.projectresults.segments;
    set(gca,'XTick',newtick(newtick >= xtick(1) & newtick <= xtick(end)));
    ylabel('relative zif268 expression','FontName','CMU Sans Serif','FontSize',10)
    xlabel('segments','FontName','CMU Sans Serif','FontSize',10)
    title('supra- and granular layers','FontName','CMU Sans Serif','FontWeight','bold','FontSize',12)
    
    %markup
    set(gca, ...
        'Layer'       , 'top'     ,...
        'Box'         , 'off'     , ...
        'TickDir'     , 'out'     , ...
        'TickLength'  , [.02 .02] , ...
        'XMinorTick'  , 'on'      , ...
        'YMinorTick'  , 'off'      , ...
        'XColor'      , [.3 .3 .3], ...
        'YColor'      , [.3 .3 .3], ...
        'LineWidth'   , 1         );
    
    if(strcmp(handles.highlightgrayband,'on'))
        extra = '_grayband';
    else
        extra = '';
    end
    print(fig,'-dpsc2', '-noui', '-painters', [path '\' listitem '_supra_' strrep(handles.graphtype{:},' ','-') extra '.ps']);
    %saveas(fig,[path '\' listitem '_supra_' strrep(handles.graphtype{:},' ','-') '.fig']);
    
    axes(newax);
    clf;
    newax = copyobj(handles.axes_mouse_infra,fig);
    axes(newax);
   
    set(newax, 'Box','off');
    xlabel('Segments');
    
    newleg = copyobj(handles.legend_infra,fig);
    set(newleg,'Position',[0.7082 0.1460 0.1786 0.1048]);
    set(gca,'YLim',[handles.ymin handles.ymax]);
    
    set(gca,'Units','Normalized');
    set(gca,'OuterPosition',[0 0 1 1]);
    set(gca,'Position',[0.1300 0.1100 0.7750 0.8150]);
    xtick = get(gca,'XTick');
    newtick = 0:5:handles.projectresults.segments;
    set(gca,'XTick',newtick(newtick >= xtick(1) & newtick <= xtick(end)));
    ylabel('relative zif268 expression','FontName','CMU Sans Serif','FontSize',10)
    xlabel('segments','FontName','CMU Sans Serif','FontSize',10)
    title('infragranular layers','FontName','CMU Sans Serif','FontWeight','bold','FontSize',12)
    
    %markup
    set(gca, ...
        'Layer'       , 'top'     ,...
        'Box'         , 'off'     , ...
        'TickDir'     , 'out'     , ...
        'TickLength'  , [.02 .02] , ...
        'XMinorTick'  , 'on'      , ...
        'YMinorTick'  , 'off'      , ...
        'XColor'      , [.3 .3 .3], ...
        'YColor'      , [.3 .3 .3], ...
        'LineWidth'   , 1         );
    
    if(strcmp(handles.highlightgrayband,'on'))
        extra = '_grayband';
    else
        extra = '';
    end
    print(fig,'-dpsc2', '-noui', '-painters', [path '\' listitem '_infra_' strrep(handles.graphtype{:},' ','-') extra '.ps']);
    %saveas(fig,[path '\' listitem '_infra_' strrep(handles.graphtype{:},' ','-') '.fig']);
    close(fig)
    guidata(hObject, handles);
    
function savetable_Callback(hObject, eventdata, handles)
    conditions = get(handles.pop_cond,'String');
    cond = conditions{get(handles.pop_cond,'Value')};
    if(isfield(handles,'savegraphpath'))
        path = handles.savegraphpath;
    else
        path = '';
    end
    path = uigetdir(path,'Save Current Table to this directory');
    handles.savegraphpath = path;

    % Connect to Excel
    Excel = actxserver('excel.application');
    Excel.visible = 1;
    Excel.Workbooks.Add;
    sheets = Excel.ActiveWorkBook.Sheets;
    
    for i=1:size(conditions,1)
        cond = conditions{i};
        supra_data = handles.projectresults.intraconditions.(cond).paireddiff_supra_p;
        supra_diff = handles.projectresults.intraconditions.(cond).difference_supra;
        infra_data = handles.projectresults.intraconditions.(cond).paireddiff_infra_p;
        infra_diff = handles.projectresults.intraconditions.(cond).difference_infra;
        sidak_alpha = handles.projectresults.intraconditions.(cond).sidak_alpha;
    
        sheets.Add([], sheets.Item(sheets.Count));
        sheet1 = get(sheets, 'Item', 2*i-1);
        sheet1.Name = [cond ' - Supra'];
        sheet2 = get(sheets, 'Item', 2*i);
        sheet2.Name = [cond ' - Infra'];
        
        invoke(sheet1,'Activate');
        range = [ExcelCol(1) '1:' ExcelCol(size(supra_data,2)) num2str(size(supra_data,1))];
        Excel.Activesheet.Range(range).Value = supra_data;
        range = [ExcelCol(1) num2str(size(supra_data,1)+3) ':' ExcelCol(size(sidak_alpha,2)) num2str(size(supra_data,1)+3)];
        Excel.Activesheet.Range(range).Value = sidak_alpha;
        colorize_excel_cells(supra_data,supra_diff,Excel,sidak_alpha);
        invoke(sheet2,'Activate');
        range = [ExcelCol(1) '1:' ExcelCol(size(supra_data,2)) num2str(size(supra_data,1))];
        Excel.Activesheet.Range(range).Value = infra_data;
        range = [ExcelCol(1) num2str(size(supra_data,1)+3) ':' ExcelCol(size(sidak_alpha,2)) num2str(size(supra_data,1)+3)];
        Excel.Activesheet.Range(range).Value = sidak_alpha;
        colorize_excel_cells(infra_data,infra_diff,Excel,sidak_alpha);
    
    end
    
    index = size(conditions,1)*2+1;
    sheet1 = get(sheets, 'Item', index);
    invoke(sheet1,'Activate');
    
    interconditions = fieldnames(handles.projectresults.interconditions);
    for i=1:size(interconditions,1)
        supra_data = handles.projectresults.interconditions.(interconditions{i}).unpaireddiff_supra_p;
        supra_diff = handles.projectresults.interconditions.(interconditions{i}).difference_supra;
        infra_data = handles.projectresults.interconditions.(interconditions{i}).unpaireddiff_infra_p;
        infra_diff = handles.projectresults.interconditions.(interconditions{i}).difference_infra;
        sidak_alpha = handles.projectresults.interconditions.(interconditions{i}).sidak_alpha;
        
        range = [ExcelCol(1) num2str(5*i-4)];
        Excel.Activesheet.Range(range).Value = interconditions{i};
        range = [ExcelCol(1) num2str(5*i-3) ':' ExcelCol(size(supra_data,2)) num2str(5*i-3)];
        Excel.Activesheet.Range(range).Value = supra_data;
        range = [ExcelCol(1) num2str(5*i-2) ':' ExcelCol(size(supra_data,2)) num2str(5*i-2)];
        Excel.Activesheet.Range(range).Value = infra_data;
        range = [ExcelCol(1) num2str(5*i-1) ':' ExcelCol(size(sidak_alpha,2)) num2str(5*i-1)];
        Excel.Activesheet.Range(range).Value = sidak_alpha;
        %colorize_excel_cells(supra_data,supra_diff,Excel,sidak_alpha);
    
        
    end
    
    %select first sheet
    sheet1 = get(sheets, 'Item', 1);
    invoke(sheet1,'Activate');
    % Save Workbook
    Excel.ActiveWorkBook.SaveAs([path '\' handles.projectresults.name '-' cond '.xlsx']);
    
    % Close Workbook
    Excel.ActiveWorkBook.Close();
    
    % Quit Excel
    Excel.Quit();
    
function colorize_excel_cells(data,diff,Excel,sidak_alpha)
    for i=1:size(data,1)
        for j=1:size(data,2)
            if(data(i,j) == 0)
                Excel.Activesheet.Range([ExcelCol(j) num2str(i)]).Value = '-';
            elseif(data(i,j) < sidak_alpha(3))
                if(diff(i,j) > 0)
                    Excel.Activesheet.Range([ExcelCol(j) num2str(i)]).Interior.ColorIndex = 3; %red
                else
                    WB.Worksheets.Range([ExcelCol(j) num2str(i)]).Interior.ColorIndex = 5; %blue
                end
            elseif(data(i,j) < sidak_alpha(2))
                if(diff(i,j) > 0)
                    Excel.Activesheet.Range([ExcelCol(j) num2str(i)]).Interior.ColorIndex = 45; %FF9900
                else
                    Excel.Activesheet.Range([ExcelCol(j) num2str(i)]).Interior.ColorIndex = 33; %0033FF
                end
            elseif(data(i,j) < sidak_alpha(1))
                if(diff(i,j) > 0)
                    Excel.Activesheet.Range([ExcelCol(j) num2str(i)]).Interior.ColorIndex = 6; %yellow
                else
                    Excel.Activesheet.Range([ExcelCol(j) num2str(i)]).Interior.ColorIndex = 28; %00FFFF
                end
            else
                Excel.Activesheet.Range([ExcelCol(j) num2str(i)]).Interior.ColorIndex = 2; %white
            end
            
        end
    end
  
function popup_intracond_region_Callback(hObject, eventdata, handles)
    conditions = get(handles.pop_cond,'String');
    cond = conditions{get(handles.pop_cond,'Value')};
    draw_table_intracondition(handles,cond)

function popup_intercond_region_Callback(hObject, eventdata, handles)
    draw_table_intercondition(handles)
    
function pop_graphtype_Callback(hObject, eventdata, handles)
    types = get(hObject,'String');
    type = types(get(hObject,'Value'));
    handles.graphtype = type;
    handles = chooseGraph(handles);
    guidata(hObject,handles);


%-x-x-x- GUI TRASH CALLBACKS -x-x-x-%
function pop_graph_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function menu_Callback(hObject, eventdata, handles)

function properties_Callback(hObject, eventdata, handles)

function menu_exit_Callback(hObject, eventdata, handles)

function pop_cond_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function pop_graphtype_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function popup_intercond_region_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function popup_intracond_region_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popup_intercond_region (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function Untitled_1_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_intracond_heatmap_Callback(hObject, eventdata, handles)
    conditions = get(handles.pop_cond,'String');
    cond = conditions{get(handles.pop_cond,'Value')};
    projectresults = handles.projectresults;
    cm = [0,0,1;0,0.2,1;0,1,1;1,1,1;1,1,0;1,0.6,0;1,0,0];
    cmv = [-3;-2;-1;0;1;2;3];
    
    test = zeros(length(projectresults.intraconditions.(cond).nonparam_matched_supra_h));
    test(find(strcmp(projectresults.intraconditions.(cond).nonparam_matched_supra_h,'***'))) = 3;
    test(find(strcmp(projectresults.intraconditions.(cond).nonparam_matched_supra_h,'**'))) = 2;
    test(find(strcmp(projectresults.intraconditions.(cond).nonparam_matched_supra_h,'*'))) = 1;
    test = test.*projectresults.intraconditions.(cond).nonparam_matched_supra_diff;
    cmtest = sort(unique(test),'descend');
    figure();
    h = subplot(2,1,1);
    imagesc(test);
    colormap(cm(ismember(cmv,cmtest),:));
    axis equal;
    set(h,'PlotBoxAspectRatioMode','auto');
    set(h,'XAxisLocation','top');
    set(h,'XGrid','on');
    set(h,'YGrid','on');
    freezecolors;
    
    test = zeros(length(projectresults.intraconditions.(cond).nonparam_matched_infra_h));
    test(find(strcmp(projectresults.intraconditions.(cond).nonparam_matched_infra_h,'***'))) = 3;
    test(find(strcmp(projectresults.intraconditions.(cond).nonparam_matched_infra_h,'**'))) = 2;
    test(find(strcmp(projectresults.intraconditions.(cond).nonparam_matched_infra_h,'*'))) = 1;
    test = test.*projectresults.intraconditions.(cond).nonparam_matched_infra_diff;
    cmtest = sort(unique(test),'descend');
    h = subplot(2,1,2);
    imagesc(test);
    colormap(cm(ismember(cmv,cmtest),:));
    axis equal;
    set(h,'PlotBoxAspectRatioMode','auto');
    set(h,'XAxisLocation','top');
    set(h,'XGrid','on');
    set(h,'YGrid','on');
    
    
    
    


% --------------------------------------------------------------------
function menu_meanmouse_Callback(hObject, eventdata, handles)
% hObject    handle to menu_meanmouse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    if(strcmp(handles.meanmouse,'on'))
        handles.meanmouse = 'off';
    else
        handles.meanmouse = 'on';
    end
    set(hObject,'Checked',handles.meanmouse);
    guidata(hObject,handles);
    
    


% --------------------------------------------------------------------
function menu_limit_supra_view_Callback(hObject, eventdata, handles)
% hObject    handle to menu_limit_supra_view (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    txt = inputdlg('Limit supra view between: (x:y, NaN to disable)','Limit supra view');
    if(~isempty(txt))
        if(strcmp(txt,'NaN'))
            handles.limitviewsupra = NaN;
            set(hObject,'Checked','off');
            set(hObject,'Label','Limit supra view: off');
        else
            txtsplit = regexp(txt,':','split');
            handles.limitviewsupra = str2num(char(txtsplit{:}))';
            if(handles.limitviewsupra(1) > 0 && handles.limitviewsupra(2) <= handles.projectresults.segments && handles.limitviewsupra(1) < handles.limitviewsupra(2))
                set(hObject,'Checked','on');
                set(hObject,'Label',sprintf('Limit supra view: %d:%d',handles.limitviewsupra(1),handles.limitviewsupra(2)));
            else
                msgbox('Wrong limits');
            end
        end
    end
    guidata(hObject,handles);


% --------------------------------------------------------------------
function menu_limit_infra_view_Callback(hObject, eventdata, handles)
% hObject    handle to menu_limit_infra_view (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    txt = inputdlg('Limit infra view between: (x:y, NaN to disable)','Limit infra view');
    if(~isempty(txt))
        if(strcmp(txt,'NaN'))
            handles.limitviewinfra = NaN;
            set(hObject,'Checked','off');
            set(hObject,'Label','Limit infra view: off');
        else
            txtsplit = regexp(txt,':','split');
            handles.limitviewinfra = str2num(char(txtsplit{:}))';
            if(handles.limitviewinfra(1) > 0 && handles.limitviewinfra(2) <= handles.projectresults.segments && handles.limitviewinfra(1) < handles.limitviewinfra(2))
                set(hObject,'Checked','on');
                set(hObject,'Label',sprintf('Limit infra view: %d:%d',handles.limitviewinfra(1),handles.limitviewinfra(2)));
            else
                msgbox('Wrong limits');
            end
        end
    end
    guidata(hObject,handles);


% --------------------------------------------------------------------
function menu_bw_Callback(hObject, eventdata, handles)
% hObject    handle to menu_bw (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if(strcmp(handles.bw,'off'))
    handles.bw = 'on';
else
    handles.bw = 'off';
end
set(hObject,'Checked',handles.bw);
guidata(hObject,handles);


% --------------------------------------------------------------------
function menu_removeouterarealborders_Callback(hObject, eventdata, handles)
% hObject    handle to menu_removeouterarealborders (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if(strcmp(handles.removeouterarealborders,'off'))
    handles.removeouterarealborders = 'on';
else
    handles.removeouterarealborders = 'off';
end
set(hObject,'Checked',handles.removeouterarealborders);
guidata(hObject,handles);


% --------------------------------------------------------------------
function menu_highlightsupra_Callback(hObject, eventdata, handles)
% hObject    handle to menu_highlightsupra (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    txt = inputdlg('Highlight supra segments between: (x:y, NaN to disable)','Highlight supra segments');
    if(~isempty(txt))
        if(strcmp(txt,'NaN'))
            handles.highlightsupra = NaN;
            set(hObject,'Checked','off');
            set(hObject,'Label','Highlight segments supra: off');
        else
            txtsplit = regexp(txt,':','split');
            handles.highlightsupra = str2num(char(txtsplit{:}))';
            if(handles.highlightsupra(1) > 0 && handles.highlightsupra(2) <= handles.projectresults.segments && handles.highlightsupra(1) < handles.highlightsupra(2))
                set(hObject,'Checked','on');
                set(hObject,'Label',sprintf('Highlight segments supra: %d:%d',handles.highlightsupra(1),handles.highlightsupra(2)));
            else
                msgbox('Wrong limits');
            end
        end
    end
    guidata(hObject,handles);

% --------------------------------------------------------------------
function menu_highlightinfra_Callback(hObject, eventdata, handles)
% hObject    handle to menu_highlightinfra (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    txt = inputdlg('Highlight infra segments between: (x:y, NaN to disable)','Highlight infra segments');
    if(~isempty(txt))
        if(strcmp(txt,'NaN'))
            handles.highlightinfra = NaN;
            set(hObject,'Checked','off');
            set(hObject,'Label','Highlight segments infra: off');
        else
            txtsplit = regexp(txt,':','split');
            handles.highlightinfra = str2num(char(txtsplit{:}))';
            if(handles.highlightinfra(1) > 0 && handles.highlightinfra(2) <= handles.projectresults.segments && handles.highlightinfra(1) < handles.highlightinfra(2))
                set(hObject,'Checked','on');
                set(hObject,'Label',sprintf('Highlight segments infra: %d:%d',handles.highlightinfra(1),handles.highlightinfra(2)));
            else
                msgbox('Wrong limits');
            end
        end
    end
    guidata(hObject,handles);


function menuhighlightgrayband_Callback(hObject, eventdata, handles)
if(strcmp(handles.highlightgrayband,'off'))
    handles.highlightgrayband = 'on';
else
    handles.highlightgrayband = 'off';
end
set(hObject,'Checked',handles.highlightgrayband);
guidata(hObject,handles);