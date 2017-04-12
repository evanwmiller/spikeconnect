function varargout = auc_gui(varargin)
% AUC_GUI Creates a GUI for calculating the area under the curve for spike
% trains using two different methods: multispike and whole trace integral.
%   The user should select a folder that has been processed using SpikeNet.
%   The program will then find all relevant data files in this directory
%   and calculate the area under the curve for them, after which the
%   results can be viewed using the GUI.

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @auc_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @auc_gui_OutputFcn, ...
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


% --- Executes just before auc_gui is made visible.
function auc_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to auc_gui (see VARARGIN)

% Choose default command line output for auc_gui
handles.output = hObject;

movegui(gcf,'center');

% DEFAULT VALUES FOR PARAMETERS
handles.selectedRoi = 1;
handles.selectedFile = 0;

spikeDataFiles = get(handles.fileListbox,'String');
% if the window is already open, get the current values instead
if iscell(spikeDataFiles)
    handles.selectedFile = get(handles.fileListbox,'Value');
    handles.selectedRoi = get(handles.roiSlider,'Value');
end

% Update handles structure
guidata(hObject, handles);

% ==================== BUTTON PRESSES ==================== %
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
    errordlg('No files found.');
    return;
else
    spikeFileNames = extractnames(spikeFilePaths, baseDir);
    set(handles.fileListbox , 'String' , spikeFileNames);
    
    % make it multiselect initially to allow for no default value
    set(handles.fileListbox, 'min', 0, 'max', 2);
    set(handles.fileListbox, 'Value',[]);
    handles.selectedFile = 0;
end
handles.spikeFilePaths = spikeFilePaths;
guidata(hObject, handles);
calculateauc(handles);


% --- Executes on button press in exportButton.
function exportButton_Callback(hObject, eventdata, h)
% hObject    handle to exportButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% h    structure with handles and user data (see GUIDATA)
if ~isfield(h,'spikeFilePaths'); return; end;
defaultDir = fullfile(h.baseDir,'..','*.xlsx');
[excelName, excelDir] = uiputfile(defaultDir, 'Specify Excel File Path');
if isequal(excelDir,0); return; end;
excelPath = [excelDir excelName];
auctoexcel(h.spikeFilePaths,excelPath, h.aucValues);
disp('Excel export completed.');

[~,fileName,~] = fileparts(excelName);
matPath = [excelDir fileName '.mat'];
aucValues = h.aucValues;
spikeAuc = h.spikeAuc;
fileNames = h.spikeFilePaths;
save(matPath, 'fileNames','aucValues', 'spikeAuc');
disp(['Saved AUC values and spike areas to' matPath]);



% ==================== PARAMETER UPDATES ==================== %
% --- Executes on selection change in fileListbox.
function fileListbox_Callback(hObject, eventdata, handles)
% hObject    handle to fileListbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.fileListbox, 'min', 0, 'max', 1);
handles.selectedFile = get(hObject,'Value');
nRoi = handles.numRois{handles.selectedFile};
set(handles.roiSlider,'Min',1,'Max',nRoi);
set(handles.roiSlider,'Value',1);
set(handles.roiSlider, 'SliderStep', [1/(nRoi-1) , 1/(nRoi-1) ]);

uicontrol(handles.roiSlider);
handles.selectedRoi = 1;
set(handles.roiText,'String',sprintf('ROI %d',1));
guidata(hObject, handles);
updateplots(handles);
% Hints: contents = cellstr(get(hObject,'String')) returns fileListbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from fileListbox

% --- Executes on slider movement.
function roiSlider_Callback(hObject, eventdata, handles)
% hObject    handle to roiSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.selectedRoi = round(get(hObject,'Value'));
%make sure it's an integer value
set(hObject,'Value',handles.selectedRoi);
set(handles.roiText,'String',sprintf('ROI %d',handles.selectedRoi));
guidata(hObject, handles);
updateplots(handles);
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% ==================== UTILITY FUNCTIONS ==================== %
function fileNames = extractnames(filePaths,baseDir)
%EXTRACTNAMES Removes the folder portion from a cell array of file paths.
fileNames = cell(size(filePaths));
for i = 1:numel(filePaths)
    fileNames{i} = strrep(filePaths{i},baseDir,'');
end

function calculateauc(handles)
busy = busydlg('Please wait...');
for iFile = 1:numel(handles.spikeFilePaths)
    spikeFile = handles.spikeFilePaths{iFile};
    sf = load(spikeFile);
    nRoi = numel(sf.spikeDataArray);
    handles.numRois{iFile} = nRoi;
    handles.frame2ms{iFile} = 1000/sf.frameRate;
    for iRoi = 1:nRoi
        trace = sf.bkgSubtractedTraces{iRoi};
        spikeData = sf.spikeDataArray{iRoi};

        dff = calcdff(trace,spikeData);
        [multiAvg,multiSum,multiArr,areas] = multispike(dff,spikeData.rasterSpikeTimes);
        [wholeAuc, wholeDff] = wholetrace(dff);
        
        auc = [multiAvg,multiSum,wholeAuc]*handles.frame2ms{iFile};
        handles.spikeAuc{iFile}{iRoi} = multiArr;
        handles.aucValues{iFile}{iRoi} = auc;
        handles.rawDffs{iFile}{iRoi} = dff;
        handles.multiAreas{iFile}{iRoi} = areas;
        handles.wholeDffs{iFile}{iRoi} = wholeDff;
    end
end
delete(busy);
guidata(gcf,handles);

function dff = calcdff(trace,spikeData)
clusters = spikeData.clusters;
baseline = clusters{spikeData.baselineClusterIndex};
baselineMedian = nanmedian(baseline);
dff = (trace-baselineMedian)/baselineMedian;


function updateplots(handles)
file = handles.selectedFile;
roi = handles.selectedRoi;
frame2s = handles.frame2ms{file}/1000;
rawDff = handles.rawDffs{file}{roi};
multiArea = handles.multiAreas{file}{roi};
wholeDff = handles.wholeDffs{file}{roi};
auc = handles.aucValues{file}{roi};
aucString = sprintf(['Multi-spike Avg: %.2f ms \nMulti-spike Sum: %.2f'...
    'ms \nWhole Trace: %.2f ms'], auc(1),auc(2),auc(3));
set(handles.aucText,'String', aucString);

x = (1:numel(rawDff)) .* frame2s;
axes(handles.traceAxes);
plot(x,rawDff);
xlabel('s');
title('dff');

axes(handles.multispikeAxes);
plot(x,rawDff);
hold on;
for i = 1:size(multiArea,1)
    %area bounds
    l = multiArea(i,1);
    r = multiArea(i,2);
    xrange = (l:r) .* frame2s;
    area(xrange, rawDff(l:r),'FaceColor','g','EdgeColor','g');
end
hold off;
xlabel('s');
title('Multi-spike');

axes(handles.wholetraceAxes);
area(x,wholeDff,'FaceColor','b','EdgeColor','b');
xlabel('s');
title('Whole Trace');

% ==================== UNUSED GUIDE FUNCTIONS ==================== %
% --- Outputs from this function are returned to the command line.
function varargout = auc_gui_OutputFcn(hObject, eventdata, handles) 
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
function roiSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to roiSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
