% stimCopyPar('copy', srcFlNm, dstFlNm)
% stimCopyPar('copy', fl, srcPd, dstPd)
% stimCopyPar('copyAll', srcPd, dstPd)

function varargout = stimCopyPar(action, varargin)
  
  if ~nargin
    action	= 'qqq'; 
  end
  
  if nargout
    varargout	= cell(1, nargout);
    [varargout{:}]= feval(['stimCopyPar_' action], varargin{:});
  else
    feval(['stimCopyPar_' action], varargin{:});
  end
  
end  % <main>
%__________________________________________________________
%% #copy
%
function stimCopyPar_copy(varargin)
  
if length(varargin) == 2
  srcFlNm	= varargin{1};
  dstFlNm	= varargin{2};
elseif length(varargin) == 3
  fl		= varargin{1};
  srcPd		= varargin{2};
  if ~isdir(srcPd)
    error('The directory "%s" does not exist!', srcPd)
  end
  dstPd		= varargin{3};
  if ~isdir(dstPd)
    error('The directory "%s" does not exist!', dstPd)
  end
  srcFlNm	= fullfile(srcPd, fl);
  dstFlNm	= fullfile(dstPd, fl);
end

stimCopyPar_copyData(srcFlNm, dstFlNm)

end  % #copy
%__________________________________________________________
%% #copyAll
%
function stimCopyPar_copyAll(srcPd, dstPd)

if ~isdir(srcPd)
  error('The directory "%s" does not exist!', srcPd)
end
if ~isdir(dstPd)
  error('The directory "%s" does not exist!', dstPd)
end

srcFls		= stimGetFiles('get', srcPd, '.mat');
if isempty(srcFls)
  error('No .mat files found in "%s".', srcPd)
end
dstFls		= stimGetFiles('get', dstPd, '.mat');
if isempty(dstFls)
  error('No .mat files found in "%s".', dstPd)
end

for ff = 1:size(dstFls, 1)
  indices	= strcmp(srcFls(:,2), dstFls{ff,2});
  
  if ~any(indices), continue, end
  
  ind		= find(indices);
  ind		= ind(1);
  
  srcFlNm	= fullfile(srcFls{ind, 1:2});
  dstFlNm	= fullfile(dstFls{ff, 1:2});
  
  stimCopyPar_copyData(srcFlNm, dstFlNm)
  
end % for ff

end  % #copyAll
%__________________________________________________________
%% #copyData
%
function stimCopyPar_copyData(srcFlNm, dstFlNm)
  
if ~exist(srcFlNm, 'file')
  error('The source file "%s" does not exist!', srcFlNm)
end

if ~exist(dstFlNm, 'file')
  AdditionalData	= [];
  P			= [];
  save(dstFlNm, 'P', 'AdditionalData')  
end

data	= load(srcFlNm);
if isfield(data, 'P')
  P	= data.P;
  save(dstFlNm, 'P', '-append')  
end
  
if isfield(data, 'AdditionalData')
  AdditionalData	= data.AdditionalData;
  save(dstFlNm, 'AdditionalData', '-append')  
end

fprintf('Copying of "%s" to "%s" done\n', srcFlNm, dstFlNm);

end  % #copyData
%__________________________________________________________
%% #qqq
%
function stimCopyPar_qqq
  
end  % #qqq
%__________________________________________________________