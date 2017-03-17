function varargout = AUCExport_gui(varargin)
% AUCEXPORT_GUI MATLAB code for AUCExport_gui.fig
%      AUCEXPORT_GUI, by itself, creates a new AUCEXPORT_GUI or raises the existing
%      singleton*.
%
%      H = AUCEXPORT_GUI returns the handle to a new AUCEXPORT_GUI or the handle to
%      the existing singleton*.
%
%      AUCEXPORT_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in AUCEXPORT_GUI.M with the given input arguments.
%
%      AUCEXPORT_GUI('Property','Value',...) creates a new AUCEXPORT_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before AUCExport_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to AUCExport_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help AUCExport_gui

% Last Modified by GUIDE v2.5 02-Feb-2017 16:04:33

% Copyright 2016 The Miller Lab, UC Berkeley
% Author: Kaveh Karbasis
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @AUCExport_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @AUCExport_gui_OutputFcn, ...
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


% --- Executes just before AUCExport_gui is made visible.
function AUCExport_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to AUCExport_gui (see VARARGIN)

% Choose default command line output for AUCExport_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes AUCExport_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = AUCExport_gui_OutputFcn(hObject, eventdata, handles) 
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

[xlsxFilename, xlsxPath] = uiputfile({'*.xlsx' ; '*.xls'} , 'Save as' , 'AUC_export.xlsx');

exportFiles = cellstr(get(handles.destination_listbox,'String'));


selected_radio = get(handles.folder_selection_radiogroup , 'SelectedObject');
selected_string = get(selected_radio , 'String');
Alphab = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

if strcmp(selected_string , 'Multi-spike')

 

    wh = busydlg('Saving files...');
    for i = 1:numel(exportFiles)
        load(exportFiles{i})

        curr_f = areas_all;
        curr_avg = areas_avg;
        disp(['saving data from ' exportFiles{i}]);
        writetable(table({exportFiles{i}}) ,[xlsxPath xlsxFilename] ,'Sheet', i, 'Range' , 'A1' , 'WriteVariableNames' , false);
        writetable(table({'Average:'}) ,[xlsxPath xlsxFilename] ,'Sheet', i, 'Range' , 'A3' , 'WriteVariableNames' , false);
        for j = 1:numel(curr_f)

            writetable(table({['ROI' num2str(j)]}) ,[xlsxPath xlsxFilename] ,'Sheet', i, 'Range' , [Alphab(j+1) '2'] , 'WriteVariableNames' , false);
            if numel(curr_f{j}) >0
                writetable(table(curr_avg{j}) , [xlsxPath xlsxFilename] , 'Sheet' , i , 'Range' ,  [Alphab(j+1) '3'], 'WriteVariableNames' , false);
                writetable(table(curr_f{j}) , [xlsxPath xlsxFilename] , 'Sheet' , i , 'Range' ,  [Alphab(j+1) '5'], 'WriteVariableNames' , false);
            end
        end
    end


    delete(wh);
elseif strcmp(selected_string , 'Whole trace')
     wh = busydlg('Saving files...');
   
   
    for i = 1:numel(exportFiles)
        writetable(table({exportFiles{i}}) ,[xlsxPath xlsxFilename] ,'Sheet', i, 'Range' , 'A1' , 'WriteVariableNames' , false);
        
        load(exportFiles{i})
        for j = 1:numel(Areas)
            writetable(table({['ROI' num2str(j)]}) ,[xlsxPath xlsxFilename] ,'Sheet', i, 'Range' , [Alphab(j+1) '2'] , 'WriteVariableNames' , false);
        end
            writetable(table(Areas) , [xlsxPath xlsxFilename] , 'Sheet' , i , 'Range' ,  ['B3'], 'WriteVariableNames' , false);

    end
 delete(wh);

else
    error(['Radio button reading error due to ambiguous radio button string value:' selected_string])
end
    
disp('Done!')



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

set(handles.radiobutton1 , 'Enable' , 'off');
set(handles.radiobutton2 , 'Enable' , 'off');


selected_radio = get(handles.folder_selection_radiogroup , 'SelectedObject');
selected_string = get(selected_radio , 'String');
if strcmp(selected_string , 'Multi-spike')
    baseDir = uigetdir('' , 'Select a folder');
    stdFileNames = recursdir(baseDir , '^AUC_MS.*.mat$');
   
elseif strcmp(selected_string , 'Whole trace')
    
    baseDir = uigetdir('' , 'Select a folder');
    stdFileNames = recursdir(baseDir , '^AUC_SS.*.mat$');
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


