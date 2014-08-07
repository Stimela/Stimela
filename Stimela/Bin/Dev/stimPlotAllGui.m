function varargout = stimPlotAll(action, varargin)
  
  if ~nargin
    action	= 'test'; 
  end
  
  if nargout
    varargout	= cell(1, nargout);
    [varargout{:}]= feval(['stimPlotAll_' action], varargin{:});
  else
    feval(['stimPlotAll_' action], varargin{:});
  end
  
end  % <main>
%__________________________________________________________
%% #init
%
function fig = stimPlotAll_init(data)
  
fig	= stimPlotAll_build;
stimPlotAll_initData(fig, data)

end  % #init
%__________________________________________________________
%% #build
%
function fig = stimPlotAll_build
  
fig				= stimFigure('create', stimPlotAll_getTag,...
  'Stimela Plot All', [inf inf], true);

rsd				= struct;
rsd.figColor			= get(fig, 'Color');
rsd.XlimOrg			= [0 1];
rsd.hLeg			= 0;

pnlPrp0				= struct;
pnlPrp0.BackgroundColor		= rsd.figColor;
pnlPrp0.BorderType		= 'none';
pnlPrp0.BorderWidth		= 1;
pnlPrp0.Parent			= fig;
pnlPrp0.Units			= 'points';

pnlPrp				= pnlPrp0;
rsd.dataPnl			= uipanel(pnlPrp);

pnlPrp				= pnlPrp0;
pnlPrp.BorderType		= 'line';
pnlPrp.HighlightColor		= 'k';
rsd.axesPnl			= uipanel(pnlPrp);

uiPrp0				= struct;
uiPrp0.FontName			= 'Arial';
uiPrp0.FontSize			= 10;
uiPrp0.FontUnits		= 'points';
uiPrp0.HorizontalAlignment	= 'left'; 
uiPrp0.Units			= 'points';

rsd				= stimPlotAll_fillDataPnl(rsd, uiPrp0);

setappdata(fig, 'rsd', rsd)

set(fig, 'Resize', 'on');
set(fig, 'ResizeFcn'      , @stimPlotAll_resize);
set(fig, 'CloseRequestFcn', @stimPlotAll_close);
set(fig, 'Visible', 'on')

end  % #build
%__________________________________________________________
%% #fillDataPnl
%
function rsd = stimPlotAll_fillDataPnl(rsd, uiPrp0)

offset				= 5;
lblSize				= [50 20];
popupSize			= [200 20];
buttonSize			= [60 20];
editSize			= [30 20];

x1				= offset;
x2				= x1 + lblSize(1) + offset;
x3				= x2 + popupSize(1) + offset;
x4				= x3 + lblSize(1) + offset;
x5				= x4 + popupSize(1) + offset*2;
x6				= x5 + lblSize(1) + offset;
x7				= x6 + buttonSize(1) + offset;
x8				= x7 + editSize(1) + offset*2;

y1				= offset;
y2				= y1 + lblSize(2) + offset;

set(rsd.dataPnl, 'Position', [0 0 10 y2 + lblSize(2) + offset]);

uiPrp0.Parent			= rsd.dataPnl;

lblPrp				= uiPrp0;
lblPrp.Style			= 'text';
lblPrp.FontWeight		= 'bold';
lblPrp.HorizontalAlignment	= 'right'; 
lblPrp.BackgroundColor		= rsd.figColor;

popupPrp			= uiPrp0;
popupPrp.Style			= 'popup';
popupPrp.BackgroundColor	= 'w';

% ----------------- Source 1 -----------------
lblPrp.String			= 'Source 1:';
lblPrp.Position			= [x1 y2-3 lblSize];
uicontrol(lblPrp);

popupPrp.String			= 'No type available';
popupPrp.Position		= [x2 y1 popupSize];
popupPrp.Callback		= '';
rsd.dataType(1)			= uicontrol(popupPrp);

