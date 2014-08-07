function varargout = stimParInputGui(action, varargin)
  
  if ~nargin
    action	= 'test'; 
  end
  
  if nargout
    varargout	= cell(1, nargout);
    [varargout{:}]= feval(['stimParInputGui_' action], varargin{:});
  else
    feval(['stimParInputGui_' action], varargin{:});
  end
  
end  % <main>
%__________________________________________________________
%% #build
%
function stimParInputGui_build(name, type)

figPrp				= struct;
figPrp.Color			= [1 1 1] * 0.98;
figPrp.MenuBar			= 'none';
figPrp.Name			= 'Stimela parameter input';
figPrp.Tag			= stimParInputGui_getTag;
figPrp.NumberTitle		= 'off';
figPrp.Resize			= 'on';
figPrp.ResizeFcn		= @stimParInputGui_resize;
figPrp.Toolbar			= 'none';
figPrp.Units			= 'points';
figPrp.Visible			= 'off';
figPrp.CloseRequestFcn		= @stimParInputGui_close;
fig				= figure(figPrp);

rsd				= struct;
rsd.name			= name;
rsd.type			= type;
rsd.screenSize			= stimParInputGui_screenSize;
rsd.uiBtnSize			= [60 25];
rsd.uiLblSize			= [200 16];
rsd.uiFldSize			= [180 rsd.uiLblSize(2)];
rsd.uiUntSize			= [50 rsd.uiLblSize(2)];
rsd.offset			= 5;

uiPrp0				= struct;
uiPrp0.FontName			= 'Arial';
uiPrp0.Units			= 'points';
uiPrp0.Parent			= fig;
uiPrp0.FontUnits		= 'points';
uiPrp0.FontSize			= 10;
rsd.uiPrp0			= uiPrp0;

% --- labels ---
uiPrpLbl			= uiPrp0;
uiPrpLbl.BackgroundColor	= figPrp.Color;
uiPrpLbl.FontWeight		= 'bold';
uiPrpLbl.HorizontalAlignment	= 'left'; 
uiPrpLbl.Style			= 'text';
rsd.uiPrpLbl			= uiPrpLbl;

uiPrp				= uiPrpLbl;
uiPrp.FontSize			= 13;
uiPrp.String			= name;
rsd.title			= uicontrol(uiPrp);
  
% --- buttons ---
uiPrpBtn			= uiPrp0;
uiPrpBtn.FontSize		= 12;
uiPrpBtn.HorizontalAlignment	= 'center'; 
uiPrpBtn.Style			= 'pushbutton';
rsd.uiPrpBtn			= uiPrpBtn;

uiPrp				= uiPrpBtn;
uiPrp.Callback			= @stimParInputGui_ok;
uiPrp.String			= 'Ok';
rsd.ok				= uicontrol(uiPrp);

uiPrp				= uiPrpBtn;
uiPrp.Callback			= @stimParInputGui_cancel;
uiPrp.String			= 'Cancel';
rsd.cancel			= uicontrol(uiPrp);


[ok, rsd] = stimParInputGui_initParam(rsd);
if ~ok
  delete(fig)
  return
end
[figPos, cols]	= stimParInputGui_getFigPos(rsd);
rsd.cols	= cols;
setappdata(fig, 'rsd', rsd)

set(fig, 'Position', figPos)
set(fig, 'Visible', 'on')

end  % #build
%__________________________________________________________
%% #resize
%
function stimParInputGui_resize(fig, evd)

rsd		= getappdata(fig, 'rsd');

figPos		= get(fig, 'Position');

titlePos	= [10 figPos(4) - 10 - rsd.uiLblSize(2)];
cancelPos	= [figPos(3) - 10 - rsd.uiBtnSize(1) 10];
okPos		= [figPos(3) - 2*(10 + rsd.uiBtnSize(1)) 10]; 

set(rsd.title,	'Position', [titlePos  rsd.uiLblSize])
set(rsd.cancel, 'Position', [cancelPos rsd.uiBtnSize])
set(rsd.ok,     'Position', [okPos     rsd.uiBtnSize])

rowLength	= 10 + rsd.uiLblSize(1) + 10 + rsd.uiFldSize(1) +...
  10 + rsd.uiUntSize(1) + 10;

for cc = 1:rsd.cols
  if cc == rsd.cols
    if cc > 1
      n(cc) = length(rsd.label) - sum(n(1:cc-1));
    else
      n(cc) = length(rsd.label);
    end
  else
    n(cc) = ceil(length(rsd.label)/rsd.cols);
  end
end % for cc

