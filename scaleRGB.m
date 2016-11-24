function output = scaleRGB(input)
    for i=1:size(input,3)
        tmp = input(:,:,i)-min(min(input(:,:,i)));
        tmp = tmp/max(max(tmp));
        output(:,:,i) = tmp;
    end