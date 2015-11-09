function plotCircle(xcenter,ycenter,radius,ls)
    theta = 0:0.01:2*pi;
    x = radius * cos(theta) + xcenter;
    y = radius * sin(theta) + ycenter;
    plot(x,y,ls);