% INTERVAL CALC 
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



function varargout = intervalcalc(varargin)
% intervalcalc MATLAB code for intervalcalc.fig
%      intervalcalc, by itself, creates a new intervalcalc or raises the existing
%      singleton*.
%
%      H = intervalcalc returns the handle to a new intervalcalc or the handle to
%      the existing singleton*.
%
%      intervalcalc('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in intervalcalc.M with the given input arguments.
%
%      intervalcalc('Property','Value',...) creates a new intervalcalc or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before intervalcalc_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to intervalcalc_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help intervalcalc

% Last Modified by GUIDE v2.5 20-Feb-2018 00:41:22

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
set(handles.folderText , 'String' , handles.baseDir)
spikeFilePaths = recursdir(handles.baseDir , '^spikes-.*.mat$');
if isempty(spikeFilePaths)
    errordlg('No files found.');
    return;
end
handles.spikeFilePaths = spikeFilePaths; %spikes-*.mat files
handles.roiFilePaths = recursdir(baseDir , '^roi-.*.mat$'); 
guidata(hObject, handles);




function [interval, means] = calculatetimes(handles) 
    rois = [];
    for iRoiFile = 1:numel(handles.roiFilePaths) 
        load(handles.roiFilePaths{iRoiFile} , 'assignments');
        for i = 1:numel(assignments)
            if strcmp(assignments{i}, 'DGC')
                rois(i) = 1;
            end
            if strcmp(assignments{i}, 'Inhib')
                rois(i) = 2;
            end
            if strcmp(assignments{i}, 'CA1')
                rois(i) = 3;
            end
            if strcmp(assignments{i}, 'CA3')
                rois(i) = 4;
            end
            if strcmp(assignments{i}, 'Unknown')
                rois(i) = 5;
            end
        end
    end
    interval = [];
    for iSpikeFile = 1:numel(handles.spikeFilePaths) 
        load(handles.spikeFilePaths{iSpikeFile} , 'spikeDataArray'); 
        intCell = {};
        meanCell = [];
        for i = 1:numel(spikeDataArray)
            intArray = [];
            spikeTimes = spikeDataArray{i}.rasterSpikeTimes; 
            if numel(spikeTimes) == 0
                intArray(1) = NaN;
            else
                for spike = spikeTimes
                    data = []; 
                    start = spike - handles.before; 
                    if start < 1
                       continue; 
                    end
                    final = spike + handles.after; 
                    if final > numel(spikeDataArray{i}.dffTrace)
                        continue; 
                    end
                    for int = (start : 1 : final) 
                        data = [data spikeDataArray{i}.dffTrace(int)]; 
                    end
                    intArray = cat(1, intArray, data); 
                end
            end
            box = {};
            box{1} = assignments{i};
            box{2} = intArray;
            intCell{i} = box;
            length = handles.after + handles.before + 1;
            interval = intCell;
           
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
                avg = cat(2, rois(i), avg);
                meanCell = cat(1, meanCell, avg); 
            end
            means = sortrows(meanCell);
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
