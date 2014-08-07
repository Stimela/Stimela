function varargout = stimResultsData(action, varargin)

if ~nargin
  action	= 'qqq';
end

if nargout
  varargout	= cell(1, nargout);
  [varargout{:}]= feval(['stimResultsData_' action], varargin{:});
else
  feval(['stimResultsData_' action], varargin{:});
end

end  % <main>
%__________________________________________________________
%% #initData
%
function dataStruct = stimResultsData_initData(hWaitbar, pd, action, varargin)

waitbar(0, hWaitbar, 'Collecting data ...');

if strcmpi(action, 'add')
  dataStructOrg	= varargin{end};
  varargin(end) = [];
  endVal	= .7;
else
  endVal	= 1;
end
if isempty(varargin) 
  input = [];
else
  input	= varargin{1};	
end

[fls, flInd] = stimResultsData_getFiles(pd, input);
waitbar(.1, hWaitbar)
dataNms		= stimResultsData_createDataNms(flInd);
waitbar(.2, hWaitbar)
modelNms	= stimResultsData_createModelNms(fls);
waitbar(.3, hWaitbar, 'Processing data ...')

[dataStruct, val]= stimResultsData_getRawData(fls, dataNms, modelNms, hWaitbar, .3, endVal);

if strcmpi(action, 'add')
  waitbar(val, hWaitbar, 'Combining data ...')
  dataStruct = stimResultsData_combineDataStructs(dataStructOrg, dataStruct);
  waitbar(val+(1-val)/2, hWaitbar, 'Combining finished')
end

end  % #initData
%__________________________________________________________
%% #getFiles
%
function [fls, flInd] = stimResultsData_getFiles(pd, varargin)

tic

dataTypeC		= stimResultsData_getdataTypeC;
nmFilter		= dataTypeC(:,1);
exe			= '.sti';
exeLength		= length(exe);

if isempty(varargin{1})
%   filter		= nmFilter;
%   filter{end+1}		= exe;
  [fls, flInd, exeInd]	= stimGetFiles('get', pd, exe, '-ends', nmFilter);
  fls			= fls(:,1:2);
else
  flsIn			= varargin{1};
  nrOfFiles		= numel(flsIn);
  fls			= cell(nrOfFiles, 2);
  fls(:,1)		= {pd};
  flInd		= nan(nrOfFiles, 4);
  for ii = 1:nrOfFiles
    fl			= flsIn{ii};
    fls{ii,2}		= fl;
    underInd		= strfind(fl, '_');
    if isempty(underInd)
      fprintf(2, 'Could not detect the type of "%s".', fl)
      continue;
    end
    flType		= fl(underInd(end):end - exeLength);
    ind			= strcmpi(flType, nmFilter);
    if ~any(ind)
      fprintf(2, 'Unknwn type "%s" found for "%s".', flType, fl)
      continue;
    elseif sum(ind) > 1
      fprintf(2, 'Multiple types found for "%s".', fl)
      continue;
    end
    flInd(ii,:)	= ind;
  end % for ii
  flInd		= logical(flInd);
end

nanInd		= any(isnan(flInd),2);
fls(nanInd)	= [];
flInd(nanInd)	= [];

pause('on')
pause(.2-toc(tic))
pause('off')

end  % #getFiles
%__________________________________________________________
%% #createDataNms
%
function dataNms = stimResultsData_createDataNms(flInd)

tic

nrOfIndices	= size(flInd, 1);
dataNms		= cell(nrOfIndices, 1);
dataTypeC	= stimResultsData_getdataTypeC;

for ii = 1:size(dataTypeC, 1)
  %   ind		= find(filterInd == ii);
  dataNm	= dataTypeC{ii, 2};
  %   dataNms(ind)	= {dataNm};
  dataNms(flInd(:,ii))	= {dataNm};
end % for ii

pause('on')
pause(0.2-toc(tic))
pause('off')
  
end  % #createDataNms
%__________________________________________________________
%% #createModelNms
%
function modelNms = stimResultsData_createModelNms(fls)

modelNms	= cell(size(fls, 1), 1);

for ii = 1:size(fls, 1)
  fl		= fls{ii,2};
  ind		= strfind(fl, '_');
  modelNm	= fl(1:ind(end)-1);
  modelNms{ii}	= modelNm;  
end % for ii
  
pause('on')
pause(0.2-toc(tic))
pause('off')


end  % #createModelNms
%__________________________________________________________
%% #getFilter
%
function dataTypeC = stimResultsData_getdataTypeC

