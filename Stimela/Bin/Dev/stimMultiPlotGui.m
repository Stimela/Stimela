function varargout = stimMultiPlotGui(action, varargin)
  
  if ~nargin
    action	= 'test'; 
  end
  
  if nargout
    varargout	= cell(1, nargout);
    [varargout{:}]= feval(['stimMultiPlotGui_' action], varargin{:});
  else
    feval(['stimMultiPlotGui_' action], varargin{:});
  end
  
end  % <main>
%__________________________________________________________
%% #init
%
function fig = stimMultiPlotGui_init(rsdP)
  
fig		= stimMultiPlotGui_build;
rsd		= getappdata(fig, 'rsd');
labelC		= stimResultsGui('getLabelsC');
set(rsd.unitPopup, 'String', labelC(:,1));

rsd.unitStruct	= stimMultiPlotGui_createUnitStruct(rsdP.dataStruct, labelC);
rsd.rsdP	= rsdP; 
setappdata(fig, 'rsd', rsd)

stimMultiPlotGui_unitChange(rsd.unitPopup, '')

end  % #init
%__________________________________________________________
%% #build
%
function fig = stimMultiPlotGui_build
  
fig = stimFigure('create', 'stimMultiPlotGui', 'Stimela multiplot', [400 800], true);

set(fig, 'Resize', 'on');
set(fig, 'ResizeFcn'      , @stimMultiPlotGui_resize);
set(fig, 'CloseRequestFcn', @stimMultiPlotGui_close);

figColor			= get(fig, 'Color');

rsd				= struct;

uiPrp0				= struct;
uiPrp0.FontName			= 'Arial';
uiPrp0.FontSize			= 10;
uiPrp0.FontUnits		= 'points';
uiPrp0.HorizontalAlignment	= 'left'; 
uiPrp0.Units			= 'points';

% ========================== unit ==========================
uiPrp				= uiPrp0;
uiPrp.Style			= 'text';
uiPrp.BackgroundColor		= figColor;
uiPrp.String			= 'Unit:';
rsd.unitLbl			= uicontrol(uiPrp);

uiPrp				= uiPrp0;
uiPrp.Style			= 'popup';
uiPrp.BackgroundColor		= 'w';
uiPrp.Callback			= @stimMultiPlotGui_unitChange;
rsd.unitDlftStr			= 'No units available';
uiPrp.String			= {rsd.unitDlftStr};
rsd.unitPopup			= uicontrol(uiPrp);

% ========================= buttons =========================
uiPrp				= uiPrp0;
uiPrp.Style			= 'pushbutton';

uiPrp.String			= 'cancel';
uiPrp.Callback			= @stimMultiPlotGui_cancel;
rsd.cancelButton		= uicontrol(uiPrp);

uiPrp.String			= 'plot';
uiPrp.Callback			= @stimMultiPlotGui_plot;
rsd.plotButton			= uicontrol(uiPrp);

% ========================== boxes ==========================
rsd.typeStr			= {'waterIn', 'waterOut', 'extraIn', 'extraOut'};

uiPrp				= uiPrp0;
uiPrp.BackgroundColor		= figColor;
uiPrp.Style			= 'Checkbox';
uiPrp.Value			= 1;
uiPrp.Callback			= @stimMultiPlotGui_typeChange;
for ii = 1:length(rsd.typeStr)
  uiPrp.String		= rsd.typeStr{ii};
  rsd.typeBox(ii)	= uicontrol(uiPrp);
end % for ii

% ========================= tables ==========================

rsd.srcTable			= uitable(fig);
rsd.varTypeTable		= uitable(fig);
rsd.varTable			= uitable(fig);

uitPrp				= uiPrp0;
uitPrp				= rmfield(uitPrp, 'HorizontalAlignment');

uitPrp.ColumnEditable		= [true false];
uitPrp.ColumnFormat		= {'logical', 'char'};
uitPrp.ColumnName		= {'use', 'Source'};	
uitPrp.RowName			= [];
uitPrp.CellEditCallback		= @stimMultiPlotGui_srcChange;
set(rsd.srcTable, uitPrp)

uitPrp.ColumnEditable		= [true false];
uitPrp.ColumnFormat		= {'logical', 'char'};
uitPrp.ColumnName		= {'use', 'Variable'};	
uitPrp.RowName			= [];
uitPrp.CellEditCallback		= @stimMultiPlotGui_varTypeChange;
set(rsd.varTypeTable, uitPrp)

uitPrp.ColumnEditable		= [true false false false];
uitPrp.ColumnFormat		= {'logical', 'char', 'char', 'char'};
uitPrp.ColumnName		= {'use', 'Variable', 'Type', 'Source'};	
uitPrp.RowName			= [];
uitPrp.CellEditCallback		= '';
set(rsd.varTable, uitPrp)

