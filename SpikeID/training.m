function varargout = training(varargin)
%TRAINING GUI to classify spikes. Select the root directory of a drive that
%contains spike files. If the program has been initialized in this
%directory before, resume operation. Otherwise, create an index of all the
%spike files and display spikes to be classified. 

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @training_OpeningFcn, ...
                   'gui_OutputFcn',  @training_OutputFcn, ...
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


% --- Executes just before training is made visible.
function training_OpeningFcn(hObject, eventdata, h, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% h    structure with h and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Choose default command line output for training
h.output = hObject;

movegui(gcf,'center')
%set instructions
instructions = sprintf(['Instructions: ' ...
                'Browse for a top-level folder containing spikes- files. '...
                'Use the < and > buttons to navigate left and right. The'...
                ' >> button will skip to the next unassigned spike.' ...
                ' Classify the indicated spike by using the number keys '...
                'or by clicking on the buttons. Assignments will be saved '...
                'periodically and when the GUI is closed.']);
set(h.instructionsText,'String',instructions);

h.currSpikeIndex = [0 0 0];
h.currFileNum = 0;

% Update h structure
guidata(hObject, h);


function h = getprevspike(hObject,h)
% GETPREVSPIKE Changes h.nextSpikeIndex to the previous spike.
prevSpikeSet = false;
file = h.currSpikeIndex(1);
roi = h.currSpikeIndex(2);
spike = h.currSpikeIndex(3);
h = loadspikefile(hObject, h, file);

while ~prevSpikeSet
    if spike > 1
        h.nextSpikeIndex = [file roi spike-1];
        prevSpikeSet = true;
    elseif roi > 1
        roi = roi - 1;
        spike = numel(h.spikeDataArray{roi}.rasterSpikeTimes)+1;
    elseif file > 1
        file = file - 1;
        h = loadspikefile(hObject, h, file);
        roi = numel(h.spikeDataArray);
        spike = numel(h.spikeDataArray{roi}.rasterSpikeTimes)+1;
    else
        %exit loop but do not change nextSpikeIndex
        prevSpikeSet = true; 
    end
end
guidata(hObject,h);


function h = getnextspike(hObject,h)
% GETNEXTSPIKE Changes h.nextSpikeIndex to the previous spike.
nextSpikeSet = false;
file = h.currSpikeIndex(1);
roi = h.currSpikeIndex(2);
spike = h.currSpikeIndex(3);
h = loadspikefile(hObject, h, file);

while ~nextSpikeSet
    if spike < numel(h.spikeDataArray{roi}.rasterSpikeTimes)
        h.nextSpikeIndex = [file roi spike+1];
        nextSpikeSet = true;
    elseif roi < numel(h.spikeDataArray)
        roi = roi + 1;
        spike = 0;
    elseif file < h.fileNumToPath.Count
        file = file +1;
        h = loadspikefile(hObject, h, file);
        roi = 1;
        spike = 0;
    else
        %exit loop but do not change nextSpikeIndex
        nextSpikeSet = true; 
    end
end
guidata(hObject,h);


function h = loadspikefile(hObject,h,fileNum)
% LOADSPIKEFILE If the fileNum is different than what's currently
% displayed, loads h.frameRate, h.spikeDataArray, and
% h.dffArray of the new fileNum.
if fileNum == h.currFileNum; return; end;

relPath = h.fileNumToPath(fileNum);
absPath = [h.baseDir relPath];
load(absPath,'spikeDataArray','frameRate','bkgSubtractedTraces');
h.frameRate = frameRate;
h.spikeDataArray = spikeDataArray;
h.dffArr = calcdff(bkgSubtractedTraces, spikeDataArray);
h.currFileNum = fileNum;

guidata(hObject,h);


function dffArr = calcdff(traces,spikeDataArray)
dffArr = cell(size(traces));
for i = 1:numel(traces)
    trace = traces{i};
    spikeData = spikeDataArray{i};
    clusters = spikeData.clusters;
    baseline = clusters{spikeData.baselineClusterIndex};
    baselineMedian = nanmedian(baseline);
    dffArr{i} = (trace-baselineMedian)/baselineMedian;
end


function displaynextspike(hObject,h)
file = h.nextSpikeIndex(1);
roi = h.nextSpikeIndex(2);
spike = h.nextSpikeIndex(3);

h = loadspikefile(hObject,h,file);
if (roi ~= h.currSpikeIndex(2)) || (file ~= h.currSpikeIndex(1)) 
    axes(h.spikeAxes);
    hold off;
    plot(h.dffArr{roi});
    xlim = get(gca,'xlim');
    axis([xlim min(h.dffArr{roi})*1.2 max(h.dffArr{roi})*1.2]);
    hold on;
    h.featureVectorArr = extractfeatures(h.dffArr{roi}, h.spikeDataArray{roi}, h.frameRate);
end
if (spike ~= h.currSpikeIndex(3)) || (roi ~= h.currSpikeIndex(2))
    if isfield(h,'arrow'); delete(h.arrow); end;
    axes(h.spikeAxes);
    xlim = get(gca,'xlim');
    spikeTime = h.spikeDataArray{roi}.rasterSpikeTimes(spike);
    dff = h.dffArr{roi}(spikeTime);
    
    % increment spikeTime while the dff is going up to find the peak
    while (spikeTime < xlim(2)) && (h.dffArr{roi}(spikeTime+1) > dff)
        spikeTime = spikeTime + 1;
        dff = h.dffArr{roi}(spikeTime);
    end
        
    h.arrow = annotation('arrow');
    set(h.arrow,'parent',gca);
    startPos = [spikeTime, dff*1.05]; 
    distance = [0 -0.00001]; %this makes the arrow point downwards
    set(h.arrow,'position',[startPos distance]);
    statusString = sprintf(['File %d of %d \n',...
        'ROI %d of %d \n',...
        'Spike %d of %d \n',...
        '%d spikes assigned'],...
        file, h.fileNumToPath.Count, roi, numel(h.spikeDataArray), ...
        spike,numel(h.spikeDataArray{roi}.rasterSpikeTimes),h.totalCount);
    set(h.statusText, 'String', statusString);
end

h.currSpikeIndex = h.nextSpikeIndex;

guidata(hObject,h);


function assigncurrentspike(hObject,h,assignment)
% ASSIGNCURRENTSPIKE Appends the assignment to the feature vector of this
% spike, and saves it in the cell array. Displays the next spike.
file = h.currSpikeIndex(1);
roi = h.currSpikeIndex(2);
spike = h.currSpikeIndex(3);
featureVector = h.featureVectorArr{spike};
h.assignments{file}{roi}{spike} = [featureVector assignment];
h.totalCount = h.totalCount + 1;
h = getnextspike(hObject, h);
if mod(h.totalCount,20) == 0
    saveassignments(h);
end
displaynextspike(hObject, h);


function resumefromfile(hObject,h)
saveData = load(h.saveFile);

h.nextSpikeIndex = saveData.currSpikeIndex;

h.fileNumToPath = saveData.fileNumToPath;
h.pathToFileNum = saveData.pathToFileNum;
h.totalCount = saveData.totalCount;

h.assignments = saveData.assignments;

displaynextspike(hObject,h);


function initialize(hObject,h)
spikeFiles = recursdir(h.baseDir , '^spikes-.*.mat$');
% remove the baseDir path
for i = 1:numel(spikeFiles)
    spikeFiles{i} = strrep(spikeFiles{i}, h.baseDir, '');
end
h.fileNumToPath = containers.Map('KeyType' , 'int32' , 'ValueType' , 'char');
h.pathToFileNum = containers.Map('KeyType' , 'char' , 'ValueType' , 'int32');
h.nextSpikeIndex = [1 1 1];
h.assignments = {};
h.totalCount = 0;

for fileNum = 1:numel(spikeFiles)
    filePath = spikeFiles{fileNum};
    h.fileNumToPath(fileNum) = filePath;
    h.pathToFileNum(filePath) = fileNum;
end
save(h.saveFile,'-struct','h','fileNumToPath','pathToFileNum','assignments','totalCount');
displaynextspike(hObject,h);


function saveassignments(h)
save(h.saveFile,'-append','-struct','h','currSpikeIndex','assignments','totalCount');

% --- Executes on button press in browseButton.
function browseButton_Callback(hObject, eventdata, h)
% hObject    handle to browseButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% h    structure with h and user data (see GUIDATA)
baseDir = uigetdir('', 'Select a folder');
if baseDir == 0; return; end;
h.baseDir = baseDir;

set(h.folderText , 'String' , h.baseDir)

h.saveFile = [baseDir filesep 'trainingdata.mat'];
if exist(h.saveFile,'file')
    resumefromfile(hObject,h);
else
    initialize(hObject, h);
end

% --- Executes on button press in previousButton.
function previousButton_Callback(hObject, eventdata, h)
% hObject    handle to previousButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% h    structure with h and user data (see GUIDATA)
if ~isfield(h,'baseDir'); return; end;
h = getprevspike(hObject, h);
displaynextspike(hObject, h);

% --- Executes on button press in nextButton.
function nextButton_Callback(hObject, eventdata, h)
% hObject    handle to nextButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% h    structure with h and user data (see GUIDATA)
if ~isfield(h,'baseDir'); return; end;
h = getnextspike(hObject, h);
displaynextspike(hObject, h);


% --- Executes on button press in spikeButton.
function spikeButton_Callback(hObject, eventdata, h)
% hObject    handle to spikeButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% h    structure with h and user data (see GUIDATA)
if ~isfield(h,'baseDir'); return; end;
assigncurrentspike(hObject, h,1);


% --- Executes on button press in surfButton.
function surfButton_Callback(hObject, eventdata, h)
% hObject    handle to surfButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% h    structure with h and user data (see GUIDATA)
if ~isfield(h,'baseDir'); return; end;
assigncurrentspike(hObject, h,2);


% --- Executes on button press in slowRepolButton.
function slowRepolButton_Callback(hObject, eventdata, h)
% hObject    handle to slowRepolButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% h    structure with h and user data (see GUIDATA)
if ~isfield(h,'baseDir'); return; end;
assigncurrentspike(hObject, h,3);


% --- Executes on button press in otherButton.
function otherButton_Callback(hObject, eventdata, h)
% hObject    handle to otherButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% h    structure with h and user data (see GUIDATA)
if ~isfield(h,'baseDir'); return; end;
assigncurrentspike(hObject, h,4);


% --- Executes on button press in onStateButton.
function onStateButton_Callback(hObject, eventdata, h)
% hObject    handle to onStateButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% h    structure with h and user data (see GUIDATA)
if ~isfield(h,'baseDir'); return; end;
assigncurrentspike(hObject, h,5);



% --- Executes on key press with focus on figure1 and none of its controls.
function figure1_KeyPressFcn(hObject, eventdata, h)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
switch eventdata.Key
    case '1'
        assigncurrentspike(hObject,h,1);
    case '2'
        assigncurrentspike(hObject,h,2);
    case '3'
        assigncurrentspike(hObject,h,3);
    case '4'
        assigncurrentspike(hObject,h,4);
    case '5'
        assigncurrentspike(hObject,h,5);
end


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, h)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% h    structure with h and user data (see GUIDATA)
if isfield(h,'baseDir')
    saveassignments(h);
end
delete(hObject);


% --- Outputs from this function are returned to the command line.
function varargout = training_OutputFcn(hObject, eventdata, h)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% h    structure with h and user data (see GUIDATA)

% Get default command line output from h structure
varargout{1} = h.output;

