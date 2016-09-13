function varargout = batchkmeans_gui(varargin)
% BATCHKMEANS_GUI MATLAB code for batchkmeans_gui.fig
%      BATCHKMEANS_GUI, by itself, creates a new BATCHKMEANS_GUI or raises the existing
%      singleton*.
%
%      H = BATCHKMEANS_GUI returns the handle to a new BATCHKMEANS_GUI or the handle to
%      the existing singleton*.
%
%      BATCHKMEANS_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BATCHKMEANS_GUI.M with the given input arguments.
%
%      BATCHKMEANS_GUI('Property','Value',...) creates a new BATCHKMEANS_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before batchkmeans_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to batchkmeans_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help batchkmeans_gui

% Last Modified by GUIDE v2.5 01-Jul-2016 16:08:25

% Begin initialization code - DO NOT EDIT
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

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes batchkmeans_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = batchkmeans_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in folder_button.
function folder_button_Callback(hObject, eventdata, handles)
% hObject    handle to folder_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global stdFileNames thresh lh dffdist rearm_factor;

set(handles.radiobutton1 , 'Enable' , 'off');
set(handles.radiobutton2 , 'Enable' , 'off');
set(handles.radiobutton3 , 'Enable' , 'off');

baseDir = uigetdir('' , 'Select a folder');
set(handles.folder_text , 'String' , baseDir)
stdFileNames = recursdir(baseDir , '^std.*\.mat$');
window = 50;
K = 3;
rearm_factor = 2;

spikesDFFValues = [];
dffSNRValues = [];
for ff = 1:numel(stdFileNames)

    load(stdFileNames{ff});
    warning('off' , 'all');
    tiffStack = tiffStackReaderFast(stackpath);
    warning('on' , 'all');
    
    selected_radio = get(handles.bkg_radiob , 'SelectedObject');
    selected_string = get(selected_radio , 'String');
    
    [bkg_subtracted_traces , ROI_traces] = getBkgSubtractedTraces(tiffStack , ROI_masks , bkg ,selected_string);

    sizeTraces = size(bkg_subtracted_traces);
    diffFeatures = cell(sizeTraces);
    clusters = cell(sizeTraces);
    spikes_cluster_idx = cell(sizeTraces);
    baseline_cluster_idx = cell(sizeTraces);
    rasterSpikeTimes = cell(sizeTraces);
    dffs = cell(sizeTraces);
    dff_snr = cell(sizeTraces);

    
    for bb = 1:numel(bkg_subtracted_traces)

        diffFeatures{bb} = sliding_window_flattener(bkg_subtracted_traces{bb} , window);
        [clusters{bb} , spikes_cluster_idx{bb} , baseline_cluster_idx{bb} , rasterSpikeTimes{bb} , dffs{bb} , dff_snr{bb}] = ...
                               kmeans_sd_with_dff_thresh2(diffFeatures{bb} ,bkg_subtracted_traces{bb} , K , -10.0);
        rasterSpikeTimes{bb} = burstAggregator(rasterSpikeTimes{bb} , rearm_factor);
        spikesDFFValues = [spikesDFFValues dffs{bb}];
        dffSNRValues = [dffSNRValues dff_snr{bb}];
    end
    [pathstr,t1,t2] = fileparts(stdFileNames{ff}); 
    disp(['Saving data to ' pathstr '\spikesData.mat'])
    save([pathstr '\spikesData.mat'] , 'clusters' , ...
        'spikes_cluster_idx' , 'baseline_cluster_idx' , ...
        'rasterSpikeTimes' , 'dffs' , 'bkg_subtracted_traces' , ...
        'ROI_traces' , 'diffFeatures' , 'snappath' , 'textPos' , 'ROI_masks' , ...
        'dff_snr');
   
end

meandff = nanmean(spikesDFFValues);
thresh = 5;
set(handles.thresh_edit , 'String' , num2str(thresh));
% figure;
binranges = (-0.06 : 0.001 : 0.3);
% binranges = (-0.00 : 0.001 : 2);
dffdist = histc(spikesDFFValues , binranges);
set(handles.dff_axes , 'Visible' , 'on')
axes(handles.dff_axes)
bar(binranges , dffdist , 'histc');
title(['$$\frac{\Delta F}{F}$$ distribution with baseline cluster median as F - ' num2str(sum(~isnan(spikesDFFValues))) ' spikes'] , 'Interpreter' , 'latex')
lh = line([thresh thresh] , [0 max(dffdist)] , 'Color' , 'r');
infoStr = ['Average dF/F = ' num2str(meandff) char(10) 'Median dF/F = ' num2str(nanmedian(spikesDFFValues))] ;

set(handles.dff_info_text , 'String' , infoStr);
set(handles.continue_button , 'Visible' , 'on');


figure;
binranges = (-5 : 0.2 : 40);
dffSNRdist = histc(dffSNRValues , binranges);
bar(binranges , dffSNRdist , 'histc');
title(num2str(sum(~isnan(dffSNRValues))));
figure;

histfit(dffSNRValues , 225 , 'kernel')
figure;
histfit(dffSNRValues , 225 , 'normal')



plot_binned_snr(spikesDFFValues , dffSNRValues , -0.0 : 0.01 : 0.12);

guidata(hObject, handles);


% --- Executes on button press in resolve_dff_button.
function resolve_dff_button_Callback(hObject, eventdata, handles)
% hObject    handle to resolve_dff_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function thresh_edit_Callback(hObject, eventdata, handles)
% hObject    handle to thresh_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of thresh_edit as text
%        str2double(get(hObject,'String')) returns contents of thresh_edit as a double


% --- Executes during object creation, after setting all properties.
function thresh_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to thresh_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in dff_edit_button.
function dff_edit_button_Callback(hObject, eventdata, handles)
% hObject    handle to dff_edit_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global thresh lh dffdist;
thresh = str2double(get(handles.thresh_edit , 'String'));
delete(lh);
lh = line([thresh thresh] , [0 max(dffdist)] , 'Color' , 'r');
guidata(hObject, handles);


% --- Executes on button press in continue_button.
function continue_button_Callback(hObject, eventdata, handles)
% hObject    handle to continue_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global thresh stdFileNames rearm_factor;

% save([pathstr '\spikesData.mat'] , 'thresh' , '-append');
% disp('Threshold saved')

disp('Updating spike times...')
% wh = busydlg('Updating spike times... Please Wait...');
for ff = 1:numel(stdFileNames)
    [pathstr,t1,t2] = fileparts(stdFileNames{ff}); 
    load([pathstr '\spikesData.mat'] , 'rasterSpikeTimes' , 'dff_snr')
    for dd = 1:numel(dff_snr)
        tmp = dff_snr{dd};
        tmp(tmp < thresh) = NaN;
        rasterSpikeTimes{dd} = find(~isnan(tmp));
        rasterSpikeTimes{dd} = burstAggregator(rasterSpikeTimes{dd} , rearm_factor);
    end
    save([pathstr '\spikesData.mat'] ,  'rasterSpikeTimes' ,  '-append');
end
disp('Spike times updated and saved')
% delete(wh);

guidata(hObject, handles);