dataTypeC = {
  % dataType	dataNm
  '_in'		'waterIn'
  '_out'	'waterOut'
  '_ES'		'extraIn'
  '_EM'		'extraOut'
  };

end  % #getFilter
%__________________________________________________________
%% #getRawData
%
function [dataStruct, val] = stimResultsData_getRawData(fls, dataNms, modelNms, hWaitbar, startVal, endVal)

dataStruct	= struct;
allVars		= st_Variabelen;

nrOfFls		= size(fls,1);
diff		= endVal - startVal;
step		= diff/(nrOfFls + 1);
val		= startVal;

for ii = 1:nrOfFls
  flNm		= fullfile(fls{ii,:});
  dataNm	= dataNms{ii};
  modelNm	= modelNms{ii};  
  data		= struct;
  
  if isempty(flNm), continue, end;
  rawData	= load(flNm, '-mat');
  fieldNms	= fieldnames(rawData);
  if ~isempty(fieldNms)
    rawData	= rawData.(fieldNms{1});
  else
    warning('No data found in: %s', flNm);
    continue;
  end
  
  if size(rawData, 1) < 2 || ~any(any(rawData(2:end,:)))
    continue
  end
  
  data.time	= rawData(1,:);
 
  varNms		= {};
  nrNotFound		= 0;
  for jj = 2:size(rawData,1)
    if ~any(rawData(jj,:))
      nrNotFound = nrNotFound+1;
      continue
    end
    if (strcmpi(dataNm, 'waterIn') || strcmpi(dataNm, 'waterOut')) &&...
	size(rawData, 1) == length(allVars)+1      
      varNm	= allVars(jj-1).LongName;
      unit	= allVars(jj-1).Unit;
    else
      varNm	= sprintf('%s_%03d', dataNm, jj - 1 - nrNotFound);
      unit	= 'unknown';
    end
    varNms{end+1}		= varNm; 
    data.(varNm).yData		= rawData(jj,:);
    data.(varNm).legendStr	= sprintf('%s - %s - %s', modelNm, dataNm, varNm);
    data.(varNm).unit		= unit;
  end % for jj
  
  data.varNms			= varNms;
  
  dataStruct.(modelNm).(dataNm)	= data;
  
  val	= val + step;
  waitbar(val, hWaitbar)
end % for ii

end  % #getRawData
%__________________________________________________________
%% #combineDataStructs
%
function dataStruct = stimResultsData_combineDataStructs(dataStructOrg, dataStructNew)

tic

orgNms		= fieldnames(dataStructOrg);
newNms		= fieldnames(dataStructNew);

dataStructNew	= stimResultsData_checkForCommon(dataStructNew, orgNms, newNms);
newNms		= fieldnames(dataStructNew);

fldNms		= [orgNms; newNms];
orgData		= struct2cell(dataStructOrg);
newData		= struct2cell(dataStructNew);
data		= [orgData; newData];

dataStruct	= cell2struct(data, fldNms, 1);

pause('on')
pause(.2-toc(tic))
pause('off')

end  % #combineDataStructs
%__________________________________________________________
%% #checkForCommon
%
function dataStructNew = stimResultsData_checkForCommon(dataStructNew, orgNms, newNms)

[nms, indOrg, indNew]	= intersect(orgNms, newNms);

nrInCommon		= numel(nms);

for ii = 1:nrInCommon 
  oldFldNm			= nms{ii};
  newFldNm			= sprintf('%s_added', oldFldNm);
  dataStructNew.(oldFldNm)	= stimResultsData_changeLegendStrings(dataStructNew.(oldFldNm),...
    oldFldNm, newFldNm);
  [dataStructNew.(newFldNm)]	= dataStructNew.(oldFldNm);
  dataStructNew			= rmfield(dataStructNew, oldFldNm);    
end % for ii

end  % #checkForCommon
%__________________________________________________________
%% #changeLegendStrings
%
function data = stimResultsData_changeLegendStrings(data, orgNm, newNm)

fldNms_ii	= fieldnames(data);
for ii = 1:numel(fldNms_ii)
  data_jj	= data.(fldNms_ii{ii});
  fldNms_jj	= fieldnames(data_jj);
  for jj = 2:numel(fldNms_jj)-1
    legendStr	= data.(fldNms_ii{ii}).(fldNms_jj{jj}).legendStr;
    data.(fldNms_ii{ii}).(fldNms_jj{jj}).legendStr = strrep(legendStr, orgNm, newNm);
  end % for jj  
end % for ii

end  % #changeLegendStrings
%__________________________________________________________
%% #qqq
%
function stimResultsData_qqq

end  % #qqq
%__________________________________________________________