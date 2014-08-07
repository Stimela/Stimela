function varargout = openProjectGui(action, varargin)
  
  if ~nargin
    action	= 'qqq'; 
  end
  
  if nargout
    varargout	= cell(1, nargout);
    [varargout{:}]= feval(['openProjectGui_' action], varargin{:});
  else
    feval(['openProjectGui_' action], varargin{:});
  end
  
end  % <main>
%__________________________________________________________
%% #build
%
function fig = openProjectGui_build(projectNr, isNew)
  
figPrp				= struct;
figPrp.Color			= [1 1 1] * 0.98;
figPrp.MenuBar			= 'none';
figPrp.Name			= 'Stimela open project';
figPrp.Tag			= openProjectGui_getTag;
figPrp.NumberTitle		= 'off';
figPrp.Resize			= 'off';
figPrp.Toolbar			= 'none';
figPrp.Units			= 'points';
figPrp.Visible			= 'off';
figPrp.Position			= openProjectGui_getFigPos;
figPrp.CloseRequestFcn		= @openProjectGui_close;
figPrp.UserData			= projectNr;
fig				= figure(figPrp);

[projects, models]		= openProjectGui_getProjectsAndModels;

rsd				= struct;
rsd.isNew			= isNew;

% --- labels ---
uiPrp				= struct;
uiPrp.BackgroundColor		= figPrp.Color;
uiPrp.FontName			= 'Arial';
uiPrp.FontSize			= 13;
uiPrp.FontUnits			= 'points';
uiPrp.FontWeight		= 'bold';
uiPrp.HorizontalAlignment	= 'left'; 
uiPrp.Parent			= fig;
uiPrp.Style			= 'text';
uiPrp.Units			= 'points';
uiPrp.String			= 'Models';
uiPrp.Position			= [10 35 200 20];
uicontrol(uiPrp);

uiPrp.String			= 'Projects';
uiPrp.Position			= [10 90 200 20];
uicontrol(uiPrp);

% --- popup menus ---
uiPrp				= struct;
uiPrp.BackgroundColor		= 'w';
uiPrp.FontName			= 'Arial';
uiPrp.FontSize			= 12;
uiPrp.FontUnits			= 'points';
uiPrp.FontWeight		= 'normal';
uiPrp.HorizontalAlignment	= 'left'; 
uiPrp.Parent			= fig;
uiPrp.Style			= 'popup';
uiPrp.Units			= 'points';
uiPrp.String			= openProjectGui_createNames(projects);
uiPrp.UserData			= projects;
uiPrp.Position			= [10 65 200 20];
projects			= uicontrol(uiPrp);

uiPrp.String			= openProjectGui_createNames(models);
uiPrp.UserData			= models;
uiPrp.Position			= [10 10 200 20];
models				= uicontrol(uiPrp);

% --- buttons ---
uiPrp				= struct;
uiPrp.FontName			= 'Arial';
uiPrp.FontSize			= 12;
uiPrp.FontUnits			= 'points';
uiPrp.HorizontalAlignment	= 'center'; 
uiPrp.Parent			= fig;
uiPrp.Style			= 'pushbutton';
uiPrp.Units			= 'points';
uiPrp.Callback			= @openProjectGui_open;
uiPrp.String			= 'open';
uiPrp.Position			= [220 65 70 20];
uiPrp.UserData			= projects;
uiPrp.Tag			= 'projects';
uicontrol(uiPrp);

uiPrp.UserData			= models;
uiPrp.Position			= [220 10 70 20];
uiPrp.Tag			= 'models';
uicontrol(uiPrp);

setappdata(fig, 'rsd', rsd)
set(fig, 'Visible', 'on')

end  % #build
%__________________________________________________________
%% #getFigPos
%
function figPos = openProjectGui_getFigPos
  
screenPosPix	= get(0, 'ScreenSize');
screenSizePix	= screenPosPix(3:4);
pixPerInch	= get(0, 'ScreenPixelsPerInch');
screenSize	= screenSizePix*72/pixPerInch; % points

figSize		= [300 120];

figPos(1)	= (screenSize(1) - figSize(1))/2;
figPos(2)	= (screenSize(2) - figSize(2))/5*3;
figPos(3:4)	= figSize;

end  % #getFigPos
%__________________________________________________________
%% #createNames
%
function names = openProjectGui_createNames(data)

names		= {};

for ii = 1:length(data)
  names{end+1} = data(ii).label;
end % for ii
  
end  % #createNames
%__________________________________________________________
%% #getTag
%
function tag = openProjectGui_getTag
  
tag = 'stimOpenProjectGui';

end  % #getTag
%__________________________________________________________
%% #open
%
function openProjectGui_open(h, evd)

fig	= hfigure(h);
rsd	= getappdata(fig, 'rsd');

hPopup	= get(h, 'UserData');
data	= get(hPopup, 'UserData');
dataInd	= get(hPopup, 'Value');

flNm	= data(dataInd).flNm;

if isempty(flNm), return, end

[pd, fl, ext]	= fileparts(flNm);

fig		= hfigure(h);
projectNr	= get(fig, 'UserData');

if strcmpi(get(h, 'Tag'), 'projects')
  addpath(genpath(fullfile(stimFolder('My_projects'), fl)), '-end')
end

if 0
  if 0
    global types
    types = {};
  end
  hList(1)	= handle.listener(slroot, 'ObjectChildAdded', @stimListener);
  setappdata(fig, 'listeners', hList);
  [pd projectNm('long') ext] = fileparts(flNm);
  setappdata(fig, 'projectNm', projectNm('long'));
end

if ~rsd.isNew
  cd(pd);
end

open(flNm);

% projectsGui('addMdl', hWindow, projectNr)

end  % #open
%__________________________________________________________
%% #getProjectsAndModels
%
function [projects, models] = openProjectGui_getProjectsAndModels
  
projects	= openProjectGui_getStruct('projects');
models		= openProjectGui_getStruct('models');

end  % #getProjectsAndModels
%__________________________________________________________
%% #getStruct
%
function data = openProjectGui_getStruct(type)

pd	= stimFolder(['My_' type]);

dataC	= {};
  
headerC	= {'label', 'flNm'};

[files, dummy] = getAllModelFiles('getFilteredFiles', pd, '.mdl', '-ext');

for ii = 1:size(files, 1)
  fl			= files{ii, 2};
  dataC{end+1, 1}	= fl(1:end-4);
  dataC{end  , 2}	= fullfile(pd, files{ii,1}, fl);  
end % for ii

if isempty(dataC)
  dataC{end+1, 1}	= ['No ' type ' available'];
  dataC{end  , 2}	= '';  
end

data	= cell2struct(dataC', headerC, 1);

end  % #getStruct
%__________________________________________________________
%% #close
%
function openProjectGui_close(fig, evd)
  
question	= {'Do you want to close?', 'Closing will cause all projects and models to be closed as well'};

awnser		= questdlg(question, 'Close', 'yes' ,'no' ,'no');

if strcmp(awnser, 'no'), return, end

projectNr	= get(fig, 'UserData');

projectsGui('removeProject',projectNr)

end  % #close
%__________________________________________________________
%% #qqq
%
function openProjectGui_qqq
  
end  % #qqq
%__________________________________________________________