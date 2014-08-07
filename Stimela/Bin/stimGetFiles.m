% Stimela function to get files with or without filter
%
% Calls:
% [files, flInd, exeInd] = stimGetFiles('get', directory, exe)
% [files, flInd, exeInd] = stimGetFiles('get', directory, exe, options)
% 
% exe: '.*' for all files in the 
% exe: '.m' to get all files with the extension ".m"
% exe: {'.m', '.mdl'} to get all files with the extension ".m" or ".mdl"
%
% Options:
% '-showBar', shows a progress bar when more than 3500 files have to be retrieved
% '-noSubDir', searches only the given directory and not the subdirectories.
% '-starts', 'filepart', filters all files which start with the given filepart
% '-starts', {'filepart_1', 'filepart_n'}, filters all files which start with the given fileparts
% '-ends', 'filepart', filters all files which end with the given filepart
% '-ends', {'filepart_1', 'filepart_n'}, filters all files which end with the given fileparts
% '-contains', 'filepart', filters all files which contain the given filepart
% '-contains', {'filepart_1', 'filepart_n'}, filters all files which contain the given fileparts
%
% The filter works with the following logic:
% (exe_1 OR exe_2) AND (starts_1 OR starts_n OR ends_1 OR ends_m OR contains_1 OR contains_k)
%
% Output:
% files: nx4 cell {directory, fileExe, file, exe} where n is the number of files found (filtered)
% flInd: nxm logical [starts_1, starts_n, ends_1, ends_m, contains_1, contains_k]
% every column contains the index to a given option in the order of 1) starts, 2) ends 3) contains
% m is the number of options
% exeInd: nxk logical [exe_1, exe_n] every column contains the index to a given extension
% k is the number of given extensions
%
% Stimela, 2004-2012

% © Martijn Sparnaaij

function varargout = stimGetFiles(action, varargin)
  
  if ~nargin
    action	= 'test'; 
  end
  
  if nargout
    varargout	= cell(1, nargout);
    [varargout{:}]= feval(['stimGetFiles_' action], varargin{:});
  else
    feval(['stimGetFiles_' action], varargin{:});
  end
  
end  % <main>
%__________________________________________________________
%% #get
%
function [filesOut, flInd, exeInd] = stimGetFiles_get(pd, exe, varargin)
  
options		= stimGetFiles_getOptions(varargin{:});
  
filesOut	= {};
flInd		= [];
exeInd		= [];

if ~strcmpi(pd(end), filesep)
  pd = [pd filesep];
end

if ~iscell(exe)
  exe = {exe};
end

ii = 1;
while ii < length(exe)
  ind	= strcmp(exe{ii}, exe);
  if sum(ind) > 1
    indOne		= find(ind == 1);
    ind(indOne(1))	= 0;
    exe(ind)		= [];   
    fprintf('Warning %s was found as a double an was removed.\n', exe{ii})
    fprintf('Please remove the double %s in the call.\n', exe{ii})
  end
  ii	= ii+1;
end % while

files			= stimGetFiles_getAllFiles(pd, options);
if isempty(files)
  return
end

if isempty(exe) && ~options.nrOfFilters
  return
end
[files, flInd, exeInd]	= stimGetFiles_filter(files, exe, options);


filesOut	= cell(size(files, 1),4);
filesOut(:,1)	= files(:,1);
for ii = 1:size(files, 1)
  filesOut{ii,2}	= [files{ii,2} files{ii,3}];
end % for ii
filesOut(:,3:4)	= files(:,2:3);

flInd	= logical(flInd);
exeInd	= logical(exeInd);

end  % #get
%__________________________________________________________
%% #getAllFiles
%
function files = stimGetFiles_getAllFiles(mainPd, options)
  
pds	= {mainPd};
% files = {pd, fl, exe}
files	= {};

if options.showBar
  options.showBar = false;
  if strncmpi(computer, 'pcwin', 5)
    [a, msg]	= dos(['dir ' mainPd ' /s /b /a:-d | find /c /v ""']);
    nrOfFilesTotal= str2double(msg);
    if ~isnan(nrOfFilesTotal)
      if nrOfFilesTotal > 3500
	options.showBar	= true;
      end
    end
  end
end

if options.showBar
  orgFontSz	= get(0,'defaultTextFontSize');
  set(0,'defaultTextFontSize',11)
  hWaitBar	= waitbar(0,'Searching all model files ...');
  set(hWaitBar, 'name', 'Stimela get files')
  set(0,'defaultTextFontSize', orgFontSz)
