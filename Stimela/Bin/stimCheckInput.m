% Stimela function for checking the input parameters of the modelblocks:
%
% This function compares the input files :
% 
% Calls:
% % check all input files
% stimCheckInput('check', projectPd)		
% % check only input files of the given model(s)
% stimCheckInput('check', projectPd, '-modeltype', 'modeltype name')
% stimCheckInput('check', projectPd, '-modeltype', {'modeltype name_1', 'modeltype name_n'})
%
% % check only input files whos filename contain a given part (case-sensitive)
% stimCheckInput('check', projectPd, options) %for the options see stimGetFiles
%
% % combinations
% stimCheckInput('check', projectPd, '-modeltype', 'modeltype name', options) 
%
% Stimela, 2004-2012

% © Martijn Sparnaaij


function varargout = stimCheckInput(action, varargin)
  
  if ~nargin
    action	= 'qqq'; 
  end
  
  if nargout
    varargout	= cell(1, nargout);
    [varargout{:}]= feval(['stimCheckInput_' action], varargin{:});
  else
    feval(['stimCheckInput_' action], varargin{:});
  end
  
end  % <main>
%__________________________________________________________
%% #check
%
function inputCheckData = stimCheckInput_check(projectPd, varargin)
  
inputCheckData	= struct;

if ~isempty(varargin)
  mdlInd	= find(strcmpi(varargin, '-modeltype'));
  mdlTypes	= varargin{mdlInd+1};
  varargin(mdlInd:mdlInd+1) = [];
else
  mdlTypes	= '';
end

flsToCheck	= stimCheckInput_getFiles(projectPd, varargin);
if isempty(flsToCheck)
  error('No files!')
end
modelData	= stimCheckInput_getModelData(mdlTypes);

flsFound	= {};

for ii = 1:size(flsToCheck, 1)
  flNm		= fullfile(flsToCheck{ii,1:2});
  mdlType	= [];
  
  
  if ~stimCheckInput_isModelType(flNm, modelData)
    continue;
  end
  flsFound(end+1,:) = flsToCheck(ii,:);
end % for ii

same		= stimCheckInput_findSame(flsFound);
differences	= stimCheckInput_findDifferences(same);

end  % #stimCheckInput
%__________________________________________________________
%% #getFiles
%
function fls = stimCheckInput_getFiles(projectPd, options)
  
[pd, dataPdNm]		= st_StimelaDataDir;
searchPd		= fullfile(projectPd, dataPdNm);
exe			= '.mat';

[fls, flInd, exeInd]	= stimGetFiles('get', searchPd, exe, options);

end  % #getFiles
%__________________________________________________________
%% #checkModelType
%
function isModelType = stimCheckInput_isModelType(flNm, modelData)
   
isModelType	= false;

rawData		= load(flNm);
if ~isfield(rawData, 'P')
  return 
end

fieldNms	= fieldnames(rawData.P)';
if numel(fieldNms) ~= numel(modelData.fieldNms)
  return
end

if ~all(strcmpi(fieldNms, modelData.fieldNms))
  return
end

isModelType	= true;
  
end  % #checkModelType
%__________________________________________________________
%% #getModelData
%
function modelData = stimCheckInput_getModelData(mdlTypes)

exe		= '.m';
if isempty(mdlTypes)
  mdlTypeNms	= {};
  for ii = 1:numel(mdlTypes)
    mdlTypeNms{end+1}	= [mdlTypes{ii} '_d'];
  end % for ii
else
  % find all
  mdlTypeNms	= '_d';
end

mdlFls		= stimGetFiles('get', stimFolder('standard_models'), exe, '-ends', mdlTypeNms);
myMdlFls	= stimGetFiles('get', stimFolder('my_models'), exe, '-ends', mdlTypeNms);

[mdlFls, ok]	= stimCheckInput_checkForDuplicates(mdlFls, myMdlFls);
if ~ok
  return
end

modelData		= struct;

