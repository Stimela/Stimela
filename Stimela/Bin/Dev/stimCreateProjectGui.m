function varargout = stimCreateProjectGui(action, varargin)
  
  if ~nargin
    action	= 'build'; 
  end
  
  if nargout
    varargout	= cell(1, nargout);
    [varargout{:}]= feval(['stimCreateProjectGui_' action], varargin{:});
  else
    feval(['stimCreateProjectGui_' action], varargin{:});
  end
  
end  % <main>
%__________________________________________________________
%% #build
%
function stimCreateProjectGui_build
  
tag	= 'createProjectGui';
fig	= stimFigure('create', tag, 'Stimela create project', [500 500], true);
set(fig, 'CloseRequestFcn', @stimCreateProjectGui_close)
set(fig, 'Visible', 'on')

rsd				= struct;
figPos				= get(fig, 'Position');

uiPrp0				= struct;
uiPrp0.FontName			= 'Arial';
uiPrp0.FontSize			= 12;
uiPrp0.FontUnits		= 'points';
uiPrp0.Units			= 'points';
uiPrp0.Parent			= fig;
uiPrp0.HorizontalAlignment	= 'left'; 

% ================== Title ==================

uiPrp				= uiPrp0; 
uiPrp.HorizontalAlignment	= 'center'; 
uiPrp.Style			= 'text';
uiPrp.BackgroundColor		= get(fig, 'Color');
uiPrp.FontSize			= 14;
uiPrp.FontWeight		= 'bold';
uiPrp.Position			= [10 figPos(4)-25 figPos(3)-20 20];
uiPrp.String			= 'Stimela create project';
uicontrol(uiPrp);

% ================== Labels ==================

uiSize1				= [60 20];
x1				= 10;
x2				= 2*x1+uiSize1(1); 
uiSize2				= [figPos(3)-(x2+x1) 20];
y1				= figPos(4)-60;
y2				= y1-30;
y3				= y2-30;
y4				= y3-30;

uiPrp				= uiPrp0; 
uiPrp.HorizontalAlignment	= 'right'; 
uiPrp.Style			= 'text';
uiPrp.BackgroundColor		= get(fig, 'Color');

uiPrp.Position			= [x1 y1-3 uiSize1];
uiPrp.String			= 'Name:';
uicontrol(uiPrp);

uiPrp.Position			= [x1 y2-3 uiSize1];
uiPrp.String			= 'Label:';
uicontrol(uiPrp);

uiPrp.Position			= [x1 y3-3 uiSize1];
uiPrp.String			= 'New:';
uicontrol(uiPrp);

% ================== Buttons ==================

uiPrp				= uiPrp0; 
uiPrp.Style			= 'pushbutton';

uiPrp.Position			= [figPos(3)-140 10 uiSize1];
uiPrp.String			= 'Create';
uiPrp.Callback			= @stimCreateProjectGui_create;
rsd.create			= uicontrol(uiPrp);

uiPrp.Position			= [figPos(3)-70 10 uiSize1];
uiPrp.String			= 'Exit';
uiPrp.Callback			= @stimCreateProjectGui_close;
rsd.exit			= uicontrol(uiPrp);

% ================== Fields ==================

uiPrp				= uiPrp0; 
uiPrp.Style			= 'edit';
uiPrp.BackgroundColor		= 'w';

uiPrp.Position			= [x2 y1 uiSize2];
uiPrp.String			= '';
uiPrp.Callback			= {@stimCreateProjectGui_checkInput, 'name'};
rsd.name			= uicontrol(uiPrp);

uiPrp.Position			= [x2 y2 uiSize2];
uiPrp.String			= '';
uiPrp.Callback			= {@stimCreateProjectGui_checkInput, 'label'};
rsd.label			= uicontrol(uiPrp);

uiPrp				= uiPrp0; 
uiPrp.BackgroundColor		= get(fig, 'Color');
uiPrp.Style			= 'Checkbox';
uiPrp.Value			= 1;
uiPrp.Position			= [x2 y3+3 30 15];
rsd.isNew			= uicontrol(uiPrp);

