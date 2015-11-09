function imrgb = nanimage(im)
    imrgb = mat2im(im,jet(1000));
    imrgb(isnan(im),:) = [1 1 1];