setappdata(fig, 'rsd', rsd)

set(fig, 'Visible', 'on')

end  % #build
%__________________________________________________________
%% #resize
%
function stimMultiPlotGui_resize(h, evd)
  
fig		= hfigure(h);
rsd		= getappdata(fig, 'rsd');
figPos		= get(fig, 'Position');

minHeight	= 160;
if figPos(4) < minHeight
  diff		= minHeight - figPos(4);
  figPos(4)	= minHeight;  
  figPos(2)	= figPos(2) - diff;
  set(fig, 'Position', figPos)
end

lblSize		= [20 20];
popupSize	= [100 lblSize(2)];
buttonSize	= [60 20];
boxSize		= [60 20];
offset		= 10;

y1		= figPos(4) - offset - lblSize(2);
unitLblPos	= [offset y1-3];
unitPopupPos	= [2*offset + lblSize(1) y1];

y2		= y1 - offset - boxSize(2);

for ii = 1:length(rsd.typeStr)
  x	= offset + (offset + boxSize(1))*(ii-1);
  set(rsd.typeBox(ii), 'Position', [x y2 boxSize]);
end % for ii

cancelButtonPos	= [figPos(3) - (offset + buttonSize(1)) offset];
plotButtonPos	= [figPos(3) - 2*(offset + buttonSize(1)) offset];

varTablePos	= [offset plotButtonPos(2) + buttonSize(2) + offset];
height		= y2 - 2*offset - varTablePos(2);
varTableSize	= [figPos(3) - 2*offset height*3/4];

width		= (figPos(3) - 3*offset)/2;
srcTablePos	= [offset varTablePos(2) + varTableSize(2) + offset];
midTableSize	= [width height*1/4];
varTypeTablePos	= [offset*2+width varTablePos(2) + varTableSize(2) + offset];


set(rsd.unitLbl      , 'Position', [unitLblPos      lblSize]);
set(rsd.unitPopup    , 'Position', [unitPopupPos    popupSize]);
set(rsd.cancelButton , 'Position', [cancelButtonPos buttonSize]);
set(rsd.plotButton   , 'Position', [plotButtonPos   buttonSize]);
set(rsd.srcTable     , 'Position', [srcTablePos     midTableSize]);
set(rsd.varTypeTable , 'Position', [varTypeTablePos midTableSize]);
set(rsd.varTable     , 'Position', [varTablePos     varTableSize]);

colWidth1		= 60;
tableWidthPix		= stimMultiPlotGui_point2pix(midTableSize(1));
set(rsd.srcTable, 'ColumnWidth', {colWidth1, tableWidthPix-colWidth1-18})
set(rsd.varTypeTable, 'ColumnWidth', {colWidth1, tableWidthPix-colWidth1-18})
varTableWidthPix	= stimMultiPlotGui_point2pix(varTableSize(1));
colWidth2		= (varTableWidthPix-colWidth1-15)/3;
set(rsd.varTable, 'ColumnWidth', {colWidth1-1, colWidth2,colWidth2,colWidth2})

end  % #resize
%__________________________________________________________
%% #point2pix
%
function pixSize = stimMultiPlotGui_point2pix(pointSize)
  
pixPerInch		= get(0, 'ScreenPixelsPerInch');
pointToPix		= pixPerInch/72;

pixSize			= pointSize*pointToPix;

end  % #point2pix
%__________________________________________________________
%% #plot
%
function stimMultiPlotGui_plot(h, evd)
  
fig		= hfigure(h);
rsd		= getappdata(fig, 'rsd');
rsdP		= rsd.rsdP;
dataStruct	= rsdP.dataStruct;

tableData	= get(rsd.varTable, 'Data');
ind		= cell2mat(tableData(:,1));
tableData	= tableData(ind,2:4);

if isempty(tableData), return, end

time		= dataStruct.(tableData{1,3}).(tableData{1,2}).time;
timeLength	= size(time, 2);
time		= time/3600;

legendStr	= cell(size(tableData, 1), 1);
xData		= zeros(size(tableData, 1), timeLength);
yData		= xData;

for ii = 1:size(tableData, 1)
    varNm_ii		= tableData{ii, 1};
    typeNm_ii		= tableData{ii, 2};
    srcNm_ii		= tableData{ii, 3};
    data_ii		= dataStruct.(srcNm_ii).(typeNm_ii).(varNm_ii);
    legendStr{ii}	= data_ii.legendStr;
    xData(ii,:)		= time;
    yData(ii,:)		= data_ii.yData;
end % for ii

