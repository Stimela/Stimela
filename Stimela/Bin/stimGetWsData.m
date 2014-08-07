% stimGetWsData('createXls', modelNm, xlsNm)	    % xls is created in the current directory
% stimGetWsData('createXls', modelNm, xlsNm, xlsPd) % xls is created in the given directory
%
% stimGetWsData('createXls', modelFlNm, xlsNm)	    % xls is created in the current directory
% stimGetWsData('createXls', modelFlNm, xlsNm, xlsPd) % xls is created in the given directory
%
%
% xlsFlNm = stimGetWsData('createXls', modelNm, xlsNm, '-hidden')	    % xls is created in the current directory
% xlsFlNm = stimGetWsData('createXls', modelNm, xlsNm, xlsPd, '-hidden') % xls is created in the given directory
%
% xlsFlNm = stimGetWsData('createXls', modelFlNm, xlsNm, '-hidden')	    % xls is created in the current directory
% xlsFlNm = stimGetWsData('createXls', modelFlNm, xlsNm, xlsPd, '-hidden') % xls is created in the given directory

function varargout = stimGetWsData(action, varargin)

if ~nargin
  action	= 'qqq';
end

if nargout
  varargout	= cell(1, nargout);
  [varargout{:}]= feval(['stimGetWsData_' action], varargin{:});
else
  feval(['stimGetWsData_' action], varargin{:});
end

end  % <main>
%__________________________________________________________
%% #createXls
%
function xlsFlNm = stimGetWsData_createXls(modelNm, xlsNm, varargin)

optionsInd		= strncmp(varargin, '-', 1);
options			= varargin(optionsInd);
varargin(optionsInd)	= [];

[ok, xlsFlNm, modelFlNm] = stimGetWsData_checkIfValidNames(modelNm, xlsNm, true, varargin{:});
if ~ok, return, end

ok		= stimGetWsData_checkFileStatus(xlsFlNm);
if ~ok, return, end

[data, msg]	= stimGetWsData_getAllMatFls(modelFlNm);

if isempty(fieldnames(data))
  if isempty(msg)
    fprintf(1, 'No data found in %s\n.', xlsFlNm)
  else
    fprintf(2, '%s\n', msg)
  end
  return
end

data		= stimGetWsData_getSheetData(data);

stimGetWsData_writeToXls(data, xlsFlNm)

if ~strcmpi(options, '-hidden')
  winopen(xlsFlNm)
end

end  % #createXls
%__________________________________________________________
%% #getSheetData
%
function data = stimGetWsData_getSheetData(data)

for ii = 1:size(data, 2)
  matFlNms_ii	= data(ii).matFlNms;
  matData	= load([data(ii).sheetNm '_p.mat']);
  array 	= fieldnames(matData.P)';
  nrOfFields	= size(array, 2);
  for jj = 1:length(matFlNms_ii)
    matFlNm	= matFlNms_ii{jj};
    matData	= load(matFlNm);
    array_jj	= struct2cell(matData.P)';
    array	= stimGetWsData_addArray(array, array_jj, nrOfFields);
  end % for jj
  
  data(ii).array	= array;
end % for ii

end  % #getSheetData
%__________________________________________________________
%% #addArray
%
function array = stimGetWsData_addArray(array, array_jj, nrOfFields)

difNr		= nrOfFields - size(array_jj, 2);
if difNr < 0
  for ii = 1:abs(difNr)
    array{:,end+1} = 'nvt';
  end % for ii
elseif difNr > 0
  for ii = 1:abs(difNr)
    array_jj{end+1} = 'nvt';
  end % for ii
end

array(end+1,:)	= array_jj;

end  % #addArray
%__________________________________________________________
%% #getAllMatFls
%
function [data, msg] = stimGetWsData_getAllMatFls(modelFlNm)

data		= struct;
msg		= '';

hSys		= load_system(modelFlNm);
[pd, fl , ext]	= fileparts(modelFlNm);

searchTags	= {'wsgetm', 'wsgetq', 'wssetc', 'wssetq'};

for ii = 1:length(searchTags)
  searchTag_ii		= searchTags{ii};
  hFcns			= find_system(hSys, 'LookUnderMasks', 'all',...
    'BlockType', 'SubSystem', 'Description', searchTag_ii);
  data(ii).sheetNm	= searchTag_ii;
  matFlNms		= {};
  for ff = 1:length(hFcns)
    openFcn	= get_param(hFcns(ff), 'OpenFcn');
    matFlNm	= stimGetWsData_getMatFlNm(openFcn, pd);
    if ~isempty(matFlNm)
      matFlNms{end+1}	= matFlNm;
    end
  end % for ff
  data(ii).matFlNms	= matFlNms;
