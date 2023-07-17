function varargout = flyBowl(varargin)
% FLYBOWL MATLAB code for flyBowl.fig
%      FLYBOWL, by itself, creates a new FLYBOWL or raises the existing
%      singleton*.
%
%      H = FLYBOWL returns the handle to a new FLYBOWL or the handle to
%      the existing singleton*.
%
%      FLYBOWL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FLYBOWL.M with the given input arguments.
%
%      FLYBOWL('Property','Value',...) creates a new FLYBOWL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before flyBowl_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to flyBowl_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help flyBowl

% Last Modified by GUIDE v2.5 25-Apr-2016 16:40:47

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @flyBowl_OpeningFcn, ...
                   'gui_OutputFcn',  @flyBowl_OutputFcn, ...
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


% --- Executes just before flyBowl is made visible.
function flyBowl_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to flyBowl (see VARARGIN)

% Choose default command line output for flyBowl
handles.output = hObject;

if nargin<4 
      portNum = 'COM5';
else
      portNum = varargin{1};
end


handles.s1 = serial(portNum, 'BaudRate', 115200, 'Terminator', 'CR');
fopen(handles.s1);
% Update handles structure
handles.blinkOn = 0;
handles.blinkOff = 0;
handles.LEDpattern = logical([1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]);
guidata(hObject, handles);

% UIWAIT makes flyBowl wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = flyBowl_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on slider movement.
function ChrInt_Callback(hObject, eventdata, handles)
% hObject    handle to ChrInt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
Chr_int_val = round(get(hObject,'Value')*1000)/10;   % this is done so only one dec place
set(handles.ChrIntVal, 'String', num2str(Chr_int_val));

%send command to controller
fprintf(handles.s1, ['CHR ',num2str(Chr_int_val)]);
delay(0.1);
while handles.s1.BytesAvailable > 1 
    display(fscanf(handles.s1));
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function ChrInt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ChrInt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function IrInt_Callback(hObject, eventdata, handles)
% hObject    handle to IrInt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
Ir_int_val = round(get(hObject,'Value')*1000)/10;   % this is done so only one dec place
set(handles.IrIntVal, 'String', [num2str(Ir_int_val)]);

%send command to controller
fprintf(handles.s1, ['IR ',num2str(Ir_int_val)]);
delay(0.1);
while handles.s1.BytesAvailable > 1 
    display(fscanf(handles.s1));
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function IrInt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to IrInt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in OnOff.
function OnOff_Callback(hObject, eventdata, handles)
% hObject    handle to OnOff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of OnOff

button_state = get(hObject,'Value');
if button_state == get(hObject,'Max')
    handles.LEDON = 1;
    
    set(hObject,'String','OFF');
    
    LEDPatt = sprintf('%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d',handles.LEDpattern);
    fprintf(handles.s1, ['PATT ', LEDPatt]);
    delay(0.1);
    while handles.s1.BytesAvailable > 1
        display(fscanf(handles.s1));
    end

    handles.pulsePeriod = handles.blinkOn + handles.blinkOff;
    
    if handles.blinkOn > 0 && handles.blinkOff > 0
        
        if handles.blinkOn > 30000
            warndlg('The value of pulse width should be equal or less than 30 seconds. Please try again', 'Pulse values error');
            return;
        end
        
        if handles.pulsePeriod > 30000
            warndlg('The value of pulse period should be equal or less than 30 seconds. Please try again', 'Pulse values error');
            return;
        end
        
        param.pulse_width = round(handles.blinkOn);
        param.pulse_period = round(handles.pulsePeriod);
        param.number_of_pulses = 100;
        param.pulse_train_interval = 0;
        param.delay_time = 0;
        param.iteration = 0;
              
        fprintf(handles.s1, ['PULSE',  num2str(param.pulse_width),',',num2str(param.pulse_period),',',num2str(param.number_of_pulses), ',', ...
            num2str(param.pulse_train_interval),',',num2str(param.delay_time),',',num2str(param.iteration)]);
        delay(0.1);
        while handles.s1.BytesAvailable > 1
            display(fscanf(handles.s1));
        end

        fprintf(handles.s1, 'RUN');
        delay(0.1);
        while handles.s1.BytesAvailable > 1
            display(fscanf(handles.s1));
        end
        
    else
        fprintf(handles.s1, 'ON');
        delay(0.1);
        while handles.s1.BytesAvailable > 1
            display(fscanf(handles.s1));
        end
        
    end
    
