function add_items_to_listbox(lisbox_handle , items)
prev_list = get(lisbox_handle,'String');

if isempty(prev_list)
    set(lisbox_handle,'String','1')
else
    
    new_list = [prev_list; {items}];
    set(lisbox_handle,'String',new_list)
end