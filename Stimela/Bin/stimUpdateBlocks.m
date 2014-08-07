function varargout = stimUpdateBlocks(action, varargin)
  
  if ~nargin
    action	= 'test';
  end
  
  if nargout
    varargout	= cell(1, nargout);
    [varargout{:}]= feval(['stimUpdateBlocks_' action], varargin{:});
  else
    feval(['stimUpdateBlocks_' action], varargin{:});
  end
  
end  % <main>


%__________________________________________________________
%% #update
%
function stimUpdateBlocks_update(updateDir, isProject)

stimUpdateBlocks_scanDir(updateDir, isProject)

cd(stimelaDir)
stimUpdate('update', stimFolder('Main'), stimFolder(updateDir))

end  % #update
%__________________________________________________________
%% #scanDir
%
function stimUpdateBlocks_scanDir(updateDir, isProject)

  mdlFiles = dir([updateDir filesep '*.mdl']);
for i = 1:length(mdlFiles)
  mdlFlNm = mdlFiles(i).name(1:end-4);
  if ~any(strfind(mdlFlNm, 'BeforeCheck'))
    stimUpdateBlocks_checkModel(updateDir,mdlFlNm, isProject);
  end
end

dirContent = dir(updateDir);
for i = 1:length(dirContent)
  name = dirContent(i).name;
  if dirContent(i).isdir && ~any(strfind(name, '.'))
    stimUpdateBlocks_scanDir([updateDir filesep name], isProject);
  end
end


end  % #scanDir
%__________________________________________________________
%% #checkModel
%
function stimUpdateBlocks_checkModel(modelDir, modelNm, isProject)
  
sysNm	= load_system([modelDir filesep modelNm]);

updated = false;
    
subSystems = find_system(modelNm,'BlockType','SubSystem');

for ss = 1:length(subSystems)
  
  subSystem	= subSystems{ss};
  
  maskIni	= get_param(subSystem,'MaskInitialization');
  indices	= strfind(maskIni,'_p(filenaam)');
  
  if any(indices)
    ind		= indices(1);
    subSystemNm = maskIni(ind-6 : ind-1);
    try
      fcnNm = get_param([subSystem '/' subSystemNm],'FunctionName');
      if length(fcnNm) == 10
	isCfile = true;
      else
	isCfile = false;
      end
    catch
      isCfile	= false;
    end
    
    if length(subSystemNm) == 6
      if ~strcmpi(subSystemNm,'block0')
	updated = updated + stimUpdateBlocks_checkBlock(modelDir,modelNm,subSystem,subSystemNm,isCfile, isProject);
      end
    end
  end
  
  openFcn = get_param(subSystems{ss},'OpenFcn');
  
  if length(openFcn)>7
    if strncmpi(openFcn,'graph', 5)
      updated = updated + stimUpdateBlocks_checkGraph(subSystem,openFcn,true, isProject);
    elseif strcmpi(openFcn(7:8),'_g')
      updated = updated + stimUpdateBlocks_checkGraph(subSystem,openFcn,false, isProject);
    end
  end
  
end % for ss

if isProject
  stimUpdateBlocks_stimelaWeb(modelDir)
end

