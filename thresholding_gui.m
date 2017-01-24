function varargout = thresholding_gui(varargin)
% THRESHOLDING_GUI MATLAB code for thresholding_gui.fig
%      THRESHOLDING_GUI, by itself, creates a new THRESHOLDING_GUI or raises the existing
%      singleton*.
%
%      H = THRESHOLDING_GUI returns the handle to a new THRESHOLDING_GUI or the handle to
%      the existing singleton*.
%
%      THRESHOLDING_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in THRESHOLDING_GUI.M with the given input arguments.
%
%      THRESHOLDING_GUI('Property','Value',...) creates a new THRESHOLDING_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before thresholding_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to thresholding_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help thresholding_gui

% Last Modified by GUIDE v2.5 21-Oct-2016 16:02:23

% Copyright 2016 The Miller Lab, UC Berkeley
% Author: Kaveh Karbasi
global rearm_factor;
rearm_factor = 2;

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @thresholding_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @thresholding_gui_OutputFcn, ...
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


% --- Executes just before thresholding_gui is made visible.
function thresholding_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to thresholding_gui (see VARARGIN)

% Choose default command line output for thresholding_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes thresholding_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = thresholding_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in preview_button.
function preview_button_Callback(hObject, eventdata, handles)
% hObject    handle to preview_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global stdFileNames thresh rearm_factor;


contents = cellstr(get(handles.rearm_popup,'String'));
selected_idx = get(handles.rearm_popup,'Value');
selected_str = contents{selected_idx};


rearm_factor = str2num(selected_str);
ROI_counts = 0;
axhandles = createROIfigure;
for ff = 1:numel(stdFileNames)
    file_path = strsplit(stdFileNames{ff},{'/','\\'});
    area_label = file_path{end-1};
    spikeDataNote = file_path{end};
    hyphen_index = strfind(spikeDataNote,'-');
    movie_label = '';
    if ~isempty(hyphen_index)
        period_index = strfind(spikeDataNote,'.');
        movie_label = spikeDataNote(hyphen_index(1):period_index(1)-1);
    end 
    roi_label = 1;
    load(stdFileNames{ff} , 'rasterSpikeTimes' , 'ROI_traces' , 'dff_snr' )
    for dd = 1:numel(rasterSpikeTimes)
        ROI_counts = ROI_counts + 1;
        tmp = dff_snr{dd};
        tmp(tmp < thresh) = NaN;
        rasterSpikeTimes{dd} = find(~isnan(tmp));
        rasterSpikeTimes{dd} = burstAggregator(rasterSpikeTimes{dd} , rearm_factor);
        
        
        if mod(ROI_counts , 9) ~= 0
            
            axes(axhandles{mod(ROI_counts , 9)}('trace'))
            plot(ROI_traces{dd})
            traceLength = numel(ROI_traces{dd});
            
            axes(axhandles{mod(ROI_counts , 9)}('spikes'))
            t = rasterSpikeTimes{dd};
            for ll = 1:numel(t)
                line([t(ll)  t(ll)] , [0.0  1.0] , 'Color' , 'k')
            end
            line([traceLength traceLength] , [0.0 1.0] , 'Color' , 'w');
            line([1 1] , [0.0 1.0] , 'Color' , 'w');
            title([area_label movie_label ' ROI ' int2str(roi_label)]);
            roi_label = roi_label + 1;
            
        else
            axes(axhandles{9}('trace'));
            plot(ROI_traces{dd})
            
            axes(axhandles{9}('spikes'));
            t = rasterSpikeTimes{dd};
            for ll = 1:numel(t)
                line([t(ll)  t(ll)] , [0.0  1.0] , 'Color' , 'k')
            end
            line([traceLength traceLength] , [0.0 1.0] , 'Color' , 'w');
            line([1 1] , [0.0 1.0] , 'Color' , 'w');
            title([area_label movie_label ' ROI ' int2str(roi_label)]);
            roi_label = roi_label + 1;
            axhandles = createROIfigure;
        end
    end    

end
guidata(hObject, handles);

% --- Executes on button press in save_button.
function save_button_Callback(hObject, eventdata, handles)
% hObject    handle to save_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global stdFileNames thresh rearm_factor;

contents = cellstr(get(handles.rearm_popup,'String'));
selected_idx = get(handles.rearm_popup,'Value');
selected_str = contents{selected_idx};


rearm_factor = str2num(selected_str);