% ================== Directory ==================

uiPrp				= uiPrp0; 
uiPrp.Style			= 'pushbutton';
uiPrp.Position			= [x1 y4 uiSize1];
uiPrp.String			= 'Directory';
uiPrp.Callback			= @stimCreateProjectGui_getPd;
rsd.pdChoose			= uicontrol(uiPrp);

uiPrp				= uiPrp0; 
uiPrp.Style			= 'text';
uiPrp.Position			= [x2 y4-3 uiSize2];
uiPrp.String			= 'Choose a project directory';
uiPrp.Callback			= '';
uiPrp.BackgroundColor		= get(fig, 'Color');
rsd.pdShow			= uicontrol(uiPrp);

% ================== Table ==================

rsd.modelTable			= uitable(fig);

uitPrp				= uiPrp0;
uitPrp				= rmfield(uitPrp, 'HorizontalAlignment');
uitPrp.Position			= [10 50 figPos(3)-20 y4-60];
uitPrp.ColumnEditable		= [true false];
uitPrp.ColumnFormat		= {'logical', 'char'};
uitPrp.ColumnName		= {'use', 'modelname'};	
uitPrp.RowName			= [];
tblWidth			= stimCreateProjectGui_pointToPix(uitPrp.Position(3));
uitPrp.ColumnWidth		= {60, tblWidth-61};
set(rsd.modelTable, uitPrp)

setappdata(fig, 'rsd', rsd)

set(fig, 'Visible', 'on')

end  % #build
%__________________________________________________________
%% #checkInput
%
function notValid = stimCreateProjectGui_checkInput(h, evd, type)
  
notValid	= 0;

str		= get(h, 'String');
if isempty(str)
  msg		= sprintf('The field "%s" is empty, it must have a value to continue.', type);
  notValid	= 2;
else
  msg = '';
  switch type
    case 'name'
      if ~stimCreateProject('isValidNm', str)
	msgLn1	= 'The name is not valid, the follwing symbols are allowed:';
	msgLn2	= '"-", "_" and all numbers and letters (whitespace not allowed).';
	msg	= {msgLn1, msgLn2};
	notValid= 2;
      end
    case 'label'
    otherwise
      error('No known: %s', evd)
  end
  if isempty(msg)
    notValid = stimCreateProject('checkNmOrLabel', str, type);
    if notValid == 2
      msgLn1	= sprintf('The %s already exists!', type);
      msgLn2	= sprintf('Choose another %s or delete the project first.', type);
      msg	= {msgLn1, msgLn2};
    elseif notValid == 1
      msgLn1	= sprintf('An project is found with the same %s, only with different cases!', type);
      msgLn2	= sprintf('It is advised to choose another %s to prevent confusion.', type);
      msg	= {msgLn1, msgLn2};
    end
  end
end

if ~isempty(msg)
  msgbox(msg, 'Field value not valid!','warn', 'modal')
end

end  % #checkInput
%__________________________________________________________
%% #getPd
%
function stimCreateProjectGui_getPd(h, evd)

fig		= hfigure(h);
rsd		= getappdata(fig, 'rsd');

projectPd	= uigetdir(userpath, 'Project Directory');

if isnumeric(projectPd), return, end

mdlFiles	= stimGetFiles('get', projectPd, '.mdl', '-showBar', true);

if isempty(mdlFiles)
  msgLn1	= sprintf('No models where found in the chosen directory and its subfolders.');
  msgLn2	= sprintf('Choose another directory.');
  msg		= {msgLn1, msgLn2};
  msgbox(msg, 'No models found','warn', 'modal')
  return
end

stimCreateProjectGui_setPdStr(rsd, projectPd)
set(rsd.pdShow, 'TooltipString', projectPd)

data		= cell(size(mdlFiles, 1), 2);

for ii = 1:size(mdlFiles, 1)
  data{ii,1}	= true;
  data{ii,2}	= mdlFiles{ii,2};
