function basep = addMiceToProject(basep,addedp)
    basep.micenames = [basep.micenames; addedp.micenames];
    basep.conditionnames = unique([basep.conditionnames; addedp.conditionnames]);
    mice = fieldnames(addedp.mice);
    for i=1:size(mice,1)
        basep.mice.(mice{i}) = addedp.mice.(mice{i});
        
    end
    