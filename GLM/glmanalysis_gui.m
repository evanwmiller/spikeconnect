function varargout = glmanalysis_gui(varargin)
% GLMANALYSIS_GUI GUI to compute coupling filters between neurons.

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @glmanalysis_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @glmanalysis_gui_OutputFcn, ...
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


% --- Executes just before glmanalysis_gui is made visible.
function glmanalysis_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to glmanalysis_gui (see VARARGIN)

% Choose default command line output for glmanalysis_gui
handles.output = hObject;
movegui(gcf,'center')

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes glmanalysis_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Executes on button press in folderButton.
function folderButton_Callback(hObject, eventdata, handles)
% hObject    handle to folderButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
baseDir = uigetdir('' , 'Select a folder');
if baseDir == 0; return; end

couplingFile = folderglmanalysis(baseDir);
if numel(couplingFile) == 0
    error('Error in analyzing spikes-*.m files. Please check directory.');
end

handles.fileText.String = couplingFile;
handles.couplingFilePath = [baseDir filesep couplingFile];
handles = initialize(handles);
updateplot(handles);

% --- Executes on button press in fileButton.
function fileButton_Callback(hObject, eventdata, handles)
% hObject    handle to fileButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[filename, pathname] = uigetfile('*.mat', 'Pick a couplings- file');
if ~startsWith(filename, 'couplings-')
    error('Must select a couplings- file');
end

handles.fileText.String = filename;
handles.couplingFilePath = [pathname filename];
handles = initialize(handles);
updateplot(handles);


% --- Executes on slider movement.
function drivingSlider_Callback(hObject, eventdata, handles)
% hObject    handle to drivingSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.drivingCell = round(get(hObject, 'Value'));
hObject.Value = handles.drivingCell;
updateplot(handles);


% --- Executes on slider movement.
function receivingSlider_Callback(hObject, eventdata, handles)
% hObject    handle to receivingSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.receivingCell = round(hObject.Value);
hObject.Value = handles.receivingCell;
updateplot(handles);


function handles = initialize(handles)
% After setting handles.couplingFilePath, change the properties of the
% sliders based on the number of cells.
handles.data = load(handles.couplingFilePath);

numCells = size(handles.data.couplingFilters, 1);

handles.numCells = numCells
handles.receivingCell = 1;
handles.drivingCell = 1;
set(handles.receivingSlider, 'Min', 1, 'Max', numCells, 'Value', 1, 'SliderStep', [1/numCells 1/numCells]);
set(handles.drivingSlider, 'Min', 1, 'Max', numCells, 'Value', 1, 'SliderStep', [1/numCells 1/numCells]);

function updateplot(h)
axes(h.filterAxes);
h.receivingText.String = sprintf('Receiving Cell: %d', h.receivingCell);
h.drivingText.String = sprintf('Driving Cell: %d', h.drivingCell);
plot(h.data.t, h.data.couplingFilters{h.drivingCell, h.receivingCell});
guidata(gcf, h);

% --- Executes on key press with focus on figure1 or any of its controls.
function figure1_WindowKeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
switch eventdata.Key
    case 'rightarrow'
        if handles.drivingCell < handles.numCells
            handles.drivingCell = handles.drivingCell + 1;
            handles.drivingSlider.Value = handles.drivingCell;
            updateplot(handles)
        end
    case 'leftarrow'
        if handles.drivingCell > 1
            handles.drivingCell = handles.drivingCell - 1;
            handles.drivingSlider.Value = handles.drivingCell;
            updateplot(handles)
        end
    case 'uparrow'
        if handles.receivingCell < handles.numCells
            handles.receivingCell = handles.receivingCell + 1;
            handles.receivingSlider.Value = handles.receivingCell;
            updateplot(handles)
        end
    case 'downarrow'
        if handles.receivingCell > 1
            handles.receivingCell = handles.receivingCell - 1;
            handles.receivingSlider.Value = handles.receivingCell;
            updateplot(handles)
        end
end


% ********** UNUSED GUIDE FUNCTIONS **********
% --- Outputs from this function are returned to the command line.
function varargout = glmanalysis_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes during object creation, after setting all properties.
function receivingSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to receivingSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes during object creation, after setting all properties.
function drivingSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to drivingSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
