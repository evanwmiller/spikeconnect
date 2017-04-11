function varargout = batchkmeans_gui(varargin)
% BATCHKMEANS_GUI GUI for running k-means clustering on batch of files
% (after ROI selection).
%   Instructions: Select the folder with the results from selectROI_gui
%   Workflow:
%       1.  Recursively find all relevant files.
%       2.  Generate traces for each ROI.
%       3.  Use k-means clustering to identify possible spikes,
%           subthreshold events, and baselines.
%       4.  Save preliminary spikesData to spikesData.mat.
%

% Copyright 2016 The Miller Lab, UC Berkeley
% Author: Kaveh Karbasi

% --- Initialization code from GUIDE.
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @batchkmeans_gui_OpeningFcn, ...
    'gui_OutputFcn',  @batchkmeans_gui_OutputFcn, ...
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


% --- Executes just before batchkmeans_gui is made visible.
function batchkmeans_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to batchkmeans_gui (see VARARGIN)

% Choose default command line output for batchkmeans_gui
handles.output = hObject;
handles.listenForTKey = 0;
% Update handles structure
guidata(hObject, handles);
movegui(gcf,'center')

% UIWAIT makes batchkmeans_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Executes on button press in folder_button.
function folder_button_Callback(hObject, eventdata, handles)
% hObject    handle to folder_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.radiobutton1 , 'Enable' , 'off');
set(handles.radiobutton2 , 'Enable' , 'off');
set(handles.radiobutton3 , 'Enable' , 'off');

baseDir = uigetdir('' , 'Select a folder');
if baseDir == 0
    set(handles.radiobutton1 , 'Enable' , 'on');
    set(handles.radiobutton2 , 'Enable' , 'on');
    set(handles.radiobutton3 , 'Enable' , 'on');
    return
end
handles.listenForTKey = 0;
set(handles.folder_text , 'String' , baseDir)
roiFilePaths = recursdir(baseDir , '^roi.*\.mat$');
WINDOW = 50;
K = 3;
REARM_FACTOR = 2;

for iRoiFile = 1:numel(roiFilePaths)
    load(roiFilePaths{iRoiFile});
    [roiPath,roiName,roiExt] = fileparts(roiFilePaths{iRoiFile});
    for iStack = 1:numel(stackPaths)
        msg = sprintf('Processing dataset %d of %d, movie %d of %d...',...
            iRoiFile,numel(roiFilePaths),iStack,numel(stackPaths));
        set(handles.info_txt , 'String' , msg);
        currentStackPath = stackPaths{iStack};
        tiffStack = tiffstackreader(currentStackPath);
        
        % Generate traces for each ROI in this movie.
        selectedRadio = get(handles.bkg_radiob , 'SelectedObject');
        selectedString = get(selectedRadio, 'String');
        [bkgSubtractedTraces , roiTraces] = computetraces...
            (tiffStack, roiMasks, bkgMask, selectedString);
        
        % K-means clustering
        nTrace = numel(bkgSubtractedTraces);
        diffFeatures = cell(1,nTrace);
        spikeDataArray = cell(1,nTrace);
        
        for iTrace = 1:nTrace
            diffFeatures{iTrace} = slidingwindowflattener(...
                bkgSubtractedTraces{iTrace} , WINDOW);
            spikeDataArray{iTrace} = spikekmeans(diffFeatures{iTrace},...
                bkgSubtractedTraces{iTrace}, K);
            spikeDataArray{iTrace}.rasterSpikeTimes = burstaggregator(...
                spikeDataArray{iTrace}.rasterSpikeTimes, REARM_FACTOR);
        end
        
        [stackDir,stackName,~] = fileparts(currentStackPath);
        saveDir = [stackDir '/spikes-' stackName '.mat'];
        disp(['Saving data to ' saveDir])
        save(saveDir,'spikeDataArray','frameRate','bkgSubtractedTraces' ,...
         'roiTraces','diffFeatures','snapPath', 'textPos', 'roiMasks');
        backgroundOption = selectedString;
        save(saveDir,'backgroundOption','-append');
        
    end
end
set(handles.info_txt , 'String' , 'Done! Press ''T'' to proceed to thresholding or select another folder for processing.');
handles.listenForTKey = 1;

guidata(hObject, handles);


% --- Executes on key press with focus on folder_button and none of its controls.
function folder_button_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
if (handles.listenForTKey) && strcmp(eventdata.Key,'t')
    close(gcbf)
    thresholding_gui;
end

function figure1_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
if (handles.listenForTKey) && strcmp(eventdata.Key,'t')
    close(gcbf)
    thresholding_gui;
end

% ********** UNUSED GUIDE FUNCTIONS **********

% --- Outputs from this function are returned to the command line.
function varargout = batchkmeans_gui_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

function figure1_KeyReleaseFcn(hObject, eventdata, handles)
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
