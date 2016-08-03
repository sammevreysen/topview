classdef Slice < handle
    properties
        Filename
        Animal
        Channels
        Layers
        Bregma
        SegmentationStatus = false;
    end
    
    properties (SetAccess = private)
       fig 
    end
    methods
        function this = Slice(filename,animal)
            this.Animal = animal;
            this.Filename = filename;
            for i=1:this.Animal.Condition.Project.noLayers
                this.Layers = [this.Layers; Layer()];
            end
            
        end
        
        function Channels = get.Channels(obj)
            Channels = size(imread(obj.Filename),3);
        end
        
        function setBorders(this)
            this.showSlice();
            for i=1:this.Animal.Condition.Project.noLayers+1
                boundary = Boundary(this.fig);
                if(i<=this.Animal.Condition.Project.noLayers)
                    this.Layers(i).setUpperBoundary(boundary);
                end
                if(i>1)
                    this.Layers(i-1).setLowerBoundary(boundary);
                end
                
            end
        end
        
        function showSlice(this)
            if(ishandle(this.fig))
                figure(this.fig);
            else
                this.fig = figure();
            end
            I = imread(this.Filename);
            imshow(I(:,:,1));
            [~,name,~] = fileparts(this.Filename);
            set(this.fig,'Name',name);            
        end
    end
end