function varargout = projectsGui(action, varargin)
  
  if ~nargin
    action	= 'build'; 
  end
  
  if nargout
    varargout	= cell(1, nargout);
    [varargout{:}]= feval(['projectsGui_' action], varargin{:});
  else
    feval(['projectsGui_' action], varargin{:});
  end
  
end  % <main>
%__________________________________________________________
%% #build
%
function projectsGui_build
  
figs				= findall(0, 'tag', projectsGui_getTag);
if any(figs)
  delete(figs);
end

figPrp				= struct;
figPrp.Color			= [1 1 1] * 0.98;
figPrp.MenuBar			= 'none';
figPrp.Name			= 'Stimela projects';
figPrp.Tag			= projectsGui_getTag;
figPrp.NumberTitle		= 'off';
figPrp.Resize			= 'off';
figPrp.Toolbar			= 'none';
figPrp.Units			= 'points';
figPrp.Visible			= 'off';
figSize				= [350 40];
figPrp.Position			= projectsGui_getFigPos(figSize);
figPrp.CloseRequestFcn		= @projectsGui_close;
fig				= figure(figPrp);

rsd				= struct;
rsd.windows			= [];
rsd.projectNr			= 0;
projectsData			= projectData('getData');

% --- popup menus ---
uiPrp				= struct;
uiPrp.BackgroundColor		= 'w';
uiPrp.FontName			= 'Arial';
uiPrp.FontSize			= 12;
uiPrp.FontUnits			= 'points';
uiPrp.HorizontalAlignment	= 'left'; 
uiPrp.Parent			= fig;
uiPrp.Style			= 'popup';
uiPrp.Units			= 'points';
uiPrp.String			= projectsGui_createNames(projectsData);
uiPrp.UserData			= projectsData;
uiPrp.Position			= [10 figSize(2)-30 200 20];
rsd.projects			= uicontrol(uiPrp);

uiPrp				= struct;
uiPrp.BackgroundColor		= 'w';
uiPrp.FontName			= 'Arial';
uiPrp.FontSize			= 12;
uiPrp.FontUnits			= 'points';
uiPrp.HorizontalAlignment	= 'right'; 
uiPrp.Parent			= fig;
uiPrp.Style			= 'Checkbox';
uiPrp.Units			= 'points';
uiPrp.String			= 'New';
uiPrp.Value			= 0;
uiPrp.Position			= [220 figSize(2)-30 40 20];
rsd.newCheck			= uicontrol(uiPrp);

uiPrp				= struct;
uiPrp.FontName			= 'Arial';
uiPrp.FontSize			= 12;
uiPrp.FontUnits			= 'points';
uiPrp.HorizontalAlignment	= 'center'; 
uiPrp.Parent			= fig;
uiPrp.Style			= 'pushbutton';
uiPrp.Units			= 'points';
uiPrp.Callback			= @projectsGui_startProject;
uiPrp.String			= 'Start';
uiPrp.Position			= [270 figSize(2)-30 70 20];
rsd.plotButton			= uicontrol(uiPrp);

setappdata(fig, 'rsd', rsd)

set(fig, 'Visible', 'on')

end  % #build
%__________________________________________________________
%% #getFigPos
%
function figPos = projectsGui_getFigPos(figSize)
  
screenPosPix	= get(0, 'ScreenSize');
screenSizePix	= screenPosPix(3:4);
pixPerInch	= get(0, 'ScreenPixelsPerInch');
screenSize	= screenSizePix*72/pixPerInch; % points

figPos(1)	= (screenSize(1) - figSize(1))/2;
figPos(2)	= (screenSize(2) - figSize(2))/5*3;
figPos(3:4)	= figSize;

end  % #getFigPos
%__________________________________________________________
%% #createNames
%
function names = projectsGui_createNames(projectsData)

projects	= projectsData.projects;

names		= {};

for ii = 1:length(projects)
  names{end+1} = projects(ii).label;
end % for ii
  
end  % #createNames
%__________________________________________________________
%% #getTag
%
function tag = projectsGui_getTag
  
tag = 'stimProjectsGui';

end  % #getTag
%__________________________________________________________
%% #startProject
%
function projectsGui_startProject(h, evd)

fig		= hfigure(h);
rsd		= getappdata(fig, 'rsd');

