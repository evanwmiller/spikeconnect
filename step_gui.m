function varargout = step_gui(varargin)
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @step_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @step_gui_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
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


% --- Executes just before step_gui is made visible.
function step_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Choose default command line output for step_gui
handles.output = hObject;
movegui(gcf,'center');
axesArr = {handles.snapAxes,handles.rawTraceAxes,...
    handles.correctedTraceAxes, handles.spikeAxes};
for i = 1:numel(axesArr)
    set(axesArr{i}, 'Visible','off');
    cla(axesArr{i});
end
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes step_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% ===================== MAIN FUNCTIONALITY ==================== %

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
    spikeFileNames = extractNames(spikeFilePaths);
    set(handles.fileListbox , 'String' , spikeFileNames);
    set(handles.fileListbox, 'Value', 1);
    handles.selectedFile = [handles.baseDir filesep spikeFileNames{1}];
    handles.data=load(handles.selectedFile);
    nRoi = numel(handles.data.spikeDataArray);
    set(handles.roiListbox, 'String', cellstr(int2str([1:nRoi]')));
    set(handles.roiListbox, 'Value', 1);
    handles.selectedRoi = 1;
    guidata(hObject, handles);
    loadimages;
end

function loadimages
handles = guidata(gcbo);
axesArr = {handles.snapAxes,handles.rawTraceAxes,...
    handles.correctedTraceAxes, handles.spikeAxes};
for i = 1:numel(axesArr)
    set(axesArr{i}, 'Visible','on');
end
%plot in figure
isPlot = 0;
loadsnap(isPlot);
loadrawtrace(isPlot);
loadcorrectedtrace(isPlot);
loadspikeplot(isPlot);

function loadsnap(isPlot)
handles = guidata(gcbo);
if isPlot
    figure;
else
    axes(handles.snapAxes);
    cla;
    hold on;
end

[dir,snapName,~] = fileparts(handles.data.snapPath);
labeledSnapPath = [dir filesep 'label-' snapName '.png'];
if exist(labeledSnapPath, 'file')
    labeledImage = imread(labeledSnapPath,'png');
    imshow(labeledImage);
else
    snap = imread(handles.data.snapPath);
    imshow(imadjust(snap));
    for i = 1:numel(handles.data.textPos)
        text('position',handles.data.textPos{i},...
            'fontsize',20 , ...
            'Color' , 'w' ,...
            'string', num2str(i));
    end
end

function loadrawtrace(isPlot)
handles = guidata(gcbo);
if isPlot
    figure;
else
    axes(handles.rawTraceAxes);
    cla;
end
hold on;
iTrace = handles.data.roiTraces{handles.selectedRoi};
plot(1:numel(iTrace),iTrace);
title('Raw Trace');

if isPlot
    xlabel('Time (s)');
    frameTick = get(gca,'xtick');
    set(gca,'xticklabel',frameTick/handles.data.frameRate);
else
    set(gca,'xtick',[])
    set(gca,'xticklabel',[])
end

function loadcorrectedtrace(isPlot)
handles = guidata(gcbo);
if isPlot
    figure;
else
    axes(handles.correctedTraceAxes);
    cla;
end
hold on;
iTrace = handles.data.bkgSubtractedTraces{handles.selectedRoi};
plot(1:numel(iTrace),iTrace);

title('Corrected Trace');
if isPlot
    xlabel('Time (s)');
    frameTick = get(gca,'xtick');
    set(gca,'xticklabel',frameTick/handles.data.frameRate);
else
    set(gca,'xtick',[])
    set(gca,'xticklabel',[])
end

function loadspikeplot(isPlot)
handles = guidata(gcbo);
if isPlot
    figure('units','inches');
    pos = get(gcf,'pos');
    set(gcf,'pos',[pos(1) pos(2) pos(3) round(pos(4)/3)])
    hold on;
else
    axes(handles.spikeAxes);
    cla;
    hold on;
end

t = handles.data.spikeDataArray{handles.selectedRoi}.rasterSpikeTimes; 
dffSnr = handles.data.spikeDataArray{handles.selectedRoi}.dffSnr;
nSpike = numel(t);
spikeSnrArr = zeros(nSpike,2);
for iSpike = 1:nSpike
  % draw a black vertical line of length 1 at time t(x) for roi1
  plot([t(iSpike) t(iSpike)],[0 1],'Color','k');
  spikeSnrArr(iSpike,1) = t(iSpike)/handles.data.frameRate;
  spikeSnrArr(iSpike,2) = dffSnr(t(iSpike));
end
nFrame = numel(handles.data.bkgSubtractedTraces{handles.selectedRoi});

axis([0 nFrame 0 1]);
set(gca,'YColor','w')
xlabel('Time (s)');
frameTick = get(gca,'xtick');
set(gca,'xticklabel',frameTick/handles.data.frameRate);
set(gca,'ytick',[])
set(gca,'yticklabel',[])
title(sprintf('Spikes for ROI %d',handles.selectedRoi));
disp(spikeSnrArr);
% ===================== MOUSE PRESSES ==================== %
% --- Executes on mouse press over axes background.
function rawTraceAxes_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to rawTraceAxes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
loadrawtrace(1);

% --- Executes on mouse press over axes background.
function correctedTraceAxes_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to correctedTraceAxes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
loadcorrectedtrace(1);

% --- Executes on mouse press over axes background.
function spikeAxes_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to spikeAxes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
loadspikeplot(1);

% ===================== UPDATES ==================== %
% --- Executes on selection change in fileListbox.
function fileListbox_Callback(hObject, eventdata, handles)
% hObject    handle to fileListbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fileNames = get(handles.fileListbox,'String');
index = get(hObject,'Value');
handles.selectedFile = [handles.baseDir filesep fileNames{index}];
handles.data=load(handles.selectedFile);
nRoi = numel(handles.data.spikeDataArray);
set(handles.roiListbox, 'String', cellstr(int2str([1:nRoi]')));
set(handles.roiListbox, 'Value', 1);
handles.selectedRoi = 1;
guidata(hObject, handles);
loadimages;

% Hints: contents = cellstr(get(hObject,'String')) returns fileListbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from fileListbox

% --- Executes on selection change in roiListbox.
function roiListbox_Callback(hObject, eventdata, handles)
% hObject    handle to roiListbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.selectedRoi = get(hObject,'Value');
guidata(hObject, handles);
loadimages;
% Hints: contents = cellstr(get(hObject,'String')) returns roiListbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from roiListbox

% ==================== UTILITY FUNCTIONS ==================== %

function fileNames = extractNames(filePaths)
%EXTRACTNAMES Removes the folder portion from a cell array of file paths.
fileNames = cell(size(filePaths));
for i = 1:numel(filePaths)
    [~,file,ext] = fileparts(filePaths{i});
    fileNames{i} = [file ext];
end

% ===================== UNUSED GUIDE FUNCTIONS ==================== %

% --- Outputs from this function are returned to the command line.
function varargout = step_gui_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;


% --- Executes during object creation, after setting all properties.
function fileListbox_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function roiListbox_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
