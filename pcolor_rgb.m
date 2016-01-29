function hh = pcolor_rgb(x,y,c)
    hh = surface(x,y,zeros(size(x)),c);
    shading flat;
    axis ij equal tight;