projectsData	= get(rsd.projects, 'UserData');
projectInd	= get(rsd.projects, 'Value');

projectPd	= projectsData.projects(projectInd).pd;
  
projectsGui_removeProjectPds;


addpath(projectPd, '-end')
addpath(genpath(stimFolder('My_models')), '-end')

new		= get(rsd.newCheck, 'Value');

if ~new
  corePd	= projectsStartup('getCorePd', false);
  pds		= textscan(path, '%s', 'Delimiter', ';');
  pds		= [pds{1}];
  modelsPd	= fullfile(corePd, 'Models');
  if any(strncmpi(pds, modelsPd, length(modelsPd)))
    rmpath(genpath(modelsPd))
  end
  corePd	= projectsStartup('getCorePd', true);
  addpath(genpath(corePd), '-end')
else
  corePd	= projectsStartup('getCorePd', true);
  pds	= textscan(path, '%s', 'Delimiter', ';');
  pds	= [pds{1}];
  if any(strcmp(pds, corePd))
    rmpath(genpath(corePd))
  end
end

stimInit('addCorePaths')

if ~new
  corePd	= projectsStartup('getCorePd', false);
  pds		= textscan(path, '%s', 'Delimiter', ';');
  pds		= [pds{1}];
  modelsPd	= fullfile(corePd, 'Models');
  if any(strncmpi(pds, modelsPd, length(modelsPd)))
    rmpath(genpath(modelsPd))
  end
end

projectString	= get(rsd.projects, 'String');

msg	= sprintf('Project "%s" started succesfully!', projectString{projectInd});

hFig	= openProjectGui('build', projectInd, new);

projectsGui_addWindow(hFig, projectInd);

msgbox(msg,'Project started','modal') 

end  % #startProject
%__________________________________________________________
%% #removeProjectPds
%
function projectsGui_removeProjectPds

homePd		= projectData('getProjectHomePd');
if ~strcmp(homePd(end), filesep)
  homePd = [homePd filesep];
end
 
pds		= textscan(path, '%s', 'Delimiter', ';');
pds		= [pds{1}];

ind		= strncmp(pds, homePd, length(homePd));

removePds	= pds(ind);
pds(ind)	= [];

if ~isempty(removePds)
  rmpath(removePds{:});
end
 
end  % #removeProjectPds
%__________________________________________________________
%% #removeProject
%
function projectsGui_removeProject(projectNr)
  
fig			= findall(0, 'tag', projectsGui_getTag);
rsd			= getappdata(fig, 'rsd');

for ii = 1:size(rsd.windows,1)
  if rsd.windows(ii, 2) == projectNr
    delete(rsd.windows(ii, 1))
    rsd.windows(ii,:) = [];
  end
end % for ii

setappdata(fig, 'rsd', rsd)

end  % #removeWindow
%__________________________________________________________
%% #removeWindow
%
function projectsGui_removeWindow(hWindow)
  
fig			= findall(0, 'tag', projectsGui_getTag);
rsd			= getappdata(fig, 'rsd');

for ii = 1:size(rsd.windows, 1)
  if rsd.windows(ii, 1) == hWindow    
    rsd.windows(ii,:) = [];
    delete(hWindow)
  end
end % for ii

setappdata(fig, 'rsd', rsd)

end  % #removeWindow
%__________________________________________________________
%% #addWindow
%
function projectsGui_addWindow(hWindow, projectNr)
  
fig			= findall(0, 'tag', projectsGui_getTag);
rsd			= getappdata(fig, 'rsd');

rsd.windows		= [rsd.windows; hWindow, projectNr];

setappdata(fig, 'rsd', rsd)

end  % #addWindow
%__________________________________________________________
%% #close
%
function projectsGui_close(fig, evd)
  
question	= {'Do you want to close?', 'Closing will cause all projects and models to be closed as well'};

awnser		= questdlg(question, 'Close', 'yes' ,'no' ,'no');

if strcmp(awnser, 'no'), return, end

rsd		= getappdata(fig, 'rsd');

for ii = 1:size(rsd.windows, 1)
  try
    delete(rsd.windows(ii,1));
  catch ME
    1;
  end
end % for ii

projectsGui_removeProjectPds

delete(fig)

end  % #close
%__________________________________________________________
%% #qqq
%
function projectsGui_qqq
  
end  % #qqq
%__________________________________________________________