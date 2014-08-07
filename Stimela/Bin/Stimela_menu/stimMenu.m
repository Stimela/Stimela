% Stimela function creating or updating the Stimela menus
%
% Steps:
% 1.) Check for changes, if no changes return. 
% 2.) Make a copy of the template.
% 3.) Add all entries.
%
% Calls:
% stimMenu('init', type)
% 
% Types: 'My_models', 'My_projects' and 'Stimela_library'
%
% Stimela, 2004-2012

% © Martijn Sparnaaij

function varargout = stimMenu(action, varargin)
  
  if ~nargin
    action	= 'qqq'; 
  end
  
  if nargout
    varargout	= cell(1, nargout);
    [varargout{:}]= feval(['stimMenu_' action], varargin{:});
  else
    feval(['stimMenu_' action], varargin{:});
  end
  
end  % <main>
%__________________________________________________________
%% #init
%
function stimMenu_init(type)
  
[newInit, mdlData]	= stimMenu_checkChanges(type, stimMenu_getMainPd(type));
if ~newInit
  return
end

srcFlNm			= fullfile(stimFolder('Stimela_Menu_Templates'), [type '_0.mdl']);
destFlNm		= fullfile(stimFolder('Stimela_Menu'), [type '.mdl']);

copyfile(srcFlNm, destFlNm, 'f')
rehash
load_system(type)

models	= mdlData.models;

switch lower(type)
  case {'my_models', 'my_projects'}    
    mainBlock	= type;
    for ii = 1:size(models, 2)
      model	= models(ii);
      stimMenu_addModel(mainBlock, type, mdlData.mainPd, model, '', [], 0);
    end % for ii
  case 'stimela_library'
    mainBlock	= {type};
    title	= models(1).pds;
    for ii = 1:size(models, 2)
      model	= models(ii);
      for jj = 1:model.lvl
	newTitle	= models(ii).pds{jj};
	ind		= strcmp(title, newTitle);
	if ii > 1 && length(ind) >= jj && ind(jj) == 1
	  continue;
	end	
	title{jj}	= newTitle;
	mainBlock{jj+1}	= stimMenu_addModel(mainBlock{jj}, type,...
	  mdlData.mainPd, [], title{jj}, jj, -1);
      end % for jj
      stimMenu_addModel(mainBlock{jj+1}, type, mdlData.mainPd, model, '', model.lvl, -1);
    end % for ii
    delete_block('Stimela_library/0');
  otherwise
    error('Type "%s" not known!', type)
end

save_system(type);
close_system(type);

end  % #init
%__________________________________________________________
%% #addModel
%
function newBlock = stimMenu_addModel(mainBlock, type, mainPd, model, title, lvl, n)

block		= 'begin';
while ~isempty(block)
  n	= n+1;
  block	= find_system(mainBlock, 'SearchDepth', 1, 'Name', num2str(n));
  if length(block) == 1 && strcmp(block, mainBlock)
    break;
  end  
end

srcBlock	= [type '/0'];
newBlock	= [mainBlock '/' num2str(n)];

pos		= get_param(srcBlock, 'Position');
height		= pos(4) - pos(2);

pos(2)		= pos(2)+n*1.3*height;
pos(4)		= pos(4)+n*1.3*height;

add_block(srcBlock, newBlock, 'Position', pos);

if ~isempty(title)
  %add title
  pos		= get_param(srcBlock, 'Position');
  height	= pos(4) - pos(2);
  pos(2)	= pos(2)-3*1.3*height;
  pos(4)	= pos(4)-3*1.3*height;
  titleBlock	= add_block('built-in/Note',[newBlock '/Note1'],'Position',pos);
  set_param(titleBlock,'Name',title,'FontSize',20);
end


if ~isempty(model) && isempty(lvl)
  set_param(newBlock, 'BackgroundColor', stimMenu_getColorStr(type));
end
if isempty(title)
  pd	= fullfile(mainPd, model.pds{:});
    openFcnStr	= sprintf('stimMenu(''open'', ''%s'', ''%s'')',...
    pd, model.nm);
  set_param(newBlock, 'OpenFcn', openFcnStr);
end
set_param(newBlock, 'MaskDisplay', stimMenu_getMaskStr(type, model, title));

end  % #addModel
%__________________________________________________________
%% #open
%
function stimMenu_open(pd, modelNm)
  
cd(pd)
open_system(modelNm)

end  % #open
%__________________________________________________________
%% #getColorStr
%
function colorStr = stimMenu_getColorStr(type)
  
