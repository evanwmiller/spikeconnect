function add_items_to_listbox(lisbox_handle , items)
% Adds items to a gui list box
% Inputs: 
% listbox_handle: a handle to a list box
% items: a string containing the item to be added
% Copyright 2016 The Miller Lab, UC Berkeley
% Author: Kaveh Karbasi
prev_list = get(lisbox_handle,'String');

if isempty(prev_list)
    set(lisbox_handle,'String','1')
else
    
    new_list = [prev_list; {items}];
    set(lisbox_handle,'String',new_list)
end