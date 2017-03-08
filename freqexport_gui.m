function varargout = freqexport_gui(varargin)
% FREQEXPORT_GUI Exports to Excel from ifreqs-*.mat files.

% Copyright 2016 The Miller Lab, UC Berkeley
% Author: Kaveh Karbasis
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @freqexport_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @freqexport_gui_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before freqexport_gui is made visible.
function freqexport_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to freqexport_gui (see VARARGIN)

% Choose default command line output for freqexport_gui
handles.output = hObject;
movegui(gcf,'center')

% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in export_button.
function export_button_Callback(hObject, eventdata, handles)
% hObject    handle to export_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ifreqsFilePaths = cellstr(get(handles.destination_listbox,'String'));
if isempty(ifreqsFilePaths) || isempty(ifreqsFilePaths{1}); return; end;

defaultDir = fullfile(handles.baseDir,'*.xlsx');
[excelName, excelDir] = uiputfile(defaultDir, 'Specify Excel File Path');
if isequal(excelName,0) || isequal(excelDir,0); return; end;

excelPath = [excelDir excelName];
freqtoexcel(ifreqsFilePaths, excelPath);


% --- Executes on selection change in source_listbox.
function source_listbox_Callback(hObject, eventdata, handles)
% Updates the handles for the source files.

% hObject    handle to source_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

contents = cellstr(get(hObject,'String'));
handles.sourceIndex = get(hObject,'Value');
handles.sourceStr = contents(handles.sourceIndex);

guidata(hObject, handles);


% --- Executes on selection change in destination_listbox.
function destination_listbox_Callback(hObject, eventdata, handles)
% Updates the handles for the destination files.

% hObject    handle to destination_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

contents = cellstr(get(hObject,'String'));
handles.destIndex = get(hObject,'Value');
handles.destStr = contents(handles.destIndex);

% --- Executes on button press in add_button.
function add_button_Callback(hObject, eventdata, handles)
% hObject    handle to add_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

pause(0.02)
contents = cellstr(get(handles.source_listbox,'String'));
if ~isempty(contents)
    prevList = get(handles.destination_listbox,'String');

    if isempty(prevList)
        set(handles.destination_listbox,'String',handles.sourceStr)
    else
        new_list = [prevList; handles.sourceStr];
        set(handles.destination_listbox,'String',new_list)
        contents = cellstr(get(handles.destination_listbox,'String'));
        if ~isempty(contents)
            handles.destIndex = 1;
            handles.destStr = contents(handles.destIndex);
        end
    end

    deletefromlistbox(handles.source_listbox , handles.sourceIndex);
    contents = cellstr(get(handles.source_listbox,'String'));
    if ~isempty(contents)
        handles.sourceIndex = 1;
        handles.sourceStr = contents(handles.sourceIndex);
    end
end
guidata(hObject, handles);


% --- Executes on button press in remove_button.
function remove_button_Callback(hObject, eventdata, handles)
% hObject    handle to remove_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
pause(0.02);
contents = cellstr(get(handles.destination_listbox,'String'));
if ~isempty(contents)
    prevList = get(handles.source_listbox,'String');

    if isempty(prevList)
        set(handles.source_listbox,'String',handles.destStr)
    else

        new_list = [prevList; handles.destStr];
        set(handles.source_listbox,'String',new_list)
        contents = cellstr(get(handles.source_listbox,'String'));
        if ~isempty(contents)
           handles.sourceIndex = 1;
           handles.sourceStr = contents(handles.sourceIndex);
        end
    end

    deletefromlistbox(handles.destination_listbox , handles.destIndex);
    contents = cellstr(get(handles.destination_listbox,'String'));

    if ~isempty(contents)
        handles.destIndex = 1;
        handles.destStr = contents(handles.destIndex);
    end
end
guidata(hObject, handles);

% --- Executes on button press in select_files_button.
function select_files_button_Callback(hObject, eventdata, handles)
% hObject    handle to select_files_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

selectedRadio = get(handles.folder_selection_radiogroup , 'SelectedObject');
selectedString = get(selectedRadio , 'String');
if strcmp(selectedString , 'Recursive')
    baseDir = uigetdir('' , 'Select a folder');
    if(baseDir == 0)
        return
    end
handles.baseDir = baseDir;
ifreqsFilePaths = recursdir(baseDir , '^ifreqs.*.mat$');
   
elseif strcmp(selectedString , 'Multi-select')
    filesnfolders = uipickfiles('REFilter' ,'^ifreqs.*.mat$');
    if filesnfolders == 0
        return
    end
    
    ifreqsFilePaths={};
    for fnf = 1:numel(filesnfolders)
        if isdir(filesnfolders{fnf})
            ifreqsFilePaths = [ifreqsFilePaths recursdir(filesnfolders{fnf} , '^ifreqs.*.mat$')];
        else
            ifreqsFilePaths = [ifreqsFilePaths filesnfolders{fnf}];
        end
    end
else
    error(['Radio button reading error due to ambiguous radio button string value:' selectedString])
end

set(handles.source_listbox , 'String' ,  ifreqsFilePaths)
contents = cellstr(get(handles.source_listbox,'String'));
if ~isempty(contents)
    handles.sourceIndex = 1;
    handles.sourceStr = contents(handles.sourceIndex);
end
guidata(hObject, handles);

% ==================== UNUSED GUIDE FUNCTIONS ==================== %
% --- Outputs from this function are returned to the command line.
function varargout = freqexport_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes during object creation, after setting all properties.
function source_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to source_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function destination_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to destination_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


