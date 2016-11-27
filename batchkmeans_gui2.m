function varargout = batchkmeans_gui2(varargin)
% BATCHKMEANS_GUI2 MATLAB code for batchkmeans_gui2.fig
%      BATCHKMEANS_GUI2, by itself, creates a new BATCHKMEANS_GUI2 or raises the existing
%      singleton*.
%
%      H = BATCHKMEANS_GUI2 returns the handle to a new BATCHKMEANS_GUI2 or the handle to
%      the existing singleton*.
%
%      BATCHKMEANS_GUI2('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BATCHKMEANS_GUI2.M with the given input arguments.
%
%      BATCHKMEANS_GUI2('Property','Value',...) creates a new BATCHKMEANS_GUI2 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before batchkmeans_gui2_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to batchkmeans_gui2_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help batchkmeans_gui2

% Last Modified by GUIDE v2.5 20-Nov-2016 22:18:06

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @batchkmeans_gui2_OpeningFcn, ...
                   'gui_OutputFcn',  @batchkmeans_gui2_OutputFcn, ...
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


% --- Executes just before batchkmeans_gui2 is made visible.
function batchkmeans_gui2_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to batchkmeans_gui2 (see VARARGIN)

% Choose default command line output for batchkmeans_gui2
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes batchkmeans_gui2 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = batchkmeans_gui2_OutputFcn(hObject, eventdata, handles) 
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

global stdFileNames thresh lh dffdist rearm_factor dffSNRdist;

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
    [stdpath,stdname,stdext] = fileparts(stdFileNames{ff});
    for curr_file_index = 2:numel(stackpath)
        curr_file_name = stackpath{curr_file_index};
        curr_file_path = [stackpath{1} curr_file_name];
        warning('off' , 'all');
        tiffStack = tiffStackReaderFast(curr_file_path);
        warning('on' , 'all');
    
        selected_radio = get(handles.bkg_radiob , 'SelectedObject');
        selected_string = get(selected_radio , 'String');

        [bkg_subtracted_traces , ROI_traces] = getBkgSubtractedTraces(tiffStack , ROI_masks , bkg_cell_stack{curr_file_index-1},selected_string);

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
                                   kmeans_sd_with_dff_thresh3(diffFeatures{bb} ,bkg_subtracted_traces{bb} , K , -10.0);
            rasterSpikeTimes{bb} = burstAggregator(rasterSpikeTimes{bb} , rearm_factor);
            spikesDFFValues = [spikesDFFValues dffs{bb}];
            dffSNRValues = [dffSNRValues dff_snr{bb}];
        end
        
        note = '';
        if strcmp(stdname(4),'-') == 1
            note = [note stdname(4:end)];
        end
        if isstrprop(curr_file_name(end-5),'digit')
            note = [note '-' curr_file_name(end-5)];
        end
        [pathstr,t1,t2] = fileparts(stdFileNames{ff});
        disp(['Saving data to ' pathstr '/spikesData' note '.mat'])
        save([pathstr '/spikesData' note '.mat'] , 'clusters' , ...
            'spikes_cluster_idx' , 'baseline_cluster_idx' , ...
            'rasterSpikeTimes' , 'dffs' , 'bkg_subtracted_traces' , ...
            'ROI_traces' , 'diffFeatures' , 'snappath' , 'textPos' , 'ROI_masks' , ...
            'dff_snr');
    end
end
guidata(hObject, handles);
