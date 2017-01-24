function varargout = trace_browser(varargin)
% TRACE_BROWSER MATLAB code for trace_browser.fig
%      TRACE_BROWSER, by itself, creates a new TRACE_BROWSER or raises the existing
%      singleton*.
%
%      H = TRACE_BROWSER returns the handle to a new TRACE_BROWSER or the handle to
%      the existing singleton*.
%
%      TRACE_BROWSER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TRACE_BROWSER.M with the given input arguments.
%
%      TRACE_BROWSER('Property','Value',...) creates a new TRACE_BROWSER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before trace_browser_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to trace_browser_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help trace_browser

% Last Modified by GUIDE v2.5 07-Jul-2016 16:15:55

% Copyright 2016 The Miller Lab, UC Berkeley
% Author: Kaveh Karbasi
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @trace_browser_OpeningFcn, ...
                   'gui_OutputFcn',  @trace_browser_OutputFcn, ...
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


% --- Executes just before trace_browser is made visible.
function trace_browser_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to trace_browser (see VARARGIN)

% Choose default command line output for trace_browser
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes trace_browser wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = trace_browser_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in files_listbox.
function files_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to files_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns files_listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from files_listbox
global bkg_sub_traces_of stdFileNames curr_file_idx snapimg_of textPos_of ROI_masks_of;

