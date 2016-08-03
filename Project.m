classdef Project < handle
    properties
        Name
        Areas
        NoSegments
        noLayers
        Conditions = [];
        Signal = 1; %0 black, 1 white
    end
    
    properties (Dependent)
        Arealborders        
    end
       
    methods
        function obj = Project(Name,Areas,NoLayers,NoSegments)
            obj.Name = Name;
            if(~iscell(Areas))
                Areas = {Areas};
            end
            obj.Areas = Areas;
            obj.NoLayers = NoLayers;
            obj.NoSegments = NoSegments;
        end
        
        function Arealborders = get.Arealborders(obj)
            Arealborders = length(obj.Areas)+1;
        end
        
        function names = getConditionNames(this)
            names = {};
            for i=1:length(this.Conditions)
                names{i} = this.Conditions(i).Name;
            end
        end
        
        function setSignal(this,signal)
            this.Signal = signal;
        end
        
        function addCondition(this,name)
            if(~isempty(name))
                if(size(regexp(name,'^[0-9]+|[^a-zA-Z0-9_]+|(_vs_)','match'),1) > 0)
                    errordlg('Name contains characters that are not allowed!');
                    return;
                elseif(any(ismember(getConditionNames(this),name)))
                    errordlg('This name is already in use.');
                    return;
                end
            end
            this.Conditions = [this.Conditions; Condition(name,this)];
        end
            
    end
end