popupPrp.String			= 'No source available';
popupPrp.Position		= [x2 y2 popupSize];
popupPrp.Callback		= @stimPlotAll_changeSrc;
popupPrp.Userdata		= rsd.dataType(1);
rsd.source(1)			= uicontrol(popupPrp);

% ----------------- Source 2 -----------------
lblPrp.String			= 'Source 2:';
lblPrp.Position			= [x3 y2-3 lblSize];
uicontrol(lblPrp);

popupPrp.String			= 'No type available';
popupPrp.Position		= [x4 y1 popupSize];
popupPrp.Callback		= '';
rsd.dataType(2)			= uicontrol(popupPrp);

popupPrp.String			= 'No source available';
popupPrp.Position		= [x4 y2 popupSize];
popupPrp.Callback		= @stimPlotAll_changeSrc;
popupPrp.Userdata		= rsd.dataType(2);
rsd.source(2)			= uicontrol(popupPrp);

% ------------------ Button ------------------
uiPrp				= uiPrp0;
uiPrp.Style			= 'pushbutton';
uiPrp.String			= 'Plot';
uiPrp.Position			= [x5 y1 buttonSize];
uiPrp.Callback			= @stimPlotAll_plot;
rsd.plot			= uicontrol(uiPrp);

% ------------------ Xlim ------------------
lblPrp.String			= 'X-lim:';
lblPrp.Position			= [x6 y2-3 lblSize];
uicontrol(lblPrp);

uiPrp				= uiPrp0;
uiPrp.Style			= 'pushbutton';
uiPrp.String			= 'Reset';
uiPrp.Position			= [x8 y2 buttonSize];
uiPrp.Callback			= {@stimPlotAll_setXlim, 'reset'};
uicontrol(uiPrp);

uiPrp.String			= 'Set';
uiPrp.Position			= [x8 y1 buttonSize];
uiPrp.Callback			= {@stimPlotAll_setXlim, 'set'};
uicontrol(uiPrp);

uiPrp				= uiPrp0;
uiPrp.Style			= 'edit';
uiPrp.String			= '';
uiPrp.BackgroundColor		= 'w';
uiPrp.Callback			= {@stimPlotAll_setXlim, 'set'};
uiPrp.Position			= [x7 y2 editSize];
rsd.Xlim(1)			= uicontrol(uiPrp);

uiPrp.Position			= [x7 y1 editSize];
uiPrp.Callback			= {@stimPlotAll_setXlim, 'set'};
rsd.Xlim(2)			= uicontrol(uiPrp);

end  % #fillDataPnl
%__________________________________________________________
%% #resize
%
function stimPlotAll_resize(h, evd)
  
fig		= hfigure(h);
rsd		= getappdata(fig, 'rsd');
figPos		= get(fig, 'Position');

dataPnlPos	= get(rsd.dataPnl, 'Position');
dataPnlPos(1)	= 0;
dataPnlPos(2)	= figPos(4) - dataPnlPos(4);
dataPnlPos(3)	= figPos(3);


axesPnlPos(1:2)	= [-1 -1];
axesPnlPos(3)	= figPos(3) + 2;
axesPnlPos(4)	= figPos(4) - dataPnlPos(4);

set(rsd.dataPnl, 'Position', dataPnlPos);
set(rsd.axesPnl, 'Position', axesPnlPos);

end  % #resize
%__________________________________________________________
%% #plot
%
function stimPlotAll_plot(h, evd)
  
fig			= hfigure(h);
rsd			= getappdata(fig, 'rsd');

allAxes			= findall(fig, 'Type', 'Axes');
delete(allAxes)

[varNms, plotData, srcsAndTypes] = stimPlotAll_getPlotData(rsd);

nrOfVars		= length(varNms);
n			= floor(nrOfVars/3);
m			= ceil(nrOfVars/n);

