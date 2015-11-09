function logical = findelements(matrix,elements)
    matrix = reshape(matrix,length(matrix),1);
    elements = reshape(elements,1,length(elements));
    fullmatrix = repmat(matrix,1,length(elements));
    fullelements = repmat(elements,length(matrix),1);
    logical = any(fullmatrix-fullelements == 0,2);