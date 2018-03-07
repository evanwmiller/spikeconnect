% INTERVAL CALC 
% Calculates average dff values over set intervals near spikes
% Input: Before (int, in frames), After (int, in frames), Directory for
% analysis
% Output: Excel file of averages



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
guidata(hObject, handles);




function [interval, means] = calculatetimes(handles) 
    interval = [];
    for iSpikeFile = 1:numel(handles.spikeFilePaths) 
        load(handles.spikeFilePaths{iSpikeFile} , 'spikeDataArray'); 
        intCell = {};
        meanCell = {};
        for i = 1:numel(spikeDataArray)
            intArray = [];
            spikeTimes = spikeDataArray{i}.rasterSpikeTimes; 
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
            intCell{i} = intArray;
            length = handles.after + handles.before;
            interval = intCell;
            if numel(intCell{i}) > 1
                avg = [];
                for k = 1:length
                    value = mean(intCell{i}(:,k));
                    avg = [avg value];
                    
                end
                meanCell{i} = avg;
            end
            means = meanCell;
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