nTot	= 0;
for jj = 1:length(n)
  xLblPos	= 10 + (jj-1)*rowLength;
  xFldPos	= xLblPos + 10 + rsd.uiLblSize(1);
  xUntPos	= xFldPos + 10 + rsd.uiFldSize(1);
  
  for ii = 1:n(jj)
    yPos_ii	= titlePos(2) - 10 - (10 + rsd.uiLblSize(2))*ii;
    lblPos_ii	= [xLblPos yPos_ii];
    fldPos_ii	= [xFldPos yPos_ii];
    untPos_ii	= [xUntPos yPos_ii];
    
    set(rsd.label(ii + nTot), 'Position', [lblPos_ii rsd.uiLblSize])
    set(rsd.field(ii + nTot), 'Position', [fldPos_ii rsd.uiFldSize])
    set(rsd.unit(ii + nTot),  'Position', [untPos_ii rsd.uiUntSize])
  end % for ii
  nTot = nTot+n(jj);
end % for jj
end  % #resize
%__________________________________________________________
%% #initParam
%
function [ok, rsd] = stimParInputGui_initParam(rsd)

ok	= true;

pInfo	= feval([rsd.type  '_d']);

if isempty(pInfo)
  warndlg('There are no parameters available for this model.','No parameters','modal');
  ok	= false;
  return;
end

data		= stimParInputGui_data('load', rsd.name);

for ii = 1:size(pInfo, 1)
  if ~isfield(data, pInfo(ii).Name)
    data	= stimParInputGui_createData(pInfo, data, rsd.name);
    break;
  end
end

uiPrpEdit			= rsd.uiPrp0;
uiPrpEdit.BackgroundColor	= 'w';
uiPrpEdit.FontWeight		= 'normal';
uiPrpEdit.HorizontalAlignment	= 'center'; 
uiPrpEdit.Style			= 'edit';

uiPrpPopup			= rsd.uiPrp0;
uiPrpPopup.BackgroundColor	= 'w';
uiPrpPopup.FontWeight		= 'normal';
uiPrpPopup.HorizontalAlignment	= 'center'; 
uiPrpPopup.Style		= 'popup';

uiPrpCheck			= rsd.uiPrp0;
uiPrpCheck.BackgroundColor	= 'w';
uiPrpCheck.FontWeight		= 'normal';
uiPrpCheck.HorizontalAlignment	= 'center'; 
uiPrpCheck.Style		= 'Checkbox';

for ii = 1:size(pInfo, 1)
  uiPrp			= rsd.uiPrpLbl;
  uiPrp.String		= pInfo(ii).Description;
  rsd.label(ii)		= uicontrol(uiPrp);
  
  switch pInfo(ii).ControlStyle
    case 'select'
      uiPrp		= uiPrpPopup;
      uiPrp.String	= pInfo(ii).MinValue;
      ind		= strcmpi(uiPrp.String, data.(pInfo(ii).Name));
      if any(ind)
	uiPrp.Value	= find(ind == 1);
      end
    case 'check'
      uiPrp		= uiPrpCheck;
      ind		= data.(pInfo(ii).Name);
      uiPrp.Value	= ind;
    case {'text', 'edit'}
      uiPrp		= uiPrpEdit;
      uiPrp.String	= data.(pInfo(ii).Name);
    otherwise
      error('ControlStyle unknown: %s', pInfo.ControlStyle)
  end
  
  rsd.field(ii)		= uicontrol(uiPrp);
  
  uiPrp			= rsd.uiPrpLbl;
  uiPrp.String		= pInfo(ii).Unit;
  rsd.unit(ii)		= uicontrol(uiPrp);
end % for ii

end  % #initParam
%__________________________________________________________
%% #getTag
%
function tag = stimParInputGui_getTag
  
tag = 'stimParInputGui';

end  % #getTag
%__________________________________________________________
%% #data
%
function data = stimParInputGui_data(action, name, varargin)

flNm	= which([projectNm('long') '_Par.mat']);

switch action
  case 'load'
    data	= load(flNm, name);
    fldNms	= fieldnames(data);
    data	= data.(fldNms{1});
  case 'save'
    data	= varargin{end};
    eval([name '= data;'])
    save(flNm, name,'-append')
  otherwise
    error('.')
end

end  % #data
%__________________________________________________________
%% #close
%
function stimParInputGui_close(fig, evd)
  
rsd		= getappdata(fig, 'rsd');

hasChanged	= stimParInputGui_hasChanged(fig);
if ~any(hasChanged) && ~rsd.forceSave
  delete(fig)
  return;
end

question	= {'Would you like to save the changes?'};

awnser		= questdlg(question, 'Save parameters', 'Yes' ,'No' ,'yes');

if strcmpi(awnser, 'no')
  delete(fig)
  return
end

rsd	= getappdata(fig, 'rsd');
data	= stimParInputGui_collectData(hasChanged, rsd);
stimParInputGui_data('save', rsd.name, data)

delete(fig)

end  % #close
%__________________________________________________________
%% #hasChanged
%
function hasChanged = stimParInputGui_hasChanged(fig)

rsd		= getappdata(fig, 'rsd');

data		= stimParInputGui_data('load', rsd.name);
pInfo		= feval([rsd.type  '_d']);

hasChanged	= zeros(length(pInfo), 1);

