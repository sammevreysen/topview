function [totmax,totmin] = FWERchecker(topview)
    n = 1000;
    totmax = zeros(241,291,1000);
    totmin = zeros(241,291,1000);
    parfor_progress(n);
%     figure();
    parfor a=1:n
        %create random data
        tmp = genArtificalData(topview);
%         subplot(1,4,1);
%         imagesc(tmp.conditions.Control1.topview_total_mean_interpol_smooth);
%         subplot(1,4,2);
%         imagesc(tmp.conditions.Control2.topview_total_mean_interpol_smooth);
        %calc pseudo t-test
        tmp = runPseudoTteststepdown(tmp,'Control1','Control2','total',0,true);
        totmax(:,:,a) = tmp.interconditions.Control1_Control2.Psdmaxtotal;
        totmin(:,:,a) = tmp.interconditions.Control1_Control2.Psdmintotal;
%         subplot(1,4,3);
%         boxplot(tmp.interconditions.Control1_Control2.Psdmintotal(:));
%         subplot(1,4,4);
%         boxplot(tmp.interconditions.Control1_Control2.Psdmaxtotal(:));
        parfor_progress;
    end
    parfor_progress(0);
end

function topview = genArtificalData(topview)
        mice = fieldnames(topview.mice);
        [xi,yi] = meshgrid(1:0.1:30,1:0.1:25);
        [x,y] = meshgrid(1:30,1:25);
        for i=1:length(mice)
            mouse = mice{i};
            topview.mice.(mouse).total = randn(25,30).*20+50; %ones(size(data));
            %     topview.mice.(mouse).total(5:20,5:25) = 20;
            topview.mice.(mouse).totalinterpol_gm = interp2(x,y,topview.mice.(mouse).total,xi,yi);
            topview.mice.(mouse).totalinterpol_gm_smooth = topview.mice.(mouse).totalinterpol_gm;
        end

        conditions = {'Control1';'Control2'};
        for i=1:2
            cond = conditions{i};
            if(i==1)
                list = 1:length(mice)/2;
            else
                list = length(mice)/2+1:length(mice);
            end
            for j=list
                mouse = mice{j};
                topview.conditions.(cond).total(:,:,mod(j-1,length(mice)/2)+1) = topview.mice.(mouse).total;
            end
            topview.conditions.(cond).mice = mice(list);
            topview.conditions.(cond).total_mean = mean(topview.conditions.(cond).total,3);
            topview.conditions.(cond).total_mean_interpol = interp2(x,y,topview.conditions.(cond).total_mean,xi,yi);
            topview.conditions.(cond).topview_total_mean_interpol = topview.conditions.(cond).total_mean_interpol;
            topview.conditions.(cond).topview_total_mean_interpol_smooth = topview.conditions.(cond).total_mean_interpol;
        end
    end