for ff = 1:numel(stdFileNames)
    load(stdFileNames{ff} , 'rasterSpikeTimes' , 'dff_snr' , 'ROI_traces')
    ifreqs = {};
    freqs = {};
    file_path = strsplit(stdFileNames{ff},{'/','\\'});
    spikeDataNote = file_path{end};
    hyphen_index = strfind(spikeDataNote,'-');
    ifreq_note = '';
    if ~isempty(hyphen_index)
        period_index = strfind(spikeDataNote,'.');
        ifreq_note = spikeDataNote(hyphen_index(1):period_index(1)-1);
    end
    
    for dd = 1:numel(dff_snr)
        tmp = dff_snr{dd};
        tmp(tmp < thresh) = NaN;
        rasterSpikeTimes{dd} = find(~isnan(tmp));
       
        rasterSpikeTimes{dd} = burstAggregator(rasterSpikeTimes{dd} , rearm_factor);
        [ifreqs{dd} , freqs{dd}] = ifreq(rasterSpikeTimes{dd}); 
        freqs{dd} = freqs{dd}/10;
    end
    if exist(stdFileNames{ff}, 'file')
    save(stdFileNames{ff} ,  'rasterSpikeTimes' ,   '-append');
    else
        error('No spikesData.mat file exists')
    end
    [pathstr,t1,t2] = fileparts(stdFileNames{ff}); 
    filename = ['ifreqs' ifreq_note '.mat'];
    if exist([pathstr filesep filename], 'file')
      save([pathstr filesep filename] , 'ifreqs' , 'freqs' , '-append')
    else
      save([pathstr filesep filename], 'ifreqs' , 'freqs')
    end
    
end
disp('Spike times updated and saved')
% delete(wh);

guidata(hObject, handles);


function thresh_box_Callback(hObject, eventdata, handles)
% hObject    handle to thresh_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of thresh_box as text
%        str2double(get(hObject,'String')) returns contents of thresh_box as a double


% --- Executes during object creation, after setting all properties.
function thresh_box_CreateFcn(hObject, eventdata, handles)
% hObject    handle to thresh_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in set_thresh_button.
function set_thresh_button_Callback(hObject, eventdata, handles)
% hObject    handle to set_thresh_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global thresh lh dffSNRdist;
thresh = str2double(get(handles.thresh_box , 'String'));
delete(lh);
lh = line([thresh thresh] , [0 max(dffSNRdist)] , 'Color' , 'r');
guidata(hObject, handles);

% --- Executes on button press in select_file_button.
function select_file_button_Callback(hObject, eventdata, handles)

% hObject    handle to select_file_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global stdFileNames;

dffSNRValues = [];

selected_radio = get(handles.folder_selection_radiogroup , 'SelectedObject');
selected_string = get(selected_radio , 'String');
if strcmp(selected_string , 'Recursive')
    disp('rec')
    baseDir = uigetdir('' , 'Select a folder');
    stdFileNames = recursdir(baseDir , '^spikesData.*.mat$')
   
elseif strcmp(selected_string , 'Multi-select')
    disp('ms')
    stdFileNames = uipickfiles('REFilter' ,'^spikesData.*.mat$') ;
else
    error(['Radio button reading error due to ambiguous radio button string value:' selected_string])
end

if isempty(stdFileNames)
    errordlg('No files found');
else

    for ff = 1:numel(stdFileNames)
        load(stdFileNames{ff} , 'dff_snr' )
        for bb = 1:numel(dff_snr)
            dffSNRValues = [dffSNRValues dff_snr{bb}];
        end
       
    end
    plot_distribution(dffSNRValues , handles.dist_axes, hObject, handles)
end

guidata(hObject, handles);



function plot_distribution(dffSNRValues , axes_handle , hObject, handles)
% dffSNRValues: A vector containg SNRs of all spikes
% axes_handle:  Axes on which distribution is displayed

global lh thresh dffSNRdist;

thresh = 5;
set(axes_handle , 'Visible' , 'on')
axes(axes_handle);
binranges = (-5 : 0.2 : 40);
dffSNRdist = histc(dffSNRValues , binranges);
bar(binranges , dffSNRdist , 'histc');

title('SNR of $$\frac{\Delta F}{F}$$ distribution'  , 'Interpreter' , 'latex')
lh = line([thresh thresh] , [0 max(dffSNRdist)] , 'Color' , 'r');
set(handles.thresh_box , 'String' , num2str(thresh));
guidata(hObject, handles);


% --- Executes on selection change in rearm_popup.
function rearm_popup_Callback(hObject, eventdata, handles)
% hObject    handle to rearm_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns rearm_popup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from rearm_popup


% --- Executes during object creation, after setting all properties.
function rearm_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rearm_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