for ii = 1:length(pInfo)
switch pInfo(ii).ControlStyle
  case 'select'
    string	= pInfo(ii).MinValue;
    valNm	= data.(pInfo(ii).Name);
    valNm	= strrep(valNm, '''', '');
    ind		= strcmpi(string, valNm);
    ind		= find(ind == 1);
    val		= get(rsd.field(ii), 'Value');
    if ind ~= val
      hasChanged(ii) = true;
    end    
  case 'check'
    valOld	= data.(pInfo(ii).Name);
    val		= get(rsd.field(ii), 'Value');
    if valOld ~= val
      hasChanged(ii) = true;
    end
  case {'text', 'edit'}
    string	= get(rsd.field(ii), 'String');
    stringOld	= data.(pInfo(ii).Name);
    if ~strcmp(string, stringOld)
      hasChanged(ii) = true;
    end
end
  
end % for ii
  
end  % #hasChanged
%__________________________________________________________
%% #screenSize
%
function screenSize = stimParInputGui_screenSize
  
screenPosPix	= get(0, 'ScreenSize');
screenSizePix	= screenPosPix(3:4);
pixPerInch	= get(0, 'ScreenPixelsPerInch');
screenSize	= screenSizePix*72/pixPerInch; % points

end  % #screenSize
%__________________________________________________________
%% #ok
%
function stimParInputGui_ok(h, evd)
  
fig = hfigure(h);

rsd		= getappdata(fig, 'rsd');
hasChanged	= stimParInputGui_hasChanged(fig);
if any(hasChanged) || rsd.forceSave
  data = stimParInputGui_collectData(hasChanged, rsd);
  stimParInputGui_data('save', rsd.name, data);
end
delete(fig)

end  % #ok
%__________________________________________________________
%% #cancel
%
function stimParInputGui_cancel(h, evd)

fig = hfigure(h);

stimParInputGui_close(fig)
  
end  % #cancel
%__________________________________________________________
%% #getFigPos
%
function [figPos, cols] = stimParInputGui_getFigPos(rsd)

cols		= 1;

figSize(1)	= 10 + rsd.uiLblSize(1) + 10 + rsd.uiFldSize(1)...
  + 10 + rsd.uiUntSize(1) + 10;

nrOfPar		= length(rsd.label);

figSize(2)	= 10 + rsd.uiBtnSize(2) + 10 + nrOfPar*(10 + rsd.uiLblSize(2))...
 + 20 + rsd.uiLblSize(2) + 10;

maxFigSize	= rsd.screenSize*0.9;

if figSize(2) > maxFigSize(2)
  if 20 + 2*figSize(1) <= maxFigSize(1) && ...
      figSize(2) - ceil(nrOfPar/2)*(10 + rsd.uiLblSize(2)) <= maxFigSize(2) 
      figSize(1) = 20 + 2*figSize(1);
      figSize(2) = figSize(2) - ceil(nrOfPar/2)*(10 + rsd.uiLblSize(2));
      cols	 = 2;
  else
    error('figure to big for screen!')
  end
elseif (figSize(1) > maxFigSize(1) && figSize(2) > maxFigSize(2) ) || figSize(1) > maxFigSize(1)
  error('figure to big for screen!')
end

figPos(1)	= (rsd.screenSize(1) - figSize(1))/2;
figPos(2)	= (rsd.screenSize(2) - figSize(2))/5*3;
figPos(3:4)	= figSize;

end  % #getFigPos
%__________________________________________________________
%% #collectData
%
function data = stimParInputGui_collectData(hasChanged, rsd)
  
data	= stimParInputGui_data('load', rsd.name);
fldNms	= fieldnames(data);

for ii = 1:length(hasChanged)
  if ~hasChanged(ii), continue, end
  h = rsd.field(ii);
  type = get(h, 'Style');
  switch type
    case 'Checkbox'
      data_ii	= get(h, 'Value');
    case 'edit'
      data_ii	= get(h, 'String');
    case 'popupmenu'
      ind	= get(h, 'Value');
      strings	= get(h, 'String');
      data_ii	= strings{ind}; 
  end
  data.(fldNms{ii})	= data_ii;  
end % for ii

end  % #collectData
%__________________________________________________________
%% #createData
%
function data = stimParInputGui_createData(pInfo, dataIn, name)
  
data	= struct;

for ii = 1:size(pInfo, 1)
  flNm	= pInfo(ii).Name;
  if ~isfield(dataIn, flNm)
    switch pInfo(ii).ControlStyle
      case 'select'
	string		= pInfo(ii).MinValue;
	data.(flNm) = string{1};
      case {'text', 'edit', 'check'}
	data.(flNm) = pInfo(ii).DefaultValue;
      otherwise
	error('ControlStyle unknown: %s', pInfo.ControlStyle)
    end
  else
    data.(flNm) = dataIn.(flNm);
  end
end % for ii

stimParInputGui_data('save', name, data);

end  % #createData
%__________________________________________________________
%% #test
%
function stimParInputGui_test
  
stimParInputGui('build','test', 'invruw');

end  % #test
%__________________________________________________________
%% #qqq
%
function stimParInputGui_qqq
  
end  % #qqq
%__________________________________________________________