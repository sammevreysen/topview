a = [];
for i=1:size(setuptable,1)
    if(isempty(setuptable{i,6}.meansupra_raw))
        a = [a i];
    end
end