elseif button_state == get(hObject,'Min')
    handles.LEDON = 0;
    set(hObject,'String','ON');
    
    if handles.blinkOn > 0 && handles.pulsePeriod > 0
        fprintf(handles.s1, 'STOP');
        delay(0.1);
        while handles.s1.BytesAvailable > 1
            display(fscanf(handles.s1));
        end
        fprintf(handles.s1, 'OFF');  
        delay(0.1);
        while handles.s1.BytesAvailable > 1
            display(fscanf(handles.s1));
        end
    else 
        fprintf(handles.s1, 'OFF');
        delay(0.1);
        while handles.s1.BytesAvailable > 1
            display(fscanf(handles.s1));
        end
        
    end
end
guidata(hObject, handles);

function ChrIntVal_Callback(hObject, eventdata, handles)
% hObject    handle to ChrIntVal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ChrIntVal as text
%        str2double(get(hObject,'String')) returns contents of ChrIntVal as a double
Chr_int_val = round(str2double(get(hObject,'String'))*10)/10;

if isnan(Chr_int_val )
    warndlg('The input value should between 0.1 to 100.', 'Wrong Chr intensity value');
    return;
end

set(handles.ChrIntVal, 'String', num2str(Chr_int_val));
set(handles.ChrInt, 'value', Chr_int_val/100);


%send command to controller
fprintf(handles.s1, ['CHR ',num2str(Chr_int_val)]);
delay(0.1);
while handles.s1.BytesAvailable > 1 
    display(fscanf(handles.s1));
end
guidata(hObject, handles);




% --- Executes during object creation, after setting all properties.
function ChrIntVal_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ChrIntVal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function IrIntVal_Callback(hObject, eventdata, handles)
% hObject    handle to IrIntVal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of IrIntVal as text
%        str2double(get(hObject,'String')) returns contents of IrIntVal as a double

Ir_int_val = round(str2double(get(hObject,'String'))*10)/10;

if isnan(Ir_int_val )
    warndlg('The input value should between 0.1 to 100.', 'Wrong IR intensity value');
    return;
end
set(handles.IrIntVal, 'String', [num2str(Ir_int_val)]);
set(handles.IrInt, 'value', Ir_int_val/100);

%send command to controller
fprintf(handles.s1, ['IR ',num2str(Ir_int_val)]);
delay(0.1);
while handles.s1.BytesAvailable > 1 
    display(fscanf(handles.s1));
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function IrIntVal_CreateFcn(hObject, eventdata, handles)
% hObject    handle to IrIntVal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes when entered data in editable cell(s) in LedPattern.
function LedPattern_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to LedPattern (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)
LED_pattern_raw = get(hObject,'data');

if isempty(find(LED_pattern_raw))
    Pattern = logical(zeros(1,16));
else
    Temp1 = flipud(LED_pattern_raw);
    Temp2 = fliplr(Temp1);
    Temp3 = Temp2';
    Temp4 = Temp3(:);
    Pattern = Temp4';
end

handles.LEDpattern = Pattern;

guidata(hObject, handles);

    

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: delete(hObject) closes the figure

%close the serial port connection
fclose(handles.s1);
delete(hObject);
clear all;



function blink_on_time_Callback(hObject, eventdata, handles)
% hObject    handle to blink_on_time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of blink_on_time as text
%        str2double(get(hObject,'String')) returns contents of blink_on_time as a double

handles.blinkOn = str2double(get(hObject,'String')) ;
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function blink_on_time_CreateFcn(hObject, eventdata, handles)
% hObject    handle to blink_on_time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function blink_off_time_Callback(hObject, eventdata, handles)
% hObject    handle to blink_off_time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of blink_off_time as text
%        str2double(get(hObject,'String')) returns contents of blink_off_time as a double
handles.blinkOff = str2double(get(hObject,'String')) ;
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function blink_off_time_CreateFcn(hObject, eventdata, handles)
% hObject    handle to blink_off_time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes during object creation, after setting all properties.
function LedPattern_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LedPattern (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


function delay(sec)

% function pause the program
% ms = delay time in seconds
tic;
while toc < sec
end