end

jj		= 1;

while ~isempty(pds)
  pd		= pds{1};
  pds(1)	= [];
  [filesFromDir, dirs]		= stimGetFiles_getFilesFromDir(pd);
  jj		= jj+1;
  if options.showBar && ~mod(jj,50)
    waitbar(size(files, 1)/nrOfFilesTotal, hWaitBar)
  end
  
  nrOfDirs = numel(dirs);
  if options.subDir && nrOfDirs > 0
    pds(end+1:end+nrOfDirs)	= strcat(pd, dirs, filesep);
  end
  
  nrOfFiles = numel(filesFromDir);

  for ii = 1:nrOfFiles
    files{end+1,1}	= pd;
    flExe		= filesFromDir{ii};
    pointInd		= strfind(flExe, '.');
    if isempty(pointInd), continue, end
    files{end  ,2}	= flExe(1:pointInd(end)-1);
    files{end  ,3}	= flExe(pointInd(end):end);
  end % for ii  
end
if options.showBar
  waitbar(1, hWaitBar)
  close(hWaitBar)
end

end  % #getAllFiles
%__________________________________________________________
%% #getFilesFromDir
%
function [filesFromDir, dirs] = stimGetFiles_getFilesFromDir(pd)

dirData		= dir(pd);
dirIndex	= [dirData.isdir];
filesFromDir	= {dirData(~dirIndex).name}';
dirs		= {dirData(dirIndex).name}';

dirs(strcmp(dirs, '.')) = [];
dirs(strcmp(dirs, '..')) = [];

end  % #getFilesFromDir
%__________________________________________________________
%% #filter
%
function [files, flInd, exeInd] = stimGetFiles_filter(filesOrg, exe, options)
  
% Filter all extensions
if ~any(strcmpi(exe, '.*'))
  [files, exeInd]	= stimGetFiles_filterExe(exe, filesOrg);
else
  files			= filesOrg;
  exeInd		= true(size(filesOrg,1),1);
end

if options.nrOfFilters > 0
  [files, flInd, exeInd]	= stimGetFiles_filterFl(options, files, exeInd);
else
  flInd				= true(size(files,1),1);
end

end  % #filter
%__________________________________________________________
%% #filterExe
%
function [files, exeInd] = stimGetFiles_filterExe(exe, filesOrg)
  
addInd	= false(size(filesOrg,1),1);

for ii = 1:numel(exe)
    addInd_ii	= strcmpi(filesOrg(:,3), exe{ii});
    addInd	= or(addInd, addInd_ii);
end % for ii

files	= filesOrg(addInd,:);

exeInd	= [];

for ii = 1:numel(exe)
    exeInd(:,ii) = strcmpi(files(:,3), exe{ii});
end % for ii

end  % #filterExe
%__________________________________________________________
%% #filterFl
%
function [files, flInd, exeInd] = stimGetFiles_filterFl(options, filesOrg, exeInd)
  
flFilterC		= options.flFilter;
[foundIndOrg, totalInd]	= stimGetFiles_filterContains(flFilterC, filesOrg);

files		= filesOrg(totalInd, :);
exeInd		= exeInd(totalInd, :);
foundIndOrg	= foundIndOrg(totalInd,:);
flInd		= [];

if ~isempty(options.starts)
  startInd		= foundIndOrg(:,find(options.flFilterInd == 1));
  [foundInd, startInd]	= stimGetFiles_filterStartsEnds(files, options.starts, startInd, 'starts');
  n = size(foundInd, 2);
  flInd(:,end+1:end+n)	= foundInd;
else
  startInd	= false(size(files,1), 1);
end

if ~isempty(options.ends)
  endInd		= foundIndOrg(:,find(options.flFilterInd == 2));
  [foundInd, endInd]	= stimGetFiles_filterStartsEnds(files, options.ends, endInd, 'ends');
  n = size(foundInd, 2);
  flInd(:,end+1:end+n)	= foundInd;
else
  endInd	= false(size(files,1), 1);
end

if ~isempty(options.contains)
  [foundInd, containInd]= stimGetFiles_filterContains(options.contains, files);
  n = size(foundInd, 2);
  flInd(:,end+1:end+n)	= foundInd;
else
  containInd	= false(size(files,1), 1);
end

