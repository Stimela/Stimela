% stimClean('beforeToBackup', pd)

function varargout = stimClean(action, varargin)
  
  if ~nargin
    action	= 'qqq'; 
  end
  
  if nargout
    varargout	= cell(1, nargout);
    [varargout{:}]= feval(['stimClean_' action], varargin{:});
  else
    feval(['stimClean_' action], varargin{:});
  end
  
end  % <main>
%__________________________________________________________
%% #beforeToBackup
%
function stimClean_beforeToBackup(pd)
  
mdlFls		= stimGetFiles('get', pd, '.mdl');
if isempty(mdlFls)
  return
end

stimUpdateBlocksDev('backupBefore', mdlFls);

end  % #beforeToBackup
%__________________________________________________________
%% #qqq
%
function stimClean_qqq
  
end  % #qqq
%__________________________________________________________