add		= get(rsdP.addBox, 'Value');
unitVal		= get(rsd.unitPopup, 'Value');
unitStr		= get(rsd.unitPopup, 'String');
unit		= unitStr{unitVal};

rsdP		= stimResultsGui('plot', rsdP, xData, yData, legendStr, unit, add);

setappdata(rsdP.fig, 'rsd', rsdP)

end  % #plot
%__________________________________________________________
%% #cancel
%
function stimMultiPlotGui_cancel(h, evd)
  
fig		= hfigure(h);
close(fig)

end  % #cancel
%__________________________________________________________
%% #unitChange
%
function stimMultiPlotGui_unitChange(h, evd)
  
fig	= hfigure(h);
rsd	= getappdata(fig, 'rsd');

val	= get(rsd.unitPopup, 'Value');

data			= rsd.unitStruct(val);

for ii = 1:length(rsd.typeBox)
  set(rsd.typeBox(ii), 'Enable', 'on')
  str	= get(rsd.typeBox(ii), 'String');
  set(rsd.typeBox(ii), 'Value', 1)
  if ~any(strcmpi(str, data.types))
    set(rsd.typeBox(ii), 'Enable', 'off')
  end
end % for ii

stimMultiPlotGui_filter(rsd, {}, {}, {})

end  % #unitChange
%__________________________________________________________
%% #typeChange
%
function stimMultiPlotGui_typeChange(h, evd)
  
fig	= hfigure(h);
rsd	= getappdata(fig, 'rsd');

types	= {};

for ii = 1:length(rsd.typeBox)
  if strcmp(get(rsd.typeBox(ii), 'Enable'), 'on') && get(rsd.typeBox(ii), 'Value')
    types{end+1} = get(rsd.typeBox(ii), 'String');
  end
end % for ii
if isempty(types)
  set(h, 'Value', ~get(h, 'Value'))
  return
end

stimMultiPlotGui_filter(rsd, types, {}, {})

end  % #typeChange
%__________________________________________________________
%% #srcChange
%
function stimMultiPlotGui_srcChange(h, evd)
  
fig	= hfigure(h);
rsd	= getappdata(fig, 'rsd');

data	= get(rsd.srcTable, 'Data');

srcsOn	= {};

for ii = 1:size(data,1)
  if data{ii,1}
    srcsOn{end+1} = data{ii,2};
  end
end

stimMultiPlotGui_filter(rsd, {}, srcsOn, {})

end  % #srcChange
%__________________________________________________________
%% #varTypeChange
%
function stimMultiPlotGui_varTypeChange(h, evd)
  
fig		= hfigure(h);
rsd		= getappdata(fig, 'rsd');

data		= get(rsd.varTypeTable, 'Data');

varTypes	= {};

for ii = 1:size(data,1)
  if data{ii,1}
    varTypes{end+1} = data{ii,2};
  end
end

stimMultiPlotGui_filter(rsd, {}, {}, varTypes)

end  % #varTypeChange
%__________________________________________________________
%% #filter
%
function stimMultiPlotGui_filter(rsd, types, srcsOn, varTypes)
 
val			= get(rsd.unitPopup, 'Value');
data			= rsd.unitStruct(val);
vars			= data.vars;

if isempty(types)
  srcs			= data.sources;
  ind			= true(size(vars,1), 1);
else
  ind			= false(size(vars,1), 1);
  srcs			= {};
  for ii = 1:length(types)
    srcs	= union(data.(types{ii}), srcs);
    indType	= strcmp(vars(:,2), types{ii});
    ind		= or(ind, indType);
  end %for ii
  srcs = unique(srcs);
end

if ~isempty(srcsOn)
  ind			= false(size(vars,1), 1);
  for ii = 1:length(srcsOn)
    indType	= strcmp(vars(:,1), srcsOn{ii});
    ind		= or(ind, indType);
  end %for ii
elseif isempty(varTypes)
  srcTableData		= cell(length(srcs), 2);
  srcTableData(:,1)	= {true};
  srcTableData(:,2)	= srcs(:);
  set(rsd.srcTable, 'Data', srcTableData)
end

if ~isempty(varTypes)
  ind			= false(size(vars,1), 1);
  for ii = 1:length(varTypes)
    indType	= strcmp(vars(:,3), varTypes{ii});
    ind		= or(ind, indType);
  end %for ii
else
  varTypes		= unique(vars(ind,3));
  varTypesData		= cell(length(varTypes), 2);
  varTypesData(:,1)	= {true};
  varTypesData(:,2)	= varTypes(:);
  set(rsd.varTypeTable, 'Data', varTypesData)
end

varTableData		= cell(sum(ind), 4);
varTableData(:,1)	= {true};
varTableData(:,2)	= vars(ind,3);
varTableData(:,3)	= vars(ind,2);
varTableData(:,4)	= vars(ind,1);
set(rsd.varTable, 'Data', varTableData)

