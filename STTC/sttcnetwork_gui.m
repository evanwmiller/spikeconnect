function varargout = sttcnetwork_gui(varargin)
% STTCNETWORK_GUI

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @sttcnetwork_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @sttcnetwork_gui_OutputFcn, ...
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

% --- Executes just before sttcnetwork_gui is made visible.
function sttcnetwork_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% OPENINGFCN Sets default values and centers the application window.

% Choose default command line output for sttcnetwork_gui
handles.output = hObject;

movegui(gcf,'center')

%DEFAULT VALUES FOR PARAMETERS
handles.sttcMaxLagMs = str2double(get(handles.sttcMaxLagEdit,'String'));
handles.xcorrMaxLagMs = str2double(get(handles.xcorrMaxLagEdit,'String'));
handles.monoMinLagMs = str2double(get(handles.monoMinLagEdit,'String'));
handles.monoMaxLagMs = str2double(get(handles.monoMaxLagEdit,'String'));
handles.splitLag = get(handles.splitLagCheck,'Value');

spikeDataFiles = get(handles.fileListbox,'String');
if iscell(spikeDataFiles)
    handles.selectedFile = spikeDataFiles{get(handles.fileListbox,'Value')};
else
    handles.selectedFile = '';
end

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

spikeFilePaths = recursdir(handles.baseDir , '^spikes-.*.mat$');
if isempty(spikeFilePaths)
    errordlg('No files found');
    return;
else
    spikeFileNames = extractNames(spikeFilePaths, baseDir);
    set(handles.fileListbox , 'String' , spikeFileNames);
    set(handles.fileListbox, 'Value', 1);
    handles.selectedFile = [handles.baseDir filesep spikeFileNames{1}];
end

guidata(hObject, handles);


% --- Executes on button press in heatmapButton.
function heatmapButton_Callback(hObject, eventdata, handles)
% hObject    handle to heatmapButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isequal(handles.selectedFile,'')
    errordlg('Please select a file first.');
    return;
end

% Embeds the heatmap into the figure
sttcArr = calcsttcarr(handles.selectedFile, handles.sttcMaxLagMs);
axes(handles.figAxes);
colormap([jet;[1,1,1]]); 
image(sttcArr , 'CDataMapping','scaled');
cbh = colorbar;
ylabel(cbh , 'STTC score')
axis square;
% Color bar is set to 0 to 1.05. STTC range is 0 to 1, and the bottom left
% triangle is set to 1.05, so it'll show up as white.
caxis([0 1.05]);

[~,fileName,~] = fileparts(handles.selectedFile);
title(fileName(8:end));

handles.heatmapFile = handles.selectedFile;
set(gcf, 'WindowButtonDownFcn', @heatmapclick);

guidata(hObject, handles);


function heatmapclick(src,~)
% Checks if the cursor position is within the heatmap, then checks if its a
% valid square to click on. If so, it plots the spike trains of the two
% relevant ROIs.
handles = guidata(src);

cursor = get(handles.figAxes, 'CurrentPoint');
x = cursor(1,1);
y = cursor(1,2);
xLimits = get(handles.figAxes, 'xlim');
yLimits = get(handles.figAxes, 'ylim');

if x > min(xLimits) && x < max(xLimits)
    if y > min(yLimits) && y < max(yLimits)
        x = round(x);
        y = round(y);
        if x >= y
            plotspikes(handles.heatmapFile,y,x);
        end
    end
end

% --- Executes on button press in seeRoiButton.
function seeRoiButton_Callback(hObject, eventdata, handles)
% hObject    handle to seeRoiButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isequal(handles.selectedFile,'')
    errordlg('Please select a file first.');
    return;
end
plotrois(handles.selectedFile);


% --- Executes on button press in networkButton.
function networkButton_Callback(hObject, eventdata, handles)
% hObject    handle to networkButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isequal(handles.selectedFile,'')
    errordlg('Please select a file first.');
    return;
