function smt = smoothfct(topview,tmp)
    if(topview.smoothwindow == 0)
        smt = tmp;
    else
        K = @(sig,x,y) exp(-(x.^2+y.^2)/2/sig^2);
        winpx = topview.smoothwindow/(topview.gridsize/10); %grid size is 100µm, interpolated grid size is 10µm, so divide by 10 (bad work around, I know)
        [dx,dy] = meshgrid(-winpx:winpx,-winpx:winpx);
        sig = winpx/(2*sqrt(2*log(2)));
        weight=K(sig,dx,dy)/sum(sum(K(sig,dx,dy)));
        smt = nanconv(tmp,weight,'noedge','nanout');
    end
end