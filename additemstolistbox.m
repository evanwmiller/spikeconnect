function additemstolistbox(listboxHandle, items)
% Adds items to a gui list box.
% Inputs: 
% listboxHandle: a handle to a list box
% items: a string containing the item to be added
% additemstolistbox(listboxHandle, items)

% Copyright 2016 The Miller Lab, UC Berkeley
% Author: Kaveh Karbasi

prevList = get(listboxHandle,'String');

if isempty(prevList)
    set(listboxHandle, 'String', '1')
else
    newList = [prevList; {items}];
    set(listboxHandle, 'String', newList)
end