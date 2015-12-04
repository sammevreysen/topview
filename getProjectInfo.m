function getProjectInfo(varargin)
    % Gathers information about the project and prints it out
    % input: filename, projectname or setuptable
    
    switch class(varargin{1})
        case 'char'
            if(exist(varargin{1},'file') == 2)
                setuptable = load(varargin{1});
                [folder,name,~] = fileparts(varargin{1});
            else
                files = openProject(varargin{1});
                setuptable = files.setuptable;
                name = varargin{1};
                folder = ''; %TODO
            end
        case 'cell'
            setuptable = varargin{1};
            name = '';
            folder = '';
        otherwise
            error('Incorrect input.');
    end
    
    fprintf('==== Project Information ====\n');
    fprintf('Name: %s\nFolder: %s\n\n',name,folder);
    fprintf('No of slices: %d\nNo of conditions: %d\nNo of Mice: %d\n\n',size(setuptable,1),size(unique(setuptable(:,1)),1),size(unique(setuptable(:,2)),1));
    fprintf('Midline registered: %d/%d\n\n',sum(cellfun(@(x) isfield(x,'midlinep'),setuptable(:,5))), size(setuptable,1));