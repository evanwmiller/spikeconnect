function varargout = sttc_gui(varargin)
% STTC_GUI

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @sttc_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @sttc_gui_OutputFcn, ...
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

% --- Executes just before sttc_gui is made visible.
function sttc_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% OPENINGFCN Sets default values and centers the application window.

% Choose default command line output for sttc_gui
handles.output = hObject;

movegui(gcf,'center')

%DEFAULT VALUES FOR PARAMETERS
handles.sttcMaxLagMs = str2double(get(handles.sttcMaxLagEdit,'String'));
handles.monoMinLagMs = str2double(get(handles.monoMinLagEdit,'String'));
handles.monoMaxLagMs = str2double(get(handles.monoMaxLagEdit,'String'));

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
    return;
else
    spikeFileNames = extractnames(handles.spikeFileStruct, baseDir);
    set(handles.fileListbox , 'String' , spikeFileNames);
    set(handles.fileListbox, 'Value', 1);
    fileGroup = getfilegroup(handles);
    load(fileGroup{1}, 'threshold');
    set(handles.rearmPopup, 'Value', threshold);
    
end

guidata(hObject, handles);


% --- Executes on button press in heatmapButton.
function heatmapButton_Callback(hObject, eventdata, handles)
% hObject    handle to heatmapButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~isfield(handles,'spikeFileStruct')
    errordlg('Please select a folder first.');
    return;
end

% Embeds the heatmap into the figure
[handles.fileGroup,handles.selection] = getfilegroup(handles);
sttcArr = calcsttcarr(handles.fileGroup, handles.sttcMaxLagMs);

% represent NaN as 1.05, which is an impossible STTC value.
sttcArr(isnan(sttcArr)) = 1.05;
axes(handles.figAxes);

% add [1,1,1] to the colormap so highest values (representing NaN) show up
% white in the heatmap
colormap([parula;[1,1,1]]); 
image(sttcArr , 'CDataMapping','scaled');
cbh = colorbar;
ylabel(cbh , 'STTC score')
axis square;
% Color bar is set to 0 to 1.05. STTC range is 0 to 1, and the bottom left
% triangle is set to 1.05, so it'll show up as white. Any STTC involving a
% nonfiring cell will also show in white.
caxis([0 1.05]);
titleText = strrep(handles.selection,'_',' ');
title(titleText);

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
            plotdetails(handles,y,x);
        end
    end
end

% --- Executes on button press in seeRoiButton.
function seeRoiButton_Callback(hObject, eventdata, handles)
% hObject    handle to seeRoiButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~isfield(handles,'spikeFileStruct')
    errordlg('Please select a folder first.');
    return;
end
fileGroup = getfilegroup(handles);
plotrois(fileGroup{1});


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
includeNonFiring = false;
sttctoexcel(handles.baseDir, excelPath, handles.sttcMaxLagMs, includeNonFiring);

disp('Excel export completed.');


% --- Executes on button press in previewButton.
function previewButton_Callback(hObject, eventdata, handles)
% hObject    handle to previewButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~isfield(handles,'spikeFileStruct')
    errordlg('Please select a folder first.');
    return;
end

fileGroup = getfilegroup(handles);
load(fileGroup{1}, 'threshold');
previewthreshold(fileGroup, threshold, getrearmfactor(handles));


% --- Executes on button press in saveButton.
function saveButton_Callback(hObject, eventdata, handles)
% hObject    handle to saveButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~isfield(handles,'spikeFileStruct')
    errordlg('Please select a folder first.'); 
    return;
end

fileGroup = getfilegroup(handles);
load(fileGroup{1}, 'threshold');
savethreshold(fileGroup, threshold, getrearmfactor(handles));
disp('Spike times updated and saved.')


% ==================== PARAMETER UPDATES ===================== %
function sttcMaxLagEdit_Callback(hObject, eventdata, handles)
% hObject    handle to sttcMaxLagEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.sttcMaxLagMs = str2double(get(handles.sttcMaxLagEdit,'String'));
guidata(hObject,handles);
% Hints: get(hObject,'String') returns contents of sttcMaxLagEdit as text
%        str2double(get(hObject,'String')) returns contents of sttcMaxLagEdit as a double


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

% ==================== UTILITY FUNCTIONS ==================== %

function [fileGroup,selection] = getfilegroup(handles)
%GETFILEGROUP Using the currently selected entry in handles.fileListbox,
%create a cell array of the associated spike files. If a file is selected,
%returns {file}. If a folder is selected, returns {files in folder}.
fileList = cellstr(get(handles.fileListbox,'String'));
selection = fileList{get(handles.fileListbox,'Value')};
[~,~,ext] = fileparts(selection);
% selected entry is a group
if isempty(ext)
    fileGroup = handles.spikeFileStruct.(selection);
else
    fileGroup = {[handles.baseDir selection]};
end


function fileNames = extractnames(fileStruct,baseDir)
%EXTRACTNAMES Creates list of folders/files from grouped spike files.
fileNames = {};
fieldNames = fieldnames(fileStruct);
for iField = 1:numel(fieldNames)
    fieldName = fieldNames{iField};
    fileNames{end+1} = fieldName;
    filesInGroup = fileStruct.(fieldName);
    for iFile = 1:numel(filesInGroup)
        file = filesInGroup{iFile};
        fileNames{end+1} = strrep(file,baseDir,'');
    end
end

function plotdetails(handles, roi1, roi2)
% Plots spikes if a file is selected. Do nothing if group is selected.
[~,~,ext] = fileparts(handles.selection);
fileGroup = getfilegroup(handles);
if ~isempty(ext) % selected file
    plotspikes(fileGroup{1},roi1,roi2);
end


function rearmFactor = getrearmfactor(handles)
% Reads the rearm factor from user selection.
contents = cellstr(get(handles.rearmPopup,'String'));
selectedIndex = get(handles.rearmPopup,'Value');
selectedStr = contents{selectedIndex};
rearmFactor = str2num(selectedStr);

% ==================== UNUSED GUIDE FUNCTIONS ==================== %

% --- Outputs from this function are returned to the command line.
function varargout = sttc_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in fileListbox.
function fileListbox_Callback(hObject, eventdata, handles)
% hObject    handle to fileListbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns fileListbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from fileListbox


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


% --- Executes on selection change in rearmPopup.
function rearmPopup_Callback(hObject, eventdata, handles)
% hObject    handle to rearmPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns rearmPopup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from rearmPopup


% --- Executes during object creation, after setting all properties.
function rearmPopup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rearmPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