if updated
  % bckup maken
  backupFlNm = sprintf('%s_BeforeCheck_%04d%02d%02d_%02d%02d%02d',modelNm,round(clock));
  copyfile([modelDir filesep modelNm '.mdl'],[modelDir '\' backupFlNm '.mdl']);
  
  save_system(modelNm)
end
close_system(modelNm)

end  % #checkModel
%__________________________________________________________
%% #checkBlock
%
function updated = stimUpdateBlocks_checkBlock(modelDir,modelNm,subSystem,subSystemNm,isCfile, isProject)

dirOrg = cd;
cd(modelDir);

disp(['gevonden: ' subSystem ', ' subSystemNm]);

% replace backwash en dose blocks of 62->631
if strcmpi(subSystemNm,'bkwash')
  subSystemNm = 'bacwa1';
end
if strcmpi(modelNm,'ozdosg')
  subSystemNm = 'ozodo1';
end

if isProject
  updated = stimUpdateBlocks_checkBlockProject(subSystem,subSystemNm);
else
  updated = stimUpdateBlocks_checkBlockModel(modelNm,subSystem,subSystemNm,isCfile);
end

cd(dirOrg);

end  % #checkBlock
%__________________________________________________________
%% #checkBlockModel
%
function updated = stimUpdateBlocks_checkBlockModel(modelNm,subSystem,subSystemNm,isCfile)

updated = 0;

oldMaskPar = stimUpdateBlocks_getOldMaskParameters(subSystem);

[modelType,portsIn,portsOut] = stimUpdateBlocks_getModelType(subSystemNm);

if isempty(modelType), return, end

copyNm = stimUpdateBlocks_copyBlock0(subSystemNm);

load_system(copyNm);
delete_block(subSystem)
add_block([copyNm(1:end-4) '/' modelType],subSystem,'position',oldMaskPar.pos);

set_param(subSystem,'Description',oldMaskPar.desc);

newDisp		= get_param(subSystem,'MaskDisplay');
searchStr	= 'disp('''')';
oldInd		= strfind(oldMaskPar.disp,searchStr);
newInd		= strfind(newDisp        ,searchStr);
newInd		= newInd(1);
if any(oldInd)
  oldInd = oldInd(1);
  set_param(subSystem,'MaskDisplay',[oldMaskPar.disp(1:oldInd-1) newDisp(newInd:end)]);
else
  if ~any(strfind(oldMaskPar.disp,'disp('''))
    set_param(subSystem,'MaskDisplay',[oldMaskPar.disp char(10) newDisp(newInd:end)]);
  end
end

set_pfil(subSystem,oldMaskPar.file);

if isCfile
  set_param([subSystem '/' subSystemNm],'FunctionName',[subSystemNm '_s_c'])
end

if oldMaskPar.ports(1) == 1 && portsIn == 2
  add_line(modelNm,[oldMaskPar.pos(1) - 5 (oldMaskPar.pos(2) + oldMaskPar.pos(4))/2;...
    oldMaskPar.pos(1) - 5 round((oldMaskPar.pos(2) +...
    oldMaskPar.pos(4))/2 - (oldMaskPar.pos(4) - oldMaskPar.pos(2))*1/5)]);
end
if oldMaskPar.ports(2) == 1 && portsOut == 2
  add_line(modelNm,[oldMaskPar.pos(3) + 5 (oldMaskPar.pos(2) + oldMaskPar.pos(4))/2;...
    oldMaskPar.pos(3) + 5 round((oldMaskPar.pos(2) +...
    oldMaskPar.pos(4))/2 - (oldMaskPar.pos(4) - oldMaskPar.pos(2))*1/5)]);
end

close_system(copyNm(1:end-4));
delete(copyNm);

updated = 1;

end  % #checkBlockModel
%__________________________________________________________
%% #checkBlockProject
%
function updated = stimUpdateBlocks_checkBlockProject(subSystem,subSystemNm)

updated = 0;

param.pos	= get_param(subSystem,'position');
param.file	= get_pfil(subSystem);
param.orient	= get_param(subSystem,'Orientation');

modelFlNm = [subSystemNm '_m.mdl'];
if ~exist(modelFlNm, 'file')
  disp([modelnm '_m.mdl niet gevonden'])
  return
end

load_system(modelFlNm);
delete_block(subSystem)
add_block([modelFlNm(1:end-4) '/' subSystemNm],subSystem,'position',param.pos,'orientation',param.orient);

[dir,fl,ext] = Fileprop(param.file);
if ~strcmp(dir,st_StimelaDataDir)
  
  %check of dir al bestaat
  if ~isdir(st_StimelaDataDir)
    mkdir(st_StimelaDataDir)
  end
  
  try
    movefile (param.file,[st_StimelaDataDir fl '.mat']);
  catch
  end
  % en de data file
  try
    movefile ([dir fl '_in.sti'],[st_StimelaDataDir fl '_in.sti']);
  catch
  end
  try
    movefile ([dir fl '_out.sti'],[st_StimelaDataDir fl '_out.sti']);
  catch
  end
  try
    movefile ([dir fl '_EM.sti'],[st_StimelaDataDir fl '_EM.sti']);
  catch
  end
  try
    movefile ([dir fl '_ES.sti'],[st_StimelaDataDir fl '_ES.sti']);
  catch
  end
  
  param.file=[st_StimelaDataDir fl '.mat'];
