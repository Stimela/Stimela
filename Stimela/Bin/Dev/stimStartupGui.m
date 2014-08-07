function varargout = stimStartupGui(action, varargin)
  
  if ~nargin
    action	= 'test'; 
  end
  
  if nargout
    varargout	= cell(1, nargout);
    [varargout{:}]= feval(['stimStartupGui_' action], varargin{:});
  else
    feval(['stimStartupGui_' action], varargin{:});
  end
  
end  % <main>
%__________________________________________________________
%% #init
%
function stimStartupGui_init
  
fig		= stimStartupGui_build;

stimStartupGui_setPositions(fig)

noProjects	= stimStartupGui_fill(fig);

set(fig, 'Visible', 'on')

stimStartupGui_selectColor(fig, 'init')
if noProjects
  stimStartupGui_selectColor(fig, 'off')
else
  stimStartupGui_changeProject(fig);
end


end  % #init
%__________________________________________________________
%% #build
%
function fig = stimStartupGui_build
  
fig = stimFigure('create', stimStartupGui_getTag, 'Stimela startup', [400 600], true);
set(fig, 'CloseRequestFcn', @stimStartupGui_close)

rsd				= struct;
rsd.isNew			= [];
rsd.openProjects		= {};
rsd.mainCd			= cd;

uiPrp0				= struct;
uiPrp0.FontName			= 'Arial';
uiPrp0.FontSize			= 12;
uiPrp0.FontUnits		= 'points';
uiPrp0.Units			= 'points';
uiPrp0.Parent			= fig;

uiPrp				= uiPrp0; 
uiPrp.FontSize			= 13;
uiPrp.FontWeight		= 'bold';
uiPrp.HorizontalAlignment	= 'left'; 
uiPrp.Style			= 'text';
uiPrp.String			= 'Projects';
uiPrp.BackgroundColor		= get(fig, 'Color');
rsd.projectsLabel		= uicontrol(uiPrp);

uiPrp				= uiPrp0; 
uiPrp.Style			= 'popup';
uiPrp.String			= 'No projects available';
uiPrp.Callback			= @stimStartupGui_changeProject;
uiPrp.BackgroundColor		= 'w';
rsd.projectsPop			= uicontrol(uiPrp);

uiPrp				= uiPrp0; 
uiPrp.Style			= 'pushbutton';
uiPrp.String			= 'Exit';
uiPrp.Callback			= @stimStartupGui_close;
rsd.exit			= uicontrol(uiPrp);

pnlPrp				= struct;
pnlPrp.Parent			= fig;
pnlPrp.Units			= 'points';
pnlPrp.BackgroundColor		= get(fig, 'Color');
pnlPrp.BorderType		= 'etchedin';
rsd.panel			= uipanel(pnlPrp);

uiPrp0.Parent			= rsd.panel;

uiPrp				= uiPrp0; 
uiPrp.FontSize			= 13;
uiPrp.FontWeight		= 'bold';
uiPrp.HorizontalAlignment	= 'left'; 
uiPrp.Style			= 'text';
uiPrp.String			= 'Models';
uiPrp.BackgroundColor		= get(fig, 'Color');
rsd.modelsLabel			= uicontrol(uiPrp);

uiPrp				= uiPrp0; 
uiPrp.Style			= 'listbox';
uiPrp.ListboxTop		= 1;
uiPrp.Min			= 1; %Single selection
rsd.modelsDftStr		= 'No models available';
uiPrp.String			= rsd.modelsDftStr;
uiPrp.BackgroundColor		= 'w';
rsd.models			= uicontrol(uiPrp);

uiPrp				= uiPrp0; 
uiPrp.Style			= 'pushbutton';
uiPrp.String			= 'Open Model';
uiPrp.Callback			= @stimStartupGui_open;
rsd.open			= uicontrol(uiPrp);

setappdata(fig, 'rsd', rsd)

end  % #build
%__________________________________________________________
%% #setPositions
%
function stimStartupGui_setPositions(fig)
 
rsd		= getappdata(fig, 'rsd');

figPos		= get(fig, 'Position');

figSize(1)	= figPos(3);
figSize(2)	= figPos(4);
pLblPos		= [5 figSize(2) - 30 figSize(1) - 10 20]; 
pPos		= [5 pLblPos(2) - 30 figSize(1) - 10 20];
exitPos		= [figSize(1) - 60 10 50 20];

pnlPos		= [5 exitPos(2) + 25 figSize(1) - 10 (pPos(2) - 5)-(exitPos(2) + 25)];
mLblPos		= [5 pnlPos(4) - 30 pnlPos(3) - 10 20];
openPos		= [pnlPos(3) - 90 5 85 20];
mPos		= [5 openPos(2) + 30 pnlPos(3) - 10 (mLblPos(2)-5)-(openPos(2) + 30)]; 	

set(rsd.projectsLabel, 'Position', pLblPos)
set(rsd.projectsPop  , 'Position', pPos)
set(rsd.modelsLabel  , 'Position', mLblPos)
set(rsd.models       , 'Position', mPos)
set(rsd.open         , 'Position', openPos)
set(rsd.exit         , 'Position', exitPos)
set(rsd.panel        , 'Position', pnlPos)

end  % #setPositions
%__________________________________________________________
%% #fill
%
function noProjects = stimStartupGui_fill(fig)

rsd		= getappdata(fig, 'rsd');
projects	= stimStartupData('getProjects');
noProjects	= false;

