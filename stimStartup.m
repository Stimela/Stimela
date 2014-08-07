% Stimela startup function:
%
% This function starts Stimela and performs the following processes (in order):
% 
%  1.) Check if the current directory has the sub-directories "My_models" and 
%      "My_projects" and if so adds the current directory to the path.
%  2.) Load simulink
%  3.) Check if Stimela is already loaded in the current Matlab session.
%  4.) Check if stimelaDir is correct for both the main path and the core path.
%      If it is not correct a new stimelaDir will be created.
%  5.) Add all paths to the Matlab path.
%  6.) Check the version of Stimela, Simulink and the compiled models.
%  7.) If the Simulink version of the models is lower than the current 
%      version they are updated by loading and subsequently saving them.
%  8.) If the mex-version is different try to recompile the compiled models
%      (see stimCheckMex).     		
%  9.) Initialize figure settings.
% 10.) Initialize or update the Stimela menus (see stimMenu).
% 11.) 
%
%
%
% Calls:
% stimStartup('startup')
% stimStartup('startup', directory) % start Stimela in the given directory
% 
% Stimela, 2004-2012

% © Martijn Sparnaaij

function varargout = stimStartup(action, varargin)
  
  if ~nargin
    action	= 'startup'; 
  end
  
  if nargout
    varargout	= cell(1, nargout);
    [varargout{:}]= feval(['stimStartup_' action], varargin{:});
  else
    feval(['stimStartup_' action], varargin{:});
  end
  
end  % <main>
%__________________________________________________________
%% #startup
%
function stimStartup_startup(varargin)

fprintf('\n========================== Stimela ==========================\n\n')

if ~isempty(varargin) && isdir(varargin{1})
  cd(varargin{1})
end
pd		= cd;
ok		= stimStartup_checkPd(pd);
if ~ok
fprintf('Stimela startup terminated.\n')
  return
end

fprintf('Loading Simulink ...')
load_simulink
fprintf('done\n')
%autoSaveOptionsOrg	= get_param(0, 'AutoSaveOptions');
%autoSaveOptions		= autoSaveOptionsOrg;	
%autoSaveOptions.SaveBackupOnVersionUpgrade = false;
%set_param(0, 'AutoSaveOptions', autoSaveOptions);

fprintf('Checking Stimela version ...')
ok		= stimStartup_checkDoubleStart(pd);
fprintf('done\n')
if ~ok
fprintf('Stimela startup terminated.\n')
  return
end

fprintf('Adding paths ...')
stimStartup_checkStimelaDir(pd)
rehash
stimStartup_addPaths
fprintf('done\n')

[checkSim, checkMex, mexVer] = stimStartup_checkVersion;
if checkSim
  stimStartup_checkSim
end

fprintf('Checking mex files ...')
if checkMex
  stimCheckMex('checkMex', mexVer)
else
  fprintf('done\n')
end

fprintf('Initializing figures ...')
fontSize = getFontsize;
set(0,'defaultAxesFontSize',fontSize)
set(0,'defaultTextFontSize',fontSize)
st_SetPaperPosition
fprintf('done\n')

fprintf('Initializing My_models and My_project ...')
stimMenu('init', 'My_models')
stimMenu('init', 'My_projects')
fprintf('done\n')

fprintf('Initializing Stimela library ...')
stimMenu('init', 'Stimela_library')
fprintf('done\n')

fprintf('Checking files for update to version R2011b or newer ...')
stimStartup_checkUpdate
fprintf('done\n')

fprintf('\n=============================================================\n')

Stimela_introduction
  
end  % #startup
%__________________________________________________________
%% #checkPd
%
function ok = stimStartup_checkPd(pd)
  
ok		= true;

% check if My_models and My_projects are sub-directories
pdData		= dir(pd);
pdIndex		= [pdData.isdir];
pds		= {pdData(pdIndex).name}';

ind		= or(strcmpi(pds, 'My_models'), strcmpi(pds, 'My_projects'));
if sum(ind) ~= 2
  ok		= false;
  fprintf(2,'Could not find the sub-directories "My_models" and "My_projects" in "%s"\n', pd)
  fprintf(2,'Make sure your current directory is correct.\n', pd)
  return
end

% Add th main pd to the path
addpath(pd)

end  % #checkPd
%__________________________________________________________
%% #checkDoubleStart
%
function ok = stimStartup_checkDoubleStart(pd)

ok			= true;

stimDirFlNms		= which('stimelaDir.m', '-all');
if isempty(stimDirFlNms)
  return
elseif length(stimDirFlNms) == 1 && strncmp(stimDirFlNms{1}, pd, length(pd))
  return
end

[pd, fl, ext]		= fileparts(stimDirFlNms{1});
ind			= strfind(pd, filesep);
mainPd			= pd(1:ind(end)-1);
msg			= {'Stimela is already started in this Matlab.',...
  'The current Stimela directory is:',mainPd ,...
  '', 'What do you want to do?'};
