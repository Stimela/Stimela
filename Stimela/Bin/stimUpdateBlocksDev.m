function varargout = stimUpdateBlocksDev(action, varargin)
  
  if ~nargin
    action	= 'qqq'; 
  end
  
  if nargout
    varargout	= cell(1, nargout);
    [varargout{:}]= feval(['stimUpdateBlocksDev_' action], varargin{:});
  else
    feval(['stimUpdateBlocksDev_' action], varargin{:});
  end
  
end  % <main>
%__________________________________________________________
%% #update
%
function stimUpdateBlocksDev_update(type, isProject)

updatePd	= stimFolder(type);

mdlFls		= stimGetFiles('get', updatePd, '.mdl');

if isempty(mdlFls)
  return
end

mdlFls		= stimUpdateBlocksDev_backupBefore(mdlFls);

updateDate	= stimUpdateBlocksDev_getUpdateDate;

for ii = 1:size(mdlFls, 1)
  mdlFl			= mdlFls(ii,1:2);

  [update, metaInd]	= stimUpdateBlocksDev_needsUpdate(mdlFl, updateDate);
  
  if update
    
    stimUpdateBlocksDev_checkModel(mdlFl, isProject, metaInd);
  end
  
end % for ii

stimUpdate('update', stimFolder('Main'), updatePd)

end  % #update
%__________________________________________________________
%% #backupBefore
%
function mdlFls = stimUpdateBlocksDev_backupBefore(mdlFls)

nms			= lower(mdlFls(:,2));

beforeCheckInd		= strfind(nms, 'beforecheck');
beforeUpdateInd		= strfind(nms, 'beforeupdate');

isNotBeforeCheck	= cellfun(@isempty, beforeCheckInd);	
isNotBeforeUpdate	= cellfun(@isempty, beforeUpdateInd);

isBefore		= or(~isNotBeforeCheck,~isNotBeforeUpdate);
  
stimUpdateBlocksDev_createBackup(mdlFls(isBefore,:))

mdlFls			= mdlFls(~isBefore, :);

end  % #backupBefore
%__________________________________________________________
%% #createBackup
%
function stimUpdateBlocksDev_createBackup(mdlFls)

backupPdNm	= 'Backup';
for ii = 1:size(mdlFls, 1)
  backupPd	= fullfile(mdlFls{ii,1}, backupPdNm);
  if ~isdir(backupPd)
    mkdir(backupPd)
  end
  movefile(fullfile(mdlFls{ii,:}), fullfile(backupPd, [mdlFls{ii,2} '.backup']));
end % for ii

end  % #createBackup
%__________________________________________________________
%% #checkModel
%
function [updated, hSys] = stimUpdateBlocksDev_checkModel(mdlFl, isProject, metaInd)

updated		= false;
flNm		= fullfile(mdlFl{:});
hSys		= load_system(flNm);
subSystems	= find_system(hSys, 'BlockType', 'SubSystem');

sysNm		= get_param(hSys, 'Name');
fprintf('Starting update of "%s"...\n', sysNm)

replaceTable	= stimUpdateBlocksDev_getReplaceTable;
%gFcnFls		= stimGetFiles('get', stimFolder('Standard_Models'), {'_g', '.m'});
gFcnFls		= stimGetFiles('get', stimFolder('Standard_Models'), '.m', '-ends', '_g');
gFcns		= gFcnFls(:,3);
%for ff = 1:size(gFcnFls, 1)
%  [pd, fl, ext]		= fileparts(gFcnFls{ff,2});
%  if strcmp(fl(end-2:end), '_g')
%    gFcns{end+1}	= fl;
%  end
%end % for ff

modelFls	= stimGetFiles('get', stimFolder('Standard_Models'), {'_m', '.mdl'});

nrOfSubSys		= length(subSystems);
[perOfSubSys, n, perRow]= stimUpdate('perInfo',nrOfSubSys);
steps			= 1;