switch lower(type)
  case 'my_models'
    colorStr = 'orange';
  case 'my_projects'
    colorStr = 'lightBlue';
  case 'stimela_library'
    colorStr = '';
  otherwise
    error('Type "%s" not known!', type)
end

end  % #getColorStr
%__________________________________________________________
%% #getMaskStr
%
function maskStr = stimMenu_getMaskStr(type, model, title)
  
switch lower(type)
  case 'my_models'
    maskStr	= sprintf('%s(%s)', model.pds{1}, model.nm(1:end-2));
  case 'my_projects'
    maskStr	= model.nm;
  case 'stimela_library'
    if isempty(title)
      maskStr	= model.nm;
    else
      maskStr	= title;
    end
  otherwise
    error('Type "%s" not known!', type)
end

maskStr	= ['disp(''' maskStr ''')'];

end  % #getMaskStr
%__________________________________________________________
%% #getMainPd
%
function mainPd = stimMenu_getMainPd(type)
 
switch lower(type)
  case 'my_models'
    mainPd = stimFolder('My_models');
  case 'my_projects'
    mainPd = stimFolder('My_projects');
  case 'stimela_library'
    mainPd = stimFolder('Standard_models');
  otherwise
    error('Type "%s" not known!', type)
end

end  % #getMainPd
%__________________________________________________________
%% #checkChanges
%
function [newInit, mdlData] = stimMenu_checkChanges(type, mainPd)

newInit		= false;

mdlFls		= stimGetFiles('get', mainPd, '.mdl');
if ~isempty(mdlFls)
  [dum, sortInd]	= sort(mdlFls(:,1));
  mdlFls		= mdlFls(sortInd,:);
end

flNm		= fullfile(stimFolder('Stimela_menu'), [type '_dat.mat']);
if ~exist(flNm, 'file')
  stimMenu_createDatFl(mdlFls, flNm, mainPd)
  mdlData		= load(flNm);
  newInit = true;
  return
end

mdlData		= load(flNm);
models		= mdlData.models;
nr		= 0;
nrOfModels	= length(models);

for ii = 1:size(mdlFls, 1)
  if ii-nr > nrOfModels
    newInit	= true;
    stimMenu_createDatFl(mdlFls, flNm, mainPd)
    mdlData	= load(flNm);
    break;
  end
  modelFlNm	= mdlFls{ii,2};
  if stimMenu_beforeUpdateCheck(modelFlNm)
    nr	= nr+1;
    continue
  end
  modelNm	= strrep(modelFlNm, '.mdl', '');
  pd		= [fullfile(mdlData.mainPd, models(ii-nr).pds{:}) filesep];
  if ~(strcmp(models(ii-nr).nm, modelNm) && strcmp(mdlFls{ii,1}, pd))
    newInit	= true;
    stimMenu_createDatFl(mdlFls, flNm, mainPd)
    mdlData	= load(flNm);
    break;
  end
end % for ii

end  % #checkChanges
%__________________________________________________________
%% #createDatFl
%
function stimMenu_createDatFl(mdlFls, flNm, mainPd)
  
mdlData		= struct;
mdlData.mainPd	= mainPd;
models		= struct([]);
nr		= 0;
for ii = 1:size(mdlFls, 1)
  modelFlNm		= mdlFls{ii,2};
  if stimMenu_beforeUpdateCheck(modelFlNm)
    nr	= nr+1;
    continue
  end
  modelNm		= strrep(modelFlNm, '.mdl', '');
  models(ii-nr).nm	= modelNm;
  pd			= mdlFls{ii,1};
  pd			= pd(length(mainPd)+2:end-1);
  pds			= textscan(pd, '%s', 'Delimiter', ['\' filesep]);
  pds			= pds{:};
  models(ii-nr).lvl	= length(pds);
  models(ii-nr).pds	= pds;
end % for ii
mdlData.models	= models;
save(flNm, '-struct', 'mdlData');

end  % #createDatFl
%__________________________________________________________
%% #beforeUpdateCheck
%
function isBeforeUpdate = stimMenu_beforeUpdateCheck(flNm)
  
if any(strfind(flNm, 'BeforeCheck')) || any(strfind(flNm, 'BeforeUpdate'))
  isBeforeUpdate = true;
else
  isBeforeUpdate = false;
end

end  % #beforeUpdateCheck
%__________________________________________________________
%% #qqq
%
function stimMenu_qqq
  
end  % #qqq
%__________________________________________________________