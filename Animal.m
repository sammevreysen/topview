classdef Animal < handle
    properties
        Name
        Condition
        Slices = [];
    end
           
    methods
        function this = Animal(Name,Condition)
            this.Name = Name;
            this.Condition = Condition;
        end
        
        function addSlice(this,filename)
            this.Slices = [this.Slices; Slice(filename,this)];
        end
            
    end
end