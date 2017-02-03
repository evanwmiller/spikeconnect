function varargout = selectroi_gui(varargin)
% SELECTROI_GUI GUI for selecting ROIs for neural activity recordings.
%   Instructions:
%       1. Select a brightfield tiff image and one or more tiff movies.
%       2. Select one or more region(s) of interest to analyze.
%       3. Select a region of the movie to serve as background.
%      
%   selectroi_gui outputs a .mat file that contains:
%       bkgMask     Logical mask for selected background
%       frameRate   Specified frame rate in frames per second
%       roiMasks    Cell array containing logical mask for each ROI
%       snapPath    Full file path for the brightfield image
%       stackPaths  Cell array with full file paths for each movie
%       textHandles Handles to the labels on the image
%       testPos     Coordinates for the labels from textHandles

% Copyright 2016 The Miller Lab, UC Berkeley
% Author: Kaveh Karbasi
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @selectroi_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @selectroi_gui_OutputFcn, ...
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


% --- Executes just before selectroi_gui is made visible.
function selectroi_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to selectroi_gui (see VARARGIN)

handles.output = hObject;
handles.colors = hsv(25);
handles.keyEventStage = 0;
DEFAULT_FRAME_RATE = 500;
% Update handles structure
guidata(hObject, handles);
movegui(gcf,'center')

% Load default frame rate from prefs.mat (if it exists).
prefsFile = [fileparts(mfilename('fullpath')) filesep 'prefs.mat'];
if exist(prefsFile,'file')
    load(prefsFile)
    set(handles.frame_rate_text, 'String', frameRate);
else
    set(handles.frame_rate_text, 'String', num2str(DEFAULT_FRAME_RATE));
end


% --- Executes on button press in snap_button.
function snap_button_Callback(hObject, eventdata, handles)
% Brings up dialog to select a brightfield image. 
%
% hObject    handle to snap_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%reset

handles.colors = handles.colors(randperm(size(handles.colors,1)),:);

baseDir = '';
disp('SELECT A SNAP FILE...');
[handles.snapFile,handles.snapDir] = uigetfile(...
    [baseDir '*.tiff'],'Select a .tif SNAP file');

if(handles.snapFile == 0)
    return
end

% if a file was selected
set(handles.snap_fn_text, 'String', [handles.snapDir,handles.snapFile]);
snap = imread([handles.snapDir,handles.snapFile]);
set(handles.image_axes , 'Visible' , 'on');
axes(handles.image_axes)
handles.mapH = imshow(imadjust(snap));

% reset ROI data
handles.roiHandles = {};
handles.textHandles = {};
handles.roiCounter  = 1;

set(handles.ROI_list , 'String' , '');

handles.parentMapH = get(handles.mapH , 'parent');
set(handles.info_text , 'String' , 'Press ''C'' to continue drawing')
guidata(hObject, handles);


% --- Executes on button press in stack_button.
function stack_button_Callback(hObject, eventdata, handles)
% Brings up dialog to select a .tiff movie.
% Sets handles.stackFile and handles.stackDir.
%
% hObject    handle to stack_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~isfield(handles,'snapDir')
    warndlg('Select a brightfield image first.')
    return
end

disp('SELECT A STACK FILE...');
[handles.stackFile, handles.stackDir] = uigetfile(...
    [handles.snapDir '*.tiff'],'Select a .tif STACK file');

if(handles.stackFile == 0)
    return
end

% cast to cell array to maintain compatibility with multiple import
handles.stackFile = {handles.stackFile};
set(handles.stack_fn_text, 'String', handles.stackFile);
guidata(hObject, handles);



