function varargout = stimMainGui(action, varargin)
  
  if ~nargin
    action	= 'init'; 
  end
  
  if nargout
    varargout	= cell(1, nargout);
    [varargout{:}]= feval(['stimMainGui_' action], varargin{:});
  else
    feval(['stimMainGui_' action], varargin{:});
  end
  
end  % <main>
%__________________________________________________________
%% #init
%
function stimMainGui_init
  
fig	= stimMainGui_build;

set(fig, 'Visible', 'on')

end  % #init
%__________________________________________________________
%% #build
%
function fig = stimMainGui_build

fig	= stimFigure('create', stimMainGui_getTag, ['Stimela - ' stimMainGui_version],...
  [inf, inf], true);

rsd	= struct;

set(fig, 'ResizeFcn', @stimMainGui_resize)
set(fig, 'Resize', 'on')

pnlPrp			= struct;
pnlPrp.parent		= fig;
pnlPrp.Units		= 'points';
pnlPrp.BorderType	= 'none';
pnlPrp.BackgroundColor	= get(fig, 'Color');

rsd.mainPanel	= stimMainGui_buildMainPanel(fig, pnlPrp);
panelNms	= {'Level 1', 'Level 2', 'Level 3', 'Level 4'};
rsd.levelPanels	= stimMainGui_buildLevelPanels(fig, pnlPrp, panelNms);

setappdata(fig, 'ResizeData', rsd)

end  % #build
%__________________________________________________________
%% #buildMainPanel
%
function hMainPanel = stimMainGui_buildMainPanel(fig, pnlPrp)

rsp	= struct;

hMainPanel		= uipanel(pnlPrp);

buttonTable		= stimMainGui_buttonTable;

lblPrp			= struct;
lblPrp.BackgroundColor	= get(hMainPanel, 'BackgroundColor');
lblPrp.Units		= 'Points';
lblPrp.Parent		= hMainPanel;
lblPrp.Style		= 'text';

lblPrp.FontSize		= 24;
lblPrp.String		= 'Stimela';
rsp.label		= uicontrol(lblPrp);

lblPrp.FontSize		= 12;
lblPrp.String		= stimMainGui_version;
rsp.verLabel		= uicontrol(lblPrp);

butPrp		= struct;
butPrp.Units	= 'Points';
butPrp.FontSize	= 10;
butPrp.Parent	= hMainPanel;
butPrp.Position	= [0 0 80 25];

for ii = 1:numel(buttonTable)
  butPrp.Callback	= buttonTable(ii).callback;
  butPrp.String		= buttonTable(ii).name;
  butPrp.Style		= buttonTable(ii).style;
  butPrp.Tag		= buttonTable(ii).tag;
  rsp.buttons(ii)	= uicontrol(butPrp);
end

setappdata(hMainPanel, 'ResizeData', rsp)

end  % #buildMainPanel
%__________________________________________________________
%% #buttonTable
%
function buttonTable = stimMainGui_buttonTable
  
buttonTableC = {
  %Name			Tag			Style		Callback
  'My projects'		'my_projects'		'toggle'	@stimMainGui_toggleCb
  'New project'		'new_project'		'push'		@stimMainGui_pushCb
  'My models'		'my_models'		'toggle'	@stimMainGui_toggleCb
  'New model'		'new_model'		'push'		@stimMainGui_pushCb
  'Stimela library'	'stimela_library'	'toggle'	@stimMainGui_toggleCb
  'Simulink library'	'simulink_library'	'push'		@stimMainGui_pushCb
  'Open'		'open'			'push'		@stimMainGui_pushCb
  'Refresh'		'refresh'		'push'		@stimMainGui_pushCb
  };

columnNms	= {'name', 'tag', 'style', 'callback'};

buttonTable	= cell2struct(buttonTableC, columnNms, 2);

end  % #buttonTable
%__________________________________________________________
%% #buildLevelPanel
%
function hLevelPanels = stimMainGui_buildLevelPanels(fig, pnlPrp, panelNms)

lblPrp			= struct;
lblPrp.Units		= 'Points';
lblPrp.Style		= 'text';
lblPrp.FontSize		= 22;

lstPrp			= struct;
lstPrp.Units		= 'Points';
lstPrp.Style		= 'listbox';
lstPrp.FontSize		= 11;
lstPrp.BackgroundColor	= 'w';

pnlPrp.BorderType	= 'none';

for pp = 1:numel(panelNms)
  rsp			= struct;
