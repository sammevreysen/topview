function handles = saveProject(handles,varargin)
    if(nargin > 1)
        savelist = varargin{1};
        saveall = 0;
    else
        saveall = 1;
        savelist = [];
    end
    savedate = clock;
    staticsavepath = 'saved_project';
    fprintf('\nSaving... ');
    tic;
    if(isfield(handles,'projectname'))
        projectname = handles.projectname;
        projectfolder = [staticsavepath filesep projectname filesep];
        if(exist(projectfolder,'dir'))
            metadata = load([projectfolder 'metadata.mat']);
            metadata = metadata.metadata;
        else
            mkdir([staticsavepath filesep projectname]);
            saveall = 1;
            metadata.projectname = projectname;
            metadata.files = {};
        end
    elseif(exist(handles.savepath) == 2)
        [path projectname ~] = fileparts(handles.savepath);
        if(exist([staticsavepath filesep projectname]) == 7 && saveall)
            answ = questdlg('This project already exists. Do you want to override this project with the current project file (old system)?','Warning','Overwrite','Rename');
            switch(answ)
                case 'Overwrite'
                    rmdir([staticsavepath filesep projectname],'s');
                case 'Rename'
                    projectname = inputdlg('Save project as...');
            end
            mkdir([staticsavepath filesep projectname]);
            saveall = 1;
            metadata.projectname = projectname;
            metadata.files = {};
        end
       
    elseif(exist(handles.savepath) == 7 && isfield(handles,'savename'))
        projectname =  handles.savename;
        metadata = load([staticsavepath filesep projectname filesep 'metadata.mat']);
        metadata = metadata.metadata;
    end
    
    files = [];
    if(isfield(handles,'setuptable') & (ismember('setuptable',savelist) | saveall))
        setuptable = handles.setuptable;
        metadata = updateSavedate(metadata,'setuptable',savedate);
        save([staticsavepath filesep projectname filesep 'setuptable'],'setuptable');
        copyfile([pwd filesep staticsavepath filesep projectname filesep 'setuptable.mat'],[pwd filesep 'saved_analysis' filesep projectname '.mat']);
    end
    if(isfield(handles,'topview') & (ismember('topview',savelist) | saveall))
        topview = handles.topview;
        metadata = updateSavedate(metadata,'topview',savedate);
        save([staticsavepath filesep projectname filesep 'topview'],'topview');
    end
    if(isfield(handles,'ROI') & (ismember('ROI',savelist) | saveall))
        ROI = handles.ROI;
        metadata = updateSavedate(metadata,'ROI',savedate);
        save([staticsavepath filesep projectname filesep 'ROI'],'ROI');
    end
    %save metadata
    save([staticsavepath filesep projectname filesep 'metadata'],'metadata');
    lapse = toc;
    fprintf('saved in %0.3f seconds.\n',lapse);
    
    handles.projectname = projectname;
    handles.savedate = savedate;
    
function metadata = updateSavedate(metadata,file,savedate)
    if(~isempty(metadata.files) & any(ismember(metadata.files(:,1),file)))
        metadata.files{ismember(metadata.files(:,1),file),2} = savedate;
    else
        metadata.files = [metadata.files; {file} savedate];
    end
       