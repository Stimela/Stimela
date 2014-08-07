% stimCompareTags('compareMdlFl', orgFl, modelNm, xlsFl)
% stimCompareTags('compareMdlFl', orgFl, modelNm, xlsFl, xlsPd)
%
% stimCompareTags('compareMdlFl', orgFl, modelNm, xlsFl, options)
% stimCompareTags('compareMdlFl', orgFl, modelNm, xlsFl, xlsPd, options)
%
% stimCompareTags('compareFls', orgFl, newFl, xlsFl)
% stimCompareTags('compareFls', orgFl, newFl, xlsFl, xlsPd)
%
% stimCompareTags('compareFls', orgFl, newFl, xlsFl, options)
% stimCompareTags('compareFls', orgFl, newFl, xlsFl, xlsPd, options)
% options:
%         '-addRem' % Check only added and removed tags
%         '-edited' % Check only edited tags
%         '-all'    % Do both (is equivalent to no options)


function varargout = stimCompareTags(action, varargin)

if ~nargin
  action	= 'qqq';
end

if nargout
  varargout	= cell(1, nargout);
  [varargout{:}]= feval(['stimCompareTags_' action], varargin{:});
else
  feval(['stimCompareTags_' action], varargin{:});
end

end  % <main>
%__________________________________________________________
%% #compareFls
%
function stimCompareTags_compareFls(orgFl, newFl, xlsFl, varargin)

optionsInd		= strncmp(varargin, '-', 1);
options			= varargin(optionsInd);
varargin(optionsInd)	= [];

[ok, xlsFlNm, dummy]	= stimGetWsData('checkIfValidNames', '', xlsFl, false, varargin{:});
if ~ok, return, end
ok			= stimGetWsData('checkFileStatus', xlsFlNm);
if ~ok, return, end

[ok, orgFlNm]		= stimCompareTags_getFlNm(orgFl);
if ~ok, return, end
[ok, newFlNm]		= stimCompareTags_getFlNm(newFl);
if ~ok, return, end

orgData		= stimCompareTags_getDataFromXls(orgFlNm);
newData		= stimCompareTags_getDataFromXls(newFlNm);

results		= stimCompareTags_compareTags(orgData, newData, options);

stimGetWsData('writeToXls', results, xlsFlNm)

winopen(xlsFlNm)

end  % #compareFls
%__________________________________________________________
%% #compareMdlFl
%
function stimCompareTags_compareMdlFl(orgFl, modelNm, xlsFl, varargin)

vararginOrg		= varargin; 
optionsInd		= strncmp(varargin, '-', 1);
% options			= varargin(optionsInd);
varargin(optionsInd)	= [];

tempFl			= 'temp_compare';

tempFlNm		= stimGetWsData('createXls', modelNm, tempFl, varargin{:}, '-hidden');

stimCompareTags_compareFls(orgFl, tempFlNm, xlsFl, vararginOrg)

delete(tempFlNm)

end  % #compareMdlFl
%__________________________________________________________
%% #getDataFromXls
%
function dataXls = stimCompareTags_getDataFromXls(xlsFlNm)

dataXls		= struct;

sheetNms	= stimCompareTags_getSheetNames(xlsFlNm);
for ii = 1:numel(sheetNms)
  sheetNm_ii		= sheetNms{ii};
  [num, txt, raw]	= xlsread(xlsFlNm, sheetNm_ii);
  data.header		= raw(1,:);
  data.data		= raw(2:end,:);
  dataXls.(sheetNm_ii)	= data;
end % for ii

end  % #getDataFromXls
%__________________________________________________________
%% #getSheetNames
%
function sheetNms = stimCompareTags_getSheetNames(xlsFlNm)

[stat, sheets, format]	= xlsfinfo(xlsFlNm);
defaultSheetIndC	= strfind(sheets, 'Sheet');
defaultSheetInd		= cellfun(@isempty, defaultSheetIndC);
sheetNms		= sheets(defaultSheetInd);

end  % #getSheetNames
%__________________________________________________________
%% #compareTags
%
function results = stimCompareTags_compareTags(orgData, newData, options)

results		= struct();

doAll		= isempty(options) || any(strcmpi(options, '-all'));

if any(strcmpi(options, '-addRem')) || doAll
  results = stimCompareTags_checkAddRem(newData, orgData, results, 'added');
  results = stimCompareTags_checkAddRem(orgData, newData, results, 'removed');
end

if any(strcmpi(options, '-edited')) || doAll
  results	= stimCompareTags_checkChanges(newData, orgData, results);
end

results		= stimCompareTags_createTotal(results);

end  % #compareTags
%__________________________________________________________
%% #checkAddRem
%
function results = stimCompareTags_checkAddRem(baseData, compData, results, type)

startInd	= size(results, 2);

fieldNmsBase	= fieldnames(baseData);