% --- Executes on button press in import_stack.
function import_stack_Callback(hObject, eventdata, handles)
% Looks in the same directory as the selected brightfield .tiff and selects
% all other .tiff files (assumes them to be movies).
% Sets handles.stackFile and handles.snapDir
% 
% hObject    handle to import_stack (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~isfield(handles,'snapDir')
    warndlg('Select a brightfield image first.');
    return
end

% match all .tiff files except the snap
handles.stackFile = currentdir(handles.snapDir, '\.tiff', handles.snapFile);
disp('Files Found:')
disp(handles.stackFile)
handles.stackDir = handles.snapDir;
set(handles.stack_fn_text, 'String', handles.stackFile);
if numel(handles.stackFile) == 0
    warndlg('No other .tiff files found.')
end
guidata(hObject, handles);



% --- Executes on key press with focus on figure1 and none of its controls.
function figure1_KeyPressFcn(hObject, eventdata, handles)
% Listens for 'c' and 'd' keypresses to draw and delete ROIs.
% When selecting background, listens for 'b' and 'return' keypresses.
%
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
if ~isfield(handles,'parentMapH')
    return
end

if strcmp(eventdata.Key,'c') && (handles.keyEventStage == 0)
    set(handles.info_text , 'String' , 'Draw an ROI')
    roi=imfreehand(handles.parentMapH);
    handles.roiHandles{handles.roiCounter} = roi;
    handles.roiMasks{handles.roiCounter} = roi.createMask();
    
    % Draws the ROI number on top of the image.
    pos = roi.getPosition();
    textX = 12+(max(pos(: , 1)) + min(pos(: , 1)))/2;
    textY = (max(pos(: , 2)) + min(pos(: , 2)))/2;
    handles.textHandles{handles.roiCounter} = text('position',[textX textY],'fontsize',20 , 'Parent' , ...
                handles.parentMapH , 'Color' , handles.colors(handles.roiCounter, :) ,'string',num2str(handles.roiCounter));
    addtolistbox(handles.ROI_list , num2str(handles.roiCounter));
    
    handles.roiCounter = handles.roiCounter + 1;

elseif strcmp(eventdata.Key,'d') && (handles.keyEventStage == 0)
    indexSelected = get(handles.ROI_list, 'Value');
    deletefromlistbox(handles.ROI_list, indexSelected);
    if numel(handles.roiHandles) > 0
        handles.roiHandles{indexSelected}.delete()
        t = handles.textHandles{indexSelected};
        handles.textHandles(indexSelected) = [];
        delete(t);
        handles.roiHandles(indexSelected) = [];
        handles.roiCounter = handles.roiCounter - 1;
        
        %adjust ROI numbers as needed
        for tt = indexSelected : numel(handles.textHandles)
            prevtxt = get(handles.textHandles{tt} , 'String');
            newtxt = num2str(str2double(prevtxt) - 1);
            set(handles.textHandles{tt} , 'String' , newtxt);
        end
        set(handles.ROI_list , 'String' , num2str([1:handles.roiCounter-1]'))
    end
    
elseif strcmp(eventdata.Key,'b') && (handles.keyEventStage == 1)
    handles.backgroundHandle = drawbackground(handles);

elseif strcmp(eventdata.Key,'return') && (handles.keyEventStage == 1)
    savebackground(hObject, handles);
    return
    
elseif (handles.keyEventStage == 2)
    if strcmp(eventdata.Key,'n')
        close(gcbf);
        batchkmeans_gui;
        return
    else
        close(gcbf);
        selectroi_gui;
        return
    end
else
    return
end
guidata(hObject, handles);

% --- Executes on key press with focus on ROI_list and none of its controls.
function ROI_list_KeyPressFcn(hObject, eventdata, handles)
% Does the same thing as the above method, but for some reason does not
% work properly when put into a function.

% hObject    handle to ROI_list (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
if ~isfield(handles,'parentMapH')
    return
end

if strcmp(eventdata.Key,'c') && (handles.keyEventStage == 0)
    set(handles.info_text , 'String' , 'Draw an ROI')
    roi=imfreehand(handles.parentMapH);
    handles.roiHandles{handles.roiCounter} = roi;
    handles.roiMasks{handles.roiCounter} = roi.createMask();
    
    % Draws the ROI number on top of the image.
    pos = roi.getPosition();
    textX = 12+(max(pos(: , 1)) + min(pos(: , 1)))/2;
    textY = (max(pos(: , 2)) + min(pos(: , 2)))/2;
    handles.textHandles{handles.roiCounter} = text('position',[textX textY],'fontsize',20 , 'Parent' , ...
                handles.parentMapH , 'Color' , handles.colors(handles.roiCounter, :) ,'string',num2str(handles.roiCounter));
    addtolistbox(handles.ROI_list , num2str(handles.roiCounter));
    
    handles.roiCounter = handles.roiCounter + 1;

elseif strcmp(eventdata.Key,'d') && (handles.keyEventStage == 0)
    indexSelected = get(handles.ROI_list, 'Value');
    deletefromlistbox(handles.ROI_list, indexSelected);
    if numel(handles.roiHandles) > 0
        handles.roiHandles{indexSelected}.delete()
        t = handles.textHandles{indexSelected};
        handles.textHandles(indexSelected) = [];
        delete(t);
        handles.roiHandles(indexSelected) = [];
        handles.roiCounter = handles.roiCounter - 1;
        
        %adjust ROI numbers as needed
        for tt = indexSelected : numel(handles.textHandles)
            prevtxt = get(handles.textHandles{tt} , 'String');
            newtxt = num2str(str2double(prevtxt) - 1);
            set(handles.textHandles{tt} , 'String' , newtxt);
        end
        set(handles.ROI_list , 'String' , num2str([1:handles.roiCounter-1]'))
    end
    
elseif strcmp(eventdata.Key,'b') && (handles.keyEventStage == 1)
    handles.backgroundHandle = drawbackground(handles);

elseif strcmp(eventdata.Key,'return') && (handles.keyEventStage == 1)
    savebackground(hObject, handles);
    return
    
elseif (handles.keyEventStage == 2)
    if strcmp(eventdata.Key,'n')
        close(gcbf);
        batchkmeans_gui;
        return
    else
        close(gcbf);
        selectroi_gui;
        return
    end
else
    return
end
guidata(hObject, handles);


function backgroundHandle = drawbackground(handles)
% Takes the first frame of the first movie.
bkgImage = tiffimagereader(handles.stackDir, handles.stackFile{1});
axes(handles.image_axes);
set(handles.info_text , 'String' , 'Draw a region of background.');
bkgmapH = imshow(imadjust(uint16(bkgImage)));
parentbkgmapH = get(bkgmapH , 'parent');
backgroundHandle=imfreehand(parentbkgmapH);
message = 'Press Return key to save or ''B'' to redraw.';
set(handles.info_text, 'String', message);

function savebackground(hObject, handles)
% Creates a mask from the backgroundHandle and saves it as bkgMask in the
% roi-***.mat file.

%background has not been selected yet so do nothing.
if ~isfield(handles,'backgroundHandle')
    return
end

[~, note, ~] = fileparts(handles.snapFile);
roiFileSavePath = [handles.snapDir 'roi-' note '.mat'];

set(handles.info_text , 'String' , 'Saving the background...')
bkgMask = handles.backgroundHandle.createMask();
disp('Saving background mask...')
save(roiFileSavePath, 'bkgMask' , '-append')
message = ['Background saved! Press ''N'' to go to kbatchmeans. '...
    'Press any other key to repeat selectROI.'];
set(handles.info_text,'String', message);

handles.keyEventStage = 2;
guidata(hObject,handles);



% --- Executes on button press in save_ROI_button.
function save_ROI_button_Callback(hObject, eventdata, handles)
% Converts each of the ROI handles drawn to a logical mask.
% Saves relevant data in a .mat file titled roi-***.mat.
% 
% hObject    handle to save_ROI_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.roiCounter == 1
    warndlg('Please select at least one ROI.')
    return
end

%Parse frame rate
frameRate = str2num(get(handles.frame_rate_text,'String'));
isNotInteger = isempty(frameRate) || rem(frameRate,1) ~= 0;
if isNotInteger
    warndlg('Specified frame rate must be an integer.');
end

nRoi = numel(handles.roiHandles);
handles.roiMasks = cell(1,nRoi);
textPos = cell(1,nRoi);
for iRoi = 1:nRoi
    handles.roiMasks{iRoi} = handles.roiHandles{iRoi}.createMask();
    textPos{iRoi} = get(handles.textHandles{iRoi} , 'position');
end

[~, note, ~] = fileparts(handles.snapFile);
roiFileSavePath = [handles.snapDir 'roi-' note '.mat'];
fprintf('Saving ROIs to %s. \n', roiFileSavePath)

stackPaths = strcat(handles.stackDir,handles.stackFile);
snapPath = [handles.snapDir handles.snapFile];
busyDialog = busydlg('Saving ROIs...');
save(roiFileSavePath, 'stackPaths','snapPath' , 'textPos','frameRate')
save(roiFileSavePath, '-struct','handles','roiMasks','textHandles','-append');
delete(busyDialog);

% disable the event pressing for 'c' and 'd'
handles.keyEventStage = 1;
handles.backgroundHandle = drawbackground(handles);

guidata(hObject, handles);


% --- Executes on button press in trace_button.
function trace_button_Callback(hObject, eventdata, handles)
% Preview the trace of the selected ROI.
%
% hObject    handle to trace_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.tiffStack = tiffstackreader([handles.stackDir handles.stackFile{1}]);
indexSelected = get(handles.ROI_list,'Value');
roiMask = handles.roiHandles{indexSelected}.createMask();
trace = applymask(handles.tiffStack , roiMask);
meanTrace = nnzMeanTrace(trace, roiMask);
clearvars trace;
 
%  subplot(2,1,1)
figure('Position', [100, 100, 800, 200]);
plot(meanTrace)
title(['ROI ' num2str(indexSelected)  ' mean trace'])

% ********** UNUSED GUIDE FUNCTIONS **********

% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over ROI_list.
function ROI_list_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to ROI_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

guidata(hObject, handles);


function frame_rate_text_Callback(hObject, eventdata, handles)
% hObject    handle to frame_rate_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of frame_rate_text as text
%        str2double(get(hObject,'String')) returns contents of frame_rate_text as a double


% --- Executes during object creation, after setting all properties.
function frame_rate_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to frame_rate_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Outputs from this function are returned to the command line.
function varargout = selectroi_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in ROI_list.
function ROI_list_Callback(hObject, eventdata, handles)
% hObject    handle to ROI_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ROI_list contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ROI_list


% --- Executes during object creation, after setting all properties.
function ROI_list_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ROI_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