for ss = 1:nrOfSubSys
  
  if ss > perOfSubSys*steps
    fprintf('...%d%% ', 5*n*steps)
    if ~any(mod(steps, perRow))
      fprintf('\n')
    end
    steps	= steps + 1;
  end
  
  subSys	= subSystems(ss);
  subSysNm	= get_param(subSys, 'Name');
  graphStr	= 'Graph';
  if strncmpi(subSysNm, graphStr, length(graphStr))
    stimUpdateBlocksDev_checkGraph(subSys, replaceTable, gFcns)
    continue
  end  
  
  sFunc		= find_system(subSys, 'SearchDepth', 1,...
    'LookUnderMasks', 'all', 'BlockType', 'S-Function');
  if length(sFunc) ~= 1
      continue
  end
  
  sFuncNm	= get_param(sFunc, 'FunctionName');
  sFuncType	= get_param(sFunc, 'Name');
  modelFl	= modelFls(strncmp(modelFls(:,2), sFuncType, length(sFuncType)), 1:2);
  
  if strcmpi(sFuncType, 'block0') || isempty(modelFl)
    continue
  end
  
  if isProject
    stimUpdateBlocksDev_checkProjectBlock(hSys, subSys, sFuncType, mdlFl{1}, modelFl);
  else
  end
  

  
end % for ss

if metaInd == 0
  meta			= get_param(hSys, 'Metadata');
  meta.lastUpdated	= now;
  set_param(hSys, 'Metadata', meta)    
elseif metaInd > 0
  meta			= struct;
  if metaInd == 2
    meta.orgData	= get_param(hSys, 'Metadata');
  end
  meta.lastUpdated	= now;
  set_param(hSys, 'Metadata', meta)    
end

save_system(hSys)
close_system(hSys)

fprintf('...100%% done\n')
fprintf('... update of "%s" done\n', sysNm);

end  % #checkModel
%__________________________________________________________
%% #checkProjectBlock
%
function stimUpdateBlocksDev_checkProjectBlock(hSys, subSys, sFuncType, pd, modelFl)
  
sFuncType	= stimUpdateBlocksDev_blockVerRename(sFuncType);

orgPos		= get_param(subSys, 'Position');
orgOrient	= get_param(subSys, 'Orientation');
[pFlNm, pFlOrg]	= stimUpdateBlocksDev_getPflNm(subSys, pd);

hModel		= load_system(fullfile(modelFl{:}));
modelSubSys	= find_system(hModel, 'LookUnderMasks', 'all',...
  'BlockType', 'SubSystem', 'Name', sFuncType);

needPortCheck	= stimUpdateBlocksDev_needPortCheck(subSys, modelSubSys);
lineInfo	= {};
if needPortCheck
  lineInfo	= stimUpdateBlocksDev_getLinesInfo(hSys, subSys,...
    modelSubSys, needPortCheck);
end

subSysNm	= getfullname(subSys);
delete_block(subSys)
add_block(modelSubSys, subSysNm, 'Position', orgPos,...
  'Orientation', orgOrient);
close_system(hModel)

for ll = 1:size(lineInfo, 1)
  action	= lineInfo{ll, 1};
  switch action
    case 'delete'
      hLine	= lineInfo{ll, 2};
      delete_line(hLine)
    case 'add'
      hSrc		= lineInfo{ll, 3};
      hDest		= lineInfo{ll, 4};
      parentSys		= get_param(subSysNm, 'Parent');
      add_line(parentSys, hSrc, hDest, 'autorouting', 'on')
  end
end % for ll

[stimDataPd, stimDataPdNm]	= st_StimelaDataDir;
dataPd				= fullfile(pd, stimDataPdNm);
if isempty(strfind(pFlNm, stimDataPdNm)) && ~isdir(dataPd) 
  % make StimelaData pd  
  mkdir(dataPd)
end

% move pFile and *.sti files to pd
matStiFls	= stimGetFiles('get', pd, {'.mat', '.sti'});
moveInd		= strncmp(matStiFls(:,1), dataPd, length(dataPd));
moveInd		= find(moveInd	== 0);
for ii = 1:length(moveInd)
  ind		= moveInd(ii);
  srcFlNm	= fullfile(matStiFls{ind,1:2});
  dstFlNm	= fullfile(dataPd, matStiFls{ind,2});
  movefile(srcFlNm, dstFlNm, 'f')