end % for ii

close_system(hSys)

end  % #getAllMatFls
%__________________________________________________________
%% #getMatFlNm
%
function matFlNm = stimGetWsData_getMatFlNm(openFcn, pd)

matFlNm		= '';

if isempty(openFcn)
  return
end

startInd	= strfind(openFcn, 'StimelaData');
if isempty(startInd)
  return
elseif size(startInd, 2) > 1
  startInd	= startInd(1);
end

endStr		= '.mat';
endInd		= strfind(openFcn, endStr);
if isempty(endInd)
  return
elseif size(endInd, 2) > 1
  endInd	= endInd(1);
end
endInd		= endInd + length(endStr) - 1;

matFl		= openFcn(startInd:endInd);
matFlNm		= fullfile(pd, matFl);

end  % #getMatFlNm
%__________________________________________________________
%% #checkFileStatus
%
function ok = stimGetWsData_checkFileStatus(xlsFlNm)

ok	= true;

if exist(xlsFlNm, 'file')
  title		= 'File already exists';
  msg1		= sprintf('The file "%s" already exists!', xlsFlNm);
  msg		= {msg1, 'Do you want to overwrite it?'};
  options	= {'Yes', 'No'};
  awnser	= questdlg(msg , title, options{1}, options{2}, options{2});
  if strcmp(awnser, options{2}) || isempty(awnser)
    ok	= false;
    return
  end
  fid		= fopen(xlsFlNm, 'r+');
  if fid == -1
    fprintf('The file is already open. Close the file before running this function.\n')
    ok	= false;
    return
  else
    fclose(fid);
  end  
  delete(xlsFlNm)
end

end  % #checkFileStatus
%__________________________________________________________
%% #checkIfValidNames
%
function [ok, xlsFlNm, modelFlNm] = stimGetWsData_checkIfValidNames(modelNm, xlsNm, checkModel, varargin)

ok	= true;

if ~isempty(varargin)
  xlsPd		= varargin{1};
  if ~isdir(xlsPd)
    fprintf(2, 'The given directory name "%s" is not a valid directory!\n', xlsPd)
    ok	= false;
    return
  end
else
  xlsPd		= cd;
end

if checkModel
  modelFlNm	= which(modelNm);
  if isempty(modelFlNm)
    if exist(modelNm, 'file')
      modelFlNm = modelNm;
    else
      fprintf(2, 'No file found with the name "%s".\n', modelNm)
      ok	= false;
      return
    end
  end
else
  modelFlNm = '';
end

[pd, fl , ext]	= fileparts(xlsNm);
if ~isvarname(fl)
  fprintf(2, 'The given filename "%s" is not a valid filename!\n', fl)
  ok	= false;
  return
end
xlsFlNm		= fullfile(xlsPd, [fl '.xls']);

end  % #checkIfValidNames
%__________________________________________________________
%% #writeToXls
%
function stimGetWsData_writeToXls(data, xlsFlNm)

oldState	= warning('off', 'MATLAB:xlswrite:AddSheet');

for ss = 1:size(data, 2)
  sheetNm_ss	= data(ss).sheetNm;
  [ok, msg]	= xlswrite(xlsFlNm, data(ss).array, sheetNm_ss);
  if ~ok
    fprintf(2, 'Failed to write the sheet "%s" to "%s"\nError message: %s\n',...
      sheetNm_ss, xlsFlNm, msg.message)
  end
end % for ss
warning(oldState.state, 'MATLAB:xlswrite:AddSheet');
stimGetWsData_removeDefaultSheets(xlsFlNm)

end  % #writeToXls
%__________________________________________________________
%% #removeDefaultSheets
%
function stimGetWsData_removeDefaultSheets(xlsFlNm)

try
  objExcel = actxserver('Excel.Application');
  objExcel.Workbooks.Open(xlsFlNm);
  for ii = 1:3
    try
      sheetNm	= sprintf('Sheet%u', ii);
      objExcel.ActiveWorkbook.Worksheets.Item(sheetNm).Delete;
    catch ME
    end
  end
  objExcel.ActiveWorkbook.Save;
  objExcel.ActiveWorkbook.Close;
  objExcel.Quit;
  objExcel.delete;
catch ME  
end

end  % #removeDefaultSheets
%__________________________________________________________
%% #qqq
%
function stimGetWsData_qqq

end  % #qqq
%__________________________________________________________