end  % #filter
%__________________________________________________________
%% #filterNew
%
function stimMultiPlotGui_filterNew(rsd, types, srcsOn, varTypes)
 
val			= get(rsd.unitPopup, 'Value');
data			= rsd.unitStruct(val);
vars			= data.vars;

if isempty(types)
  srcs			= data.sources;
  ind			= true(size(vars,1), 1);
else
  ind			= false(size(vars,1), 1);
  srcs			= {};
  for ii = 1:length(types)
    srcs	= union(data.(types{ii}), srcs);
    indType	= strcmp(vars(:,2), types{ii});
    ind		= or(ind, indType);
  end %for ii
  srcs			= unique(srcs);
  srcsOldTable		= get(rsd.srcTable, 'data');
  srcsOld		= srcsOldTable(:,2);
  n			= size(srcs, 1);  
  ind1			= ismember(srcs, srcsOld);
  ind2			= ismember(srcsOld, srcs);
  srcsNewTable		= cell(n, 2);
  srcsNewTable(:,2)	= srcs;
  srcsNewTable(:,1)	= {true};
  srcsNewTable(ind1,1)	= srcsOldTable(ind2,1);
  set(rsd.srcTable, 'Data', srcsNewTable)
end

% if ~isempty(srcsOn)
%   ind			= false(size(vars,1), 1);
%   for ii = 1:length(srcsOn)
%     indType	= strcmp(vars(:,1), srcsOn{ii});
%     ind		= or(ind, indType);
%   end %for ii
% elseif isempty(varTypes)
%   srcTableData		= cell(length(srcs), 2);
%   srcTableData(:,1)	= {true};
%   srcTableData(:,2)	= srcs(:);
%   set(rsd.srcTable, 'Data', srcTableData)
% end
% 
% if ~isempty(varTypes)
%   ind			= false(size(vars,1), 1);
%   for ii = 1:length(varTypes)
%     indType	= strcmp(vars(:,3), varTypes{ii});
%     ind		= or(ind, indType);
%   end %for ii
% else
%   varTypes		= unique(vars(ind,3));
%   varTypesData		= cell(length(varTypes), 2);
%   varTypesData(:,1)	= {true};
%   varTypesData(:,2)	= varTypes(:);
%   set(rsd.varTypeTable, 'Data', varTypesData)
% end
% 
% varTableData		= cell(sum(ind), 4);
% varTableData(:,1)	= {true};
% varTableData(:,2)	= vars(ind,3);
% varTableData(:,3)	= vars(ind,2);
% varTableData(:,4)	= vars(ind,1);
% set(rsd.varTable, 'Data', varTableData)

end  % #filterNew
%__________________________________________________________
%% #createUnitStruct
%
function unitStruct = stimMultiPlotGui_createUnitStruct(data, labelC)
  
srcNms		= fieldnames(data);

unitC		= {};
unitStruct	= struct;

for ii = 1:length(srcNms)
  dataNms = fieldnames(data.(srcNms{ii}));
  for jj = 1:length(dataNms)
    varNms = data.(srcNms{ii}).(dataNms{jj}).varNms;
    for kk = 1:length(varNms)
      unitC{end+1,1} = srcNms{ii};
      unitC{end  ,2} = dataNms{jj};
      unitC{end  ,3} = varNms{kk};
      unitC{end  ,4} = data.(srcNms{ii}).(dataNms{jj}).(varNms{kk}).unit;
    end % for kk
  end % for jj
end % for ii

for ii = 1:size(labelC, 1)
  ind				= strcmp(unitC(:,4), labelC{ii,1});
  unitStruct(ii).sources	= unique(unitC(ind,1));
  unitStruct(ii).types		= unique(unitC(ind,2));
  unitStruct(ii).vars		= unitC(ind,1:3);
  for jj = 1:length(unitStruct(ii).types)
    type			= unitStruct(ii).types{jj};
    ind				= strcmp(unitC(:,2), type);
    unitStruct(ii).(type) 	= unique(unitC(ind,1));       
  end % for jj
end % for ii

end  % #createUnitStruct
%__________________________________________________________
%% #close
%
function stimMultiPlotGui_close(h, evd)
  
fig		= hfigure(h);
stimResultsGui('rmHandle', 'mp')
delete(fig)
  
end  % #close
%__________________________________________________________
%% #test
%
function stimMultiPlotGui_test
  
rsdP = evalin('base', 'rsd'); 

stimMultiPlotGui_init(rsdP)

end  % #test
%__________________________________________________________
%% #qqq
%
function stimMultiPlotGui_qqq
  
end  % #qqq
%__________________________________________________________