end % for ii

% change pFile in maksIni & openFcn
stimUpdateBlocksDev_setPfile(subSysNm, pFlOrg, stimDataPd, pd)

end  % #checkProjectBlock
%__________________________________________________________
%% #checkGraph
%
function updated = stimUpdateBlocksDev_checkGraph(subSys, replaceTable, gFcns)

updated		= true;

openFcnStr	= get_param(subSys, 'OpenFcn');

if any(strcmp(gFcns, openFcnStr))
  updated		= false;
  return
end

tableInd	= [];

for ii = 1:size(replaceTable, 1)
  ind	= strfind(openFcnStr, replaceTable{ii,1}); 
  if any(ind)
    tableInd	= ii;
    break
  end
end % for ii

if isempty(tableInd)
  fprintf('Unknown openFcn: "%s"', openFcnStr)
  return
end

set_param(subSys, 'openFcn', replaceTable{tableInd, 2})
 
end  % #checkGraph
%__________________________________________________________
%% #getReplaceTable
%
function replaceTable = stimUpdateBlocksDev_getReplaceTable

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
%% #setPfile
%
function stimUpdateBlocksDev_setPfile(subSysNm, pFl, stimDataPd, pd)

[pFlNm, pFlOrg]	= stimUpdateBlocksDev_getPflNm(subSysNm, pd);
[pd, fl, ext]	= fileparts(pFl);
pFl		= [fl ext];
pFlNew		= fullfile(stimDataPd, pFl);

maskIniStr	= get_param(subSysNm, 'MaskInitialization');

maskIniStr	= strrep(maskIniStr, pFlOrg, pFlNew);
set_param(subSysNm, 'MaskInitialization', maskIniStr);

openFcnStr	= get_param(subSysNm, 'OpenFcn');
openFcnStr	= strrep(openFcnStr, pFlOrg, pFlNew);
set_param(subSysNm, 'OpenFcn', openFcnStr);

end  % #setPfile
%__________________________________________________________
%% #needPortCheck
%
function needPortCheck = stimUpdateBlocksDev_needPortCheck(subSys, modelSubSys)

portsC		= get_param(subSys, 'Ports');
if iscell(portsC)
  ports		= portsC{:};
else
  ports		= portsC;
end
orgNrOfPortsIn	= ports(1);
orgNrOfPortsOut	= ports(2);

portsC		= get_param(modelSubSys, 'Ports');
if iscell(portsC)
  ports		= portsC{:};
else
  ports		= portsC;
end
newNrOfPortsIn	= ports(1);
newNrOfPortsOut	= ports(2);
  
needPortCheck	= ~isequal(orgNrOfPortsIn, newNrOfPortsIn) +...
  2*(~isequal(orgNrOfPortsOut, newNrOfPortsOut));

end  % #needPortCheck
%__________________________________________________________
%% #getLinesInfo
%
function lineInfo = stimUpdateBlocksDev_getLinesInfo(hSys, subSys, modelSubSys, needPortCheck)

lineInfo	= {
%action		hLine		srcPortNm	dstPortNm  
};

subSysNm	= get_param(subSys, 'Name');

if needPortCheck == 1
  portNm	= 'Inport';
  lineDir	= 'Dst';
elseif needPortCheck == 2
  portNm	= 'Outport';
  lineDir	= 'Src'; 
elseif needPortCheck == 3
  inLineInfo	= stimUpdateBlocksDev_getLinesInfo(hSys, subSys,...
    modelSubSys, 1);
  outLineInfo	= stimUpdateBlocksDev_getLinesInfo(hSys, subSys,...
    modelSubSys, 2);  
  lineInfo	= [inLineInfo; outLineInfo]; %Combine in & out
  return
end

blockNm		= [lineDir, 'Block'];

hPortsOrg	= find_system(subSys, 'SearchDepth', 1,...
  'LookUnderMasks', 'all', 'BlockType', portNm);
