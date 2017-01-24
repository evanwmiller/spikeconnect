function item_selected = delete_item_from_listbox(listbox_handle , item_idx)
% Delete items from a gui list box
% Inputs: 
% listbox_handle: a handle to a list box
% item_idx: Index of the item to be deleted
% Copyright 2016 The Miller Lab, UC Berkeley
% Author: Kaveh Karbasi
list = get(listbox_handle,'String');
if ~isempty(list)
    item_selected = str2double(list(item_idx)); 
    list(item_idx) = [];
    set(listbox_handle , 'Value' , 1)
    set(listbox_handle,'String',list)

end