end
set_pfil(subSystem,param.file);

% tijdelijke verwijderen
close_system(modelFlNm(1:end-4));

updated = 1;

end  % #checkBlockProject
%__________________________________________________________
%% #checkGraph
%
function updated = stimUpdateBlocks_checkGraph(subSystem,openFcn,isOld, isProject)

updated = true;

if isOld
  replaceTable = stimUpdateBlocks_getReplaceTable;
  openFcnLower = lower(openFcn);
  for ii = 1:size(replaceTable, 1)
    oldModelNm_ii		= replaceTable(ii).oldModelNm;
    newModelNm_ii		= replaceTable(ii).newModelNm;
    ind				= strfind(openFcnLower, oldModelNm_ii);
    if any(ind)
      endIndNew			= ind + length(newModelNm_ii) - 1;
      endIndOld			= ind + length(oldModelNm_ii) - 1;
      openFcn(ind:endIndNew)	= newModelNm_ii;
      
      openFcn(endIndNew+1:endIndOld)= [];
    end
  end % for i
end

modelNm	= openFcn(1:6);

if ~isProject
  modelDesc	= get_param(subSystem,'Description');
end
modelPos	= get_param(subSystem,'Position');

if isProject
  modelFlNm	= [modelNm '_m.mdl'];
else
  modelFlNm	= stimUpdateBlocks_copyBlock0(modelNm);
end

load_system(modelFlNm);

delete_block(subSystem)

add_block([modelFlNm(1:end-4) '/Graphical output'],subSystem,'position',modelPos);
if ~isProject
  set_param(subSystem,'Description',modelDesc);
  set_param(subSystem,'OpenFcn',openFcn);
end

close_system(modelFlNm(1:end-4));
if ~isProject
  delete(modelFlNm);
end

end  % #checkGraph
%__________________________________________________________
%% #stimelaWeb
%
function stimUpdateBlocks_stimelaWeb(modelDir)