if isempty(fieldnames(projects))
  set(rsd.projectsPop, 'Enable', 'off')  
  noProjects	= true;
  return
end
  
projectsC		= {};

for ii = 1:size(projects, 2)   
  projectsC{end+1} = projects(ii).lbl;
  if isempty(projects(ii).modelNms)
    projects(ii).modelNms{end+1} = rsd.modelsDftStr;
    projects(ii).modelFlNms{end+1} = '';
  end
end % for ii

rsd.projects	= projects;
set(rsd.projectsPop, 'String', projectsC)

setappdata(fig, 'rsd', rsd)
  
end  % #fill
%__________________________________________________________
%% #close
%
function stimStartupGui_close(h, evd)
  
fig	= hfigure(h);
rsd	= getappdata(fig, 'rsd');

msg	= {'Do you want to close and close all current models without saving?', ...
  'To close with saving the models, press "no" and save all models you want to save.', ...
  'To close without saving the models, press "yes".'
  };
awnser	= questdlg(msg,'Close','yes','no','no') ;
if strcmp(awnser, 'no')
  return
end

set(fig, 'Visible', 'off')
drawnow
cd(rsd.mainCd)
bdclose('all')

stimStartupData('switchModelVer', rsd.isNew, [])
stimStartupData('changeProjectPd', rsd.openProjects, {})


delete(fig)



end  % #close
%__________________________________________________________
%% #changeProject
%
function  stimStartupGui_changeProject(h, evd)
 
fig		= hfigure(h);
rsd		= getappdata(fig, 'rsd');
projects	= rsd.projects;

value		= get(rsd.projectsPop, 'Value');
modelNms	= projects(value).modelNms;

set(rsd.models, 'String', modelNms)
set(rsd.models, 'Value', 1)

if length(modelNms) == 1 && strcmp(modelNms{1}, rsd.modelsDftStr)
  stimStartupGui_selectColor(fig, 'off')
else
  stimStartupGui_selectColor(fig, 'on')
end

end  % #changeProject
%__________________________________________________________
%% #open
%
function stimStartupGui_open(h, evd)
  
fig		= hfigure(h);
rsd		= getappdata(fig, 'rsd');

projectVal	= get(rsd.projectsPop, 'Value');
modelVal	= get(rsd.models, 'Value');

project		= rsd.projects(projectVal);
modelNms	= project.modelNms;
isNew		= project.isNew;

modelNm		= modelNms{modelVal};

rsd		= stimStartupGui_openModel(rsd, isNew, modelNm, project.nm);

setappdata(fig, 'rsd', rsd)

end  % #open
%__________________________________________________________
%% #openModel
%
function rsd = stimStartupGui_openModel(rsd, isNew, modelNm, projectNm)
  
isSameProj	= any(strcmp(rsd.openProjects, projectNm));

isNewProd	= rsd.isNew+isNew;

oldOpenProjects	= rsd.openProjects;

changeNms	= {'project', 'version'};

if isNewProd <= 1
  if ~isSameProj;
    changeNm	= changeNms{isNewProd+1};
    msgLn1	= sprintf('The open models are from another %s!', changeNm);
    msgLn2	= sprintf('To open this model you have to switch %s, this will close all open models.', changeNm);
    msgLn3	= sprintf('Do you want to switch %s and close all current models?', changeNm);
    msg		= {msgLn1, msgLn2, msgLn3};
    
    awnser	= questdlg(msg,'Switch?','yes','no','no') ;
    if strcmp(awnser, 'no')
      return
    end
    bdclose('all')
    if isNewProd
      % Open model with version change
      stimStartupData('switchModelVer', rsd.isNew, isNew)
      rsd.isNew		= isNew;
    end
    rsd.openProjects	= {};
  end
elseif isempty(isNewProd)
  % Init
  stimStartupData('switchModelVer', rsd.isNew, isNew)
  rsd.isNew	= isNew;
  rsd		= stimStartupGui_openModel(rsd, isNew, modelNm, projectNm);
  return
end

if ~isSameProj  
  rsd.openProjects{end+1}	= projectNm;
  stimStartupData('changeProjectPd', oldOpenProjects, rsd.openProjects, isNew, rsd.mainCd)
end

open_system(modelNm)

end  % #openModel
%__________________________________________________________
%% #getTag
%
function tag = stimStartupGui_getTag
  
tag = 'startUpGui';

end  % #getTag
%__________________________________________________________
%% #selectColor
%
function stimStartupGui_selectColor(fig, type)
  
rsd		= getappdata(fig, 'rsd');

% jScrollPane	= findjobj(rsd.models);
% jListbox	= jScrollPane.getViewport.getComponent(0);

switch type
  case 'init'
%   rsd.selectColor = get(jListbox, 'SelectionBackground');
%   setappdata(fig, 'rsd', rsd)
  case 'on'
%   set(jListbox, 'SelectionBackground', rsd.selectColor);
    set(rsd.models, 'Enable', 'on')
    set(rsd.open  , 'Enable', 'on')
  case 'off'
%   set(jListbox, 'SelectionBackground', [1 1 1]);
    set(rsd.models, 'Enable', 'off')
    set(rsd.open  , 'Enable', 'off')
 otherwise
    error('Type "%s" unknown.', type)
end

drawnow

end  % #selectColor
%__________________________________________________________
%% #test
%
function stimStartupGui_test
  
stimStartupGui_init

end  % #test
%__________________________________________________________
%% #qqq
%
function stimStartupGui_qqq
  
end  % #qqq
%__________________________________________________________