function relborders = relativearealborders_polynom(p,xa,xb,arealborders,rastersegments)
    totlen = arclength(p(1),p(2),p(3),xa,xb);
    relborders = zeros(1,size(arealborders,1));
    for i=1:size(arealborders,1)
        relborders(i) = arclength(p(1),p(2),p(3),xa,arealborders(i))/totlen*rastersegments + 0.5;
    end
