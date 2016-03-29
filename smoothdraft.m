smoothVar = 0.72; %0.1

% for i=1:15,
%     for j=1:15,
%         filterSmooth(i,j) = exp(-0.5*[i-8 j-8]*inv(smoothVar*eye(2))*[i-8 j-8]');
%     end;
% end;

% sigCon = (randn(nrVox(1),nrVox(2)));
% conv2(sigCon,filterSmooth,'shape')

K = @(sig,x,y) exp(-(x.^2+y.^2)/2/sig^2);

window = [0.1 0.15 0.2 0.25]; %200 µm
delta = 0.01; %grid step



figure();
for i=1:length(window)
    winpx = window(i)/delta;
    [dx,dy] = meshgrid(-winpx:winpx,-winpx:winpx);
    sig = winpx/(2*sqrt(2*log(2)));
    weight=K(sig,dx,dy)/sum(sum(K(sig,dx,dy)));
    datasmooth = nanconv(data,weight,'noedge','nanout');
    
    subplot(length(window),3,3*(i-1)+1);
    imagesc(data);
    axis equal tight;
    ylabel([num2str(window(i)) ' mm']);
    colormap jet;
    subplot(length(window),3,3*(i-1)+2);
    imagesc(weight);
    axis equal tight;
    ylim([1 size(data,2)]);
    xlim([1 size(data,1)]);
    colormap jet;
    subplot(length(window),3,3*(i-1)+3);
    imagesc(datasmooth);
    axis equal tight;
    colormap jet;
end