for ii = 1:numel(fieldNmsBase)
  ind			= startInd + ii;
  
  sheetNmOrg		= fieldNmsBase{ii};
  sheetNm		= sprintf('%s_%s', sheetNmOrg, type);
  results(ind).sheetNm	= sheetNm;
  
  baseData_ii		= baseData.(sheetNmOrg);
  if ~isfield(compData, sheetNmOrg)
    array			= [baseData_ii.header; baseData_ii.data];
    results(ind).array		= array;
    continue
  end
  compData_ii		= compData.(sheetNmOrg);
  
  baseTags		= baseData_ii.data(:,1);
  compTags		= compData_ii.data(:,1);
  [diff, diffInd]	= setdiff(baseTags, compTags);
  if ~isempty(diffInd)
    array			= [baseData_ii.header; baseData_ii.data(diffInd,:)];
    results(ind).array	= array;
  else
    results(ind).array	= {sprintf('No tags %s.', type)};
  end
end % for ii

end  % #checkAddRem
%__________________________________________________________
%% #checkChanges
%
function results = stimCompareTags_checkChanges(baseData, compData, results)

startInd	= size(results, 2);

fieldNmsBase	= fieldnames(baseData);

for ii = 1:numel(fieldNmsBase)
  ind			= startInd + ii;
  
  sheetNmOrg		= fieldNmsBase{ii};
  sheetNm		= sprintf('%s_%s', sheetNmOrg, 'changed');
  
  
  results(ind).sheetNm	= sheetNm;
  if ~isfield(compData, sheetNmOrg)
    continue
  end
  baseData_ii		= baseData.(sheetNmOrg);
  compData_ii		= compData.(sheetNmOrg);
  baseDataTags_ii	= baseData_ii.data(:,1);
  compDataTags_ii	= compData_ii.data(:,1);
  
  [rowCnt, colCnt]	= size(baseData_ii.data);
  array			= cell(rowCnt*3 + 2, colCnt+1);
  rowInd		= 1;
  array(rowInd, 2:end)	= baseData_ii.header;
  
  [c, baseInd, compInd]	= intersect(baseDataTags_ii, compDataTags_ii);
  
  for jj = 1:numel(c)
    baseInd_jj	= baseInd(jj);
    compInd_jj	= compInd(jj);
    baseData_jj	= baseData_ii.data(baseInd_jj,:);
    compData_jj	= compData_ii.data(compInd_jj,:);
    
    for kk = 1:colCnt
      baseData_kk	= baseData_jj{kk};
      compData_kk	= compData_jj{kk};
      if isnumeric(baseData_kk)
	changed		= ~isequal(baseData_kk, compData_kk);
      else
	changed		= ~strcmp(baseData_kk, compData_kk);
      end
      
      if changed
	rowInd			= rowInd + 2;
	array{rowInd,1}		= 'current';
	array(rowInd,2:end)	= baseData_jj(:);
	rowInd			= rowInd + 1;
	array{rowInd,1}		= 'old';
	array(rowInd,2:end)	= compData_jj(:);
      end
    end % for kk
  end % for jj
  
  if rowInd < 2
    array		= {};
    array{1,1}		= 'No changes detected.';
  else
    rowInd		= rowInd + 1;
    array(rowInd:end,:)	= [];
  end
  results(ind).array	= array;
  
end % for ii

end  % #checkChanges
%__________________________________________________________
%% #num2char
%
function out = stimCompareTags_num2char(in)

if isnumeric(in)
  out = sprintf('%d', in);
else
  out = in;
end

end  % #num2char
%__________________________________________________________
%% #createTotal
%
function results = stimCompareTags_createTotal(results)

arrays		= {results.array};
sizesC		= cellfun(@size, arrays, 'UniformOutput', false);
sizesRow	= [sizesC{:}];
rowsLengths	= sizesRow(2:2:end);
maxRowLength	= max(rowsLengths);
colInd		= find(rowsLengths > 1);
colCnts		= sizesRow(colInd*2 - 1);
colCnt		= sum(colCnts);
colCnt		= colCnt + numel(colInd)*2 - 1;

array		= cell(colCnt, maxRowLength);
ind		= 1;
for ii = 1:numel(colInd)
  colInd_ii		= colInd(ii);
  array{ind,1}		= results(colInd_ii).sheetNm;
  newInd		= ind+colCnts(ii);
  rng_1			= ind+1:newInd;
  rng_2			= 1:rowsLengths(colInd_ii);
  array(rng_1, rng_2)	= results(colInd_ii).array;
  ind			= newInd + 2;
end % for ii

results(1).sheetNm	= 'Total';
results(1).array	= array;

end  % #createTotal
%__________________________________________________________
%% #getFlNm
%
function [ok, flNm] = stimCompareTags_getFlNm(fl)

ok	= false;

flNm	= which(fl);
if isempty(flNm)
  fprintf(2, 'File "%s" does not exist!\n', fl)
  fprintf(2,'Include path if it is not included in the Matlab path.\n')
  return
end
ok	= true;

end  % #getFlNm
%__________________________________________________________
%% #qqq
%
function stimCompareTags_qqq

end  % #qqq
%__________________________________________________________