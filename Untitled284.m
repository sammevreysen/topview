for i=1:size(setuptable,1)
    setuptable{i,2} = [setuptable{i,2} setuptable{i,1}(end-2:end)];
end