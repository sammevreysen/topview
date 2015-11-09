function [newprojection newp] = smoothProjection(projection,coxy,p)
%     figure();
%     plot(projection,repmat((1:size(projection,1))',1,size(projection,2)),'ko');
%     hold on;
    smoothl1 = smoothLine(projection(:,1),5);
    smoothl2 = smoothLine(projection(:,end),5);
%     plot(projection(:,1),1:size(projection,1),'k-');
%     plot(projection(:,end),1:size(projection,1),'k-');
%     plot(smoothl1,1:size(projection,1),'k-','LineWidth',2)
%     plot(smoothl2,1:size(projection,1),'k-','LineWidth',2)
    newprojection = nan(size(projection));
    newp = nan(size(p));
    dist = abs(smoothl1 - smoothl2);
%     figure();
    for i=1:size(smoothl1,1)
%         axis ij;
%           axis equal;
%         hold on;
%         plot(squeeze(coxy(i,:,1)),squeeze(coxy(i,:,2)),'ko-');
        P = reshape(coxy(i,1,:),1,2);
%         plot(P(1),P(2),'ro');
        O = reshape(coxy(i,end,:),1,2);
%         plot(O(1),O(2),'go');
        PN = dist(i);
        NQ = abs(smoothl2(i));
        PQ = abs(smoothl1(i));
        if(NQ > PQ)
            tmp = NQ;
            NQ = PQ;
            PQ = tmp;
            tmp = P;
            P = O;
            O = tmp;
        end
        PO = sqrt(sum(diff([P;O],1).^2));
        ON = sqrt(PO^2-PN^2);
        if(isreal(ON) && ~isnan(ON))
%             plotCircle(P(1),P(2),PN,'r-');
%             plotCircle(O(1),O(2),ON,'g-');
            %2 possible points N at PN from P and at ON from O
            [Nx Ny] = circcirc(P(1),P(2),PN,O(1),O(2),ON);
%             plot(Nx,Ny,'bo');
            %new midline slope based on polynom of orthogonal PN
            ONm = (Nx-P(1))./(P(2)-Ny);
            %decide which point is most likely by selecting new midline that
            %has the smallest angle with the original midline
            ONangle = atan(abs((ONm-p(i,1))./(1+ONm.*p(i,1))))*180/pi;
            ONm = ONm(ONangle == min(ONangle));
            N = [Nx(ONangle == min(ONangle)) Ny(ONangle == min(ONangle))];
            %polynom PN
            PNm = (P(2)-N(2))/(P(1)-N(1));
            PNc = -PNm.*N(1)+N(2);
            %calculate Q
%             plotCircle(P(1),P(2),PQ,'c-');
%             plotCircle(N(1),N(2),NQ,'c-');
            [Qx Qy] = circcirc(P(1),P(2),PQ,N(1),N(2),NQ);
            %use other method if this fails
            if(isnan(Qx))
                [Qx Qy] = linecirc(PNm,PNc,N(1),N(2),NQ);
                newPQ = sqrt(sum(([Qx' Qy'] - [P;P]).^2,2));
                Q = [Qx(newPQ > PN) Qy(newPQ > PN)];
            else
                Q = [Qx(1) Qy(1)];
            end
%             plot(Q(1),Q(2),'md');
%             plot([P(1);Q(1)],[P(2);Q(2)],'m-');
            %calculate new midline through Q
            newp(i,:) = [ONm -ONm.*Q(1)+Q(2)];
            %calculate new projection values
            newprojection(i,:) = real(projectToTopview(reshape(coxy(i,:,:),[],2),newp(i,:)));
        else
            newp(i,:) = [NaN NaN];
            newprojection(i,:) = nan(1,size(projection,2));
        end
        
    end
%     plot(newprojection,repmat(((1:size(projection,1)))',1,size(projection,2)),'bx');
    
    %interpolate NaN values
    if(any(isnan(newprojection)))
        newprojection = inpaint_nans(newprojection,3);
%         plot(newprojection,repmat(((1:size(projection,1)))',1,size(projection,2)),'gs');
    end
    
    
    