hPortsNew	= find_system(modelSubSys, 'SearchDepth', 1,...
  'LookUnderMasks', 'all', 'BlockType', portNm);
hLines		= find_system(hSys, 'Findall', 'on',...
  'LookUnderMasks', 'all', 'Type', 'Line', blockNm, subSysNm);

orgPortNrs	= str2double(get_param(hPortsOrg, 'Port'));
newPortNrs	= str2double(get_param(hPortsNew, 'Port'));

portNrNm	= [lineDir, 'Port'];

for ll = 1:length(hLines)
  hLine		= hLines(ll);
  portNr	= str2double(get_param(hLine, portNrNm));
  type		= ismember(portNr, orgPortNrs) + 2*ismember(portNr, newPortNrs); 
  if type == 1 
    % delete line
    lineInfo	= stimUpdateBlocksDev_createLineInfo(lineInfo, 'delete', hLine);
  elseif type == 2 
    % add line (unlikly)
    lineInfo	= stimUpdateBlocksDev_createLineInfo(lineInfo, 'add', hLine);
  elseif type == 3
    % delete line add add again
    lineInfo	= stimUpdateBlocksDev_createLineInfo(lineInfo, 'delete', hLine);
    lineInfo	= stimUpdateBlocksDev_createLineInfo(lineInfo, 'add', hLine);
  end
  
end % for ll

end  % #getLinesInfo
%__________________________________________________________
%% #createLineInfo
%
function lineInfo = stimUpdateBlocksDev_createLineInfo(lineInfo, type, hLine)
  
% h = add_line('MIraflores_Panama_v2/Aeration', 'cascad1/1', 'Mixer_Aer1/2')

switch type
  case 'add' 
    lineInfo{end+1,1}	= 'add';
    lineInfo{end  ,2}	= [];
    
    srcBlockNm		= get_param(hLine, 'SrcBlock');
    srcPortNr		= get_param(hLine, 'SrcPort');
    lineInfo{end  ,3}	= [srcBlockNm '/' srcPortNr];
    
    dstBlockNm		= get_param(hLine, 'DstBlock');
    dstPortNr		= get_param(hLine, 'DstPort');
    lineInfo{end  ,4}	= [dstBlockNm '/' dstPortNr];
  case 'delete'
    lineInfo{end+1,1}	= 'delete';
    lineInfo{end  ,2}	= hLine;
    lineInfo{end  ,3}	= '';
    lineInfo{end  ,4}	= '';
end 

end  % #createLineInfo
%__________________________________________________________
%% #blockVerRename
%
function fcnNm = stimUpdateBlocksDev_blockVerRename(fcnNm)

renameTbl	= {
  %old name	%new name
  'bkwash'	'bacwa1'
  'ozdosg'	'ozodo1'
  };

ind	= strcmpi(renameTbl(:,1), fcnNm);
if any(ind)
  fcnNm		= renameTbl{ind(1),2};  
end

end  % #blockVerRename
%__________________________________________________________
%% #getPflNm
%
function [pFlNm, pFlOrg] = stimUpdateBlocksDev_getPflNm(subSys, pd)
  
%"filenaam='./StimelaData/FE7_ME_UV254.mat';\n\n[Pn,Fn,Fext]=Fi

maskIniStr	= get_param(subSys, 'MaskInitialization');
if isempty(maskIniStr)
  fprintf('%s\n', get_param(subSys, 'name'))
   pFlNm	= '';
   pFlOrg	= '';
   return