% --- Executes on button press in AUC_select_folder_button.
function AUC_select_folder_button_Callback(hObject, eventdata, handles)
% hObject    handle to AUC_select_folder_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Get the directory path
baseDir = '';
dirToProcess = uigetdir(baseDir);
stdFileNames = recursdir([dirToProcess ''] , '^spikesData.*.mat$');
traceLength = 5000;
%-----------------------Filter Parameters--------------------------
fc = 50; % Cutoff frequency
fs = 500; % Sampling frequency
%------------------------------------------------------------------

areas_of = containers.Map;
avg_of = containers.Map;

K = 1;

for ff = 1:numel(stdFileNames)
    disp(stdFileNames{ff});
    load(stdFileNames{ff});
    areas_all = {};
    areas_avg = {};

    [pathstr,name,ext] = fileparts(stdFileNames{ff}); 
    for rr = 1:numel(rasterSpikeTimes)
        areas_ROI = [];
        t = rasterSpikeTimes{rr};
        t = burstAggregator(t , 2); % rearming if needed
        [b,a] = butter(6,fc/(fs/2)); % Create a Butterworth low pass filter (gets rid of any frequency higher than fc)
        trace = ROI_traces{rr}; 
        dataIn = trace';
        dataOut = filter(b,a,dataIn); % Apply the filter to the trace
        avgDataOut = mean(dataOut); % mean of the filtered trace
        dataOut(1:30) = avgDataOut; % The low-pass filter messes up the first few frames. Set the first 30 frames to the average.
         SWFtrace = sliding_window_flattener(dataOut , 100); %Use sliding window filter to level the low-pass-filtered trace
         for i = 1:numel(t)
             toNxt = find_next_ptn_idx_zero(SWFtrace(t(i)+5:end)) + t(i) + 5; %Find the next point that touches zero
             if isempty(toNxt)
                 toNxt = t(i);
             end
             if toNxt + 2 <= traceLength && t(i)-2 > 0
                 areas_ROI = [areas_ROI trapz(t(i)-2:toNxt+2 , SWFtrace(t(i)-2:toNxt+2))]; %Calculate the area under curve
             end
         end
         areas_all{rr} = areas_ROI';
         areas_avg{rr} = mean(areas_ROI);
    end
    save([pathstr filesep 'AUC_MS_' name '.mat'] , 'areas_all', 'areas_avg' , 'ROI_traces' , 'rasterSpikeTimes');
    disp(['Saving to ' pathstr filesep  'AUC_MS_' name '.mat']);
end
%----------------------------------------AUC whole trace-----------
for ff = 1:numel(stdFileNames)
    load(stdFileNames{ff})
    [pathstr,name,ext] = fileparts(stdFileNames{ff}); 
    Areas = [];
    for rr = 1:numel(rasterSpikeTimes)
        trace = ROI_traces{rr}; 
        dataIn = trace';
        dataOut = filter(b,a,dataIn);

  
        avgDataOut = mean(dataOut);
        % dataIn(1:30) = avgDataIn;
        dataOut(1:30) = avgDataOut;
        t = rasterSpikeTimes{rr};

