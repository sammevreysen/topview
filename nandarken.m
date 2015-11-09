function im = nandarken(im,nanmap)
    im = mat2im(im,jet(1000));
    im(logical(repmat(nanmap,[1 1 3]))) = im(logical(repmat(nanmap,[1 1 3])))/5*3;