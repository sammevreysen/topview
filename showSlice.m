function hfigselslice = showSlice(setuptablerow,varargin)
    if(nargin > 1)
        hfigselslice = varargin{1};
        if(~ishandle(hfigselslice))
            hfigselslice = figure();
        end
    else
        hfigselslice = figure();
    end
    if(isfield(setuptablerow{6},'pivot'))
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
        if(ishandle(hfigselslice))
            hfigselslice = figure(hfigselslice);
        else
            hfigselslice = figure();
        end
        img = imread([setuptablerow{4} setuptablerow{3}]);
        imshow(img);
        set(gcf,'Name',(sprintf('%s - %s - %s',setuptablerow{1},setuptablerow{2},setuptablerow{3})));
        hold on;
        plot([topcox'; midtcox'],[topcoy'; midtcoy'],'b-');
        plot([midbcox'; botcox'],[midbcoy'; botcoy'],'c-');
        plot(setuptablerow{5}.topareaxy(:,1),setuptablerow{5}.topareaxy(:,2),'ro');
        plot(setuptablerow{5}.midareaxy(:,1),setuptablerow{5}.midareaxy(:,2),'ro');
        plot(setuptablerow{5}.botareaxy(:,1),setuptablerow{5}.botareaxy(:,2),'ro');
        if(isfield(setuptablerow{5},'meanbgcoordinates'))
            plot(setuptablerow{5}.meanbgcoordinates([1 2 2 1 1],1),setuptablerow{5}.meanbgcoordinates([1 1 2 2 1],2),'g-');
        end
        hold off;
    else
        hfigselslice = figure(hfigselslice);
        img = imread([setuptablerow{4} setuptablerow{3}]);
        imshow(img);
        hold on;
        plot(setuptablerow{5}.topx(1:100:end),setuptablerow{5}.topy(1:100:end),'b-');
        plot(setuptablerow{5}.midx(1:100:end),setuptablerow{5}.midy(1:100:end),'b-');
        plot(setuptablerow{5}.botx(1:100:end),setuptablerow{5}.boty(1:100:end),'b-');
        plot(setuptablerow{5}.topareaxy(:,1),setuptablerow{5}.topareaxy(:,2),'ro');
        plot(setuptablerow{5}.midareaxy(:,1),setuptablerow{5}.midareaxy(:,2),'ro');
        plot(setuptablerow{5}.botareaxy(:,1),setuptablerow{5}.botareaxy(:,2),'ro');
        plot(setuptablerow{5}.meanbgcoordinates([1 2 2 1 1],1),setuptablerow{5}.meanbgcoordinates([1 1 2 2 1],2),'g-');
        if(isfield(setuptablerow{6},'topcoxy'))
            plot([setuptablerow{6}.topcoxy(:,1)'; setuptablerow{6}.midcoxy(:,1)'],[setuptablerow{6}.topcoxy(:,2)'; setuptablerow{6}.midcoxy(:,2)'],'b-');
            plot([setuptablerow{6}.midcoxy(:,1)'; setuptablerow{6}.botcoxy(:,1)'],[setuptablerow{6}.midcoxy(:,2)'; setuptablerow{6}.botcoxy(:,2)'],'c-');
        end
        hold off;
    end
    if(isfield(setuptablerow{5},'midlinep'))
        hold on;
        yl = ylim;
        p = setuptablerow{5}.midlinep;
        plot(polyval([1/p(1) -p(2)/p(1)],yl(1):0.1:yl(2)),yl(1):0.1:yl(2),'g-');
        hold off;
    end