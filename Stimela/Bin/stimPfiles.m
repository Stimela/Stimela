% pFiles = stimPfiles('getPfiles', modelNm);
% pFiles = stimPfiles('getPfiles', modelNm, options);
% options: '-assigninBase'
%
% stimPfiles('removeOnlyFiles', modelNm)
% stimPfiles('removeOnlyFiles', pFiles)

function varargout = stimPfiles(action, varargin)
  
  if ~nargin
    action	= 'qqq'; 
  end
  
  if nargout
    varargout	= cell(1, nargout);
    [varargout{:}]= feval(['stimPfiles_' action], varargin{:});
  else
    feval(['stimPfiles_' action], varargin{:});
  end
  
end  % <main>
%__________________________________________________________
%% #removeOnlyFiles
%
function stimPfiles_removeOnlyFiles(input)
  
if ~isstruct(input)
  pFiles = stimPfiles_getPfiles(input);
else
  pFiles = input;
end

onlyFile	= pFiles.onlyFile;
if isempty(onlyFile)
  return
end

[pd, fl ,ext]	= fileparts(onlyFile{1});

zipFlNm		= fullfile(pd, 'removedPfiles.zip');
ok		= stimZip('zip', zipFlNm, onlyFile);
% zip(zipFlNm, onlyFile);

% for ii = 1:numel(onlyFile)
%   delete(onlyFile{ii});
% end

end  % #removeOnlyFiles
%__________________________________________________________
%% #getPfiles
%
function pFiles = stimPfiles_getPfiles(modelNm, varargin)
  
optionsInd		= strncmp(varargin, '-', 1);
options			= varargin(optionsInd);

mdlFlNm	= which(modelNm);
if isempty(mdlFlNm)
  fprintf(2, 'No model whith the name "%s" found in the path.\n', modelNm)
  return
end

[mdlPd, mdlFl, ext]	= fileparts(mdlFlNm);
[dPd, dataPdNm]		= st_StimelaDataDir;

mdlDataPd		= fullfile(mdlPd, dataPdNm);

if ~isdir(mdlDataPd)
  fprintf(2, '"%s" does not exist!\n', mdlDataPd)
  return  
end

matFiles		= stimGetFiles('get', mdlDataPd, '.mat');
[ok, pFls]		= stimPfiles_getPfilesFromModel(mdlFlNm);
if ~ok
  return
end

[both, onlyFile, onlyP]	= stimPfiles_compareFlNms(matFiles, pFls);

pFiles			= struct;
pFiles.both		= both;
pFiles.onlyFile		= onlyFile;
pFiles.onlyP		= onlyP;

if strcmpi(options, '-assigninBase')
  assignin('base', 'pFiles', pFiles)
end

end  % #getPfiles
%__________________________________________________________
%% #getPfilesFromModel
%
function [ok, pFls] = stimPfiles_getPfilesFromModel(mdlFlNm)
  
ok		= false;

[fid, msg]	= fopen(mdlFlNm, 'r');
if fid < 3
  fprintf(2, 'Error while opening model file "%s".\nMessage: %s\n', mdlFlNm, msg)
  return
end

text		= fscanf(fid, '%s');
fclose(fid);

matStr		= '.mat';
matStrLength	= length(matStr);
matInd		= strfind(text, matStr); 
fSlashInd	= strfind(text, '/'); 
bSlashInd	= strfind(text, '\');
slashInd	= union(fSlashInd, bSlashInd);
apostInd	= strfind(text, ''''); 
quotaInd	= strfind(text, '"'); 

matIndCnt	= numel(matInd);
pFls		= cell(matIndCnt, 1);

noneFoundStr	= 'noneFound';

for ii = 1:matIndCnt
 matInd_ii	= matInd(ii);
 slashInd_ii	= slashInd(slashInd < matInd_ii);  
 apostInd_ii	= apostInd(apostInd < matInd_ii);
 quotaInd_ii	= quotaInd(quotaInd < matInd_ii);
 
 slashInd	= slashInd(slashInd > matInd_ii);  
 apostInd	= apostInd(apostInd > matInd_ii);
 quotaInd	= quotaInd(quotaInd > matInd_ii);
 
 endInd		= matInd_ii + matStrLength - 1;	
 
 if isempty(slashInd_ii), slashInd_ii = -3; end
 if isempty(apostInd_ii), apostInd_ii = -2; end
 if isempty(quotaInd_ii), quotaInd_ii = -1; end
 
 if quotaInd_ii(end) > slashInd_ii(end) && ...
     quotaInd_ii(end) > apostInd_ii(end)
 pFls{ii} = 'noneFound';  
   continue
 end
 
 if slashInd_ii(end) > apostInd_ii(end)
   startInd	= slashInd_ii(end) + 1; 
 else
   startInd	= apostInd_ii(end) + 1;
 end
 pFls{ii}	= text(startInd:endInd); 
end % for ii

ind		= strcmp(pFls, noneFoundStr);
pFls(ind)	= [];

pFls		= unique(pFls);

ok		= true;

end  % #getPfilesFromModel
%__________________________________________________________
%% #compareFlNms
%
function [both, onlyFile, onlyP] = stimPfiles_compareFlNms(matFiles, pFls)
  
matFls		= matFiles(:,2);

both		= intersect(matFls, pFls);
[dummy, ind]	= setdiff(matFls, pFls);
onlyP		= setdiff(pFls, matFls);

matFiles	= matFiles(ind, :); 
onlyFile	= cellfun(@fullfile, matFiles(:,1), matFiles(:,2), 'UniformOutput', false);

end  % #compareFlNms
%__________________________________________________________
%% #qqq
%
function stimPfiles_qqq
  
end  % #qqq
%__________________________________________________________