title			= 'Stimela already started.';
buttons			= {'Continue with current version',...
  'Start new version', 'Stop stimela'}; 
awnser			= questdlg(msg, title, buttons{1}, buttons{2},...
  buttons{3}, buttons{2});
switch awnser
  case {'', buttons{1}}
    ok = false;
    cd(pd)    
  case buttons{2}
    warning('off', 'MATLAB:rmpath:DirNotFound')
    rmpath(genpath(pd))    
    warning('on', 'MATLAB:rmpath:DirNotFound')
  case buttons{3}
    ok = false;
    cd(userpath)
    warning('off', 'MATLAB:rmpath:DirNotFound')
    rmpath(genpath(pd))    
    warning('on', 'MATLAB:rmpath:DirNotFound')
end

end  % #checkDoubleStart
%__________________________________________________________
%% #addPaths
%
function stimStartup_addPaths

% Add the core path
[dummy, corePd]		= stimelaDir('core');
addpath(corePd)

% Add "Bin" and "Standard_models/projects" to the path
addpath(genpath(stimFolder('Bin')))
addpath(genpath(stimFolder('Toolbox')))
addpath(genpath(stimFolder('Standard_models')))
addpath(genpath(stimFolder('Standard_projects')))

% Add "My_models/projects" to the path
addpath(genpath(stimFolder('My_models')))
addpath(genpath(stimFolder('My_projects')))

end  % #addPaths
%% #checkStimelaDir
%
function stimStartup_checkStimelaDir(pd)

fl	= 'stimelaDir.m';
if exist(fl, 'file') && nargout('stimelaDir') == 2
  [stimPd, corePd]	= stimelaDir('core');
else
  stimPd = 'noDir';
  corePd = '';
end

stimelaPd	= fullfile(stimPd, 'Stimela');

