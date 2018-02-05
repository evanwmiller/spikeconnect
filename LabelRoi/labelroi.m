function varargout = labelroi(varargin)
%LABELROI GUI to classify cells as DGC, CA1, CA3, or inhibitory. After the
%user selects a folder, it will looks for a label-*.png file which has the
%circled ROIs. Then, after the user classifies each ROI, the results are
%saved into the corresponding roi-*.mat file under "assignments".

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @labelroi_OpeningFcn, ...
                   'gui_OutputFcn',  @labelroi_OutputFcn, ...
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


% --- Executes just before labelroi is made visible.
function labelroi_OpeningFcn(hObject, eventdata, h, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% h    structure with h and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Choose default command line output for labelroi
h.output = hObject;

movegui(gcf,'center')
%set instructions
instructions = sprintf(['Instructions: ' ...
                'Browse for folder containing a label-*.png file. '...
                ' Classify the indicated ROI by using the number keys '...
                'or by clicking on the buttons. Assignments will be saved '...
                'when the GUI is closed or when user selects a new folder.']);
set(h.instructionsText,'String',instructions);

h.neuronTypes = {'DGC','Inhib','CA1','CA3','Unknown'};
h.buttons = {h.dgcButton, h.inhibButton, h.ca1Button, h.ca3Button, h.unknownButton};
set(h.statusText,'FontSize',16,'FontWeight','Bold');
% Update h structure
guidata(hObject, h);


function h = getprevroi(hObject,h)
% GETPREVROI Return to previous ROI and update statusText.
if h.currRoiNum > 1
    h.currRoiNum = h.currRoiNum - 1;
end
status = sprintf('Select label for ROI %d',h.currRoiNum);
set(h.statusText,'String',status);
displaycurrentassignment(hObject,h);


function h = getnextroi(hObject,h)
% GETNEXTROI Advance to next ROI and update statusText.
if h.currRoiNum < h.totalRoiNum
    h.currRoiNum = h.currRoiNum + 1;
end
status = sprintf('Select label for ROI %d',h.currRoiNum);
set(h.statusText,'String',status);
displaycurrentassignment(hObject,h);

function displaycurrentassignment(hObject,h)
% DISPLAYCURRENTASSIGNMENT If the current ROI already has an assignment,
% make the associated button green.

assignment = find(strcmp(h.neuronTypes,h.assignments{h.currRoiNum}));
h = resetcolors(h); %reset to gray
if ~isempty(assignment)
    set(h.buttons{assignment},'BackgroundColor',[0 0.8 0]);
end
guidata(hObject,h);


function h = resetcolors(h)
% RESETCOLORS Makes the background color of the assignments buttons gray.
for i = 1:numel(h.neuronTypes)
    set(h.buttons{i},'BackgroundColor',[0.94 0.94 0.94]);
end


function assigncurrentroi(hObject,h,assignment)
% ASSIGNCURRENTROI
h.assignments{h.currRoiNum} = h.neuronTypes{assignment};
getnextroi(hObject,h);

function saveassignments(h)
save(h.roiFile,'-append','-struct','h','assignments');

% --- Executes on button press in browseButton.
function browseButton_Callback(hObject, eventdata, h)
% hObject    handle to browseButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% h    structure with h and user data (see GUIDATA)
if isfield(h,'baseDir')
    saveassignments(h);
end

baseDir = uigetdir('', 'Select a folder');
if baseDir == 0; return; end;
h.baseDir = baseDir;

set(h.folderText , 'String' , h.baseDir)

pngFileName = currentdir(h.baseDir , '^label-.*.png$');
snap = imread([h.baseDir filesep pngFileName{1}]);
set(h.figAxes , 'Visible' , 'on');
axes(h.figAxes);
imshow(snap);

roiFileName = currentdir(h.baseDir , '^roi-.*.mat$');
h.roiFile = [h.baseDir filesep roiFileName{1}];
h.roiData = load(h.roiFile);
h.totalRoiNum = numel(h.roiData.roiMasks);
h.currRoiNum = 0;
if isfield(h.roiData,'assignments')
    h.assignments = h.roiData.assignments;
else
    h.assignments = cell(1,h.totalRoiNum);
end

getnextroi(hObject,h);


% --- Executes on button press in previousButton.
function previousButton_Callback(hObject, eventdata, h)
% hObject    handle to previousButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% h    structure with h and user data (see GUIDATA)
if ~isfield(h,'baseDir'); return; end;
getprevroi(hObject, h);


% --- Executes on button press in nextButton.
function nextButton_Callback(hObject, eventdata, h)
% hObject    handle to nextButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% h    structure with h and user data (see GUIDATA)
if ~isfield(h,'baseDir'); return; end;
getnextroi(hObject, h);


% --- Executes on button press in dgcButton.
function dgcButton_Callback(hObject, eventdata, h)
% hObject    handle to dgcButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% h    structure with h and user data (see GUIDATA)
if ~isfield(h,'baseDir'); return; end;
assigncurrentroi(hObject, h,1);


% --- Executes on button press in inhibButton.
function inhibButton_Callback(hObject, eventdata, h)
% hObject    handle to inhibButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% h    structure with h and user data (see GUIDATA)
if ~isfield(h,'baseDir'); return; end;
assigncurrentroi(hObject, h,2);


% --- Executes on button press in ca1Button.
function ca1Button_Callback(hObject, eventdata, h)
% hObject    handle to ca1Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% h    structure with h and user data (see GUIDATA)
if ~isfield(h,'baseDir'); return; end;
assigncurrentroi(hObject, h,3);


% --- Executes on button press in ca3Button.
function ca3Button_Callback(hObject, eventdata, h)
% hObject    handle to ca3Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% h    structure with h and user data (see GUIDATA)
if ~isfield(h,'baseDir'); return; end;
assigncurrentroi(hObject, h,4);

% --- Executes on button press in unknownButton.
function unknownButton_Callback(hObject, eventdata, h)
% hObject    handle to unknownButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~isfield(h, 'baseDir'); return; end;
assigncurrentroi(hObject, h, 5);

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
        assigncurrentroi(hObject,h,1);
    case '2'
        assigncurrentroi(hObject,h,2);
    case '3'
        assigncurrentroi(hObject,h,3);
    case '4'
        assigncurrentroi(hObject,h,4);
    case '5'
        assigncurrentroi(hObject,h,5);
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
function varargout = labelroi_OutputFcn(hObject, eventdata, h)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% h    structure with h and user data (see GUIDATA)

% Get default command line output from h structure
varargout{1} = h.output;