for ii = 1:nrOfVars
  varNm_ii		= varNms{ii};
  data			= plotData.(varNm_ii);
  h			= subplot(m,n,ii, 'Parent', rsd.axesPnl);
  data.xData(:,:)	= data.xData(:,:)/3600;
  if size(data.xData, 1) == 1
    plot(h, data.xData(:), data.yData(:))
  elseif size(data.xData, 1) >= 2
    plot(h, data.xData(1,:), data.yData(1,:), data.xData(2,:), data.yData(2,:))
  end
  title(h, varNm_ii, 'Interpreter', 'none')
  xlabel(h, 'time (h)')
  yLabel	= stimResultsGui('getYLabel', data.unit);
  ylabel(h, yLabel)
  xlim(h, [min(min(data.xData(:,:))), max(max(data.xData(:,:)))])

  yLim		= [min(min(data.yData(:,:))), max(max(data.yData(:,:)))];
  dYlim		= yLim(2) - yLim(1);
  yLim(1)	= yLim(1) - 0.2*abs(max(yLim(1), dYlim));
  yLim(2)	= yLim(2) + 0.2*abs(yLim(2));
  ylim(h, yLim)
end

rsd.XlimOrg	= get(h, 'XLim');
set(rsd.Xlim(1), 'String', rsd.XlimOrg(1))
set(rsd.Xlim(2), 'String', rsd.XlimOrg(2))


if nrOfVars < m*n
  h		= subplot(m,n,nrOfVars+1, 'Parent', rsd.axesPnl);  
else
  axesPnlPos	= get(rsd.axesPnl, 'Position');
  axesSize	= [80 60];
  h		= axes('Parent', rsd.axesPnl,'Units', 'points', 'Position',...
    [(axesPnlPos(3)-axesSize(1))/2 (axesPnlPos(4)-axesSize(2))/2 axesSize]);
end
plot(h, [0 0], [0 0], [0 0], [0 0])
set(h, 'Visible', 'off')
legendStr{1}	= sprintf('%s - %s', srcsAndTypes{1,1}, srcsAndTypes{1,2});
legendStr{2}	= sprintf('%s - %s', srcsAndTypes{2,1}, srcsAndTypes{2,2});
hLeg		= legend(h, legendStr{1}, legendStr{2});
set(hLeg, 'Interpreter', 'none')
rsd.hLeg	= hLeg;
setappdata(fig, 'rsd', rsd)

end  % #plot
%__________________________________________________________
%% #getPlotData
%
function [varNms, plotData, srcsAndTypes] = stimPlotAll_getPlotData(rsd)
  
[varNms, rawData, srcsAndTypes] = stimPlotAll_getVarNms(rsd);

plotData			= struct;

for ii = 1:length(varNms)
  varNm		= varNms{ii};
  kk		= 0;
  for jj = 1:length(fieldnames(rawData))
    rawDataNm		= stimPlotAll_rawDataNm(jj);
    data		= rawData.(rawDataNm);
    if isfield(data, varNm)      
      kk		= kk+1;
      plotData.(varNm).xData(kk,:)	= data.time;
      plotData.(varNm).yData(kk,:)	= data.(varNm).yData;
      plotData.(varNm).unit		= data.(varNm).unit;
    end
  end % for jj    
end % for ii

end  % #getPlotData
%__________________________________________________________
%% #getVarNms
%
function [varNms, rawData, srcsAndTypes] = stimPlotAll_getVarNms(rsd)
  
varNms		= {};
rawData		= struct;
srcsAndTypes	= {};

for ii = 1:size(rsd.source, 2)
  srcNms_ii		= get(rsd.source(ii), 'String');
  srcVal_ii		= get(rsd.source(ii), 'Value');
  srcNm_ii		= srcNms_ii{srcVal_ii};
  typeNms_ii		= get(rsd.dataType(ii), 'String');
  typeVal_ii		= get(rsd.dataType(ii), 'Value');
  typeNm_ii		= typeNms_ii{typeVal_ii};
  varNms_ii		= rsd.data.(srcNm_ii).(typeNm_ii).varNms;
  varNms		= union(varNms, varNms_ii);
  rawDataNm		= stimPlotAll_rawDataNm(ii);
  rawData.(rawDataNm)	= rsd.data.(srcNm_ii).(typeNm_ii);
  srcsAndTypes{ii,1}	= srcNm_ii;
  srcsAndTypes{ii,2}	= typeNm_ii;
