function varargout = Karaoke(varargin)
%
%[Function Description]
%This program attempts to create karaoke of a song. It attempts to remove
%voice and then writes it to a new wav file.
%
%[Algorithm]
%This program utilizes the well known fact that voice is recorded equally in both channels
%without any stereo effect.
%First one of the channel is high pass filterd. This is done to protect the
%low end bass which is also recorded equally on both channels. Then this
%channel is subtracted from the other. The commoon part that is voice gets
%cancelled.
%
%Best use set the high pass cut off for 50Hz and try
%
%[Author]
%Shreyes



% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Karaoke_OpeningFcn, ...
                   'gui_OutputFcn',  @Karaoke_OutputFcn, ...
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


% --- Executes just before Karaoke is made visible.
function Karaoke_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Karaoke (see VARARGIN)

% Choose default command line output for Karaoke
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Karaoke wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Karaoke_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes during object creation, after setting all properties.
function path_txt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to path_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in input_btn.
function input_btn_Callback(hObject, eventdata, handles)
% hObject    handle to input_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[file, path] = uigetfile('*.wav','Select a .wav file');
if file == 0
    return
end
set(handles.path_txt,'String',[path file]);


% --- Executes during object creation, after setting all properties.
function out_txt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to out_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in output_btn.
function output_btn_Callback(hObject, eventdata, handles)
% hObject    handle to output_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

out_dir = uigetdir(cd,'Choose output folder');
if out_dir == 0
    return;
end
set(handles.out_txt,'String',out_dir);


% --- Executes on button press in go_btn.
function go_btn_Callback(hObject, eventdata, handles)
% hObject    handle to go_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.path_txt,'Enable','off');
set(handles.input_btn,'Enable','off');
set(handles.out_txt,'Enable','off');
set(handles.output_btn,'Enable','off');
set(handles.fc_slider,'Enable','off');
set(handles.hpcut_txt,'Enable','off');

file = get(handles.path_txt,'String');
try
    [y,Fs,nbits]= wavread(file);
catch
    msgbox('Invalid File');
    set(handles.path_txt,'Enable','on');
    set(handles.input_btn,'Enable','on');
    set(handles.out_txt,'Enable','on');
    set(handles.output_btn,'Enable','on');
    set(handles.fc_slider,'Enable','on');
    set(handles.hpcut_txt,'Enable','on');
    return;
end
if size(y,2) == 1
    msgbox('The selected file is Mono. This algorithm is applicable only for Stereo files.');
    set(handles.path_txt,'Enable','on');
    set(handles.input_btn,'Enable','on');
    set(handles.out_txt,'Enable','on');
    set(handles.output_btn,'Enable','on');
    set(handles.fc_slider,'Enable','on');
    set(handles.hpcut_txt,'Enable','on');
    return;
end

warning off all;
%High pass filter
fc = str2double(get(handles.hpcut_txt,'String'));
fc = round(fc);
if fc > 20
    fp = fc+5;
    fs = fc/(Fs/2);
    fp = fp/(Fs/2);
    [n wn] = buttord(fp,fs,0.5,80);
    [b, a] = butter(5,wn,'High');
    channel_2 = filtfilt(b,a,y(:,2));
else
    channel_2 = y(:,2);
end

%Remove voice
karaoke_wav = y(:,1) - channel_2;

%Write it to a file
[p name ext] = fileparts(file);
dir = get(handles.out_txt,'String');
if isdir(dir)
    wavwrite(karaoke_wav,Fs,nbits,[dir '\' name ext]);
else
    wavwrite(karaoke_wav,Fs,nbits,[cd '\' name ext]);
end

set(handles.path_txt,'Enable','on');
set(handles.input_btn,'Enable','on');
set(handles.out_txt,'Enable','on');
set(handles.output_btn,'Enable','on');
set(handles.fc_slider,'Enable','on');
set(handles.hpcut_txt,'Enable','on');

% --- Executes on slider movement.
function fc_slider_Callback(hObject, eventdata, handles)
% hObject    handle to fc_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

slide_input = get(handles.fc_slider,'Value');
set(handles.hpcut_txt,'String',num2str(slide_input*500));

% --- Executes during object creation, after setting all properties.
function fc_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fc_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes during object creation, after setting all properties.
function hpcut_txt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hpcut_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