keepInd		= or(startInd, endInd);
keepInd		= or(keepInd, containInd);

files		= files(keepInd, :);
exeInd		= exeInd(keepInd, :);
flInd		= flInd(keepInd, :);

end  % #filterFl
%__________________________________________________________
%% #filterContains
%
function [foundInd, totalInd] = stimGetFiles_filterContains(flFilterC, filesOrg)
  
if ~iscell(flFilterC)
  flFilterC = {flFilterC};
end

nrOfFilters	= numel(flFilterC);
totalInd	= false(size(filesOrg, 1), 1);
foundInd	= false(size(filesOrg, 1), nrOfFilters);

for ii = 1:nrOfFilters
  foundInd(:,ii)= ~cellfun(@isempty, strfind(filesOrg(:,2),flFilterC{ii}));
  totalInd	= or(totalInd, foundInd(:,ii));
end % for ii

end  % #filterContains
%__________________________________________________________
%% #filterStartsEnds
%
function [typeInd, totalInd] = stimGetFiles_filterStartsEnds(files, filterStr, typeInd, type)
  
nrOfVals	= numel(filterStr);
totalInd	= false(size(files,1), 1);

for ii = 1:nrOfVals
  flsToCheck		= files(typeInd(:,ii),2);
  typeInd_ii		= stimGetFiles_filterTypeFls(flsToCheck, filterStr{ii}, type);
  typeInd(typeInd(:,ii),ii) = typeInd_ii;  
  totalInd		= or(totalInd, typeInd(:,ii));
end % for ii

end  % #filterStartsEnds
%__________________________________________________________
%% #filterTypeFls
%
function typeInd = stimGetFiles_filterTypeFls(fls, str, type)
  
isStart = any(strcmpi(type, 'starts'));
typeInd	= false(numel(fls), 1);

n	= length(str);
for ff = 1:numel(fls)
  fl_ii		= fls{ff};
  if isStart
    flPart	= fl_ii(1:n);
  else
    flLength	= length(fl_ii);
    m		= flLength - n + 1;
    flPart	= fl_ii(m:end);
  end
  typeInd(ff)	= any(strcmp(flPart, str));
end % for ff

end  % #filterTypeFls
%__________________________________________________________
%% #getOptions
%
function options = stimGetFiles_getOptions(varargin)
  
options			= struct;

subDirInd		= strcmpi(varargin, '-noSubDir');
options.subDir		= ~any(subDirInd);
varargin(subDirInd)	= [];

showBarInd		= strcmpi(varargin, '-showBar');
options.showBar		= any(showBarInd);
varargin(showBarInd)	= [];

options.starts		= '';
options.ends		= '';
options.contains	= '';
options.flFilter	= {};
options.flFilterInd	= [];

optionsInd	= find(strncmp(varargin, '-', 1));
valInd		= optionsInd + 1;


typeC		= {'starts', 'ends', 'contains'};

for ii = 1:numel(optionsInd)
  optionNm			= varargin{optionsInd(ii)};
  optionNm			= optionNm(2:end);
  if isfield(options, optionNm)
    filterVal			= varargin{valInd(ii)};
    typeNr			= find(strcmpi(typeC, optionNm));
    if iscell(filterVal)
      n	= numel(filterVal);
      options.(optionNm)		= filterVal;
      options.flFilter(end+1:end+n)	= filterVal(:);
      options.flFilterInd(end+1:end+n)	= typeNr;
    else
      options.(optionNm)	= {filterVal};
      options.flFilter{end+1}	= filterVal;
      options.flFilterInd(end+1)= typeNr; 
    end
  end
end % for ii

options.nrOfFilters	= 3 - sum([isempty(options.starts), ...
  isempty(options.ends), isempty(options.contains)]);

end  % #getOptions
%__________________________________________________________
%% #test
%
function stimGetFiles_test
%   [files filterInd] = stimGetFiles('get', 'C:\Users\M.Sparnaaij\Documents\TU\Stimela\Waternet', {'WPK', '.m', '.m', '.mdl', '.docx', '.doc', '_s'});
  files = stimGetFiles('get', stimFolder('bin'), {'.m', '.mdl'}, '-starts', 'stim', '-ends', {'Model', 'Gui'}, '-showBar');
end  % #test
%__________________________________________________________
%% #qqq
%
function stimGetFiles_qqq
  
end  % #qqq
%__________________________________________________________