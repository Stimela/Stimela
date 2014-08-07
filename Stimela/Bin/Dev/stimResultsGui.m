function varargout = stimResultsGui(action, varargin)

if ~nargin
  action	= 'test';
end

if nargout
  varargout	= cell(1, nargout);
  [varargout{:}]= feval(['stimResultsGui_' action], varargin{:});
else
  feval(['stimResultsGui_' action], varargin{:});
end

end  % <main>
%__________________________________________________________
%% #init
%
function stimResultsGui_init(varargin)

fig = stimResultsGui_build;

set(0,'defaultTextFontSize', 12)

if ~isempty(varargin)
  modelNm		= varargin{1};
else
%   stimResultsGui_getData(fig)
end

end  % #init
%__________________________________________________________
%% #build
%
function fig = stimResultsGui_build

fig = stimFigure('create', stimResultsGui_getTag, '', [inf inf], true);

figColor			= get(fig, 'Color');
set(fig, 'Resize', 'on');
set(fig, 'ResizeFcn', @stimResultsGui_resize);
set(fig, 'CloseRequestFcn', @stimResultsGui_close);

stimResultsGui_setFigNm(fig, '')

rsd				= struct;
rsd.curUnit			= '';
rsd.legendStr			= {};
% rsd.curPlotted			= {};
rsd.xLim			= [inf -inf];
rsd.yLim			= [inf -inf];
rsd.fig				= fig;
rsd.mpFig			= 0;
rsd.paFig			= 0;

% ======================= uicontrols =======================

pnlPrp0				= struct;
pnlPrp0.BackgroundColor		= figColor;
pnlPrp0.BorderType		= 'etchedout';
pnlPrp0.BorderWidth		= 1;
pnlPrp0.FontName		= 'Arial';
pnlPrp0.FontSize		= 12;
pnlPrp0.FontUnits		= 'points';
pnlPrp0.FontWeight		= 'bold';
pnlPrp0.Parent			= fig;
pnlPrp0.TitlePosition		= 'lefttop';
pnlPrp0.Units			= 'points';

pnlPrp				= pnlPrp0;
pnlPrp.Title			= 'Data';
rsd.dataPnl			= uipanel(pnlPrp);

pnlPrp				= pnlPrp0;
pnlPrp.Title			= 'Control';
rsd.ctrlPnl			= uipanel(pnlPrp);

uiPrp0				= struct;
uiPrp0.FontName			= 'Arial';
uiPrp0.FontSize			= 10;
uiPrp0.FontUnits		= 'points';
uiPrp0.HorizontalAlignment	= 'left';
uiPrp0.Units			= 'points';

rsd	= stimResultsGui_fillDataPnl(rsd, uiPrp0, figColor);
rsd	= stimResultsGui_fillCtrlPnl(rsd, uiPrp0);

% ========================== axes ==========================

axPrp				= struct;
axPrp.Box			= 'on';
axPrp.Color			= 'w';
axPrp.NextPlot			= 'add';
axPrp.Parent			= fig;
axPrp.Units			= 'points';
axPrp.FontName			= 'Arial';
axPrp.FontSize			= 11;
axPrp.FontUnits			= 'points';
axPrp.FontWeight		= 'bold';
axPrp.LineStyleOrder		= '-|--|:|->';
rsd.ax				= axes(axPrp);

% ========================== menus ==========================
setappdata(fig, 'rsd', rsd)

stimResultsGui_createMenu(fig, rsd);

set(get(rsd.ax, 'XLabel'), 'FontName', 'Arial', ...
  'FontSize', 12, 'FontWeight', 'bold')
set(get(rsd.ax, 'YLabel'), 'FontName', 'Arial', ...
  'FontSize', 12, 'FontWeight', 'bold')
set(get(rsd.ax, 'XLabel'), 'String', 'time (h)')

stimResultsGui_resize(fig)

set(fig, 'Visible', 'on')

end  % #build
%__________________________________________________________
%% #fillDataPnl
%
function rsd = stimResultsGui_fillDataPnl(rsd, uiPrp0, figColor)

popupSize		= [200 20];
lblSize			= [45 popupSize(2)];
buttonSize		= [60 20];
boxSize			= [40 20];
offset			= 5;
titleOffset		= 15;

uiPrp0.Parent		= rsd.dataPnl;