end
startStr	= 'filenaam=''';
startIndices	= strfind(maskIniStr, startStr);
startInd	= startIndices(1) + length(startStr);
endIndices	= strfind(maskIniStr, ''';');
endIndices	= endIndices(endIndices>startInd);
endInd		= endIndices(1) - 1;

pFlOrg		= strtrim(maskIniStr(startInd:endInd));
if strncmp(pFlOrg, '.', 1)
  pFl	= pFlOrg(3:end);
else
  pFl	= pFlOrg;
end
pFlNm		= fullfile(pd, pFl);

if ~exist(pFlNm, 'file')
  pFlNm		= '';
end

end  % #getPflNm
%__________________________________________________________
%% #needsUpdate
%
function [update, metaInd] = stimUpdateBlocksDev_needsUpdate(mdlFl, updateDate)
  
update	= true;
metaInd = 0;

flNm		= fullfile(mdlFl{:});
metadata	= Simulink.MDLInfo.getMetadata(flNm);

if isempty(metadata)
  metaInd = 1;
  return
elseif ~isstruct(metadata)
  metaInd = 2;
  return
elseif ~any(strcmpi(fieldnames(metadata), 'lastUpdated'))
  return
end

lastUpdated	= metadata.lastUpdated;
if lastUpdated > updateDate
  update	= false;
end

end  % #needsUpdate
%__________________________________________________________
%% #getUpdateDate
%
function updateDate = stimUpdateBlocksDev_getUpdateDate
  
updateDate	= now;

sFcnsDates	= [];
%sFcnFls		= stimGetFiles('get', stimFolder('Standard_Models'), {'_s', '.m'});
sFcnFls		= stimGetFiles('get', stimFolder('Standard_Models'), '.m', '-ends', '_s');
for ff = 1:size(sFcnFls, 1)
  %[pd, fl, ext]		= fileparts(sFcnFls{ff,2});
  %if strcmp(fl(end-1:end), '_s')
  flNm		= fullfile(sFcnFls{ff,1:2});
  flInfo		= dir(flNm);
  sFcnsDates(end+1)	= flInfo.datenum;
  %end
end % for ff

if ~isempty(sFcnsDates)
  updateDate	= max(sFcnsDates);
end

end  % #getUpdateDate
%__________________________________________________________
%% #getOpcTags
%
function [fromTags, gotoTags] = stimUpdateBlocksDev_getOpcTags(subSystem)

fromBlocks	= find_system(subSystem, 'LookUnderMasks', 'all', 'BlockType', 'From');
gotoBlocks	= find_system(subSystem, 'LookUnderMasks', 'all', 'BlockType', 'Goto');

fromTags	= stimUpdateBlocksDev_getTags(fromBlocks);
gotoTags	= stimUpdateBlocksDev_getTags(gotoBlocks);

end  % #getOpcTags
%__________________________________________________________
%% #getTags
%
function tags = stimUpdateBlocksDev_getTags(blocks)
  
tags	= {
  %name		%pos	% WStag
  };

for tt = 1:length(blocks)
  nm		= get_param(blocks(tt), 'Name');
  pos		= get_param(blocks(tt), 'Position');
  WStag		= get_param(blocks(tt), 'GotoTag');
  
  tags{end+1,1}	= nm;
  tags{end  ,2}	= pos;
  tags{end  ,3}	= WStag;  
end % for tt
  
end  % #getTags
%__________________________________________________________
%% #setOpcTags
%
function stimUpdateBlocksDev_setOpcTags(subSystem, fromTags, gotoTags)
  
fromBlocks	= find_system(subSystem, 'LookUnderMasks', 'all', 'BlockType', 'From');
gotoBlocks	= find_system(subSystem, 'LookUnderMasks', 'all', 'BlockType', 'Goto');

stimUpdateBlocksDev_setTags(fromBlocks, fromTags)
stimUpdateBlocksDev_setTags(gotoBlocks, gotoTags)

end  % #setOpcTags
%__________________________________________________________
%% #setTags
%
function stimUpdateBlocksDev_setTags(blocks, tags)
  
for tt = 1:length(blocks)
  nm		= get_param(blocks(tt), 'Name');
  if strcmpi(nm, 'goto')
    pos		= get_param(blocks(tt), 'Position');
    ind		= isequal(tags(:,2), pos);
  else
    ind		= strcmp(tags(:,1), nm);
  end
  tag		= tags(ind, 3);
  tag		= tag{1};
  set_param(blocks(tt), 'GotoTag', tag);  
end % for tt

end  % #setTags
%__________________________________________________________
%% #qqq
%
function stimUpdateBlocksDev_qqq
  
end  % #qqq
%__________________________________________________________