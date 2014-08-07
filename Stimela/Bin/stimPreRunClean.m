function varargout = stimPreRunClean(action, varargin)
  
  if ~nargin
    action	= 'qqq'; 
  end
  
  if nargout
    varargout	= cell(1, nargout);
    [varargout{:}]= feval(['stimPreRunClean_' action], varargin{:});
  else
    feval(['stimPreRunClean_' action], varargin{:});
  end
  
end  % <main>
%__________________________________________________________
%% #run
%
function stimPreRunClean_run
  
[dummy, dataPd]		= st_StimelaDataDir;
flPd			= fullfile(cd, dataPd); 

pdAndFls	= stimGetFiles('get', flPd, '.mat');
fls		= pdAndFls(:,2);
fls		= strrep(fls, '.mat', '');

whosData	= evalin('base', 'whos');
varNms		= {whosData.name};

varNmsToRemove	= intersect(fls,varNms);

if isempty(varNmsToRemove)
  return
end

clearStr	= stimPreRunClean_createClearStr(varNmsToRemove);
evalin('base', clearStr)

end  % #run
%__________________________________________________________
%% #createClearStr
%
function clearStr = stimPreRunClean_createClearStr(varNmsToRemove)
  
strStart	= 'clear(';
strEnd		= ')';

clearStr	= strStart;		
for ii = 1:numel(varNmsToRemove)
  varNm		= varNmsToRemove{ii};
  varNmStr	= ['''' varNm ''', '];
  clearStr	= [clearStr varNmStr];
end % for ii
clearStr	= [clearStr(1:end-2) strEnd];

end  % #createClearStr
%__________________________________________________________
%% #qqq
%
function stimPreRunClean_qqq
  
end  % #qqq
%__________________________________________________________