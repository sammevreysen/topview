function im = nan2white(im)
    im(isnan(im)) = 1;