end % for ii

end  % #getVarNms
%__________________________________________________________
%% #rawDataNm
%
function rawDataNm = stimPlotAll_rawDataNm(nr)
  
rawDataNm = sprintf('rd%d', nr);

end  % #rawDatNm
%__________________________________________________________
%% #changeSrc
%
function stimPlotAll_changeSrc(h, evd)
  
fig		= hfigure(h);
rsd		= getappdata(fig, 'rsd');

srcNms		= get(h, 'String');
val		= get(h, 'Value');
srcNm		= srcNms{val};
data		= rsd.data;
typeNms		= fieldnames(data.(srcNm));
typeField	= get(h, 'Userdata');

set(typeField, 'String', typeNms)
set(typeField, 'Value', 1)

% if isequal(h, rsd.source(1))
%   srcNms2	= get(rsd.source(2), 'String');
%   val2		= get(rsd.source(2), 'Value');
%   srcNm2	= srcNms2{val2};
%   srcNms	= setdiff(srcNms, srcNm);
%   set(rsd.source(2), 'String', srcNms)
%   ind		= strcmp(srcNms, srcNm2);
%   if any(ind)
%     val		= find(ind);
%     valDataType = get(rsd.dataType(2), 'Value');
%   else
%     val		= 1;
%   end
%   set(rsd.source(2), 'Value', val)
%   if any(ind)    
%     set(rsd.dataType(2), 'Value', valDataType)
%   end
% end

end  % #changeSrc
%__________________________________________________________
%% #setXlim
%
function stimPlotAll_setXlim(h, evd, type)

fig		= hfigure(h);
rsd		= getappdata(fig, 'rsd');

axes		= findall(fig, 'Type', 'Axes');
axes		= setdiff(axes, rsd.hLeg);

switch type
  case 'set'
    xLim(1)	= str2double(get(rsd.Xlim(1), 'String'));
    xLim(2)	= str2double(get(rsd.Xlim(2), 'String'));
    if isnan(xLim(1)) || xLim(1)<rsd.XlimOrg(1) || xLim(2)<=xLim(1) 
      set(rsd.Xlim(1), 'BackgroundColor', 'r')
      return
    end
    if isnan(xLim(2)) || xLim(2)>rsd.XlimOrg(2) || xLim(1)>=xLim(2)
      set(rsd.Xlim(2), 'BackgroundColor', 'r')
      return
    end
    set(rsd.Xlim(:), 'BackgroundColor', 'w')
  case 'reset'
    xLim	= rsd.XlimOrg;
    set(rsd.Xlim(1), 'String', xLim(1))
    set(rsd.Xlim(2), 'String', xLim(2))
    set(rsd.Xlim(:), 'BackgroundColor', 'w')
  otherwise
    error('No type: %s', type)
end

for ii = 1:length(axes)
  xlim(axes(ii), xLim)
end % for ii

end  % #setXlim
%__________________________________________________________
%% #initData
%
function stimPlotAll_initData(fig, data)
  
rsd		= getappdata(fig, 'rsd');
rsd.data	= data;
srcNms		= fieldnames(data);

set(rsd.source(1), 'String', srcNms)
set(rsd.source(2), 'String', srcNms)
setappdata(fig, 'rsd', rsd)

stimPlotAll_changeSrc(rsd.source(1), '');
stimPlotAll_changeSrc(rsd.source(2), '');

end  % #initData
%__________________________________________________________
%% #getTag
%
function tag = stimPlotAll_getTag
  
tag = 'stimPlotAll';

end  % #getTag
%__________________________________________________________
%% #close
%
function stimPlotAll_close(h, evd)
  
fig		= hfigure(h);
stimResultsGui('rmHandle', 'pa')
delete(fig)

end  % #close
%__________________________________________________________
%% #test
%
function stimPlotAll_test
  

end  % #test
%__________________________________________________________
%% #qqq
%
function stimPlotAll_qqq
  
end  % #qqq
%__________________________________________________________