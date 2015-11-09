function saveFigAsPDF(varargin)

if(nargin == 0 || (nargin == 3 && ishandle(varargin{3})))
    outerpos = [0 0 26 20];
    set(gcf,'PaperType','A4');
    set(gcf,'PaperOrientation','landscape');
    set(gcf,'PaperUnits','centimeters');
    set(gcf,'PaperPositionMode','auto');
else
    if(nargin >=3 & ishandle(varargin{3}))
        outerpos = [0 0 varargin{4} varargin{5}];
    else
        outerpos = [0 0 varargin{1} varargin{2}];
    end
    set(gcf,'PaperUnits','centimeters');
    set(gcf,'PaperSize',[varargin{2} varargin{1}]);
    set(gcf,'PaperPositionMode','auto');
%     set(gca,'FontSize',15);
%     set(get(gca,'XLabel'),'FontSize',varargin{3});
%     set(get(gca,'YLabel'),'FontSize',varargin{3});
end
% set(gcf,'Color',[1 1 1]);
if(nargin > 2)
    if(ishandle(varargin{3}))
        handles = guidata(varargin{3});
        pdffolder = handles.pdfsavefolder;
    end
else
    pdffolder = 'C:\CloudStation\Data\CurrentMouse\pdf\';
end
[savename pdffolder] = uiputfile('*.pdf','Save As...',pdffolder);

set(gcf,'WindowStyle','normal');
set(gcf,'Units','centimeters');
set(gcf,'OuterPosition',outerpos);

if(nargin > 2)
    if(ishandle(varargin{3}) && ~strcmp(handles.pdfsavefolder,pdffolder))
        handles.pdfsavefolder = pdffolder;
        guidata(varargin{3},handles);
    end
end
if(savename)
    print(gcf,'-dpdf','-r300',[pdffolder savename]); %-dpdf
%     saveas(gcf,[pdffolder savename(1:end-3) 'fig'],'fig');
end