end
plotnetwork(handles.selectedFile, handles.xcorrMaxLagMs, ...
            handles.monoMinLagMs, handles.monoMaxLagMs);

% --- Executes on button press in exportExcelButton.
function exportExcelButton_Callback(hObject, eventdata, handles)
% hObject    handle to exportExcelButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isequal(handles.selectedFile,'')
    errordlg('Please select a folder first.');
    return;
end
defaultDir = fullfile(handles.baseDir,'..','*.xlsx');
[excelName, excelDir] = uiputfile(defaultDir, 'Specify Excel File Path');
if isequal(excelDir,0); return; end;
excelPath = [excelDir excelName];
sttctoexcel(handles.baseDir,excelPath,handles.sttcMaxLagMs);


% ==================== PARAMETER UPDATES ===================== %

% --- Executes on selection change in fileListbox.
function fileListbox_Callback(hObject, eventdata, handles)
% hObject    handle to fileListbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fileNames = get(handles.fileListbox,'String');
index = get(hObject,'Value');
handles.selectedFile = [handles.baseDir filesep fileNames{index}];
guidata(hObject, handles);
% Hints: contents = cellstr(get(hObject,'String')) returns fileListbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from fileListbox


function sttcMaxLagEdit_Callback(hObject, eventdata, handles)
% hObject    handle to sttcMaxLagEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.sttcMaxLagMs = str2double(get(handles.sttcMaxLagEdit,'String'));
guidata(hObject,handles);
% Hints: get(hObject,'String') returns contents of sttcMaxLagEdit as text
%        str2double(get(hObject,'String')) returns contents of sttcMaxLagEdit as a double


function xcorrMaxLagEdit_Callback(hObject, eventdata, handles)
% hObject    handle to xcorrMaxLagEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.xcorrMaxLagMs = str2double(get(hObject,'String'));
guidata(hObject,handles);
% Hints: get(hObject,'String') returns contents of xcorrMaxLagEdit as text
%        str2double(get(hObject,'String')) returns contents of xcorrMaxLagEdit as a double


function monoMinLagEdit_Callback(hObject, eventdata, handles)
% hObject    handle to monoMinLagEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.monoMinLagMs = str2double(get(hObject,'String'));
guidata(hObject, handles);
% Hints: get(hObject,'String') returns contents of monoMinLagEdit as text
%        str2double(get(hObject,'String')) returns contents of monoMinLagEdit as a double


function monoMaxLagEdit_Callback(hObject, eventdata, handles)
% hObject    handle to monoMaxLagEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.monoMaxLagMs = str2double(get(hObject,'String'));
guidata(hObject, handles);
% Hints: get(hObject,'String') returns contents of monoMaxLagEdit as text
%        str2double(get(hObject,'String')) returns contents of monoMaxLagEdit as a double


% --- Executes on button press in splitLagCheck.
function splitLagCheck_Callback(hObject, eventdata, handles)
% hObject    handle to splitLagCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.splitLag = get(hObject, 'Value');
guidata(hObject, handles);
% Hint: get(hObject,'Value') returns toggle state of splitLagCheck

% ==================== UTILITY FUNCTIONS ==================== %
function fileNames = extractNames(filePaths,baseDir)
%EXTRACTNAMES Removes the folder portion from a cell array of file paths.
fileNames = cell(size(filePaths));
for i = 1:numel(filePaths)
    fileNames{i} = strrep(filePaths{i},baseDir,'');
end

% ==================== UNUSED GUIDE FUNCTIONS ==================== %

% --- Outputs from this function are returned to the command line.
function varargout = sttcnetwork_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes during object creation, after setting all properties.
function fileListbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fileListbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function sttcMaxLagEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sttcMaxLagEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function xcorrMaxLagEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xcorrMaxLagEdit (see GCBO)
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

% --- Executes on mouse press over axes background.
function figAxes_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to figAxes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
