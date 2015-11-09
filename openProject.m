function out = openProject(projectname,varargin)
    staticprojectpath = 'saved_project';
    if(exist([staticprojectpath filesep projectname]) == 7)
        metadata = load([staticprojectpath filesep projectname filesep 'metadata.mat']);
        metadata = metadata.metadata;
        out.metadata = metadata;
        if(nargin > 1 & ischar(varargin{1}))
            tmp = load([staticprojectpath filesep projectname filesep varargin{1} '.mat']);
            out.(varargin{1}) = tmp.(varargin{1});
        else
            for i=1:size(metadata.files,1)
                tmp = load([staticprojectpath filesep projectname filesep metadata.files{i,1} '.mat']);
                out.(metadata.files{i,1}) = tmp.(metadata.files{i,1});
            end
        end
    else
        warndlg(sprintf('Project %s doesn''t exist',projectname));
    end