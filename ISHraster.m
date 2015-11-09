function ISHraster()
    [filename path] = uigetfile('saved_analysis/*.mat','Select setup file');
    if(~isnumeric(filename))
        temp = load([path filename],'setuptable');
        setuptable = temp.setuptable;
        fprintf('Setup %s loaded.',filename);     
        disp(setuptable(:,3));
        sel = input('Select slice to show: ','s');
        fprintf('\nShowing slice %s',sel);
        rasterize(setuptable,str2double(sel));
       
    end
    
    function test(obj,eventdata,var)
        disp(var);
    
    function rasterize(setuptable,selected)
        fig = figure();
        tablesetuprow = setuptable(selected,:);
        segments = tablesetuprow{1,6}.segments;

        img = imread([char(tablesetuprow(4)) char(tablesetuprow(3))]);
        imshow(img);
        hold on;
        borders = tablesetuprow{1,5};
        topx = borders.arealborder(:,1);
        topp = borders.topp;
        midp = borders.midp;
        botp = borders.botp;
        intersec = borders.intersec;
        intersecbot = borders.intersecbot;
        
        plot(topx(1):0.1:topx(end),polyval(topp,topx(1):0.1:topx(end)),'g-',topx,polyval(topp,topx),'bo');
        plot(intersec(1):0.1:intersec(end),polyval(midp,intersec(1):0.1:intersec(end)),'g-',intersec,polyval(midp,intersec),'bo');
        plot(intersecbot(1):0.1:intersecbot(end),polyval(botp,intersecbot(1):0.1:intersecbot(end)),'g-',intersecbot,polyval(botp,intersecbot),'bo');
        for i=1:size(topx,1)
            orth = polyfit([topx(i) intersecbot(i)],[polyval(topp,topx(i)) polyval(botp,intersecbot(i))],1);
            plot(topx(i):0.1:intersecbot(i),polyval(orth,topx(i):0.1:intersecbot(i)),'b:');
        end
        
        %place rectangle window between top and supra-infra border and set mask
        %length arc top border
        %arclength = quad(@(x) (sqrt(1+(2*topp(1)*x+topp(2)).^2)),topx(1),topx(end));
        %approximate with line between first and last point of visual cortex
        linelength = sqrt((topx(end)-topx(1))^2+(polyval(topp,topx(end))-polyval(topp,topx(1)))^2);
        linep = polyfit([topx(1) topx(end)],[polyval(topp,topx(1)) polyval(topp,topx(end))],1);
        a = linep(1); b = linep(2);
        
        r = linelength / segments;
        %supra variables
        s = topx(1);t = polyval(linep,s);
        u = intersec(1); v = polyval(midp,intersec(1));
        %infra variables
        k = intersec(1); l = polyval(midp, intersec(1));
        m = intersecbot(1); n = polyval(botp,intersecbot(1));
        
        raster = zeros(1,segments);
        for i=1:segments
            %segment supragranular layer
            newx = (sqrt(-t^2+(2*a*s+2*b)*t-a^2*s^2-2*a*b*s+(a^2+1)*r^2-b^2)+a*t+s-a*b)/(a^2+1);
            raster(i) = newx;
            %calculate orthogonal and intersection with infra-supra border
            rasterricoorth = -1./polyval(polyder(topp),newx);
            rasterorth = [rasterricoorth,(polyval(topp,newx)-rasterricoorth*newx)];
            
            %intersection orthogonal with supra-infra border
            pintersec = midp - [0 rasterorth];
            root = roots(pintersec);
            xintersec = root(2);
%             plot([s u xintersec newx s],[polyval(topp,s) v polyval(rasterorth,xintersec) polyval(rasterorth,newx) polyval(topp,s)],'r-');
            
            pintersec = botp - [0 rasterorth];
            root = roots(pintersec);
            xintersecbot = root(2);
            % plot([u m xintersecbot xintersec u],[v n polyval(rasterorth,xintersecbot) polyval(rasterorth,xintersec) v],'r-');
            
            if rasterorth(1) >= 0
                plot(newx:xintersecbot,polyval(rasterorth,newx:xintersecbot),'r-');
            else
                plot(xintersecbot:newx,polyval(rasterorth,xintersecbot:newx),'r-');
            end
            
            text(xintersecbot-50,polyval(rasterorth,xintersecbot)+85,sprintf('%d',i),'FontSize',8);
            
            %store new points in variables
            s = newx; t = polyval(linep,newx);
            u = xintersec; v = polyval(midp,xintersec);
            m = xintersecbot; n = polyval(botp,xintersecbot);
        end