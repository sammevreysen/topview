handles.topview.conditions.(handles.topview.conditionnames{iii}).supra = nan(size(bregmalist,1),size(segmentlist,2),size(micelist,1));
handles.topview.conditions.(handles.topview.conditionnames{iii}).infra = nan(size(bregmalist,1),size(segmentlist,2),size(micelist,1));
handles.topview.conditions.(handles.topview.conditionnames{iii}).arearelsupra = nan(size(bregmalist,1),handles.arealborders,size(micelist,1));
handles.topview.conditions.(handles.topview.conditionnames{iii}).arearelinfra = nan(size(bregmalist,1),handles.arealborders,size(micelist,1));
%normalize to selected mouse
for jjj = 1:size(micelist,1)
    if(~strcmp(handles.topview.normalizeto,'None'))
        handles.topview.conditions.(handles.topview.conditionnames{iii}).supra(ismember(bregmalist,handles.topview.mice.(micelist{jjj}).bregmas),:,jjj) = handles.topview.mice.(micelist{jjj}).supra.*handles.topview.mice.(micelist{jjj}).normalizefactor_supra;
        handles.topview.conditions.(handles.topview.conditionnames{iii}).infra(find(handles.topview.mice.(micelist{jjj}).bregmasinterpol(1)==bregmainterpollist):find(handles.topview.mice.(micelist{jjj}).bregmasinterpol(end)==bregmainterpollist),:,jjj) = handles.topview.mice.(micelist{jjj}).infrainterpol.*handles.topview.mice.(micelist{jjj}).normalizefactor_infra;
    else
        handles.topview.conditions.(handles.topview.conditionnames{iii}).suprainterpol(find(handles.topview.mice.(micelist{jjj}).bregmasinterpol(1)==bregmainterpollist):find(handles.topview.mice.(micelist{jjj}).bregmasinterpol(end)==bregmainterpollist),:,jjj) = handles.topview.mice.(micelist{jjj}).suprainterpol;
        handles.topview.conditions.(handles.topview.conditionnames{iii}).infrainterpol(find(handles.topview.mice.(micelist{jjj}).bregmasinterpol(1)==bregmainterpollist):find(handles.topview.mice.(micelist{jjj}).bregmasinterpol(end)==bregmainterpollist),:,jjj) = handles.topview.mice.(micelist{jjj}).infrainterpol;
    end
    handles.topview.conditions.(handles.topview.conditionnames{iii}).arearelsupra(find(handles.topview.mice.(micelist{jjj}).bregmasinterpol(1)==bregmainterpollist):find(handles.topview.mice.(micelist{jjj}).bregmasinterpol(end)==bregmainterpollist),:,jjj) = handles.topview.mice.(micelist{jjj}).arearelsuprainterpol;
    handles.topview.conditions.(handles.topview.conditionnames{iii}).arearelinfra(find(handles.topview.mice.(micelist{jjj}).bregmasinterpol(1)==bregmainterpollist):find(handles.topview.mice.(micelist{jjj}).bregmasinterpol(end)==bregmainterpollist),:,jjj) = handles.topview.mice.(micelist{jjj}).arearelinfrainterpol;
    
end


%for all permuations
handles.topview.conditions.(handles.topview.conditionnames{iii}).supra_mean = nanmean(handles.topview.conditions.(handles.topview.conditionnames{iii}).supra,3);

[xx yy] = meshgrid(segmentlist,bregmalist);
[xxi yyi] = meshgrid(1:0.1:size(xx,2),yy(1):1:yy(end));
handles.topview.conditions.(handles.topview.conditionnames{iii}).supra_mean_interpol = interp2(xx,yy,handles.topview.conditions.(handles.topview.conditionnames{iii}).supra_mean,xxi,yyi,'linear');