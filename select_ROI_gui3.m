function varargout = select_ROI_gui3(varargin)
% SELECT_ROI_GUI3 MATLAB code for select_ROI_gui3.fig
%      SELECT_ROI_GUI3, by itself, creates a new SELECT_ROI_GUI3 or raises the existing
%      singleton*.
%
%      H = SELECT_ROI_GUI3 returns the handle to a new SELECT_ROI_GUI3 or the handle to
%      the existing singleton*.
%
%      SELECT_ROI_GUI3('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SELECT_ROI_GUI3.M with the given input arguments.
%
%      SELECT_ROI_GUI3('Property','Value',...) creates a new SELECT_ROI_GUI3 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before select_ROI_gui3_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to select_ROI_gui3_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help select_ROI_gui3

% Last Modified by GUIDE v2.5 24-Jan-2017 15:55:50

% Copyright 2016 The Miller Lab, UC Berkeley
% Author: Kaveh Karbasi
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @select_ROI_gui3_OpeningFcn, ...
                   'gui_OutputFcn',  @select_ROI_gui3_OutputFcn, ...
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


% --- Executes just before select_ROI_gui3 is made visible.
function select_ROI_gui3_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to select_ROI_gui3 (see VARARGIN)

% Choose default command line output for select_ROI_gui3
global bkg_curr_val;
bkg_curr_val = 0;
handles.output = hObject;
handles.colors = hsv(25);
% Update handles structure
guidata(hObject, handles);
settings_file = [fileparts(mfilename('fullpath')) filesep 'settings.mat'];
if exist(settings_file,'file')
    load(settings_file)
    set(handles.frame_rate_text, 'String', frame_rate);
else
    set(handles.frame_rate_text, 'String', '200');
end

% UIWAIT makes select_ROI_gui3 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = select_ROI_gui3_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in ROI_list.
function ROI_list_Callback(hObject, eventdata, handles)
% hObject    handle to ROI_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ROI_list contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ROI_list


% --- Executes during object creation, after setting all properties.
function ROI_list_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ROI_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in snap_button.
function snap_button_Callback(hObject, eventdata, handles)
% hObject    handle to snap_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global mapH parentmapH;
global ROI_counter text_handles ROI_handles;
global SnapPathName SnapFileName;
global bkg_curr_val;
bkg_curr_val = 0;
%set(handles.save_ROI_button , 'String' , 'Save ROIs and choose background')
%set(handles.bkg_checkbox , 'Value' , 0);

ROI_handles = {};
text_handles = {};
ROI_counter  = 1;

set(handles.ROI_list , 'String' , '');

handles.colors = handles.colors(randperm(size(handles.colors,1)),:);
% baseDir = 'E:\MillerLabData\Su16Data\ForSTTC\testMultiFolder\Slide 1\';
baseDir = '';
disp('SELECT A SNAP FILE...');
[SnapFileName,SnapPathName] = uigetfile([baseDir '*.tiff'],'Select a .tif SNAP file');
if(SnapFileName == 0)
    return
end

%if a file was selected
handles.curr_snap_filename = SnapFileName;
handles.curr_snap_path = SnapPathName;
set(handles.snap_fn_text , 'String' , [SnapPathName,SnapFileName]);
snap = imread([SnapPathName,SnapFileName]);
set(handles.image_axes , 'Visible' , 'on');
axes(handles.image_axes)
mapH = imshow(imadjust(snap));



parentmapH = get(mapH , 'parent');
set(handles.info_text , 'String' , 'Press ''C'' to continue drawing')
guidata(hObject, handles);

% --- Executes on key press with focus on figure1 and none of its controls.
function figure1_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
global ROI_counter parentmapH ROI_handles text_handles ROI_masks;
if eventdata.Key == 'c'
    set(handles.info_text , 'String' , 'Draw an ROI')
    h=imfreehand(parentmapH);
    ROI_handles{ROI_counter} = h;
    ROI_masks{ROI_counter} = h.createMask();
    pos = h.getPosition();
    textX = 12+(max(pos(: , 1)) + min(pos(: , 1)))/2;
    textY = (max(pos(: , 2)) + min(pos(: , 2)))/2;
    
    text_handles{ROI_counter} = text('position',[textX textY],'fontsize',20 , 'Parent' , ...
                parentmapH , 'Color' , handles.colors(ROI_counter , :) ,'string',num2str(ROI_counter));
    add_items_to_listbox(handles.ROI_list , num2str(ROI_counter));
    
    ROI_counter = ROI_counter + 1;
end

if eventdata.Key == 'd'
    
    index_selected = get(handles.ROI_list,'Value');
    delete_item_from_listbox(handles.ROI_list , index_selected);
    if numel(ROI_handles) > 0
        ROI_handles{index_selected}.delete()
        t = text_handles{index_selected};
        text_handles(index_selected) = [];
        delete(t);
        ROI_handles(index_selected) = [];
        ROI_counter = ROI_counter - 1;
        
        for tt = index_selected : numel(text_handles)

            prevtxt = get(text_handles{tt} , 'String');
            newtxt = num2str(str2double(prevtxt) - 1);
            set(text_handles{tt} , 'String' , newtxt);
        end
        set(handles.ROI_list , 'String' , num2str([1:ROI_counter-1]'))
    end
end
guidata(hObject, handles);


% --- Executes on key press with focus on ROI_list and none of its controls.
function ROI_list_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to ROI_list (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
global ROI_counter parentmapH ROI_handles text_handles;

if eventdata.Key == 'c'
    set(handles.info_text , 'String' , 'Draw an ROI')
    h=imfreehand(parentmapH);
    ROI_handles{ROI_counter} = h;
%     ROI_masks{ROI_counter} = h.createMask();
    pos = h.getPosition();
    textX = 12+(max(pos(: , 1)) + min(pos(: , 1)))/2;
    textY = (max(pos(: , 2)) + min(pos(: , 2)))/2;  
    text_handles{ROI_counter} = text('position',[textX textY],'fontsize',20 , 'Parent' , ...
                parentmapH , 'Color' , handles.colors(ROI_counter , :) ,'string',num2str(ROI_counter));
    add_items_to_listbox(handles.ROI_list , num2str(ROI_counter));
    ROI_counter = ROI_counter + 1;
end

if eventdata.Key == 'd'
    index_selected = get(handles.ROI_list,'Value');
    delete_item_from_listbox(handles.ROI_list , index_selected);
    if numel(ROI_handles) > 0
        ROI_handles{index_selected}.delete()
        t = text_handles{index_selected};
        text_handles(index_selected) = [];
        delete(t);
        ROI_handles(index_selected) = [];
        ROI_counter = ROI_counter - 1;
        
        for tt = index_selected : numel(text_handles)

            prevtxt = get(text_handles{tt} , 'String');
            newtxt = num2str(str2double(prevtxt) - 1);
            set(text_handles{tt} , 'String' , newtxt);
        end
        set(handles.ROI_list , 'String' , num2str([1:ROI_counter-1]'))
    end
end
guidata(hObject, handles);


% --- Executes on button press in save_ROI_button.
function save_ROI_button_Callback(hObject, eventdata, handles)
warning ('off','all');
% hObject    handle to save_ROI_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ROI_handles ROI_counter SnapPathName StackFileName StackPathName bkg_curr_val;
global tiffStack text_handles SnapFileName;

% Error Checking
if ROI_counter == 1
    warndlg('Please select at least one ROI.')
    return
end

frame_rate = str2num(get(handles.frame_rate_text,'String'));
if isempty(frame_rate) || rem(frame_rate,1) ~= 0 %check if integer
    warndlg('Specified frame rate must be an integer.');
end

ROI_masks = {};
textPos = {};
for rr = 1:numel(ROI_handles)
    ROI_masks{rr} = ROI_handles{rr}.createMask();
    textPos{rr} = get(text_handles{rr} , 'position');
end

[file,path,FilterIndex] = uiputfile(fullfile(SnapPathName,'std.mat'),'Save data');
if file == 0
    return
end
if strcmp(file(1:3),'std') == 0
    file = strcat('std-',file);
end
disp(sprintf('Saving to %s.', [path file]))
if FilterIndex~=0
    disp('Saving ROIs and tiff stack...')
    
    wh = busydlg('Saving Data... Please Wait...');
    stackpath = [StackPathName StackFileName];
    snappath = [SnapPathName SnapFileName];
    
    
    save([path file] , 'ROI_masks' , 'stackpath' , 'text_handles' ,'snappath' , 'textPos','frame_rate')
    delete(wh);

    set(handles.info_text , 'String' , 'Data saved! Press any key to continue...');
    if bkg_curr_val == 0
        bkg_image = tiffImageReader(StackPathName, StackFileName{1});
        axes(handles.image_axes);
        set(handles.info_text , 'String' , 'Draw a region of background.');
        bkgmapH = imshow(imadjust(uint16(bkg_image)));
        parentbkgmapH = get(bkgmapH , 'parent');
        h=imfreehand(parentbkgmapH);
        set(handles.info_text , 'String' , 'Saving the background...')
        bkg_mask = h.createMask();
        disp('Saving background mask...')
        save([path file] , 'bkg_mask' , '-append')
        set(handles.info_text , 'String' , 'Background saved! Press any key to continue...')
    end
end
warning ('on','all');
guidata(hObject, handles);

waitforbuttonpress;
close(gcbf)
select_ROI_gui3
% --- Executes on button press in bkg_checkbox.
function bkg_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to bkg_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global bkg_curr_val;

% Hint: get(hObject,'Value') returns toggle state of bkg_checkbox
newval =  get(hObject,'Value');

if bkg_curr_val == 0 && newval == 1
    bkg_curr_val = 1;
    set(handles.save_ROI_button , 'String' , 'Save ROIs')
end
if bkg_curr_val == 1 && newval == 0
    bkg_curr_val = 0;
    set(handles.save_ROI_button , 'String' , 'Save ROIs and choose background')
end
guidata(hObject, handles);

% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over ROI_list.
function ROI_list_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to ROI_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

guidata(hObject, handles);


% --- Executes on button press in stack_button.
function stack_button_Callback(hObject, eventdata, handles)
% hObject    handle to stack_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
warning('off' , 'all');
global StackFileName StackPathName SnapPathName;
global tiffStack;

disp('SELECT A STACK FILE...');
[StackFileName,StackPathName] = uigetfile([SnapPathName '*.tiff'],'Select a .tif STACK file');
if(StackFileName == 0)
    return
end
StackFileName = {StackFileName}; % cast to cell array to maintain compatibility
set(handles.stack_fn_text , 'String' , [StackPathName StackFileName]);
warning('on' , 'all');

% --- Executes on button press in import_stack.
function import_stack_Callback(hObject, eventdata, handles)
% hObject    handle to import_stack (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global SnapFileName SnapPathName StackFileName StackPathName;
global tiffStack;
if(length(SnapPathName) > 0)
    % match all .tiff files except the snap
    StackFileName = currentdir(SnapPathName, '\.tiff', SnapFileName);
    disp('Files Found:')
    disp(StackFileName)
    StackPathName = SnapPathName;
    set(handles.stack_fn_text , 'String' , StackFileName);
else
    disp('Please select a snap first.')
    return
end
if numel(StackFileName) == 0
    disp('No matching .tiff files found.')
end



% --- Executes on button press in trace_button.
function trace_button_Callback(hObject, eventdata, handles)
% hObject    handle to trace_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 global ROI_handles StackPathName StackFileName;
 tiffStack = tiffStackReaderFast([StackPathName StackFileName{1}]);
 index_selected = get(handles.ROI_list,'Value');
 ROI_mask = ROI_handles{index_selected}.createMask();
 trace = applyMask2TiffStack(tiffStack , ROI_mask);
 meanTrace = nnzMeanTrace(trace , ROI_mask);
 clearvars trace;

 
%  subplot(2,1,1)
figure('Position', [100, 100, 800, 200]);
plot(meanTrace)
title(['ROI ' num2str(index_selected)  ' mean trace'])



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