% pnlPrp.BackgroundColor= [1 1 1] * (0.4+.1*pp);
  hLevelPanels(pp)	= uipanel(pnlPrp);
  % -------- label
  lblPrp.BackgroundColor= get(hLevelPanels(pp), 'BackgroundColor');
  lblPrp.Parent		= hLevelPanels(pp);
  lblPrp.String		= sprintf('Level %u', pp);
  rsp.label		= uicontrol(lblPrp);
  % -------- listbox
  lstPrp.Parent		= hLevelPanels(pp);
  rsp.listbox		= uicontrol(lstPrp);
  
  setappdata(hLevelPanels(pp), 'ResizeData', rsp)
end

end  % #buildMainPanel
%__________________________________________________________
%% #resize
%
function stimMainGui_resize(fig, evd)
  
rsd	= getappdata(fig, 'ResizeData');

figPos	= get(fig, 'Position');
figOrg	= figPos(1:2);
figSz	= figPos(3:4);

% ===================== Labels & Buttons mainPanel ========================
margin		= 5;
rsp		= getappdata(rsd.mainPanel, 'ResizeData');

butPos		= get(rsp.buttons(1), 'Position');
butSzOrg	= butPos(3:4);

marginAdd	= 0;
lblSz		= [butSzOrg(1) + 4*margin 26];
lblOrg		= [2 figSz(2) - lblSz(2) - margin];
set(rsp.label, 'Position', [lblOrg lblSz])

verLblSz	= [lblSz(1) 14];
verLblOrg	= [lblOrg(1) lblOrg(2) - verLblSz(2) - margin];
set(rsp.verLabel, 'Position', [verLblOrg verLblSz])

for rr = 1:numel(rsp.buttons)
  butOrg(1)	= margin*2; 
  if strncmpi(get(rsp.buttons(rr), 'tag'), 'new', 3)
    butSz	= butSzOrg;
    butSz(1)	= butSz(1) - 2*margin;
    butOrg(1)	= butOrg(1) + 2*margin;
  else
    butSz	= butSzOrg;    
  end  
  if any(strcmpi(get(rsp.buttons(rr), 'Tag'), 'open'))
    marginAdd	= marginAdd + 1;
  end
  butOrg(2) = verLblOrg(2) - (margin + butSz(2))*(rr+marginAdd) - 2*margin;
  set(rsp.buttons(rr), 'Position', [butOrg butSz])
end

% ============================ mainPanel ==================================
mainPnlSz	= [lblSz(1)+6 figSz(2)];
if figSz(1) <= mainPnlSz(1)
  figSz(1)	= mainPnlSz(1) + 20;
  set(fig, 'Position', [figOrg, figSz])
end
mainPnlOrg	= [0 0];
set(rsd.mainPanel, 'Position', [mainPnlOrg mainPnlSz]);

% ============================ levelPanels ================================
nrOfPanels	= numel(rsd.levelPanels);
levelPnlSz(1)	= (figSz(1) - mainPnlSz(1))/nrOfPanels;
levelPnlSz(2)	= figSz(2);
levelPnlOrg(2)	= 0;
for pp = 1:nrOfPanels
  levelPnlOrg(1) = mainPnlSz(1) + levelPnlSz(1)*(pp-1);   
  set(rsd.levelPanels(pp), 'Position', [levelPnlOrg levelPnlSz]);
  
  rsp		= getappdata(rsd.levelPanels(pp), 'ResizeData');
  lblSz		= [70 25];
  lblOrg	= [5 figSz(2) - lblSz(2) - 10];
  set(rsp.label, 'Position', [lblOrg lblSz]);

  lstSz		= [levelPnlSz(1) lblOrg(2) - 5];
  lstOrg	= [0 0];
  set(rsp.listbox, 'Position', [lstOrg lstSz]);
end

end  % #resize
%__________________________________________________________
%% #getTag
%
function tag = stimMainGui_getTag
  
tag	= 'stimMainGui';

end  % #getTag
%__________________________________________________________
%% #toggleCb
%
function stimMainGui_toggleCb(h, evd)
  
'toggle'

end  % #toggleCb
%__________________________________________________________
%% #pushCb
%
function stimMainGui_pushCb(h, evd)
  
'push'

end  % #pushCb
%__________________________________________________________
%% #version
%
function version = stimMainGui_version
  
version	= 'v2011b';

end  % #version
%__________________________________________________________
%% #qqq
%
function stimMainGui_qqq
  
end  % #qqq
%__________________________________________________________