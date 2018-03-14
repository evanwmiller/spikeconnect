function value = getvalueofassignment(assignment)
switch lower(assignment)
    case 'dgc'
        value = 1;
    case 'inhib'
        value = 2;
    case 'ca1'
        value = 3;
    case 'ca3'
        value = 4;
    otherwise
        value = 5;
end