cla(handles.image_axes);
index_selected = get(hObject,'Value');
ROIsList = 1:numel(bkg_sub_traces_of(stdFileNames{index_selected}));
set(handles.ROIs_listbox , 'String' , num2str(ROIsList'))
curr_file_idx = index_selected;

set(handles.ROIs_listbox , 'Value' , 1)

axes(handles.image_axes)
ROI_masks = ROI_masks_of(stdFileNames{curr_file_idx});
curr_image = snapimg_of(stdFileNames{curr_file_idx});
curr_txt = textPos_of(stdFileNames{curr_file_idx});
for ii = 1:numel(ROI_masks)
    curr_image = curr_image + uint16(ROI_masks{ii}*20000);
   
    text('position' , curr_txt{ii} ,'fontsize',20 , 'Parent' , ...
                handles.image_axes , 'Color' , 'r' ,'string', num2str(ii));
end
 imshow(imadjust(curr_image));
for ii = 1:numel(ROI_masks)
   text('position' , curr_txt{ii} ,'fontsize',20 , 'Parent' , ...
                handles.image_axes , 'Color' , 'r' ,'string', num2str(ii));
end

set(handles.image_axes , 'YTick' , []);
set(handles.image_axes , 'XTick' , []);
title('Area snapshot')

set(handles.image_axes , 'Visible' , 'on')

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function files_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to files_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in folder_button.
function folder_button_Callback(hObject, eventdata, handles)
% hObject    handle to folder_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global bkg_sub_traces_of rasterSpikeTimes_of stdFileNames curr_file_idx;
global ROI_traces_of dffs_of diffFeatures_of traceLength snapimg_of textPos_of ROI_masks_of;
baseDir = uigetdir('' , 'Select a folder');
set(handles.folder_text , 'String' , baseDir)
set(handles.uipanel1 , 'Visible' , 'on')
stdFileNames = recursdir(baseDir , '^spikesData.*.mat$');
if isempty(stdFileNames)
    errordlg('No files found');
else
    set(handles.files_listbox , 'String' , stdFileNames);
    bkg_sub_traces_of = containers.Map;
    rasterSpikeTimes_of = containers.Map;
    ROI_traces_of = containers.Map;
    dffs_of = containers.Map;
    diffFeatures_of = containers.Map;
    snapimg_of = containers.Map;
    textPos_of = containers.Map;
    ROI_masks_of = containers.Map;
    

    
    for ff = 1:numel(stdFileNames)
        load(stdFileNames{ff} , 'rasterSpikeTimes' , 'bkg_subtracted_traces' , ...
            'ROI_traces' , 'dffs' , 'diffFeatures' , 'snappath' , 'textPos' , 'ROI_masks')
        bkg_sub_traces_of(stdFileNames{ff}) = bkg_subtracted_traces;
        rasterSpikeTimes_of(stdFileNames{ff}) = rasterSpikeTimes;
        ROI_traces_of(stdFileNames{ff}) = ROI_traces;
        dffs_of(stdFileNames{ff}) = dffs;
        diffFeatures_of(stdFileNames{ff}) = diffFeatures;
        snapimg_of(stdFileNames{ff}) = imread(snappath);
        textPos_of(stdFileNames{ff}) = textPos;
        ROI_masks_of(stdFileNames{ff}) = ROI_masks;
        clearvars 'rasterSpikeTimes'  'bkg_subtracted_traces'
    end

    ROIsList = 1:numel(bkg_sub_traces_of(stdFileNames{1}));
    curr_file_idx = 1;
    set(handles.ROIs_listbox , 'String' , num2str(ROIsList'))
    
    curr_traces = bkg_sub_traces_of(stdFileNames{curr_file_idx});
    curr_trace = curr_traces{1};
    traceLength = numel(curr_trace);

end


axes(handles.image_axes)
ROI_masks = ROI_masks_of(stdFileNames{curr_file_idx});
curr_image = snapimg_of(stdFileNames{curr_file_idx});
curr_txt = textPos_of(stdFileNames{curr_file_idx});
for ii = 1:numel(ROI_masks)
    curr_image = curr_image + uint16(ROI_masks{ii}*20000);
   
    text('position' , curr_txt{ii} ,'fontsize',20 , 'Parent' , ...
                handles.image_axes , 'Color' , 'r' ,'string', num2str(ii));
end
 imshow(imadjust(curr_image));
for ii = 1:numel(ROI_masks)
   text('position' , curr_txt{ii} ,'fontsize',20 , 'Parent' , ...
                handles.image_axes , 'Color' , 'r' ,'string', num2str(ii));
end

set(handles.image_axes , 'YTick' , []);
set(handles.image_axes , 'XTick' , []);
title('Area snapshot')

set(handles.image_axes , 'Visible' , 'on')
guidata(hObject, handles);


% --- Executes on selection change in ROIs_listbox.
function ROIs_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to ROIs_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ROIs_listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ROIs_listbox
global bkg_sub_traces_of rasterSpikeTimes_of stdFileNames curr_file_idx;
global ROI_traces_of dffs_of diffFeatures_of curr_ROI_idx traceLength snapimg_of;

curr_rasterTimes = rasterSpikeTimes_of(stdFileNames{curr_file_idx});
index_selected = get(hObject , 'Value');
curr_ROI_idx = index_selected;



axes(handles.raster_axes);
cla(handles.raster_axes);
t = curr_rasterTimes{index_selected};

for ll = 1:numel(t)
    line([t(ll)  t(ll)] , [0.0  1.0] , 'Color' , 'k')
end
line([traceLength traceLength] , [0.0 1.0] , 'Color' , 'w');
line([1 1] , [0.0 1.0] , 'Color' , 'w');
title('Spike train')

axes(handles.raw_axes)
curr_ROI_traces = ROI_traces_of(stdFileNames{curr_file_idx});
plot(curr_ROI_traces{index_selected});
title('Raw trace')

set(handles.raw_axes , 'Visible' , 'on')
set(handles.raster_axes , 'Visible' , 'on')


% figure;
% subplot(2,1,1)
% curr_dffs = dffs_of(stdFileNames{curr_file_idx});
% plot(curr_dffs{index_selected});
% title('deltaF/F')
% 
% subplot(2,1,2)
% curr_traces = bkg_sub_traces_of(stdFileNames{curr_file_idx});
% curr_trace = curr_traces{index_selected};
% plot(curr_trace)
% title('Bkg subtracted/corrected')


guidata(hObject, handles);





% --- Executes during object creation, after setting all properties.
function ROIs_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ROIs_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function uipushtool3_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to uipushtool3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global stdFileNames curr_file_idx curr_ROI_idx;
traceIm = frame2im(getframe(get(handles.raw_axes , 'parent')));


curr_file = stdFileNames{curr_file_idx};
[pathstr,~ ,~] = fileparts(curr_file);
wh = busydlg('Saving figure snapshot...');
imwrite(traceIm , [pathstr  '\ROI_' num2str(curr_ROI_idx) '_trace.jpg'])

delete(wh)
guidata(hObject, handles);


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global rasterSpikeTimes_of stdFileNames curr_file_idx traceLength;

curr_raster = rasterSpikeTimes_of(stdFileNames{curr_file_idx});

raster_plot(curr_raster , traceLength , 'Raster Plot')
