function backupcode_ISH()

    % Tangent and orthogonal to top border
%     pdiff = polyder(topp);
%     fdiff = polyval(pdiff,areax);
%     forth = -1./fdiff;
% 
%     intersec = zeros(size(forth));
%     distance = zeros(size(forth));
%     intersecbot = zeros(size(forth));
%     for i = 1:size(forth)
%         %y = mx-mx1+y1
%         orthogonal = [forth(i),(polyval(topp,areax(i))-forth(i)*areax(i))];
%         plot(areax(i),polyval(topp,areax(i)),'ro');
%         %intersection orthogonal with supra-infra border and distance between top and supra-infra border
%         pintersec = midp - [0 orthogonal];
%         root = roots(pintersec);
%         intersec(i) = root(2);
%     %     if orthogonal(1) >= 0
%     %         plot(topx(i):intersec(i),polyval(orthogonal,topx(i):intersec(i)),'b-');
%     %     else
%     %         plot(intersec(i):topx(i),polyval(orthogonal,intersec(i):topx(i)),'b-');
%     %     end
%         distance(i) = sqrt((areax(i)-intersec(i))^2+(areay(i)-polyval(orthogonal,intersec(i)))^2);
%         plot(intersec(i),polyval(orthogonal,intersec(i)),'ro');
%     end
%     plot(intersec(1):intersec(end),polyval(midp,intersec(1):intersec(end)),'g-');

%     for i = 1:size(forth)
%         %y = mx-mx1+y1
%         orthogonal = [forth(i),(polyval(topp,areax(i))-forth(i)*areax(i))];
%         %intersection orthogonal with bottom border and distance between supra-infra and bottom border
%         pintersec = botp - [0 orthogonal];
%         root = roots(pintersec);
%         intersecbot(i) = root(2);
%         if orthogonal(1) >= 0
%             plot(areax(i):0.1:intersecbot(i),polyval(orthogonal,areax(i):0.1:intersecbot(i)),'b-');
%         else
%             plot(intersecbot(i):0.1:areax(i),polyval(orthogonal,intersecbot(i):0.1:areax(i)),'b-');
%         end
%         plot(intersecbot(i),polyval(orthogonal,intersecbot(i)),'ro');
%     end
%     plot(intersecbot(1):intersecbot(end),polyval(botp,intersecbot(1):inte
%     rsecbot(end)),'g-');


%*****************************%

%     plot(borders.arealborder(:,1),borders.arealborder(:,2),'rp');
    %approximate with line between first and last point of visual cortex
%     linelength = sqrt((topx(end)-topx(1))^2+(polyval(topp,topx(end))-polyval(topp,topx(1)))^2);
%     linep = polyfit([topx(1) topx(end)],[polyval(topp,topx(1)) polyval(topp,topx(end))],1);
%     a = linep(1); b = linep(2);
% 
%     r = linelength / rastervalues.segments;
%     %supra variables
%     s = topx(1);t = polyval(linep,s);
%     u = intersec(1); v = polyval(midp,intersec(1));
%     %infra variables
%     k = intersec(1); l = polyval(midp, intersec(1));
%     m = intersecbot(1); n = polyval(botp,intersecbot(1));
% 
%     raster = zeros(1,rastervalues.segments);
%     for i=1:rastervalues.segments
%         %segment supragranular layer
%         newx = (sqrt(-t^2+(2*a*s+2*b)*t-a^2*s^2-2*a*b*s+(a^2+1)*r^2-b^2)+a*t+s-a*b)/(a^2+1);
%         raster(i) = newx;
%         %calculate orthogonal and intersection with infra-supra border
%         rasterricoorth = -1./polyval(polyder(topp),newx);
%         rasterorth = [rasterricoorth,(polyval(topp,newx)-rasterricoorth*newx)];
% 
%         %intersection orthogonal with supra-infra border
%         pintersec = midp - [0 rasterorth];
%         root = roots(pintersec);
%         xintersec = root(2);
%         segmentmask = roipoly(img,[s u xintersec newx],[polyval(topp,s) v polyval(rasterorth,xintersec) polyval(rasterorth,newx)]);
%         %calculate mean grayvalue of segment
%         rastervalues.meansupra_raw(i) = mean(mean(img(segmentmask)));
% 
%         %segment infragranular layer    
%         %intersection orthogonal with supra-infra border
%         pintersec = botp - [0 rasterorth];
%         root = roots(pintersec);
%         xintersecbot = root(2);
% %         if rasterorth(1) >= 0
% %             plot(newx:xintersecbot,polyval(rasterorth,newx:xintersecbot),'r-');
% %         else
% %             plot(xintersecbot:newx,polyval(rasterorth,xintersecbot:newx),'r-');
% %         end
%         segmentmask = roipoly(img,[u m xintersecbot xintersec],[v n polyval(rasterorth,xintersecbot) polyval(rasterorth,xintersec)]);
%         %calculate mean grayvalue of segment
%         rastervalues.meaninfra_raw(i) = mean(mean(img(segmentmask)));
% 
%         %store new points in variables
%         s = newx; t = polyval(linep,newx);
%         u = xintersec; v = polyval(midp,xintersec);
%         m = xintersecbot; n = polyval(botp,xintersecbot);
%     end
%     %close(rasterfig);