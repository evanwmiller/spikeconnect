function varargout = thresholding_gui(varargin)
% THRESHOLDING_GUI GUI for setting threshold and rearm factor for spikes.
%   Instructions: After using batchkmeans_gui to cluster each of the
%   spikes, use this GUI to visualize the distribution of delta-f over f
%   and set a threshold for what is considered a spike.
%

% Copyright 2016 The Miller Lab, UC Berkeley
% Author: Kaveh Karbasi

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
movegui(gcf,'center') 

%set rearm factor to 3 by default
set(handles.rearm_popup,'Value',3);

% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in select_file_button.
function select_file_button_Callback(hObject, eventdata, handles)

% hObject    handle to select_file_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
dffSnrValues = [];

selectedRadio = get(handles.folder_selection_radiogroup , 'SelectedObject');
selectedString = get(selectedRadio , 'String');
if strcmp(selectedString , 'Recursive')
    baseDir = uigetdir('' , 'Select a folder');
    if baseDir == 0
        return
    end
    handles.spikeFilePaths = recursdir(baseDir , '^spikes.*.mat$');
    
elseif strcmp(selectedString , 'Multi-select')
    handles.spikeFilePaths = uipickfiles('REFilter' ,'^spikes.*.mat$');
    if handles.spikeFilePaths == 0
        return
    end
else
    error(['Radio button reading error due to ambiguous radio button string value:' selectedString])
end

if isempty(handles.spikeFilePaths)
    errordlg('No files found');
else
    %aggregate dffSnr of all ROIs from selected files to plot distribution
    for iSpikeFile = 1:numel(handles.spikeFilePaths)
        load(handles.spikeFilePaths{iSpikeFile} , 'spikeDataArray');
        for i = 1:numel(spikeDataArray)
            dffSnrValues = [dffSnrValues spikeDataArray{i}.dffSnr];
        end
    end
    plotdistribution(dffSnrValues, hObject, handles);
    % update to include lineHandle (added in plotdistribution)
    handles=guidata(gcbo);
end

guidata(hObject, handles);


function plotdistribution(dffSNRValues, hObject, handles)
% dffSNRValues: A vector containg SNRs of all spikes

handles.threshold = 5;
set(handles.dist_axes , 'Visible' , 'on')
axes(handles.dist_axes);
binranges = (-5 : 0.2 : 40);
handles.dffSnrDist = histc(dffSNRValues , binranges);
bar(binranges , handles.dffSnrDist , 'histc');

title('SNR of $$\frac{\Delta F}{F}$$ distribution'  , 'Interpreter' , 'latex')
handles.lineHandle = line([handles.threshold handles.threshold] , [0 max(handles.dffSnrDist)] , 'Color' , 'r');
set(handles.thresh_box , 'String' , num2str(handles.threshold));

guidata(hObject, handles);


% --- Executes on button press in set_thresh_button.
function set_thresh_button_Callback(hObject, eventdata, handles)
% Sets handles.threshold and readjusts the threshold line.

% hObject    handle to set_thresh_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.threshold = str2double(get(handles.thresh_box , 'String'));
delete(handles.lineHandle);
handles.lineHandle = line([handles.threshold handles.threshold],...
    [0 max(handles.dffSnrDist)] , 'Color' , 'r');

guidata(hObject, handles);


% --- Executes on button press in preview_button.
function preview_button_Callback(hObject, eventdata, handles)
% hObject    handle to preview_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.rearmFactor = getrearmfactor(handles);

