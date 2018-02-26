function varargout = xci_gui(varargin)
% XCI_GUI

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @xci_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @xci_gui_OutputFcn, ...
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

% --- Executes just before xci_gui is made visible.
function xci_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% OPENINGFCN Sets default values and centers the application window.

% Choose default command line output for xci_gui
handles.output = hObject;

movegui(gcf,'center')

%DEFAULT VALUES FOR PARAMETERS
handles.params.monoMinLagMs = str2double(get(handles.monoMinLagEdit,'String'));
handles.params.monoMaxLagMs = str2double(get(handles.monoMaxLagEdit,'String'));
handles.params.minFreq = str2double(get(handles.minFreqEdit,'String'));
handles.params.xciThreshold = str2double(get(handles.xciThresholdEdit,'String'));
handles.params.filter.dgc = 'include';
handles.params.filter.inhib = 'include';
handles.params.filter.ca1 = 'include';
handles.params.filter.ca3 = 'include';
handles.changed = true;

% Update handles structure
guidata(hObject, handles);


% ==================== BUTTON PRESSES ===================== %

% --- Executes on button press in browseButton.
function browseButton_Callback(hObject, eventdata, handles)
% hObject    handle to browseButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
baseDir = uigetdir('', 'Select a folder');
if baseDir == 0; return; end;
handles.baseDir = baseDir;

set(handles.folderText , 'String' , handles.baseDir)

handles.spikeFileStruct = findgroups(handles.baseDir);
if isempty(fieldnames(handles.spikeFileStruct))
    errordlg('No files found.');
else
    guidata(hObject, handles);
end


% --- Executes on button press in updateButton.
function updateButton_Callback(hObject, eventdata, handles)
% hObject    handle to updateButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~isfield(handles,'spikeFileStruct')
    errordlg('Please select a folder first.');
    return;
end

if ~handles.changed
    return;
end

handles.results = xcianalysis(handles.spikeFileStruct, handles.params);
handles.changed = false;

axes(handles.figAxes);

[dist, edges] = histcounts(handles.results.aggregate.xci, 20);
centers = (edges(1:end-1) + edges(2:end))/2;
bar(centers, dist);
xlabel('XCI');
ylabel('Count');

guidata(hObject, handles);


% --- Executes on button press in exportExcelButton.
function exportExcelButton_Callback(hObject, eventdata, handles)
% hObject    handle to exportExcelButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~isfield(handles,'spikeFileStruct')
    errordlg('Please select a folder first.');
    return;
end

defaultDir = fullfile(handles.baseDir,'..','*.xlsx');
[excelName, excelDir] = uiputfile(defaultDir, 'Specify Excel File Path');
if isequal(excelDir,0); return; end;

disp('Please wait...');
excelPath = [excelDir excelName];

if handles.changed
    handles.results = xcianalysis(handles.spikeFileStruct, handles.params);
    handles.changed = false;
end

xcitoexcel(handles.results, excelPath);

disp('Excel export completed.');
guidata(hObject, handles);

% ==================== PARAMETER UPDATES ===================== %
function minFreqEdit_Callback(hObject, eventdata, handles)
handles.params.minFreq = str2double(get(handles.minFreqEdit,'String'));
handles.changed = true;
guidata(hObject,handles);


function xciThresholdEdit_Callback(hObject, eventdata, handles)
handles.params.xciThreshold = str2double(get(hObject,'String'));
handles.changed = true;
guidata(hObject,handles);


function monoMinLagEdit_Callback(hObject, eventdata, handles)
handles.params.monoMinLagMs = str2double(get(hObject,'String'));
handles.changed = true;
guidata(hObject, handles);


function monoMaxLagEdit_Callback(hObject, eventdata, handles)
handles.params.monoMaxLagMs = str2double(get(hObject,'String'));
handles.changed = true;
guidata(hObject, handles);


function includeDgcRadio_Callback(hObject, eventdata, handles)
handles.params.filter.dgc = 'include';
handles.changed = true;
guidata(hObject, handles);


function requireDgcRadio_Callback(hObject, eventdata, handles)
handles.params.filter.dgc = 'require';
handles.changed = true;
guidata(hObject, handles);


function excludeDgcRadio_Callback(hObject, eventdata, handles)
handles.params.filter.dgc = 'exclude';
handles.changed = true;
guidata(hObject, handles);


function includeInhibRadio_Callback(hObject, eventdata, handles)
handles.params.filter.inhib = 'include';
handles.changed = true;
guidata(hObject, handles);


function requireInhibRadio_Callback(hObject, eventdata, handles)
handles.params.filter.inhib = 'require';
handles.changed = true;
guidata(hObject, handles);


function excludeInhibRadio_Callback(hObject, eventdata, handles)
handles.params.filter.inhib = 'exclude';
handles.changed = true;
guidata(hObject, handles);


function includeCa1Radio_Callback(hObject, eventdata, handles)
handles.params.filter.ca1 = 'include';
handles.changed = true;
guidata(hObject, handles);


function requireCa1Radio_Callback(hObject, eventdata, handles)
handles.params.filter.ca1 = 'require';
handles.changed = true;
guidata(hObject, handles);


function excludeCa1Radio_Callback(hObject, eventdata, handles)
handles.params.filter.ca1 = 'exclude';
handles.changed = true;
guidata(hObject, handles);


function includeCa3Radio_Callback(hObject, eventdata, handles)
handles.params.filter.ca3 = 'include';
handles.changed = true;
guidata(hObject, handles);


function requireCa3Radio_Callback(hObject, eventdata, handles)
handles.params.filter.ca3 = 'require';
handles.changed = true;
guidata(hObject, handles);


function excludeCa3Radio_Callback(hObject, eventdata, handles)
handles.params.filter.ca3 = 'exclude';
handles.changed = true;
guidata(hObject, handles);

% ==================== UNUSED GUIDE FUNCTIONS ==================== %

% --- Outputs from this function are returned to the command line.
function varargout = xci_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes during object creation, after setting all properties.
function minFreqEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to minFreqEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function xciThresholdEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xciThresholdEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function monoMinLagEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to monoMinLagEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function monoMaxLagEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to monoMaxLagEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
