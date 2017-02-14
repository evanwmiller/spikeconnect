function varargout = prefs_gui(varargin)
% PREFS_GUI MATLAB code for prefs_gui.fig
%      PREFS_GUI, by itself, creates a new PREFS_GUI or raises the existing
%      singleton*.
%
%      H = PREFS_GUI returns the handle to a new PREFS_GUI or the handle to
%      the existing singleton*.
%
%      PREFS_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PREFS_GUI.M with the given input arguments.
%
%      PREFS_GUI('Property','Value',...) creates a new PREFS_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before prefs_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to prefs_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help prefs_gui

% Last Modified by GUIDE v2.5 01-Feb-2017 02:38:29

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @prefs_gui_OpeningFcn, ...
    'gui_OutputFcn',  @prefs_gui_OutputFcn, ...
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


% --- Executes just before prefs_gui is made visible.
function prefs_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to prefs_gui (see VARARGIN)

% Choose default command line output for prefs_gui
handles.output = hObject;
movegui(gcf,'center')

%Load current preferences
prefsFile = [fileparts(mfilename('fullpath')) filesep 'prefs.mat'];
if exist(prefsFile,'file')
    load(prefsFile)
    set(handles.frame_rate_text, 'String', frame_rate);
else
    set(handles.frame_rate_text, 'String', '500');
end

% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in save_button.
function save_button_Callback(hObject, eventdata, handles)
% Check validity of inputs and save in prefs.mat.
%
% hObject    handle to save_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
prefsFile = [fileparts(mfilename('fullpath')) filesep 'prefs.mat'];
frameRate = str2num(get(handles.frame_rate_text,'String'));
if ~isempty(frameRate) && rem(frameRate,1) == 0 %check if integer
    if exist(prefsFile,'file')
        save(prefsFile,'frameRate','-append');
    else
        save(prefsFile,'frameRate');
    end
    close all;
else
    warndlg('Specified frame rate must be an integer.');
end

% --- Executes on button press in cancel_button.
function cancel_button_Callback(hObject, eventdata, handles)
% hObject    handle to cancel_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close all;

% --- Outputs from this function are returned to the command line.
function varargout = prefs_gui_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


function frame_rate_text_Callback(hObject, eventdata, handles)
% hObject    handle to frame_rate_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of frame_rate_text as text
%        str2double(get(hObject,'String')) returns contents of frame_rate_text as a double


% --- Executes during object creation, after setting all properties.
function frame_rate_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to frame_rate_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end