y1			= offset;
y2			= y1 + offset + buttonSize(2);
y3			= y2 + offset + lblSize(2);
y4			= y3 + offset + lblSize(2);
pnlSize(1)		= 3*offset + popupSize(1) + lblSize(1);
pnlSize(2)		= y4 + offset + lblSize(2) + titleOffset;
set(rsd.dataPnl, 'Position', [0 0 pnlSize]);

% ========================= buttons ==========================
uiPrp			= uiPrp0;
uiPrp.Style		= 'pushbutton';
uiPrp.String		= 'plot';
uiPrp.Position		= [pnlSize(1) - offset - buttonSize(1) y1 buttonSize];
uiPrp.Callback		= @stimResultsGui_preparePlot;
rsd.plotButton		= uicontrol(uiPrp);

uiPrp.String		= 'mulitplot';
uiPrp.Position		= [pnlSize(1) - 2*(offset + buttonSize(1)) y1 buttonSize];
uiPrp.Callback		= @stimResultsGui_multiplot;
uiPrp.Enable		= 'off';
rsd.multiplotButton	= uicontrol(uiPrp);

uiPrp.String		= 'plot all';
uiPrp.Position		= [pnlSize(1) - 3*(offset + buttonSize(1)) y1 buttonSize];
uiPrp.Callback		= @stimResultsGui_plotAll;
uiPrp.Enable		= 'off';
rsd.plotAllButton	= uicontrol(uiPrp);

uiPrp			= uiPrp0;
uiPrp.BackgroundColor	= figColor;
uiPrp.Style		= 'Checkbox';
uiPrp.String		= 'add';
uiPrp.Value		= 1;
uiPrp.Position		= [pnlSize(1) - 4*offset - 3*buttonSize(1) - boxSize(1) y1 boxSize];
uiPrp.Callback		= '';
uiPrp.Enable		= 'on';
rsd.addBox		= uicontrol(uiPrp);

% ========================== labels ==========================
uiPrp			= uiPrp0;
uiPrp.Style		= 'text';
uiPrp.BackgroundColor	= figColor;

uiPrp.String		= 'Variable:';
uiPrp.Position		= [offset y2-3 lblSize];
uicontrol(uiPrp)

uiPrp.String		= 'Type:';
uiPrp.Position		= [offset y3-3 lblSize];
uicontrol(uiPrp)

uiPrp.String		= 'Source:';
uiPrp.Position		= [offset y4-3 lblSize];
uicontrol(uiPrp)

% ========================== popups ==========================
uiPrp			= uiPrp0;
uiPrp.Style		= 'popup';
uiPrp.BackgroundColor	= 'w';

x			= lblSize(1) + 2*offset;

uiPrp.Callback		= '';
rsd.varDlftStr		= 'No variables available';
uiPrp.String		= {rsd.varDlftStr};
uiPrp.Position		= [x y2 popupSize];
rsd.popupVar		= uicontrol(uiPrp);

uiPrp.Callback		= @stimResultsGui_changeDataType;
rsd.typeDlftStr		= 'No types available';
uiPrp.String		= {rsd.typeDlftStr};
uiPrp.Position		= [x y3 popupSize];
rsd.popupType		= uicontrol(uiPrp);

uiPrp.Callback		= @stimResultsGui_changeSrc;
rsd.srcDlftStr		= 'No sources available';
uiPrp.String		= {rsd.srcDlftStr};
uiPrp.Position		= [x y4 popupSize];
rsd.popupSrc		= uicontrol(uiPrp);

end  % #fillDataPnl
%__________________________________________________________
%% #fillCtrlPnl
%
function rsd = stimResultsGui_fillCtrlPnl(rsd, uiPrp0)

buttonSize		= [60 20];
offset			= 5;

uiPrp0.Parent		= rsd.ctrlPnl;

y1			= offset;
y2			= y1 + offset + buttonSize(2);

dataPnlPos		= get(rsd.dataPnl, 'Position') ;
pnlSize(1)		= 2*offset + buttonSize(1);
pnlSize(2)		= dataPnlPos(4);
set(rsd.ctrlPnl, 'Position', [0 0 pnlSize]);

% --- toggle button ---
uiPrp			= uiPrp0;
uiPrp.Style		= 'togglebutton';
uiPrp.Callback		= @stimResultsGui_zoomPan;

uiPrp.String		= 'Zoom';
uiPrp.Position		= [offset y1 buttonSize];
rsd.zoomToggle		= uicontrol(uiPrp);

uiPrp.String		= 'Pan';
uiPrp.Position		= [offset y2 buttonSize];
rsd.panToggle		= uicontrol(uiPrp);

