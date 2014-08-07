function varargout = stimMainData(action, varargin)
  
  if ~nargin
    action	= 'get'; 
  end
  
  if nargout
    varargout	= cell(1, nargout);
    [varargout{:}]= feval(['stimMainData_' action], varargin{:});
  else
    feval(['stimMainData_' action], varargin{:});
  end
  
end  % <main>
%__________________________________________________________
%% #get
%
function stimData = stimMainData_get
  
stimData	= struct;

stimData	= stimMainData_getMyProjects(stimData);
stimData	= stimMainData_getMyModels(stimData);
stimData	= stimMainData_getStandardModels(stimData);

end  % #get
%__________________________________________________________
%% #getMyProjects
%
function stimData = stimMainData_getMyProjects(stimData)

myProjects	= struct;

myProjectsPd	= stimFolder('My_projects');
mdlFls		= stimGetFiles('get', myProjectsPd, '.mdl');


  
stimData.myProjects	= myProjects;

end  % #getMyProjects
%__________________________________________________________
%% #getMyModels
%
function stimData = stimMainData_getMyModels(stimData)

myModels	= struct;

myModelsPd	= stimFolder('My_models');
mdlFls		= stimGetFiles('get', myModelsPd, '.mdl');

stimData.myModels	= myModels;

end  % #getMyModels
%__________________________________________________________
%% #getStandardModels
%
function stimData = stimMainData_getStandardModels(stimData)

standardModels	= struct;

standardPd	= stimFolder('Standard_models');
mdlFls		= stimGetFiles('get', standardPd, '.mdl');

standardModels	= stimMainData_getLevels(mdlFls, standardPd, standardModels);

stimData.standardModels	= standardModels;

end  % #getStandardModels
%__________________________________________________________
%% #getLevels
%
function mainStruct = stimMainData_getLevels(mdlFls, mainPd, mainStruct)
  
mainStruct.mainPd	= mainPd;

for ff = 1:size(mdlFls,1)
  pd	= mdlFls{ff, 1};
  level = stimMainData_getLevel(mainPd, pd);
  
  
  
end % for ff

end  % #getLevels
%__________________________________________________________
%% #getLevel
%
function level = stimMainData_getLevel(mainPd, pd)
  
level		= {};

pdStr		= strrep(pd, mainPd, '');
result		= textscan(pdStr, '%s', 'Delimiter', '\\');
parts		= result{1};

emptyInd	= cellfun(@isempty, parts);
parts(emptyInd)	= [];

end  % #getLevel
%__________________________________________________________
%% #qqq
%
function stimMainData_qqq
  
end  % #qqq
%__________________________________________________________