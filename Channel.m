classdef Channel
    properties
        Slice
        Index
        Meanbackground
    end
    
    methods
        function this = Channel(Index,Slice)
            this.Index = Index;
            this.Slice = Slice;
        end
        
        function setBackground(this)
            this.Meanbackground = 1;
        end
    end
end