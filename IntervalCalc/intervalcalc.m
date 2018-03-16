function varargout = intervalcalc(varargin)
% intervalcalc MATLAB code for intervalcalc.fig
%
% Calculates average dff values over set intervals near spikes
% Input: Before (int), After (int), Directory for
% analysis
% Before and after values indicate interval size
% Time is expressed in frames
% Output: meantrace.mat file containing dff trace for spike intervals and
% mean trace
% IntervalTrace: 1x2 cell containing ROI assignment and trace matrix
% FOR MEANTRACE MATRIX: First column is ROI assignments:
% 1 = DGC
% 2 = Inhib
% 3 = CA1
% 4 = CA3
% 5 = Unknown
% 6 = No assignment

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @intervalcalc_OpeningFcn, ...
                   'gui_OutputFcn',  @intervalcalc_OutputFcn, ...
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



% --- Executes just before intervalcalc is made visible.
function intervalcalc_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to intervalcalc (see VARARGIN)

% Choose default command line output for intervalcalc
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes intervalcalc wait for user response (see UIRESUME)
% uiwait(handles.figure1);



% --- Outputs from this function are returned to the command line.
function varargout = intervalcalc_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



% --- Executes on button press in browsebutton.
function browsebutton_Callback(hObject, eventdata, handles)
% hObject    handle to browsebutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
baseDir = uigetdir('', 'Select a folder');
if baseDir == 0; return; end;
handles.baseDir = baseDir;
set(handles.folderText , 'String' , baseDir)
handles.spikeFilePaths = recursdir(baseDir , '^spikes-.*.mat$');
handles.roiFilePaths = recursdir(baseDir , '^roi-.*.mat$'); 
if isempty(handles.spikeFilePaths)
    errordlg('No files found.');
    return;
end
guidata(hObject, handles);


function [interval, totalMeans] = calculatetimes(handles) 
rois = [];
noAssignments = false;
if isempty(handles.roiFilePaths)
    noAssignments = true;
else
    load(handles.roiFilePaths{1}, 'assignments');
    if isempty(assignments)
        noAssignments = true;
    else
        for i = 1:numel(assignments)
            rois(i) = getvalueofassignment(assignments{i});
        end
    end
end


interval = [];
totalMeans = [];
index = 0;
for iSpikeFile = 1:numel(handles.spikeFilePaths) 
    load(handles.spikeFilePaths{iSpikeFile}, 'spikeDataArray');
    intCell = {};
    meanCell = [];
    for i = 1:numel(spikeDataArray)
        intArray = [];
        spikeTimes = spikeDataArray{i}.rasterSpikeTimes; 
        if numel(spikeTimes) == 0
            intArray(1) = NaN;
        else
            for spike = spikeTimes
                start = spike - handles.before;
                final = spike + handles.after;
                if start < 1 || final > numel(spikeDataArray{i}.dffTrace)
                    continue; 
                end
                data = spikeDataArray{i}.dffTrace(start:final); 
                intArray = [intArray; data]; 
            end
        end

        box = {};
        if noAssignments == true
            box{1} = 'No assignment';
        else
            box{1} = assignments{i};
        end
        box{2} = intArray;
        intCell{i} = box;
        length = handles.after + handles.before + 1;
        

        if numel(intCell{i}{2}) > 0
            avg = [];
            if isnan(intCell{i}{2})
                for k = 1:length
                    avg = [avg NaN];
                end
            else
                for k = 1:length
                    value = mean(intCell{i}{2}(:,k));
                    avg = [avg value];
                end
            end
            if noAssignments == true
                avg = cat(2, 0, avg);
            else
                avg = cat(2, rois(i), avg);
            end
            meanCell = [meanCell; avg]; 
        end
        
    end
    interval = [interval intCell];
    totalMeans = [totalMeans; meanCell];
    if noAssignments == false
        totalMeans = sortrows(totalMeans);
    end
end



% --- Executes during object creation, after setting all properties.
function before_box_Callback(hObject, eventdata, handles)
% hObject    handle to before_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes during object creation, after setting all properties.
function after_box_Callback(hObject, eventdata, handles)
% hObject    handle to after_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in exportbutton.
function exportbutton_Callback(hObject, eventdata, handles)
% hObject    handle to exportbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.before = str2double(get(handles.before_box , 'String'));
handles.after = str2double(get(handles.after_box , 'String'));

[intervalTrace, meanTrace] = calculatetimes(handles);

saveDir = [handles.baseDir '\meantrace.mat']; 
save(saveDir, 'intervalTrace', 'meanTrace'); 