stimWebFlNm = fullfile(modelDir, 'StimelaWebInfo.m');
if exist(stimWebFlNm, 'file')
  fid = fopen(stimWebFlNm);
  if fid > 2
    while ~feof(fid)
      ln = fgetl(fid);
      
      txtPos = strfind(lower(ln),'.txt');
      if ~isempty(txtPos)
	apPos	= strfind(ln,'''');
	flNm	= ln(max(apPos(apPos<txtPos))+1:txtPos);
	flNm	= fullfile(modelDir, flNm, 'txt');
	if exist(flNm, 'file')
	  newFlNm = fullfile(modelDir, st_StimelaDataDir, flNm, 'txt');
	  movefile(flNm,newFlNm,'f');
	end
      end
    end
    fclose(fid);
  end
end

end  % #stimelaWeb
%__________________________________________________________
%% #getReplaceTable
%
function replaceTable = stimUpdateBlocks_getReplaceTable

replaceTable = {
  % old name			new name
  'graphkoolfilter'		'koofil_g'
  'graphplaatbeluchter'		'plaatb_g'
  'graphbot'			'torbk2_g'
  'graphBOTsc'			'torbsc_g'
  'graphvacuumcontinu'		'vacslp_g'
  'graphvacuumdiscontinu'	'vacuum_g'
  'graphcascade'		'cascad_g'
  'graphtimedistribution'	'timeds_g'
  'graphozonereactor'		'ozonox_g'
  'graphbiologicalfilter'	'biofil_g'
  'Graphfysdubfilter'		'dubfil_g'
  'Graphfysenkfilter'		'irofil_g'
  'graphbiologicalfilter'	'nitfil_g'
  'Graphfysenkfilter'		'enkfil_g'
  'graphflocculation'		'vlokvo_g'
  };

end % #getReplaceTable
%__________________________________________________________
%% #copyBlock0

function copyNm = stimUpdateBlocks_copyBlock0(modelNm)

srcNm	= 'block0';
copyNm	= 'tmpmodelvoorconversie.mdl';

block0	= which([srcNm '_m.mdl']);
copyfile(block0,copyNm);

fid	= fopen(copyNm,'r');
text	= fscanf(fid, '%c');
fclose(fid);

text	= strrep(text,'block0','Block0'); %TEMP
text	= strrep(text,'Block0',modelNm);

fid	= fopen(copyNm,'w');
fwrite(fid,text,'char');
fclose(fid);

end % #copyBlock0
%__________________________________________________________________________
%% #getOldMaskParameters

function oldMaskPar = stimUpdateBlocks_getOldMaskParameters(subSystem)

openFcn		= get_param(subSystem,'OpenFcn');
openFcnInit	= strfind(openFcn,'filenaam=''');
openFcnLength	= size(openFcn,2);
openFcnEnd	= openFcnInit-1 + strfind(openFcn(openFcnInit:openFcnLength),''';');

oldMaskPar	= struct;

oldMaskPar.file = openFcn(openFcnInit+10:openFcnEnd-1);
oldMaskPar.disp = get_param(subSystem,'MaskDisplay');
oldMaskPar.desc = get_param(subSystem,'Description');
oldMaskPar.pos	= get_param(subSystem,'Position');
oldMaskPar.ports= get_param(subSystem,'Ports');

end % #getOldMaskParameters
%__________________________________________________________________________
%% #getModelType

function [modelType,portsIn,portsOut] = stimUpdateBlocks_getModelType(subSystemNm)

modelType	= '';
portsIn		= 0;
portsOut	= 0;

text = stimUpdateBlocks_getText(subSystemNm, '_i');
if isempty(text), return, end

[waterIn, waterOut, setPoints, measurements] = stimUpdateBlocks_getPorts(text);

modelType = subSystemNm;
switch waterIn*1000 + waterOut*100 + setPoints*10 + measurements
  case 1110
    modelType = [subSystemNm '_m_u'];
  case 1111
    modelType = [subSystemNm '_m_uy'];
  case 1101
    modelType = [subSystemNm '_m_y'];
    
  case 1010
    modelType = [subSystemNm '_e_u'];
  case 1000
    modelType = [subSystemNm '_e'];
  case 1011
    modelType = [subSystemNm '_e_uy'];
  case 1001
    modelType = [subSystemNm '_e_y'];
    
  case 0101
    modelType = [subSystemNm '_b_y'];
  case 0100
    modelType = [subSystemNm '_b'];
    
  case 0001
    modelType = [subSystemNm '_b'];    
end

portsIn  = waterIn  + setPoints;
portsOut = waterOut + measurements;

end % #getModelType
%__________________________________________________________________________
%% #getText

function text = stimUpdateBlocks_getText(subSystemNm, ext)

text = '';

flNm	= which([subSystemNm ext]);
fid	= fopen(flNm,'r');

if fid < 3
  disp(['-----failed : ' subSystemNm ext ' not found !']);
  return
end

text	= fscanf(fid, '%c');
fclose(fid);

end % #getText
%__________________________________________________________________________
%% #getPorts

function [waterIn, waterOut, setPoints, measurements] = stimUpdateBlocks_getPorts(text)

waterIn		= stimUpdateBlocks_portExists(text,'B.WaterIn');
waterOut	= stimUpdateBlocks_portExists(text,'B.WaterOut');
setPoints	= stimUpdateBlocks_portExists(text,'B.Setpoints');
measurements	= stimUpdateBlocks_portExists(text,'B.Measurements');

end % #getPorts
%__________________________________________________________________________
%% #portExists

function portExists = stimUpdateBlocks_portExists(text,part)

portExists	= true;
startInd	= strfind(text, part);
if any(startInd)
  startInd	= startInd(1);
  endPartInd	= startInd + length(part);
  endInd	= strfind(text(endPartInd + 1:end),';');
  endInd	= endInd(1) - 1;
  for ii = 1:endInd
    if any(strfind('123456789', text(endPartInd + ii)))
      portExists = true;
      return
    end
  end % for ii
  
  if any(strfind(text(endPartInd:endPartInd+endInd),'0'))
    portExists = false;
  end
end

end % #portExists
%__________________________________________________________________________
%% #test
%
function stimUpdateBlocks_test
  
end  % #test


%__________________________________________________________
%% #qqq
%
function stimUpdateBlocks_qqq
  
end  % #qqq
%__________________________________________________________