end  % #fillCtrlPnl
%__________________________________________________________
%% #resize
%
function stimResultsGui_resize(h, evd)

fig		= hfigure(h);
rsd		= getappdata(fig, 'rsd');
figPos		= get(fig, 'Position');

dataPnlPos	= get(rsd.dataPnl, 'Position');
dataPnlPos(1)	= 5;
dataPnlPos(2)	= figPos(4) - dataPnlPos(4) - 5;

ctrlPnlPos	= get(rsd.ctrlPnl, 'Position');
ctrlPnlPos(1)	= 5 + dataPnlPos(3) + dataPnlPos(1);
ctrlPnlPos(2)	= figPos(4) - ctrlPnlPos(4) - 5;

set(rsd.dataPnl   , 'Position', dataPnlPos);
set(rsd.ctrlPnl   , 'Position', ctrlPnlPos);

axPos(1:2)	= [3 1]*-10;
axPos(3)	= figPos(3) - axPos(1)*2;
axPos(4)	= dataPnlPos(2) - axPos(2)*2;

set(rsd.ax, 'OuterPosition', axPos);

end  % #resize
%__________________________________________________________
%% #setFigNm
%
function stimResultsGui_setFigNm(fig, nm)

defaultStr	= 'Stimela Results';

if ~isempty(nm)
  figNm	= sprintf('%s - %s', defaultStr, nm);
else
  figNm	= defaultStr;
end
set(fig, 'Name', figNm)

end  % #setFigNm
%__________________________________________________________
%% #getTag
%
function tag = stimResultsGui_getTag

tag = 'stimResultsGui';

end  % #getTag
%__________________________________________________________
%% #getFigPos
%
function figPos = stimResultsGui_getFigPos

screenPosPix	= get(0, 'ScreenSize');
screenSizePix	= screenPosPix(3:4);
pixPerInch	= get(0, 'ScreenPixelsPerInch');
screenSize	= screenSizePix*72/pixPerInch; % points

widthFact	= 0.7;
heightFact	= 0.7;
heightOffSetFact= 0.1;

figPos(1)	= (1 - widthFact)/2 * screenSize(1);
figPos(2)	= ((1 -heightFact)/2 + heightOffSetFact) * screenSize(2);
figPos(3)	= widthFact * screenSize(1);
figPos(4)	= heightFact * screenSize(2);

end  % #getFigPos
%__________________________________________________________
%% #getData
%
function stimResultsGui_getData(fig, action, varargin)

rsd		= getappdata(fig, 'rsd');

nrOfInputs	= numel(varargin);

if nrOfInputs == 1
  pd		= varargin{1};
  varargin(1)	= [];
elseif nrOfInputs == 3
  pd		= varargin{2};
  varargin(2)	= [];
else
  error('The function cannot handle a varargin with %d of inputs', nrOfInputs)
end

if strcmpi(action, 'add')
  if isfield(rsd, 'dataStruct')
    varargin{end+1}= rsd.dataStruct;
  else
    action = 'open';
  end
end

hWaitbar	= waitbar(0, '', 'WindowStyle', 'modal', 'Name', 'Stimela result - loading data');
try
  dataStruct	= stimResultsData('initData', hWaitbar, pd, action, varargin{:});
catch ME
  close(hWaitbar)
  error('%s', ME.getReport)
end

waitbar(1, hWaitbar)
close(hWaitbar)

if ~isempty(dataStruct)
  %   stimResultsGui_setFigNm(fig, pdNm)
  rsd.dataStruct	= dataStruct;
  setappdata(fig, 'rsd', rsd)
  set(rsd.popupSrc, 'String', fieldnames(dataStruct))
  stimResultsGui_changeSrc(rsd.popupSrc, '')
  stimResultsGui_changeDataType(rsd.popupType)
end

end  % #getData
%__________________________________________________________
%% #zoomPan
%
function stimResultsGui_zoomPan(h, evd)

fig	= hfigure(h);
rsd	= getappdata(fig, 'rsd');

on	= get(h, 'Value');

if on
  if h == rsd.zoomToggle
    zoom(fig, 'on');
    pan(fig, 'off');
    set(rsd.panToggle, 'Value', 0);
  else
    zoom(fig, 'off');
    pan(fig, 'on')
    set(rsd.zoomToggle, 'Value', 0);
  end
else
  if h == rsd.zoomToggle
    zoom(fig, 'off');
  else
    pan(fig, 'off')
  end
end

end  % #zoomPan
%__________________________________________________________
%% #changeDataType
%
function stimResultsGui_changeDataType(h, evd)

