function enlargesubplot(hObject,callbackdata)
    maxposition = [0.05 0.05 0.9 0.85];
    plottitle = get(get(gca,'Title'),'String');
    cmapname = get(gca,'Tag');
    if(strcmp(cmapname,''))
        cmapname = 'jet';
    end
    if(exist(cmapname)==0)
        cmap = load(cmapname);
        cmap = cmap.(cmapname);
    else
        eval('cmap = cmapname;');
    end
    tempAxes = copyobj(gca,gcf);

    h = figure('Resize','on',...
        'IntegerHandle','off',...
        'NumberTitle','off',...
        'Name',plottitle,...
        'Interruptible','off',...
        'BackingStore','off',...
        'Color',get(0,'DefaultUIControlBackgroundColor'));
    set(tempAxes,'Position', maxposition,'Parent',h);
    colormap(cmap);
    title(plottitle);
    
end