%         ROI_trace = traceFlattener(dataOut' , 1);
        ROI_trace = dataOut';
        curr_clusters = clusters{rr};

        baseline = curr_clusters{baseline_cluster_idx{rr}};
        baseline_med = nanmedian(baseline);
        dff_med = (ROI_trace - baseline_med)./baseline_med;

          dff_med(dff_med<0.007) = 0;
          disp([stdFileNames{ff} '....ROI(' num2str(rr) '):'])

          AUC  = trapz(1:traceLength , dff_med(1:traceLength));
          Areas = [Areas AUC];

    end
    save([pathstr filesep 'AUC_SS_' name '.mat'] , 'Areas', 'ROI_traces' ,...
        'rasterSpikeTimes', 'clusters' , 'baseline_cluster_idx');
    disp(['Saving to ' pathstr filesep  'AUC_SS_' name '.mat']);

end

disp('Done!');


% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1


% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selected_radio = get(handles.folder_selection_radiogroup , 'SelectedObject');
selected_string = get(selected_radio , 'String');
if strcmp(selected_string , 'Multi-spike')
    f1 = figure('units','normalized','outerposition',[0.1 0.6 0.8 0.3]);
    f2 = figure('units','normalized','outerposition',[0.1 0.3 0.8 0.3]);

    exportFiles = cellstr(get(handles.source_listbox,'String'));
    traceLength = 5000;
    %-----------------------Filter Parameters--------------------------
    fc = 50; % Cutoff frequency
    fs = 500; % Sampling frequency
    %------------------------------------------------------------------

    areas_of = containers.Map;
    avg_of = containers.Map;
    K = 1;

    for ff = 1:numel(exportFiles)
        load(exportFiles{ff})
        for rr = 1:numel(rasterSpikeTimes)
            areas_ROI = [];
            t = rasterSpikeTimes{rr};
            t = burstAggregator(t , 2); % rearming if needed
            [b,a] = butter(6,fc/(fs/2)); % Create a Butterworth low pass filter (gets rid of any frequency higher than fc)
            trace = ROI_traces{rr}; 
            dataIn = trace';
            dataOut = filter(b,a,dataIn); % Apply the filter to the trace
            avgDataOut = mean(dataOut); % mean of the filtered trace

            figure(f1);
            plot(trace);
            dataOut(1:30) = avgDataOut; % The low-pass filter messes up the first few frames. Set the first 30 frames to the average.
            figure(f2);
            plot(dataOut-avgDataOut);

             SWFtrace = sliding_window_flattener(dataOut , 100); %Use sliding window filter to level the low-pass-filtered trace
             hold on

             h = plot(SWFtrace , 'r');
             pause(1)

             for i = 1:numel(t)
                 line([t(i)-2  t(i)-2] , get(get(h,'parent'),'YLim')  , 'Color' , 'G')


                 toNxt = find_next_ptn_idx_zero(SWFtrace(t(i)+5:end)) + t(i) + 5; %Find the next point that touches zero

                 if isempty(toNxt)
                     toNxt = t(i);
                 end
                 if toNxt + 2 <= traceLength && t(i)-2>0
                    line([toNxt+2  toNxt+2] , get(get(h,'parent'),'YLim')  , 'Color' , 'K')
                     area(t(i)-2:toNxt+2 , SWFtrace(t(i)-2:toNxt+2)); %Color the area under curve
                     areas_ROI = [areas_ROI trapz(t(i)-2:toNxt+2 , SWFtrace(t(i)-2:toNxt+2))]; %Calculate the area under curve
    %              saveas(f2 , ['.\image3\' num2str(K) '.jpg']); % to save the plots   
                 K = K+1;
                 end

                 pause(0.03)
             end
             areas_all{rr} = areas_ROI';
             areas_avg{rr} = mean(areas_ROI);
             hold off
    %           waitforbuttonpress %uncomment if you want to wait on each ROI



        end
    end
elseif strcmp(selected_string , 'Whole trace')
  
    warning('off' , 'all')
    fc = 50;
    fs = 500;

    std_coeff = 2;

    diff_thresh = 40;
    traceIdx = 1;
    traceLength = 5000;

    [b,a] = butter(6,fc/(fs/2));

  exportFiles = cellstr(get(handles.source_listbox,'String'));
    f = figure('units','normalized','outerposition',[0.1 0.3 0.8 0.6]);

   for ff = 1:numel(exportFiles)
        load(exportFiles{ff})
        
        for rr = 1:numel(rasterSpikeTimes)
            trace = ROI_traces{rr}; 
            dataIn = trace';
            dataOut = filter(b,a,dataIn);

            avgDataIn = mean(dataIn);
            avgDataOut = mean(dataOut);
            % dataIn(1:30) = avgDataIn;
            dataOut(1:30) = avgDataOut;
            t = rasterSpikeTimes{rr};

    %         ROI_trace = traceFlattener(dataOut' , 1);
            ROI_trace = dataOut';
            curr_clusters = clusters{rr};

            baseline = curr_clusters{baseline_cluster_idx{rr}};
            


            baseline_med = nanmedian(baseline);
            baseline_min = min(baseline);

            
            dff_med = (ROI_trace - baseline_med)./baseline_med;

    %         dff_med(dff_med < 0) = 0;

              hold off 
              subplot(2,1,1) 
              trace_med = trace - min(trace);
              plot(trace_med); 
              subplot(2,1,2) 
              dff_med(dff_med<0.007) = 0;

              h = plot(dff_med); hold on
              title([exportFiles{ff} '_ROI' num2str(rr)]);
              disp([exportFiles{ff} '....ROI(' num2str(rr) '):'])
              area(1:traceLength , dff_med(1:traceLength));

            pause(0.5);        


        end

    %   waitforbuttonpress;
    end


    warning('on' , 'all')
else
    error(['Radio button reading error due to ambiguous radio button string value:' selected_string])
end