fig		= hfigure(h);
rsd		= getappdata(fig, 'rsd');

[srcNm, dataNm, varNm] = stimResultsGui_getNms(rsd);

if strcmp(dataNm, rsd.typeDlftStr), return, end

data		= rsd.dataStruct.(srcNm).(dataNm);
varNms		= data.varNms;
varNmsOld	= get(rsd.popupVar, 'String');
varOld		= get(rsd.popupVar, 'Value');
varNmOld	= varNmsOld{varOld};
indCmp	= strcmp(varNmOld, varNms);
if any(indCmp)
  val = find(indCmp == 1);
else
  val = 1;
end

set(rsd.popupVar, 'String', varNms, 'Value', val);

end  % #changeDataType
%__________________________________________________________
%% #changeSrc
%
function stimResultsGui_changeSrc(h, evd)

fig		= hfigure(h);
rsd		= getappdata(fig, 'rsd');

[srcNm, dataNm, varNm] = stimResultsGui_getNms(rsd);

if strcmp(srcNm, rsd.srcDlftStr), return, end

oldTypeNms	= get(rsd.popupType, 'String');
oldTypeVal	= get(rsd.popupType, 'Value');
oldTypeNm	= oldTypeNms{oldTypeVal};
data		= rsd.dataStruct.(srcNm);
typeNms		= fieldnames(data);
set(rsd.popupType, 'String', typeNms)
indCmp	= strcmp(oldTypeNm, typeNms);
if any(indCmp)
  val = find(indCmp == 1);
else
  val = 1;
end

set(rsd.popupType, 'Value', val)
stimResultsGui_changeDataType(rsd.popupType, '')

end  % #changeSrc
%__________________________________________________________
%% #getNms
%
function [srcNm, dataNm, varNm] = stimResultsGui_getNms(rsd)

srcVal		= get(rsd.popupSrc, 'Value');
srcStr		= get(rsd.popupSrc, 'String');
srcNm		= srcStr{srcVal};

typeValue	= get(rsd.popupType, 'Value');
typeString	= get(rsd.popupType, 'String');
dataNm		= typeString{typeValue};

varValue	= get(rsd.popupVar, 'Value');
varString	= get(rsd.popupVar, 'String');
varNm		= varString{varValue};

end  % #getNms
%__________________________________________________________
%% #multiplot
%
function stimResultsGui_multiplot(h, evd)

fig		= hfigure(h);
rsd		= getappdata(fig, 'rsd');

if rsd.mpFig
  close(rsd.mpFig)
end

rsd.mpFig	= stimMultiPlotGui('init', rsd);
setappdata(fig, 'rsd', rsd)

end  % #multiplot
%__________________________________________________________
%% #plotAll
%
function stimResultsGui_plotAll(h, evd)

fig		= hfigure(h);
rsd		= getappdata(fig, 'rsd');

if rsd.paFig
  close(rsd.paFig)
end

rsd.paFig	= stimPlotAllGui('init', rsd.dataStruct);
setappdata(fig, 'rsd', rsd)


end  % #plotAll
%__________________________________________________________
%% #preparePlot
%
function stimResultsGui_preparePlot(h, evd)

fig		= hfigure(h);
rsd		= getappdata(fig, 'rsd');

varValue	= get(rsd.popupVar, 'Value');
varString	= get(rsd.popupVar, 'String');
if strcmp(varString{varValue}, rsd.varDlftStr), return, end

[srcNm, dataNm, varNm] = stimResultsGui_getNms(rsd);

add		= get(rsd.addBox, 'Value');
data	= rsd.dataStruct.(srcNm).(dataNm);
legendStr	= data.(varNm).legendStr;

if add && any(strcmp(legendStr, rsd.legendStr)), return, end

xData	= data.time / 3600;
yData	= data.(varNm).yData;
unit	= data.(varNm).unit;
rsd		= stimResultsGui_plot(rsd, xData, yData, {legendStr}, unit, add);

setappdata(fig, 'rsd', rsd)

end  % #preparePlot
%__________________________________________________________
%% #plot
%
function rsd = stimResultsGui_plot(rsd, xData, yData, legendStr, unit, add)

if ~all(size(xData) == size(yData)) || size(xData, 1) ~= length(legendStr)
  error('Data sizes differ.')
end

