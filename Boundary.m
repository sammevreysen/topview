classdef Boundary
    properties
        x
        y
        segmentx
        segmenty
        areax
        areay
                
    end
    
    methods
        function this = Boundary(fig)
            [this.x,this.y] = draw_curve(fig);
        end
        
    end
    
end