end % for ii
  
set(rsd.modelTable, 'Data', data)

end  % #getPd
%__________________________________________________________
%% #create
%
function stimCreateProjectGui_create(h, evd)
  
fig		= hfigure(h);
rsd		= getappdata(fig, 'rsd');

% Check fields
notValid	= stimCreateProjectGui_checkInput(rsd.name, '', 'name');
if notValid >= 2, return, end
notValid	= stimCreateProjectGui_checkInput(rsd.label, '', 'label');
if notValid >= 2, return, end

projectPd	= get(rsd.pdShow, 'TooltipString');
if isempty(projectPd)
  msgLn1	= sprintf('No project directory has been set.');
  msgLn2	= sprintf('Choose a project directory.');
  msg		= {msgLn1, msgLn2};
  msgbox(msg, 'No models found','warn', 'modal')
  return
end

tableData	= get(rsd.modelTable, 'Data');
if isempty(tableData)
  msgLn1	= sprintf('No models where found in the chosen directory and its subfolders.');
  msgLn2	= sprintf('Choose another directory.');
  msg		= {msgLn1, msgLn2};
  msgbox(msg, 'No models found','warn', 'modal')
  return
end

% collect data from fields
name		= get(rsd.name, 'String');
label		= get(rsd.label, 'String');
isNew		= get(rsd.isNew, 'Value');
modelInd	= cellfun(@any,tableData(:,1));
models		= tableData(modelInd,2);

[ok, msg] = stimCreateProject('create', name, label, isNew, projectPd, models);

stimCreateProjectGui_finish(fig, ok, msg)

end  % #create
%__________________________________________________________
%% #finish
%
function stimCreateProjectGui_finish(fig, ok, msg)
  
if ok
  title		= 'Project succesfully created';
  msg		= {'The project was succefully created!', 'Do you want to close the dialog?'};
else
  title		= 'Project creation failed';
  msg		= {'The project creation has failed!', 'Do you want to close the dialog?'};
end

awnser	= questdlg(msg, title, 'yes','no', 'yes'); 

if strcmpi(awnser, 'yes')
  delete(fig);
end

end  % #finish
%__________________________________________________________
%% #close
%
function stimCreateProjectGui_close(h, evd)
  
fig	= hfigure(h);

msg	= {'Do you want to close?'};
  
awnser	= questdlg(msg,'Close','yes','no','no') ;
if strcmp(awnser, 'no')
  return
end

set(fig, 'Visible', 'off')

delete(fig)

end  % #close
%__________________________________________________________
%% #pointToPix
%
function pixSize = stimCreateProjectGui_pointToPix(pointSize)
  
pixPerInch	= get(0, 'ScreenPixelsPerInch');
pointToPix	= pixPerInch/72;

pixSize		= pointSize*pointToPix;

end  % #pointToPix
%__________________________________________________________
%% #setPdStr
%
function stimCreateProjectGui_setPdStr(rsd, projectPd)

set(rsd.pdShow, 'Visible', 'off')
set(rsd.pdShow, 'String', projectPd)
set(rsd.pdShow, 'TooltipString', projectPd)

pos		= get(rsd.pdShow, 'Position');
strLength	= get(rsd.pdShow, 'Extent');
ii		= 1;

while strLength(3)>pos(3)  
  str		= get(rsd.pdShow, 'String');
  ind		= strfind(str, filesep);
  if ii == 1
    strToRep	= str(ind(ii)+1:ind(ii+1)-1);
    str		= strrep(str, strToRep, '...');
  else
    strToRep	= str(ind(1)+1:ind(ii+1)-1);
    str		= strrep(str, strToRep, '...');    
  end
  set(rsd.pdShow, 'String', str)
  strLength	= get(rsd.pdShow, 'Extent');
  ii		= ii + 1;
end


set(rsd.pdShow, 'Visible', 'on')

end  % #setPdStr
%__________________________________________________________
%% #qqq
%
function stimCreateProjectGui_qqq
  
end  % #qqq
%__________________________________________________________