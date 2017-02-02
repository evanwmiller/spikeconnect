function itemSelected = deletefromlistbox(listboxHandle , itemIndex)
% Delete items from a gui list box
% Inputs: 
% listbox_handle: a handle to a list box
% item_idx: Index of the item to be deleted
% Copyright 2016 The Miller Lab, UC Berkeley
% Author: Kaveh Karbasi
list = get(listboxHandle,'String');
if ~isempty(list)
    itemSelected = str2double(list(itemIndex)); 
    list(itemIndex) = [];
    set(listboxHandle , 'Value' , 1)
    set(listboxHandle,'String',list)
end
