function exportToExcel(projectresults,filename)

    %reorder vars
    
    %Information tab
    conds = fieldnames(projectresults.conditions);
    info{1,1} = 'Project';
    info{1,2} = projectresults.name; 
    info{2,1} = 'Amount of slices'; 
         %; 'Conditions ' ];
    info{2,2} =  projectresults.amountslices;
    info{3,1} = 'Amount of segments';
    info{3,2} = projectresults.segments;
    info{4,1} = 'Areas';
    info{4,2} =  projectresults.areas;
    info{5,1} = 'Conditions';
    info{6,1} = 'Mice';
    for i=1:length(conds)
        info{5,1+i} =  conds{i};
        mice = projectresults.conditions.(conds{i}).mice;
        for j=1:length(mice)
            info{6+j-1,1+i} = mice{j};
        end
    end
    info{end+1,1} = 'Regions';
    dim = size(info);
    regions = fieldnames(projectresults.regions);
    for i=1:size(regions,1)
        info{dim(1)+i,1} = regions{i};
        regio = projectresults.regions.(regions{i});
        for j=1:size(regio,2)
            info{dim(1)+i,1+j} = regio{j};
        end
    end
    dim = size(info);
    info{dim(1)+1,1} = 'Relative areal borders';
    info{dim(1)+2,1} = 'Top border';
    info{dim(1)+3,1} = 'Bottom border';
    toparearel = mean(projectresults.alltoparearel,1);
    botarearel = mean(projectresults.allbotarearel,1);
    info(dim(1)+2,1+(1:size(toparearel,2))) = num2cell(toparearel);
    info(dim(1)+3,1+(1:size(botarearel,2))) = num2cell(botarearel);
    
    mice = fieldnames(projectresults.mice);
       
    %mice tab
    dim = [-1,0];
    for i=1:length(mice)
        mouse = projectresults.mice.(mice{i});
        regions = fieldnames(mouse.regions);
        micetab{dim(1)+2,1} = mice{i};
        %segments
        micetab{dim(1)+3,1} = 'Supra Segments';
        micetab(dim(1)+3,1+(1:size(mouse.slicesxsegments_supra,2))) = num2cell(1:size(mouse.slicesxsegments_supra,2));
        micetab(dim(1)+3+(1:size(mouse.slicesxsegments_supra,1)),1+(1:size(mouse.slicesxsegments_supra,2))) = num2cell(mouse.slicesxsegments_supra);
        
        tempdim = size(micetab);
        micetab{tempdim(1)+1,1} = 'Mean';
        micetab(tempdim(1)+1,2:2+size(mouse.slicesxsegments_supra_mean,2)-1) = num2cell(mouse.slicesxsegments_supra_mean);
        micetab{tempdim(1)+2,1} = 'Std';
        micetab(tempdim(1)+2,2:2+size(mouse.slicesxsegments_supra_std,2)-1) = num2cell(mouse.slicesxsegments_supra_std);
        micetab{tempdim(1)+3,1} = 'Ste';
        micetab(tempdim(1)+3,2:2+size(mouse.slicesxsegments_supra_sterr,2)-1) = num2cell(mouse.slicesxsegments_supra_sterr);
        micetab{tempdim(1)+4,1} = 'Relative areal borders';
        micetab(tempdim(1)+4,2:2+size(mouse.toparearel_mean,2)-1) = num2cell(mouse.toparearel_mean);
        
        tempdim = size(micetab);
        micetab{tempdim(1)+2,1} = 'Infra Segments';
        micetab(tempdim(1)+2,1+(1:size(mouse.slicesxsegments_infra,2))) = num2cell(1:size(mouse.slicesxsegments_infra,2));
        micetab(tempdim(1)+2+(1:size(mouse.slicesxsegments_infra,1)),1+(1:size(mouse.slicesxsegments_infra,2))) = num2cell(mouse.slicesxsegments_infra);
        tempdim = size(micetab);
        micetab{tempdim(1)+1,1} = 'Mean';
        micetab(tempdim(1)+1,2:2+size(mouse.slicesxsegments_infra_mean,2)-1) = num2cell(mouse.slicesxsegments_infra_mean);
        micetab{tempdim(1)+2,1} = 'Std';
        micetab(tempdim(1)+2,2:2+size(mouse.slicesxsegments_infra_std,2)-1) = num2cell(mouse.slicesxsegments_infra_std);
        micetab{tempdim(1)+3,1} = 'Ste';
        micetab(tempdim(1)+3,2:2+size(mouse.slicesxsegments_infra_sterr,2)-1) = num2cell(mouse.slicesxsegments_infra_sterr);
        micetab{tempdim(1)+4,1} = 'Relative areal borders';
        micetab(tempdim(1)+4,2:2+size(mouse.botarearel_mean,2)-1) = num2cell(mouse.botarearel_mean);
        
        %regions
        for j=1:size(regions,1)
            tempdim = size(micetab);
            regio = fieldnames(mouse.regions.(regions{j}));
            micetab{tempdim(1)+2,1} = ['Supra ' regions{j}];
            for k=1:size(regio,1)
                micetab{tempdim(1)+2,1+k} = regio{k};
                micetab(tempdim(1)+2+(1:size(mouse.regions.(regions{j}).(regio{k}).segments_supra_mean,1)),1+k) = num2cell(mouse.regions.(regions{j}).(regio{k}).segments_supra_mean);
            end
            tempdim = size(micetab);
            regmean = zeros(1,size(regio,1));
            regstd = zeros(1,size(regio,1));
            regste = zeros(1,size(regio,1));
            for k=1:size(regio,1)
                regmean(k) = mean(mouse.regions.(regions{j}).(regio{k}).segments_supra_mean);
                regstd(k) = std(mouse.regions.(regions{j}).(regio{k}).segments_supra_mean);
                regste(k) = regstd(k)/sqrt(length(mouse.regions.(regions{j}).(regio{k}).segments_supra_mean));
                
            end
            micetab{tempdim(1)+1,1} = 'Mean';
            micetab(tempdim(1)+1,2:2+size(regio,1)-1) = num2cell(regmean);
            micetab{tempdim(1)+2,1} = 'Std';
            micetab(tempdim(1)+2,2:2+size(regio,1)-1) = num2cell(regstd);
            micetab{tempdim(1)+3,1} = 'Ste';
            micetab(tempdim(1)+3,2:2+size(regio,1)-1) = num2cell(regste);
            
            tempdim = size(micetab);
            regio = fieldnames(mouse.regions.(regions{j}));
            micetab{tempdim(1)+2,1} = ['Infra ' regions{j}];
            for k=1:size(regio,1)
                micetab{tempdim(1)+2,1+k} = regio{k};
                micetab(tempdim(1)+2+(1:size(mouse.regions.(regions{j}).(regio{k}).segments_infra_mean,1)),1+k) = num2cell(mouse.regions.(regions{j}).(regio{k}).segments_infra_mean);
            end
            tempdim = size(micetab);
            regmean = zeros(1,size(regio,1));
            regstd = zeros(1,size(regio,1));
            regste = zeros(1,size(regio,1));
            for k=1:size(regio,1)
                regmean(k) = mean(mouse.regions.(regions{j}).(regio{k}).segments_infra_mean);
                regstd(k) = std(mouse.regions.(regions{j}).(regio{k}).segments_infra_mean);
                regste(k) = regstd(k)/sqrt(length(mouse.regions.(regions{j}).(regio{k}).segments_infra_mean));
                
            end
            micetab{tempdim(1)+1,1} = 'Mean';
            micetab(tempdim(1)+1,2:2+size(regio,1)-1) = num2cell(regmean);
            micetab{tempdim(1)+2,1} = 'Std';
            micetab(tempdim(1)+2,2:2+size(regio,1)-1) = num2cell(regstd);
            micetab{tempdim(1)+3,1} = 'Ste';
            micetab(tempdim(1)+3,2:2+size(regio,1)-1) = num2cell(regste);
        end
        
        
        
        dim = size(micetab);
    end
    
    %conditions tab
    conditions = fieldnames(projectresults.conditions);
    dim = [-1,0];
    for i=1:length(conditions)
        cond = projectresults.conditions.(conditions{i});
        regions = fieldnames(cond.regions);
        condtab{dim(1)+2,1} = conditions{i};
        %segments
        condtab{dim(1)+3,1} = 'Supra Segments per slice';
        condtab(dim(1)+3,1+(1:size(cond.slicesxsegments_supra,2))) = num2cell(1:size(cond.slicesxsegments_supra,2));
        condtab(dim(1)+3+(1:size(cond.slicesxsegments_supra,1)),1+(1:size(cond.slicesxsegments_supra,2))) = num2cell(cond.slicesxsegments_supra);
        
        tempdim = size(condtab);
        condtab{tempdim(1)+1,1} = 'Mean';
        condtab(tempdim(1)+1,2:2+size(cond.slicesxsegments_supra_mean,2)-1) = num2cell(cond.slicesxsegments_supra_mean);
        condtab{tempdim(1)+2,1} = 'Std';
        condtab(tempdim(1)+2,2:2+size(cond.slicesxsegments_supra_std,2)-1) = num2cell(cond.slicesxsegments_supra_std);
        condtab{tempdim(1)+3,1} = 'Ste';
        condtab(tempdim(1)+3,2:2+size(cond.slicesxsegments_supra_sterr,2)-1) = num2cell(cond.slicesxsegments_supra_sterr);
        condtab{tempdim(1)+4,1} = 'Relative areal borders';
        condtab(tempdim(1)+4,2:2+size(cond.toparearel,2)-1) = num2cell(mean(cond.toparearel));
        
        tempdim = size(condtab);
        condtab{tempdim(1)+2,1} = 'Infra Segments per slice';
        condtab(tempdim(1)+2,1+(1:size(cond.slicesxsegments_infra,2))) = num2cell(1:size(cond.slicesxsegments_infra,2));
        condtab(tempdim(1)+2+(1:size(cond.slicesxsegments_infra,1)),1+(1:size(cond.slicesxsegments_infra,2))) = num2cell(cond.slicesxsegments_infra);
        tempdim = size(condtab);
        condtab{tempdim(1)+1,1} = 'Mean';
        condtab(tempdim(1)+1,2:2+size(cond.slicesxsegments_infra_mean,2)-1) = num2cell(cond.slicesxsegments_infra_mean);
        condtab{tempdim(1)+2,1} = 'Std';
        condtab(tempdim(1)+2,2:2+size(cond.slicesxsegments_infra_std,2)-1) = num2cell(cond.slicesxsegments_infra_std);
        condtab{tempdim(1)+3,1} = 'Ste';
        condtab(tempdim(1)+3,2:2+size(cond.slicesxsegments_infra_sterr,2)-1) = num2cell(cond.slicesxsegments_infra_sterr);
        condtab{tempdim(1)+4,1} = 'Relative areal borders';
        condtab(tempdim(1)+4,2:2+size(cond.botarearel,2)-1) = num2cell(mean(cond.botarearel));
        
        tempdim = size(condtab);
        condtab{tempdim(1)+2,1} = 'Supra Segments with mean per mouse';
        condtab(tempdim(1)+2,1+(1:size(cond.slicesxsegments_supra_mousemean,2))) = num2cell(1:size(cond.slicesxsegments_supra_mousemean,2));
        condtab(tempdim(1)+2+(1:size(cond.slicesxsegments_supra_mousemean,1)),1+(1:size(cond.slicesxsegments_supra_mousemean,2))) = num2cell(cond.slicesxsegments_supra_mousemean);
        tempdim = size(condtab);
        condtab{tempdim(1)+1,1} = 'Mean';
        condtab(tempdim(1)+1,2:2+size(cond.slicesxsegments_supra_mousemean_mean,2)-1) = num2cell(cond.slicesxsegments_supra_mousemean_mean);
        condtab{tempdim(1)+2,1} = 'Std';
        condtab(tempdim(1)+2,2:2+size(cond.slicesxsegments_supra_mousemean_std,2)-1) = num2cell(cond.slicesxsegments_supra_mousemean_std);
        condtab{tempdim(1)+3,1} = 'Ste';
        condtab(tempdim(1)+3,2:2+size(cond.slicesxsegments_supra_mousemean_sterr,2)-1) = num2cell(cond.slicesxsegments_supra_mousemean_sterr);
        condtab{tempdim(1)+4,1} = 'Relative areal borders';
        condtab(tempdim(1)+4,2:2+size(cond.botarearel,2)-1) = num2cell(mean(cond.botarearel));
        
        tempdim = size(condtab);
        condtab{tempdim(1)+2,1} = 'Infra Segments with mean per mouse';
        condtab(tempdim(1)+2,1+(1:size(cond.slicesxsegments_infra_mousemean,2))) = num2cell(1:size(cond.slicesxsegments_infra_mousemean,2));
        condtab(tempdim(1)+2+(1:size(cond.slicesxsegments_infra_mousemean,1)),1+(1:size(cond.slicesxsegments_infra_mousemean,2))) = num2cell(cond.slicesxsegments_infra_mousemean);
        tempdim = size(condtab);
        condtab{tempdim(1)+1,1} = 'Mean';
        condtab(tempdim(1)+1,2:2+size(cond.slicesxsegments_infra_mousemean_mean,2)-1) = num2cell(cond.slicesxsegments_infra_mousemean_mean);
        condtab{tempdim(1)+2,1} = 'Std';
        condtab(tempdim(1)+2,2:2+size(cond.slicesxsegments_infra_mousemean_std,2)-1) = num2cell(cond.slicesxsegments_infra_mousemean_std);
        condtab{tempdim(1)+3,1} = 'Ste';
        condtab(tempdim(1)+3,2:2+size(cond.slicesxsegments_infra_mousemean_sterr,2)-1) = num2cell(cond.slicesxsegments_infra_mousemean_sterr);
        condtab{tempdim(1)+4,1} = 'Relative areal borders';
        condtab(tempdim(1)+4,2:2+size(cond.botarearel,2)-1) = num2cell(mean(cond.botarearel));
        
        %regions
        for j=1:size(regions,1)
            tempdim = size(condtab);
            regio = fieldnames(cond.regions.(regions{j}));
            condtab{tempdim(1)+2,1} = ['Supra ' regions{j}];
            for k=1:size(regio,1)
                condtab{tempdim(1)+2,1+k} = regio{k};
                condtab(tempdim(1)+2+(1:size(cond.regions.(regions{j}).(regio{k}).segments_supra,1)),1+k) = num2cell(cond.regions.(regions{j}).(regio{k}).segments_supra);
            end
            tempdim = size(condtab);
            regmean = zeros(1,size(regio,1));
            regstd = zeros(1,size(regio,1));
            regste = zeros(1,size(regio,1));
            for k=1:size(regio,1)
                regmean(k) = mean(cond.regions.(regions{j}).(regio{k}).segments_supra);
                regstd(k) = std(cond.regions.(regions{j}).(regio{k}).segments_supra);
                regste(k) = regstd(k)/sqrt(length(cond.regions.(regions{j}).(regio{k}).segments_supra));
                
            end
            condtab{tempdim(1)+1,1} = 'Mean';
            condtab(tempdim(1)+1,2:2+size(regio,1)-1) = num2cell(regmean);
            condtab{tempdim(1)+2,1} = 'Std';
            condtab(tempdim(1)+2,2:2+size(regio,1)-1) = num2cell(regstd);
            condtab{tempdim(1)+3,1} = 'Ste';
            condtab(tempdim(1)+3,2:2+size(regio,1)-1) = num2cell(regste);
            
            tempdim = size(condtab);
            regio = fieldnames(cond.regions.(regions{j}));
            condtab{tempdim(1)+2,1} = ['Infra ' regions{j}];
            for k=1:size(regio,1)
                condtab{tempdim(1)+2,1+k} = regio{k};
                condtab(tempdim(1)+2+(1:size(cond.regions.(regions{j}).(regio{k}).segments_infra,1)),1+k) = num2cell(cond.regions.(regions{j}).(regio{k}).segments_infra);
            end
            tempdim = size(condtab);
            regmean = zeros(1,size(regio,1));
            regstd = zeros(1,size(regio,1));
            regste = zeros(1,size(regio,1));
            for k=1:size(regio,1)
                regmean(k) = mean(cond.regions.(regions{j}).(regio{k}).segments_infra);
                regstd(k) = std(cond.regions.(regions{j}).(regio{k}).segments_infra);
                regste(k) = regstd(k)/sqrt(length(cond.regions.(regions{j}).(regio{k}).segments_infra));
                
            end
            condtab{tempdim(1)+1,1} = 'Mean';
            condtab(tempdim(1)+1,2:2+size(regio,1)-1) = num2cell(regmean);
            condtab{tempdim(1)+2,1} = 'Std';
            condtab(tempdim(1)+2,2:2+size(regio,1)-1) = num2cell(regstd);
            condtab{tempdim(1)+3,1} = 'Ste';
            condtab(tempdim(1)+3,2:2+size(regio,1)-1) = num2cell(regste);
        end
        
        
        
        dim = size(condtab);
    end
    
    % Connect to Excel
    %Excel = actxserver('excel.application');
    NET.addAssembly('microsoft.office.interop.excel');
    app = Microsoft.Office.Interop.Excel.ApplicationClass;
    books = app.Workbooks;
    newWB = Add(books);
    app.Visible = false;
    sheets = newWB.Worksheets;
    
    newSheet = Item(sheets,1);
    newWS = Microsoft.Office.Interop.Excel.Worksheet(newSheet);
    newWS.Name = 'Information';
    dim = size(info);
    range = Range(newWS,[ExcelCol(1) '1:' ExcelCol(dim(2)) num2str(dim(1))]);
    range.Value2 = info;
    
    newSheet = Item(sheets,2);
    newWS = Microsoft.Office.Interop.Excel.Worksheet(newSheet);
    newWS.Name = 'Mice';
    dim = size(micetab);
    range = Range(newWS,[ExcelCol(1) '1:' ExcelCol(dim(2)) num2str(dim(1))]);
    range.Value2 = micetab;
    
    newSheet = Item(sheets,3);
    newWS = Microsoft.Office.Interop.Excel.Worksheet(newSheet);
    newWS.Name = 'Conditions';
    dim = size(condtab);
    range = Range(newWS,[ExcelCol(1) '1:' ExcelCol(dim(2)) num2str(dim(1))]);
    range.Value2 = condtab;
    
    
    %select first sheet
    newSheet = Item(sheets,1);
    % Save Workbook
    if exist(filename, 'file')
        Save(newWB);
    else
        SaveAs(newWB,filename);
    end
    
    % Close Workbook
    Close(newWB);
    
    % Quit Excel
    Quit(app);