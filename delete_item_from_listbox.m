function item_selected = delete_item_from_listbox(listbox_handle , item_idx)

list = get(listbox_handle,'String');
if ~isempty(list)
    item_selected = str2double(list(item_idx)); 
    list(item_idx) = [];
    set(listbox_handle , 'Value' , 1)
    set(listbox_handle,'String',list)

end