if ~add || stimResultsGui_checkUnit(rsd.curUnit, unit)
  set(rsd.ax, 'NextPlot', 'replaceChildren')
  yLabel		= stimResultsGui_getYLabel(unit);
  set(get(rsd.ax, 'YLabel'), 'String', yLabel)
  rsd.curUnit		= unit;
  rsd.legendStr		= {};
  rsd.curPlotted	= {};
  rsd.xLim		= [inf -inf];
  rsd.yLim		= [inf -inf];
  add			= false;
end

if add
  set(rsd.ax, 'NextPlot', 'add')
  hold(rsd.ax, 'all')
end

plotStr		= 'plot(rsd.ax';

for ii = 1:size(xData, 1)
  plotStr		= sprintf('%s, xData(%d,:), yData(%d,:)', plotStr, ii, ii);
  rsd.legendStr{end+1}	= legendStr{ii};
end % for ii

plotStr		= [plotStr ')'];
eval(plotStr);

% plot(rsd.ax, xData, yData)
stimResultsGui_setLegend(rsd)
rsd		= stimResultsGui_setLims(xData, yData, rsd, add);

zoom('reset')

end  % #plot
%__________________________________________________________
%% #setLegend
%
function stimResultsGui_setLegend(rsd)

evalStr	= 'legend(rsd.ax';
for ii = 1:length(rsd.legendStr)
  evalStr = [evalStr ', ''' rsd.legendStr{ii} ''''];
end % for ii

evalStr = [evalStr ', ''Location'',''Best'')'];

h = eval(evalStr);
set(h ,'Interpreter','none')

end  % #setLegend
%__________________________________________________________
%% #setLims
%
function rsd = stimResultsGui_setLims(xData, yData, rsd, add)

curXlim		= rsd.xLim;
curYlim		= rsd.yLim;

xDataMin	= min(min(xData, [], 2));
xDataMax	= max(max(xData, [], 2));
yDataMin	= min(min(yData, [], 2));
yDataMax	= max(max(yData, [], 2));

rsd.xLim	= [min(curXlim(1), xDataMin) max(curXlim(2), xDataMax)];
rsd.yLim	= [min(curYlim(1), yDataMin) max(curYlim(2), yDataMax)];
offset(1)	= - 0.05*abs(rsd.yLim(1));
offset(2)	=   0.05*abs(rsd.yLim(2));

if add
  if curYlim(1) <= yDataMin + offset(1)
    offset(1) = 0;
  end
  if curYlim(2) >= yDataMax + offset(2)
    offset(2) = 0;
  end
end

rsd.yLim(1)	= rsd.yLim(1) + offset(1);
rsd.yLim(2)	= rsd.yLim(2) + offset(2);

set(rsd.ax, 'XLim', rsd.xLim)
set(rsd.ax, 'YLim', rsd.yLim)

end  % #setLim
%__________________________________________________________
%% #checkUnit
%
function change = stimResultsGui_checkUnit(curUnit, unit)

if ~strcmpi(curUnit, unit)
  change = true;
else
  change = false;
end

end  % #checkUnit
%__________________________________________________________
%% #getYLabel
%
function yLabel = stimResultsGui_getYLabel(unit)

labelC	= stimResultsGui_getLabelsC;

ind	= strcmpi(labelC(:,1), unit);
if any(ind)
  yLabel = sprintf('%s (%s)', labelC{ind, 2}, unit);
else
  yLabel = sprintf('(%s)',unit);
end

end  % #getYLabel
%__________________________________________________________
%% #getLabelsC
%
function labelC = stimResultsGui_getLabelsC

labelC	= {
  %unit		label
  'mg/l'	'Concentration'
  'mmol/l'	'Concentration'
  '-'		'Number of'
  'ug/l'	'Concentration'
  'unknown'	'unknown';
  '^oC'		'Temperature'
  'FTE'		'Turbidity'
  'mS/m'	'Conductivity'
  'pH'		'pH'
  '1/m'		'UV254'
  };

end  % #getLabelsC
%__________________________________________________________
%% #close
%
function stimResultsGui_close(h, evd)

fig		= hfigure(h);
rsd		= getappdata(fig, 'rsd');

if rsd.mpFig
  close(rsd.mpFig)
end
if rsd.paFig
  close(rsd.paFig)
end

delete(fig)

end  % #close
%__________________________________________________________
%% #rmHandle
%
function stimResultsGui_rmHandle(type)

fig	= findall(0, 'type', 'figure', 'tag', stimResultsGui_getTag);
rsd	= getappdata(fig, 'rsd');

switch type
  case 'pa'
    rsd.paFig	= 0;
  case 'mp'
    rsd.mpFig	= 0;
  otherwise
    error('No handle by the name: %s', type)
end

setappdata(fig, 'rsd', rsd)

end  % #qqq
%__________________________________________________________
%% #createMenu
%
function rsd = stimResultsGui_createMenu(fig, rsd)

menuDataC	= {
  %label		Accelerator Parent	Separator name		Callback					
  '&File'		''	    fig		'off'     'fileMenu'	''						
  '&Open directory'	'o'	    'fileMenu'	'off'	  'openPd'	{@stimResultsGui_openDirectory, 'open'}		
  'Open &files'		'f'	    'fileMenu'	'of'      'openFl'	{@stimResultsGui_openFiles, 'open'}	
  'Add &directory'	'd'	    'fileMenu'	'on'      'addPd'	{@stimResultsGui_openDirectory, 'add'}	
  '&Add files'		'a'	    'fileMenu'	'off'     'addFl'	{@stimResultsGui_openFiles, 'add'}
  };

header		= {'label', 'accelerator', 'parent', 'separator', 'name', 'callback'}';

menuData	= cell2struct(menuDataC, header, 2);

for ii = 1:size(menuData, 1)

  menuData_ii		= menuData(ii);
  
  uimPrp		= struct;
  if ischar(menuData_ii.parent)
    parentStr	= menuData_ii.parent;
    if isfield(rsd, parentStr)
      parent	= rsd.(parentStr);
    else
      error('Unknown parent "%s" for menu item "%s"', parentStr, menuData_ii.name)      
    end
  else
    parent	= menuData_ii.parent;
  end
  
  uimPrp.Parent		= parent;
  uimPrp.Label		= menuData_ii.label;
  uimPrp.Accelerator	= menuData_ii.accelerator;
  uimPrp.Callback	= menuData_ii.callback;
  uimPrp.Separator	= menuData_ii.separator;
  evalStr		= sprintf('rsd.%s = uimenu(uimPrp);', menuData_ii.name);
  eval(evalStr);  
  
end % for ii

setappdata(fig, 'rsd', rsd)

end  % #createMenu
%__________________________________________________________
%% #openFiles
%
function stimResultsGui_openFiles(h, evd, action)

fig		= hfigure(h);

filter		= {
  % exe		name
  '*.sti'	'Stimela output files (*.sti)'
%   '*.mat'	'MAT-files (*.mat)'
  };

dlgTitle	= sprintf('Pick one ore multiple files to  %s', action);
userPath	= userpath;
path		= userPath(1:end-1);
path		= 'C:\Users\M.Sparnaaij\Documents\TU\Stimela\Stimela_v2011b_IM\My_projects\Int_model_new\StimelaData';

[flNms, pd, filterInd]	= uigetfile(filter, dlgTitle, path, 'MultiSelect', 'on');

if isempty(flNms) || isnumeric(flNms)
  return
else
  exeStr	= filter{filterInd(1), 1}; 
  exe		= exeStr(2:end);
  stimResultsGui_getData(fig, action, flNms, pd, exe)
end


end  % #openFiles
%__________________________________________________________
%% #openDirectory
%
function stimResultsGui_openDirectory(h, evd, action)

fig		= hfigure(h);

dlgTitle	= sprintf('Pick a directory to %s', action);

userPath	= userpath;
path		= userPath(1:end-1);
path		= 'C:\Users\M.Sparnaaij\Documents\TU\Stimela\Stimela_v2011b_IM\My_projects\Int_model_new\StimelaData';

pdNm		= uigetdir(path, dlgTitle);

if isempty(pdNm) || isnumeric(pdNm)
  return
else
  stimResultsGui_getData(fig, action, pdNm)
end

end  % #openDirectory
%__________________________________________________________
%% #test
%
function stimResultsGui_test

delete(findall(0, 'Tag', stimResultsGui_getTag));
% addpath('C:\Users\M.Sparnaaij\Documents\TU\CT3000-09\Stimela\My_projects\Chlorination_MS_test2\StimelaData');
%
% stimResultsGui('build', 'chloMS_p')

% projectPd = 'C:\Users\M.Sparnaaij\Documents\TU\Stimela\Projects\WaterspotInt_Old';
%
% addpath(genpath(projectPd));
%
% stimResultsGui('build', [projectPd, '\StimelaData'])
%

stimResultsGui('init')

end  % #test
%__________________________________________________________
%% #qqq
%
function stimResultsGui_qqq

end  % #qqq
%__________________________________________________________