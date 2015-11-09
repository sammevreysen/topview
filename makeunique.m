function makeunique(xi,vector)
    windowWidth = int16(5);
    halfWidth = windowWidth / 2;
    gaussFilter = gausswin(5,2.5);
    gaussFilter = gaussFilter / sum(gaussFilter); % Normalize.
    
    % Do the blur.
    smoothedVector = conv(vector, gaussFilter);
    % plot it.
    hold on;
    plot(xi(1+halfWidth:end-halfWidth),smoothedVector(1+halfWidth:end-halfWidth), 'g-'); 