if ~(exist(stimelaPd, 'dir') == 7 || exist(corePd, 'dir') == 7)
  flNm	= which(fl);
  if isempty(flNm)
    flNm = fullfile(pd, fl);
  end
  
  corePd	= stimStartup_getCorePd(pd);
  
  fid		= fopen(flNm, 'w');
  fprintf(fid,'function [stimDir, corePd] = stimelaDir(varargin)\n');
  fprintf(fid,'%%automatically generated\n');
  fprintf(fid,'\n');
  fprintf(fid,'if ~isempty(varargin) && strcmpi(varargin{1}, ''core'')\n');
  fprintf(fid,'  corePd = ''%s'';\n', corePd);
  fprintf(fid,'else\n');
  fprintf(fid,'  corePd = '''';\n');
  fprintf(fid,'end\n');
  fprintf(fid,'\n');
  fprintf(fid,'stimDir = ''%s'';\n', pd);
  fprintf(fid,'\n');
  fprintf(fid,'end');
  fclose(fid);
end

end  % #checkStimelaDir
%__________________________________________________________
%% #getCorePd
%
function corePd = stimStartup_getCorePd(pd)

corePd		= fullfile(pd, 'Stimela');

return

question	= {
  'Do you want to use the default Stimela core directory?'
  corePd};
title		= 'Choose Stimela core directory';
useDefaultStr	= 'Use Default';
selectStr	= 'Select Directory';
defaultVal	= 'Use Default';

awnser		= questdlg(question, title, useDefaultStr, selectStr, defaultVal); 

if strcmp(awnser, selectStr)
  title		= 'Select Stimela core directory';
  pdChoosen	= uigetdir(pd, title);
  binPd		= fullfile(pdChoosen, 'Bin');
  modelPd	= fullfile(pdChoosen, 'Standard_models');
  
  if ~(exist(binPd, 'dir') == 7 && exist(modelPd, 'dir') == 7)
    warningStr	= {
      'The selected folder is not a valid Stimela core directory!'
      'The directory should contain the sub-directories:'
      '"Bin", "Standard_models", "Standard_projects" and "Toolbox"'};
    title	= '';
    warndlg(warningStr, title, 'modal');
    corePd	= stimStartup_getCorePd(pd);
  else
    corePd	= pdChoosen;
  end
end

end  % #getCorePd
%__________________________________________________________
%% #checkVersion
%
function [checkSim, checkMex, mexVer] = stimStartup_checkVersion

checkMex	= true;
checkSim	= true;

mexVer		= mexext;
[dummy, compNm]	= system('hostname');
compNm		= deblank(compNm);
simVerStruct	= ver('Simulink');
simVer		= simVerStruct.Version;

fl		= 'stimelaVer';
verFlNms	= which(fl, '-all');

if isempty(verFlNms) 
  stimStartup_createVerFcn(fl, mexVer, compNm, simVer)
  return
end

stimVer		= stimelaVer;

if ~isstruct(stimVer) || ~all(isfield(stimVer, {'mexVer', 'compNm', 'simVer'}))
  stimStartup_createVerFcn(fl, mexVer, compNm, simVer)
  return
end

if strcmp(compNm, stimVer.compNm) && strcmp(mexVer, stimVer.mexVer)
  checkMex	= false;
end
if strcmp(simVer, stimVer.simVer)
  checkSim	= false;
end
  
if ~(checkSim && checkMex)
  stimStartup_createVerFcn(fl, mexVer, compNm, simVer)
end

end  % #checkVersion
%__________________________________________________________
%% #createVerFcn
%
function stimStartup_createVerFcn(fl, mexVer, compNm, simVer)

flNm	= fullfile(stimFolder('Main'), [fl '.m']);
fid	= fopen(flNm, 'w');
fprintf(fid,'function stimVer = %s\n', fl);
fprintf(fid,'%%automatically generated\n');
fprintf(fid,'\n');
fprintf(fid,'stimVer		= struct;\n');
fprintf(fid,'stimVer.mexVer	= ''%s'';\n', mexVer);
fprintf(fid,'stimVer.compNm	= ''%s'';\n', compNm);
fprintf(fid,'stimVer.simVer	= ''%s'';\n', simVer);
fprintf(fid,'\n');
fprintf(fid,'end');
fclose(fid);

end  % #createVerFcn
%__________________________________________________________
%% #checkSim
%
function stimStartup_checkSim
  
fprintf('Checking mdl files ...\n')

modelPd			= stimFolder('Main');
filter			= '.mdl';
mdlFls			= stimGetFiles('get', modelPd, filter);
backupPd		= stimFolder('Backup');

fprintf('Updating mdl files ...')
notStatus		= com.mathworks.services.Prefs.getBooleanPref('SimulinkShowPersistentBackupNotification');
com.mathworks.services.Prefs.setBooleanPref('SimulinkShowPersistentBackupNotification', false)
%autoSaveOptionsOrg	= get_param(0, 'AutoSaveOptions');
%autoSaveOptions		= autoSaveOptionsOrg;	
%autoSaveOptions.SaveBackupOnVersionUpgrade = false;
%set_param(0, 'AutoSaveOptions', autoSaveOptions);
newMdlError		= get_param(0, 'ErrorIfLoadNewModel');
set_param(0, 'ErrorIfLoadNewModel', 'off')

extLength		= length('.mdl');
for ii = 1:size(mdlFls,1)
  flNm		= fullfile(mdlFls{ii,1}, mdlFls{ii,2});
  backupFlNm	= fullfile(backupPd, [mdlFls{ii,2} '.backup']);
  copyfile(flNm, backupFlNm, 'f') 

  fl		= mdlFls{ii,2};
  sysNm		= fl(1:end-extLength);
  load_system(sysNm)
  save_system(sysNm)
  close_system(sysNm)
end % for ii

com.mathworks.services.Prefs.setBooleanPref('SimulinkShowPersistentBackupNotification', notStatus)
set_param(0, 'AutoSaveOptions', autoSaveOptionsOrg);
set_param(0, 'ErrorIfLoadNewModel', newMdlError)
fprintf('done\n')

fprintf('Checking mdl files done\n')

end  % #checkSim
%__________________________________________________________
%% #needsUpdate
%
function stimStartup_checkUpdate

fls	= stimGetFiles('get', stimFolder('Main'), {'.m', '.mdl'});
fls	= fls(:,2);

fl		= 'stimUpdateData.mat';
dataFlNms	= which(fl, '-all');

if isempty(dataFlNms)
  stimUpdate('update', stimFolder('Main'), stimFolder('Main'));
  stimStartup_createUpdateData(fl, fls);
  return
end

data		= load(dataFlNms{1}); 		
flsFromDat	= data.fls;

flsToUpdate	= setdiff(fls, flsFromDat);
try
pcNm		= getenv('COMPUTERNAME');
  if ~isempty(pcNm) && strcmp(pcNm, 'MSPARNAAIJ-PC')
    flsToPrint = flsToUpdate';
    fprintf('%s\n', flsToPrint{:})
  end
catch
end

if ~isempty(flsToUpdate)
  stimUpdate('update', stimFolder('Main'), stimFolder('Main'), flsToUpdate);
  stimStartup_createUpdateData(fl, fls)
  return
end

flsRemoved	= setdiff(flsFromDat, fls);

if ~isempty(flsRemoved)
  stimStartup_createUpdateData(fl, fls)
end

end  % #needsUpdate
%__________________________________________________________
%% #createUpdateData
%
function stimStartup_createUpdateData(fl, fls)
  
flNm	= fullfile(stimFolder('Bin'), fl);

save(flNm, 'fls')

end  % #createUpdateData
%__________________________________________________________
%% #qqq
%
function stimStartup_qqq
  
end  % #qqq
%__________________________________________________________