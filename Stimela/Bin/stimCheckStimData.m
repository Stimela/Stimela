% stimCheckStimData('checkSfncs')
% stimCheckStimData('check', checkPd)
%

function varargout = stimCheckStimData(action, varargin)
  
  if ~nargin
    action	= 'qqq'; 
  end
  
  if nargout
    varargout	= cell(1, nargout);
    [varargout{:}]= feval(['stimCheckStimData_' action], varargin{:});
  else
    feval(['stimCheckStimData_' action], varargin{:});
  end
  
end  % <main>
%__________________________________________________________
%% #checkSfncs
%
function stimCheckStimData_checkSfncs
  
type		= 'Standard_models';
updatePd	= stimFolder(type);

mdlFls		= stimGetFiles('get', updatePd, '.mdl');

stimCheckStimData_checkStimData(mdlFls)

end  % #checkSfncs
%__________________________________________________________
%% #check
%
function stimCheckStimData_check(checkPd)
  
mdlFls		= stimGetFiles('get', checkPd, '.mdl');

stimCheckStimData_checkStimData(mdlFls)

end  % #check
%__________________________________________________________
%% #checkStimData
%
function stimCheckStimData_checkStimData(mdlFls)
  
for ii = 1:size(mdlFls, 1)
  mdlFl		= mdlFls(ii,1:2);
  flNm		= fullfile(mdlFl{:}) ;
  hSys		= load_system(flNm);
  subSystems	= find_system(hSys, 'BlockType', 'SubSystem');

  for ss = 1:length(subSystems)
    subSys		= subSystems(ss);

    mdlPd		= mdlFl{1};
    [pFlNm, pFlOrg]	= stimUpdateBlocksDev('getPflNm', subSys, mdlPd);
    
    if ~isempty(pFlNm) || isempty(pFlOrg)
      continue
    end    
    
    dataPd		= fullfile(mdlPd, 'StimelaData');
    if ~exist(dataPd, 'dir')
      mkdir(dataPd)
    end    
    if strncmp(pFlOrg, '.', 1)
      pFl	= pFlOrg(3:end);
    else
      pFl	= pFlOrg;
    end
    pFl			= strrep(pFl, 'StimelaData', '');
    
    dataFlNm		= fullfile(dataPd, pFl);
    AdditionalData	= [];
    P			= [];
    save(dataFlNm, 'P', 'AdditionalData')
  
    stimUpdateBlocksDev('setPfile', subSys, pFl, './StimelaData/', mdlPd)

    sFunc		= find_system(subSys, 'SearchDepth', 1,...
      'LookUnderMasks', 'all', 'BlockType', 'S-Function');
    if length(sFunc) ~= 1
      continue
    end
    
    sFuncNm		= get_param(sFunc, 'Name');
    P			= eval([sFuncNm '_p(''' dataFlNm ''')']);
    save(dataFlNm, 'P', 'AdditionalData', '-append')        
    
  end % for ss
  fprintf('%s done\n', get_param(hSys, 'Name'))
  save_system(hSys, [], 'OverwriteIfChangedOnDisk', true)
  
  close_system(hSys)
  
end % for ii


end  % #checkStimData
%__________________________________________________________
%% #qqq
%
function stimCheckStimData_qqq
  
end  % #qqq
%__________________________________________________________