function flag = hasDoubleEntries(setuptable)
    micenames = unique(setuptable(:,2));
    flag = 0;
    for i=1:size(micenames,1)
        mouse = micenames{i};
        bregmas = cell2mat(cellfun(@(x) x.bregma,setuptable(strcmp(setuptable(:,2),mouse),5),'UniformOutput',false));
        if(size(unique(bregmas),1) < size(bregmas,1))
            if(flag == 0)
                fprintf('\nDouble entries detected, please check following list:\n');
            end
            [~,I] = unique(bregmas,'first');
            doubles = bregmas(~ismember(1:numel(bregmas),I));
            fprintf(['Mouse %s has double entries for bregma levels ' repmat('%d,',1,length(doubles)-1) '%d\n'],mouse,doubles);
            flag = 1;
        end
    end