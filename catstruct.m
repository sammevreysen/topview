function C = catstruct(A,B)
    if(~(isstruct(A)&&isstruct(B)))
        error('A and B needs to be structs!');
    else
        fieldsA = sort(fieldnames(A));
        fieldsB = sort(fieldnames(B));
        samefields = fieldsA(ismember(fieldsA,fieldsB));
        uniqfieldsB = fieldsB(~ismember(fieldsB,fieldsA));
        C = A;
        for i=1:size(samefields,1)
            if(isstruct(A.(samefields{i})) && isstruct(B.(samefields{i})))
                C.(samefields{i}) = catstruct(A.(samefields{i}),B.(samefields{i}));
            else 
                C.(samefields{i}) = A.(samefields{i});
            end
        end
        for i=1:size(uniqfieldsB,1)
            C.(uniqfieldsB{i}) = B.(uniqfieldsB{i});
        end
    end