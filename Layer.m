classdef Layer < handle
    properties
        Upperboundary = Boundary.empty;
        Lowerboundary = Boundary.empty;
                
    end
    
    methods
        function this = Layer()
            
        end
        
        function setUpperBoundary(this,boundary)
            this.Upperboundary = boundary;
        end
        
        function setLowerBoundary(this,boundary)
            this.Lowerboundary = boundary;
        end
        
        
    end
    
end
    