roiCounts = 0;
axhandles = createpreviewfigure;
for iSpikeFile = 1:numel(handles.spikeFilePaths)
    roiLabel = 1;
    load(handles.spikeFilePaths{iSpikeFile} ,'spikeDataArray' ,'roiTraces' )
    fprintf('Movie %d: %s \n', iSpikeFile,handles.spikeFilePaths{iSpikeFile});
    for i = 1:numel(spikeDataArray)
        roiCounts = roiCounts + 1;
        tmp = spikeDataArray{i}.dffSnr;
        tmp(tmp < handles.threshold) = NaN;
        spikeDataArray{i}.rasterSpikeTimes = find(~isnan(tmp));
        spikeDataArray{i}.rasterSpikeTimes = ...
            burstaggregator(spikeDataArray{i}.rasterSpikeTimes, handles.rearmFactor);
        
        %plot in groups of 3 by 3
        if mod(roiCounts , 9) ~= 0
            axes(axhandles{mod(roiCounts , 9)}('trace'))
            plot(roiTraces{i})
            traceLength = numel(roiTraces{i});
            
            axes(axhandles{mod(roiCounts , 9)}('spikes'))
            t = spikeDataArray{i}.rasterSpikeTimes;
            for ll = 1:numel(t)
                line([t(ll)  t(ll)] , [0.0  1.0] , 'Color' , 'k')
            end
            line([traceLength traceLength] , [0.0 1.0] , 'Color' , 'w');
            line([1 1] , [0.0 1.0] , 'Color' , 'w');
            title(sprintf('Movie %d ROI %d', iSpikeFile, roiLabel));
            roiLabel = roiLabel + 1;
            
        else
            axes(axhandles{9}('trace'));
            plot(roiTraces{i})
            
            axes(axhandles{9}('spikes'));
            t = spikeDataArray{i}.rasterSpikeTimes;
            for ll = 1:numel(t)
                line([t(ll)  t(ll)] , [0.0  1.0] , 'Color' , 'k')
            end
            line([traceLength traceLength] , [0.0 1.0] , 'Color' , 'w');
            line([1 1] , [0.0 1.0] , 'Color' , 'w');
            title(sprintf('Movie %d ROI %d', iSpikeFile, roiLabel));
            roiLabel = roiLabel + 1;
            axhandles = createpreviewfigure;
        end
    end    

end
guidata(hObject, handles);

% --- Executes on button press in save_button.
function save_button_Callback(hObject, eventdata, handles)
% hObject    handle to save_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.rearmFactor = getrearmfactor(handles);

for iSpikeFile = 1:numel(handles.spikeFilePaths)
    load(handles.spikeFilePaths{iSpikeFile}, 'spikeDataArray', ...
        'roiTraces', 'frameRate');
    ifreqs = {};
    freqs = {};
    % maxCount determines height of matrix for excel exporting
    maxCount = 0;
    
    % get number of frames per video
    nFrame = numel(spikeDataArray{1}.dffSnr);
    
    for i = 1:numel(spikeDataArray)
        %replace subtreshold events with NaN
        tmp = spikeDataArray{i}.dffSnr;
        tmp(tmp < handles.threshold) = NaN;
        
        spikeDataArray{i}.rasterSpikeTimes = find(~isnan(tmp));
        spikeDataArray{i}.rasterSpikeTimes = ...
            burstaggregator(spikeDataArray{i}.rasterSpikeTimes , handles.rearmFactor);
        
        [ifreqs{i} , freqs{i}, count] = ...
            ifreq(spikeDataArray{i}.rasterSpikeTimes,frameRate, nFrame); 
        if count > maxCount
            maxCount = count;
        end
    end
    save(handles.spikeFilePaths{iSpikeFile} ,'spikeDataArray' ,'-append');
    
    [~,movieName,~] = fileparts(handles.spikeFilePaths{iSpikeFile});
    % 8 is length of 'spikes-' tag
    nameWithoutPrefix = movieName(8:end);
    filename = ['ifreqs-' nameWithoutPrefix '.mat'];
    if exist([pathstr filesep filename], 'file')
      save([pathstr filesep filename] , 'ifreqs' , 'freqs' , 'maxCount', '-append')
    else
      save([pathstr filesep filename], 'ifreqs' , 'freqs','maxCount')
    end
    
end
disp('Spike times updated and saved.')

guidata(hObject, handles);

function rearmFactor = getrearmfactor(handles)
% Reads the rearm factor from user selection.
contents = cellstr(get(handles.rearm_popup,'String'));
selectedIndex = get(handles.rearm_popup,'Value');
selectedStr = contents{selectedIndex};
rearmFactor = str2num(selectedStr);

% ********** UNUSED GUIDE FUNCTIONS ********** %

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


% --- Outputs from this function are returned to the command line.
function varargout = thresholding_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

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