for ii = 1:numel(mdlFls)
  fieldNms	= {};
  fields	= struct;
  mdlFl_ii	= mdlFls{ii};
  mdlFcnNm_ii	= mdlFl_ii(1:end-2);
  rawData	= feval(mdlFcnNm_ii);
  for jj = 1:size(rawData, 1)
    nm			= rawData(jj).Name;
    fieldNms{end+1}	= nm;
    fields.(nm)		= rawData(jj).DefaultValue;
  end % for ii
  
  modelData(ii).fieldNms	= fieldNms;
  modelData(ii).fields		= fields;
end % for ii

end  % #getModelData
%__________________________________________________________
%% #checkForDuplicates
%
function [mdlFls, ok] = stimCheckInput_checkForDuplicates(mdlFlsOrg, myMdlFls)
  
ok		= false;

[dubFls, mdlInd, myMdlInd] = intersect(mdlFlsOrg(:,2), myMdlFls(:,2));

for ii = 1:numel(dubFls)
  mdlFl		= mdlFlsOrg{mdlInd(ii),2};
  myMdlFl	= myMdlFls{myMdlInd(ii),2};
 
  if ~stimCheckInput_isDuplicate(mdlFl, myMdlFl)
    fprintf(2, 'The files "%s\\%s" and\n "%s\\%s" have the same name but are different!', ...
      mdlFlsOrg{mdlInd(ii),1}, mdlFl, myMdlFls{myMdlInd(ii),1}, myMdlFl)
    return
  else
    fprintf(1, 'The files "%s\\%s" and\n "%s\\%s" are duplicates. Second is used.', ...
      mdlFlsOrg{mdlInd(ii),1}, mdlFl, myMdlFls{myMdlInd(ii),1}, myMdlFl)
  end
end % for ii

mdlFls	= union(mdlFlsOrg, myMdlFls);
ok	= true;

end  % #checkForDuplicates
%__________________________________________________________
%% #isDuplicate
%
function isDublicate = stimCheckInput_isDuplicate(mdlFl, myMdlFl)

isDublicate	= false;

mdlFcn		= mdlFl(1:end-2);
myMdlFcn	= myMdlFl(1:end-2);
mdlRawData	= feval(mdlFcn);
myMdlRawData	= feval(myMdlFcn);

if numel(mdlRawData) == numel(myMdlRawData)
  mdlNms	= {mdlRawData.Name};
  myMdlNms	= {myMdlRawData.Name};
  dupNms	= intersect(mdlNms, myMdlNms);
  if numel(dupNms) == numel(mdlRawData)
    isDublicate	= true;
  end
end

end  % #isDuplicate
%__________________________________________________________
%% #findSame
%
function same = stimCheckInput_findSame(flsFound)
  
same = struct;
% same.nrOfGroups;
% same.groups; % {cell_group1; cell_group2}

groups	= {};

nrOfFls = size(flsFound, 1);

while nrOfFls > 1
  mainData = stimCheckInput_getData(flsFound(1,:));
  groupInd = 1;
  for ii = 2:nrOfFls
    if stimCheckInput_dataIsSame(flsFound(ii,:), mainData)
      groupInd(end+1) = ii;
    end
  end
  group		= flsFound(groupInd, :);
  groups{end+1} = group;
  flsFound(groupInd,:) = [];
  nrOfFls = size(flsFound, 1);
end

same.groups	= groups;
same.nrOfGroups = numel(groups);

end  % #findSame
%__________________________________________________________
%% #getData
%
function data = stimCheckInput_getData(flC)

flNm	= fullfile(flC{:});
rawData = load(flNm);
dataC	= struct2cell(rawData.P); 
data	= cellfun(@str2double, dataC);

end  % #getData
%__________________________________________________________
%% #findDifferences
%
function differences = stimCheckInput_findDifferences(same)

differences = struct;

if same.nrOfGroups < 2
  return;
end

end  % #findDifferences
%__________________________________________________________
%% #dataIsSame
%
function dataIsSame = stimCheckInput_dataIsSame(flC, mainData)
  
dataIsSame	= false;

secData		= stimCheckInput_getData(flC);
difference	= setdiff(mainData, secData);

if isempty(difference)
  dataIsSame = true;
end

end  % #dataIsSame
%__________________________________________________________
%% #qqq
%
function stimCheckInput_qqq
  
end  % #qqq
%__________________________________________________________