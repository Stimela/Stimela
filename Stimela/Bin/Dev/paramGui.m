function varargout = paramGui(action, varargin)
  
  if ~nargin
    action	= 'qqq'; 
  end
  
  if nargout
    varargout	= cell(1, nargout);
    [varargout{:}]= feval(['paramGui_' action], varargin{:});
  else
    feval(['paramGui_' action], varargin{:});
  end
  
end  % <main>
%__________________________________________________________
%% #qqq
%
function paramGui_qqq
  
end  % #qqq
%__________________________________________________________