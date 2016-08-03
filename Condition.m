classdef Condition < handle
    properties
        Name
        Project
        Animals = [];
    end
           
    methods
        function this = Condition(Name,Project)
            this.Name = Name;
            this.Project = Project;
        end
        
        function addAnimal(this,name)
            if(~isempty(name))
                if(size(regexp(name,'^[0-9]+|[^a-zA-Z0-9_]+|(_vs_)','match'),1) > 0)
                    errordlg('Name contains characters that are not allowed!');
                    return;
                elseif(any(ismember(this.Animals,name)))
                    errordlg('This name is already in use.');
                    return;
                end
            end
            this.Animals = [this.Animals; Animal(name,this)];
        end
            
    end
end