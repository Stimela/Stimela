function varargout = plotStimela2(varargin)
% plotStimela2 M-file for plotStimela2.fig
%      plotStimela2, by itself, creates a new plotStimela2 or raises the existing
%      singleton*.
%
%      H = plotStimela2 returns the handle to a new plotStimela2 or the handle to
%      the existing singleton*.
%
%      plotStimela2('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in plotStimela2.M with the given input arguments.
%
%      plotStimela2('Property','Value',...) creates a new plotStimela2 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before plotStimela2_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to plotStimela2_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help plotStimela2

% Last Modified by GUIDE v2.5 16-Sep-2008 13:19:18

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @plotStimela2_OpeningFcn, ...
                   'gui_OutputFcn',  @plotStimela2_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin & isstr(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% --- Executes just before plotStimela2 is made visible.
function plotStimela2_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to plotStimela2 (see VARARGIN)



%vinden van alle ToFiles
Fs={};
Ns={};
vr={};

FsX={};
NsX={};
vrX={};

f=0;
fX=0;

sfuns = find_system(gcs,'LookUnderMasks','all');
for b=1:length(sfuns)
  try
  if strcmp(get_param(sfuns{b},'BlockType'),'ToFile')
    fl=get_param(sfuns{b},'Filename');
    if strcmp(fl(end-6:end),'_in.sti') || strcmp(fl(end-7:end),'_out.sti')
      f=f+1;
      Ns{f} = fl;
      [Pn,Fn]=Fileprop(fl);
      Fs{f} = Fn;
      vr{f} = get_param(sfuns{b},'MatrixName');
    end 
    if strcmp(fl(end-6:end),'_ES.sti') || strcmp(fl(end-6:end),'_EM.sti')
      fX=fX+1;
      NsX{fX} = fl;
      [Pn,Fn]=Fileprop(fl);
      FsX{fX} = Fn;
      vrX{fX} = get_param(sfuns{b},'MatrixName');
    end 
  end
catch
end
end

[Fs,Fi]=sort(Fs);
U.vr = vr(Fi);
U.Ns = Ns(Fi);
set(handles.files,'String',Fs);
set(handles.files,'Userdata',U);

[FsX,Fi]=sort(FsX);
U.vr = vrX(Fi);
U.Ns = NsX(Fi);
set(handles.filesExtra,'String',FsX);
set(handles.filesExtra,'Userdata',U);

% fill pulldown
V = st_Variabelen;
for i=1:length(V)
  Vs{i}=V(i).Description;
end

set(handles.vars,'String',Vs);

% Choose default command line output for plotStimela2
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes plotStimela2 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = plotStimela2_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
axes(handles.axes1);
if get(handles.checkbox1,'Value')
  cla;
  set(handles.vars,'Userdata','');
end 

kl='rycmkb';

Fs = get(handles.files,'String');
n = get(handles.files,'Value');
vars = get(handles.vars,'String');
var = get(handles.vars,'Value');
U = get(handles.files,'Userdata');


leg=  get(handles.vars,'Userdata');

load([U.Ns{n}],'-mat');
eval (['data =  ' U.vr{n}  ';']);
plot(data(1,:),data(var+1,:),kl(rem(length(leg),length(kl))+1))
hold on

leg{end+1}=[Fs{n} ' : ' vars{var}];

interpreter=get(0,'defaulttextinterpreter');
set(0,'defaulttextinterpreter','none')
legend(leg);
set(0,'defaulttextinterpreter',interpreter)

set(handles.vars,'Userdata',leg);

% --------------------------------------------------------------------
function FileMenu_Callback(hObject, eventdata, handles)
% hObject    handle to FileMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function OpenMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to OpenMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
file = uigetfile('*.fig');
if ~isequal(file, 0)
    open(file);
end

% --------------------------------------------------------------------
function PrintMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to PrintMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
printdlg(handles.figure1)

% --------------------------------------------------------------------
function CloseMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to CloseMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selection = questdlg(['Close ' get(handles.figure1,'Name') '?'],...
                     ['Close ' get(handles.figure1,'Name') '...'],...
                     'Yes','No','Yes');
if strcmp(selection,'No')
    return;
end

delete(handles.figure1)


% --- Executes during object creation, after setting all properties.
function files_CreateFcn(hObject, eventdata, handles)
% hObject    handle to filesExtra (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on selection change in filesExtra.
function files_Callback(hObject, eventdata, handles)
% hObject    handle to filesExtra (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns filesExtra contents as cell array
%        contents{get(hObject,'Value')} returns selected item from filesExtra



% --- Executes during object creation, after setting all properties.
function vars_CreateFcn(hObject, eventdata, handles)
% hObject    handle to vars (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in vars.
function vars_Callback(hObject, eventdata, handles)
% hObject    handle to vars (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns vars contents as cell array
%        contents{get(hObject,'Value')} returns selected item from vars


% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1


% --- Executes during object creation, after setting all properties.
function filesExtra_CreateFcn(hObject, eventdata, handles)
% hObject    handle to filesExtra (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in filesExtra.
function filesExtra_Callback(hObject, eventdata, handles)
% hObject    handle to filesExtra (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns filesExtra contents as cell array
%        contents{get(hObject,'Value')} returns selected item from filesExtra


% --- Executes during object creation, after setting all properties.
function NoExtra_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NoExtra (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function NoExtra_Callback(hObject, eventdata, handles)
% hObject    handle to NoExtra (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of NoExtra as text
%        str2double(get(hObject,'String')) returns contents of NoExtra as a double


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

axes(handles.axes1);
if get(handles.checkbox1,'Value')
  cla;
  set(handles.vars,'Userdata','');
end 

kl='rycmkb';

Fs = get(handles.filesExtra,'String');
n = get(handles.filesExtra,'Value');
NoStr = get(handles.NoExtra,'String');
eval(['No=' NoStr ';'],'No=1;');
U = get(handles.filesExtra,'Userdata');


leg=  get(handles.vars,'Userdata');

load([U.Ns{n}],'-mat');
eval (['data =  ' U.vr{n}  ';']);
if size(data,1)>No
  plot(data(1,:),data(No+1,:),kl(rem(length(leg),length(kl))+1))
  hold on

  leg{end+1}=[Fs{n} ' : ' NoStr];

  interpreter=get(0,'defaulttextinterpreter');
  set(0,'defaulttextinterpreter','none')
  legend(leg);
  set(0,'defaulttextinterpreter',interpreter)

  set(handles.vars,'Userdata',leg);
else
  disp(['PlotStimela : Number OutOfBound (' Fs{n} ' : ' num2str(NoStr) ')']);
end

