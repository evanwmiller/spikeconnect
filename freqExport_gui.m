function varargout = freqExport_gui(varargin)
% FREQEXPORT_GUI MATLAB code for freqExport_gui.fig
%      FREQEXPORT_GUI, by itself, creates a new FREQEXPORT_GUI or raises the existing
%      singleton*.
%
%      H = FREQEXPORT_GUI returns the handle to a new FREQEXPORT_GUI or the handle to
%      the existing singleton*.
%
%      FREQEXPORT_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FREQEXPORT_GUI.M with the given input arguments.
%
%      FREQEXPORT_GUI('Property','Value',...) creates a new FREQEXPORT_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before freqExport_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to freqExport_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help freqExport_gui

% Last Modified by GUIDE v2.5 07-Oct-2016 15:12:45

% Copyright 2016 The Miller Lab, UC Berkeley
% Author: Kaveh Karbasis
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @freqExport_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @freqExport_gui_OutputFcn, ...
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


% --- Executes just before freqExport_gui is made visible.
function freqExport_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to freqExport_gui (see VARARGIN)

% Choose default command line output for freqExport_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes freqExport_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = freqExport_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in export_button.
function export_button_Callback(hObject, eventdata, handles)
% hObject    handle to export_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[xlsxFilename, xlsxPath] = uiputfile({'*.xlsx' ; '*.xls'} , 'Save as' , 'export.xlsx');

exportFiles = cellstr(get(handles.destination_listbox,'String'));
iFreqs_all_files = [];
freqs_all_files = [];
for ff = 1:numel(exportFiles)
    load(exportFiles{ff} , 'freqs' , 'ifreqs','maxcount');
    ifreqs_all = save_ifreq_xlsx(ifreqs , freqs ,maxcount, [xlsxPath xlsxFilename] , ff , exportFiles{ff});
    iFreqs_all_files = [iFreqs_all_files; ifreqs_all];
    freqs_all_files = [freqs_all_files; cell2mat(freqs)'];
    disp(['Saving data to ' xlsxPath xlsxFilename ' ... '])
end
writetable(table(iFreqs_all_files) , [xlsxPath xlsxFilename] ,'Sheet',...
    ff+1,  'Range' , 'A2' , 'WriteVariableNames' , false);
writetable(table({'Inst. Freqs (All Files)'}) ,[xlsxPath xlsxFilename] ,...
    'Sheet', ff+1, 'Range' , 'A1' , 'WriteVariableNames' , false);

writetable(table(freqs_all_files) , [xlsxPath xlsxFilename] ,'Sheet',...
    ff+1,  'Range' , 'C2' , 'WriteVariableNames' , false);
writetable(table({'Frequencies (All Files)'}) ,[xlsxPath xlsxFilename] ,...
    'Sheet', ff+1, 'Range' , 'C1' , 'WriteVariableNames' , false);





% --- Executes on selection change in source_listbox.
function source_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to source_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global src_selected_idx src_selected_str
contents = cellstr(get(hObject,'String'));
src_selected_idx = get(hObject,'Value');
src_selected_str = contents(src_selected_idx);


guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function source_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to source_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in destination_listbox.
function destination_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to destination_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global dest_selected_idx dest_selected_str
contents = cellstr(get(hObject,'String'));
dest_selected_idx = get(hObject,'Value');
dest_selected_str = contents(dest_selected_idx);


% --- Executes during object creation, after setting all properties.
function destination_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to destination_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in add_button.
function add_button_Callback(hObject, eventdata, handles)
% hObject    handle to add_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global src_selected_str src_selected_idx dest_selected_str dest_selected_idx;
pause(0.02)
contents = cellstr(get(handles.source_listbox,'String'));
if ~isempty(contents)
    
    prev_list = get(handles.destination_listbox,'String');

    if isempty(prev_list)
        set(handles.destination_listbox,'String',src_selected_str)
    else

        new_list = [prev_list; src_selected_str];
        set(handles.destination_listbox,'String',new_list)
        contents = cellstr(get(handles.destination_listbox,'String'));
        if ~isempty(contents)
            dest_selected_idx = 1;
            dest_selected_str = contents(dest_selected_idx);
        end
    end

    delete_item_from_listbox(handles.source_listbox , src_selected_idx);
    contents = cellstr(get(handles.source_listbox,'String'));
    if ~isempty(contents)
        src_selected_idx = 1;
        src_selected_str = contents(src_selected_idx);
    end
end
guidata(hObject, handles);


% --- Executes on button press in remove_button.
function remove_button_Callback(hObject, eventdata, handles)
% hObject    handle to remove_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global src_selected_str src_selected_idx dest_selected_str dest_selected_idx;
pause(0.02);
contents = cellstr(get(handles.destination_listbox,'String'));
if ~isempty(contents)
    prev_list = get(handles.source_listbox,'String');

    if isempty(prev_list)
        set(handles.source_listbox,'String',dest_selected_str)
    else

        new_list = [prev_list; dest_selected_str];
        set(handles.source_listbox,'String',new_list)
        contents = cellstr(get(handles.source_listbox,'String'));
        if ~isempty(contents)
           src_selected_idx = 1;
           src_selected_str = contents(src_selected_idx);
        end
    end

    delete_item_from_listbox(handles.destination_listbox , dest_selected_idx);
    contents = cellstr(get(handles.destination_listbox,'String'));

    if ~isempty(contents)
        dest_selected_idx = 1;
        dest_selected_str = contents(dest_selected_idx);
    end
end
guidata(hObject, handles);

% --- Executes on button press in select_files_button.
function select_files_button_Callback(hObject, eventdata, handles)
% hObject    handle to select_files_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global stdFileNames src_selected_str src_selected_idx;
selected_radio = get(handles.folder_selection_radiogroup , 'SelectedObject');
selected_string = get(selected_radio , 'String');
if strcmp(selected_string , 'Recursive')
    baseDir = uigetdir('' , 'Select a folder');
    if(baseDir == 0)
        return
    end
    stdFileNames = recursdir(baseDir , '^ifreqs.*.mat$');
   
elseif strcmp(selected_string , 'Multi-select')
    
    filesnfolders = uipickfiles('REFilter' ,'^ifreqs.*.mat$') ;
    stdFileNames={};
    for fnf = 1:numel(filesnfolders)
        if isdir(filesnfolders{fnf})
            stdFileNames = [stdFileNames recursdir(filesnfolders{fnf} , '^ifreqs.*.mat$')];
        else
            stdFileNames = [stdFileNames filesnfolders{fnf}];
        end
    end
else
    error(['Radio button reading error due to ambiguous radio button string value:' selected_string])
end

set(handles.source_listbox , 'String' ,  stdFileNames)
contents = cellstr(get(handles.source_listbox,'String'));
if ~isempty(contents)
    src_selected_idx = 1;
    src_selected_str = contents(src_selected_idx);
end
guidata(hObject, handles);
